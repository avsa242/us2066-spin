{
    --------------------------------------------
    Filename: display.oled.us2066.spin
    Author: Jesse Burt
    Description: Driver for US2066-based OLED alphanumeric displays
    Copyright (c) 2022
    Created Dec 30, 2017
    Updated Dec 3, 2022
    See end of file for terms of use.
    --------------------------------------------
}
#include "terminal.common.spinh"

CON
' I2C Defaults
    SLAVE_WR        = core#SLAVE_ADDR
    SLAVE_RD        = SLAVE_WR|1
    R               = 1

    DEF_SCL         = 28
    DEF_SDA         = 29
    DEF_HZ          = 100_000
    I2C_MAX_FREQ    = core#I2C_MAX_FREQ

' Build some basic headers for I2C transactions
    CMD_HDR         = ((core#CTRLBYTE_CMD << 8) | SLAVE_WR)
    DAT_HDR         = ((core#CTRLBYTE_DATA << 8) | SLAVE_WR)

    CMDSET_FUND     = 0
    CMDSET_EXTD     = 1
    CMDSET_EXTD_IS  = 2
    CMDSET_OLED     = 3

    LEFT            = core#DISP_LEFT
    RIGHT           = core#DISP_RIGHT

' Display visibility modes
    OFF             = 0
    NORM            = 1
    ON              = 1
    INVERT          = 2

' SEG Voltage reference/enable or disable internal regulator
    INT             = 0
    EXT             = 1

' Flag top-level objects can use to tell this is the PASM version
    PASM            = TRUE

' Character attributes
    CHAR_PROC       = (1 << 1)

VAR

    long _char_attrs
    byte _RESET
    byte _addr_bits

    { shadow registers }
    byte _mirror_h, _mirror_v
    byte _char_predef, _char_set
    byte _fnt_wid, _curs_invert, _disp_lines_nw
    byte _freq, _clkdiv
    byte _disp_en, _curs_en, _blink_en
    byte _disp_lines_n, _dblht_en
    byte _seg_remap, _seg_pincfg
    byte _ext_vsl, _gpio_state
    byte _contrast
    byte _phs1_per, _phs2_per
    byte _vcomh_des_lvl
    byte _dblht_mode
    byte _cgram_blink, _disp_invert
    byte _fadeblink
    byte _disp_width, _disp_height, _disp_xmax, _disp_ymax

OBJ

    i2c     : "com.i2c"                         ' I2C engine
    core    : "core.con.us2066"                 ' HW-specific constants
    time    : "time"                            ' time-delay routines

PUB null{}
' This is not a top-level object

PUB start(RST_PIN): status
' Use "standard" Propeller I2C pins, and 100kHz, 4x20
'   Specify reset pin
    return startx(DEF_SCL, DEF_SDA, RST_PIN, core#I2C_MAX_FREQ, 0, 4)

PUB startx(SCL_PIN, SDA_PIN, RST_PIN, I2C_HZ, ADDR_BIT, DISP_LINES): status
' Start with custom settings
'  SCL      - I2C Serial Clock pin
'  SDA      - I2C Serial Data pin
'  RST_PIN  - OLED display's assigned reset pin
'  I2C_HZ   - I2C Bus Frequency (max 400kHz)
'  ADDR_BIT - Flag to indicate optional alternative slave address
    if (lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) and lookdown(DISP_LINES: 2, 4))
        if (status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ))
            time.usleep(core#T_POR)
            _RESET := RST_PIN
            if (ADDR_BIT)
                _addr_bits := (1 << 1)
            else
                _addr_bits := 0
            if (DISP_LINES == 2)
                preset_2x16{}
            elseif (DISP_LINES == 4)
                preset_4x20{}
            reset{}
            defaults{}
            if (dev_id{} == core#DEVID_RESP)
                return
    ' if this point is reached, something above failed
    ' Double check I/O pin assignments, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE

PUB stop{}
' Turn the display visibility off and stop the I2C cog
    visibility(OFF)
    i2c.deinit{}

PUB defaults{}
' Factory default settings - initialize shadow registers
    _fnt_wid := core#FNTWIDTH_5
    _curs_invert := core#CURS_NORM

    _disp_lines_n := core#DISP_LINES_2_4
    _dblht_en := 0

    _disp_en := 0
    _curs_en := 0
    _blink_en := 0

    _char_predef := core#CG_ROM_RAM_240_8
    _char_set := core#CHAR_ROM_A

    _freq := %0111
    _clkdiv := %0000

    _mirror_h := core#SEG0_99
    _mirror_v := core#COM0_31

    _seg_remap := core#SEG_LR_REMAP_DIS
    _seg_pincfg := core#ALT_SEGPINCFG

    _ext_vsl := core#VSL_INT
    _gpio_state := core#GPIO_OUT_LOW

    _contrast := 127

    _phs1_per := 8
    _phs2_per := 7

    _vcomh_des_lvl := 2

    _cgram_blink := core#CGRAM_BLINK_DIS
    _disp_invert := core#NORM_DISP

    _fadeblink := 0

PUB preset_2x16{}
' Set up for 2x16 displays
    _disp_width := 16
    _disp_height := 2
    _disp_xmax := (_disp_width-1)
    _disp_ymax := (_disp_height-1)
    _disp_lines_nw := core#NW_1_2_LINE

PUB preset_4x20{}
' Set up for 4x20 displays
    _disp_width := 20
    _disp_height := 4
    _disp_xmax := (_disp_width-1)
    _disp_ymax := (_disp_height-1)
    _disp_lines_nw := core#NW_3_4_LINE


PUB char_attrs(attr)
' Set character attributes
'   Valid values:
'       CHAR_PROC (2) - process control codes (0 to print literal char)
    _char_attrs := attr

PUB char_gen(count)
' Select number of pre-defined vs free user-defined character cells
'   Valid values:
'       240 (leaves 8 available user-defined characters)
'       248 (leaves 8 available user-defined characters)
'       250 (leaves 6 available user-defined characters)
'       256 (leaves 0 available user-defined characters)
    case count
        240:
            _char_predef := core#CG_ROM_RAM_240_8
        248:
            _char_predef := core#CG_ROM_RAM_248_8
        250:
            _char_predef := core#CG_ROM_RAM_250_6
        256:
            _char_predef := core#CG_ROM_RAM_256_0
        other:
            return

    writereg(2, CMDSET_EXTD, core#FUNCT_SEL_B, _char_predef | _char_set)

PUB char_rom(char_set)
' Select ROM font / character set
'   Valid values:
'       0: ROM A
'       1: ROM B
'       2: ROM C
'   Any other value returns the current setting
    case char_set
        0:
            _char_set := core#CHAR_ROM_A
        1:
            _char_set := core#CHAR_ROM_B
        2:
            _char_set := core#CHAR_ROM_C
        other:
            return _char_set

    writereg(2, CMDSET_EXTD, core#FUNCT_SEL_B,{
}   _char_predef | _char_set)

PUB clear{}
' Clear display
    writereg(0, CMDSET_FUND, core#CLEAR_DISP, 0)

PUB clear_line(line)
' Clear specified line
'   Valid values: 0..3 (dependent on display's total lines)
'   Any other value is ignored
    if ((line => 0) and (line =< _disp_ymax))
        pos_xy(0, line)
        repeat _disp_width
            char(" ")

PUB clk_freq(freq)
' Set display internal oscillator frequency, in kHz
'   Valid values:
'       454..556 (clamped to range; see table below; POR: 501)
    _freq := ((0 #> lookdown(freq: 454, 460, 467, 474, 481, 488, 494, 501, 508, 515, 522, 528, {
}                                  535, 542, 549, 556) <# 15) << core#OSC_FREQ)

    writereg(1, CMDSET_OLED, core#DISP_CLKDIV_OSC, _freq | _clkdiv)

PUB clk_div(divider)
' Set clock frequency divider used by the display controller
'   Valid values: 1..16 (clamped to range; POR: 1)
    divider := ((1 #> divider <# 16) - 1)
    _clkdiv := divider

    writereg(1, CMDSET_OLED, core#DISP_CLKDIV_OSC, _freq | _clkdiv)

PUB com_logic_high_lvl(level)
' Set COMmon pins high logic level relative to Vcc ((level / 100) * Vcc)
'   Valid values:
'       0_65, 0_71, 0_77, 0_83, 1_00 (clamped to range; POR: 0_77)
    level := ((0 #> lookdownz(level: 0_65, 0_71, 0_77, 0_83, 1_00) <# 4) << core#VCOMH)
    writereg(1, CMDSET_OLED, core#SET_VCOMH_DESEL, level)

PUB contrast(level)
' Set display contrast level
'   Valid values: 0..127 (clamped to range; POR: 127)
    writereg(1, CMDSET_OLED, core#SET_CONTRAST, (0 #> level <# 127))

PUB cursor_blink_ena(state)
' Enable cursor blinking
'   Valid values:
'      *FALSE (0): Steady cursor
'       TRUE (non-zero): Blinking cursor
    _blink_en := state := ((state <> 0) & 1)
    writereg(0, CMDSET_FUND, core#DISP_ONOFF | (_disp_en | _curs_en | _blink_en), 0)

PUB cursor_invert_ena(state)
' Invert cursor
'   Valid values:
'      *FALSE (0): Normal cursor
'       TRUE (non-zero): Inverted cursor
    _curs_invert := state := (((state <> 0) & 1) << 1)
    writereg(1, CMDSET_EXTD, core#EXTD_FUNCSET | (_fnt_wid | _curs_invert | _disp_lines_nw), 0)

PUB cursor_mode(type)
' Select cursor display mode
'   Valid values:
'       0: No cursor
'       1: Block, blinking
'       2: Underscore, no blinking
'       3: Underscore, block blinking
    case type
        0:
            _curs_invert := _blink_en := _curs_en := FALSE
        1:
            _curs_en := core#CURS_OFF
            _curs_invert := core#CURS_INVERT
            _blink_en := core#BLINK_ON
        2:
            _curs_en := core#CURS_ON
            _curs_invert := core#CURS_NORM
            _blink_en := core#BLINK_OFF
        3:
            _curs_en := core#CURS_ON
            _curs_invert := core#CURS_NORM
            _blink_en := core#BLINK_ON
        other:
            return

    writereg(0, CMDSET_FUND, core#DISP_ONOFF | (_disp_en |_curs_en | _blink_en), 0)
    cursor_invert_ena(_curs_invert >> 1)

PUB dev_id{}: id
' Read device ID
'   Returns: $21 if successful
    writereg(0, CMDSET_FUND, $00, 0)

    i2c.start{}
    i2c.write(SLAVE_RD | _addr_bits)
    i2c.read(i2c#ACK)                           ' dummy read
    id := i2c.read(i2c#NAK)                     ' Second read gets the Part ID
    i2c.stop{}

PUB disp_blink_tm(delay)
' Set time interval for display blink/gradual fade in/out, in number of frames
'   Valid values:
'       0..128 (rounded to nearest multiple of 8; clamped to range; POR: 0)
'   NOTE: 0 effectively disables the setting
    if (delay)
        _fadeblink := (core#BLINK_ENA | (((8 #> delay <# 128) / 8) - 1))
    else
        _fadeblink := core#FADE_BLINK_DIS

    writereg(1, CMDSET_OLED, core#FADE_BLINK, _fadeblink)

PUB disp_fade_tm(delay)
' Set time interval for display fade out, in number of frames
'   Valid values:
'       0..128 (rounded to nearest multiple of 8; clamped to range; POR: 0)
'   NOTE: The fade will occur only once
'   NOTE: 0 effectively disables the function
    if (delay)
        _fadeblink := (core#FADE_OUT_ENA | (((8 #> delay <# 128) / 8) - 1))
    else
        _fadeblink := core#FADE_BLINK_DIS

    writereg(1, CMDSET_OLED, core#FADE_BLINK, _fadeblink)

PUB disp_lines(lines)
' Set number of display lines
'   Valid values:
'       1..4
    case lines
        1:
            _disp_lines_n := core#DISP_LINES_1_3
            _disp_lines_nw := core#NW_1_2_LINE
        2:
            _disp_lines_n := core#DISP_LINES_2_4
            _disp_lines_nw := core#NW_1_2_LINE
        3:
            _disp_lines_n := core#DISP_LINES_1_3
            _disp_lines_nw := core#NW_3_4_LINE
        4:
            _disp_lines_n := core#DISP_LINES_2_4
            _disp_lines_nw := core#NW_3_4_LINE
        other:
            return

    writereg(1, CMDSET_FUND, core#FUNCT_SET_0 | (_disp_lines_n | _dblht_en), 0)
    writereg(1, CMDSET_EXTD, core#EXTD_FUNCSET | (_fnt_wid | _curs_invert | _disp_lines_nw), 0)

PUB disp_rdy{}: flag
' Flag indicating display is ready
'   Returns: TRUE (-1) or FALSE (0)
    writereg(0, CMDSET_FUND, 0, 0)
    i2c.start{}
    i2c.write(SLAVE_RD | _addr_bits)
    flag := i2c.read(i2c#NAK)
    i2c.stop{}

    return (((flag >> 7) & 1) <> 1)

PUB disp_shift(direction)
' Shift the display left or right by one character cell's width
'   Valid values:
'       LEFT (2)
'       RIGHT (3)
'   Any other value is ignored
    writereg(0, CMDSET_FUND, core#CURS_DISP_SHIFT | (LEFT #> direction <# RIGHT), 0)

PUB dbl_height(mode)
' Set double-height font style mode
'   Valid values:
'      *0: Standard height font all 4 lines / double-height disabled
'       1: Bottom two lines form one double-height line (top 2 lines standard height,
'           effectively 3 lines)
'       2: Middle two lines form one double-height line (top and bottom lines standard height,
'           effectively 3 lines)
'       3: Top and bottom lines each form a double-height line (effectively 2 lines)
'       4: Top two lines form one double-height line (bottom 2 lines standard height,
'           effectively 3 lines)
'   NOTE: Takes effect immediately - will affect current screen contents
    case mode
        0:
            _dblht_mode := 0
            _dblht_en := 0
            writereg(1, CMDSET_EXTD, core#FUNCT_SET_0 | {
}           (core#DISP_LINES_2_4 | core#DBLHT_FNT_DIS), 0)
            return
        1:
            _dblht_mode := core#DBLHT_BOTTOM
        2:
            _dblht_mode := core#DBLHT_MIDDLE
        3:
            _dblht_mode := core#DBLHT_BOTH
        4:
            _dblht_mode := core#DBLHT_TOP
        other:
            return

    _dblht_en := core#DBLHT_FNT_EN

    writereg(1, CMDSET_EXTD, core#DBLHT | _dblht_mode, 0)

PUB fnt_width(sz)
' Set Font width, in pixels
'   Valid values: 5 or 6 (clamped to range; POR: 5)
    _fnt_wid := sz := ((0 #> (sz-5) <# 1) << core#FNTWIDTH)
    writereg(1, CMDSET_EXTD, core#EXTD_FUNCSET | (_fnt_wid | _curs_invert | _disp_lines_nw), 0)

PUB get_pos{}: addr
' Get current pos in display RAM
'   Returns: Display address of current cursor pos
    writereg(0, CMDSET_FUND, 0, 0)
    i2c.start{}
    i2c.write(SLAVE_RD | _addr_bits)
    addr := i2c.read(TRUE)
    i2c.stop{}

PUB gpio_state(state)
' Set state of GPIO pin
'   Valid values:
'       0: GPIO pin HiZ, input disabled (always read as low)
'       1: GPIO pin HiZ, input enabled
'       2: GPIO pin output, low (POR)
'       3: GPIO pin output, high
    _gpio_state := state := (core#GPIO_HIZ_INP_DIS #> state <# core#GPIO_OUT_HIGH)
    writereg(1, CMDSET_OLED, core#FUNCT_SEL_C, (_ext_vsl | _gpio_state))

PUB home{}
' Returns cursor to home pos (0, 0)
'   NOTE: Doesn't clear the display
    writereg(0, CMDSET_FUND, core#HOME_DISP, 0)

PUB invert_colors(state)
' Invert display colors
'   Valid values:
'       TRUE (non-zero), FALSE (0)
    state := (((state <> 0) & 1) + 1)
    visibility(state)

PUB mirror_h(state)
' Mirror display, horizontally
'   Valid values: TRUE (non-zero), FALSE (0)
    _mirror_h := ((state <> 0) & 1)
    writereg(1, CMDSET_EXTD, core.ENTRY_MODE_SET | (_mirror_h | _mirror_v), 0)

PUB mirror_v(state)
' Mirror display, vertically
'   Valid values: TRUE (non-zero), FALSE (0)
    _mirror_v := ((( (state <> 0) & 1) ^ 1) << 1)
    writereg(1, CMDSET_EXTD, core.ENTRY_MODE_SET | (_mirror_h | _mirror_v), 0)

PUB pin_cfg(cfg)
' Change mapping between display data column address and segment driver.
'   Valid values:
'       0: Sequential SEG pin cfg
'       1: Alternative (odd/even) SEG pin cfg
'   NOTE: Only affects subsequent data input. Data already displayed/in DDRAM will be unchanged.
    _seg_pincfg := (0 #> cfg <# 1)
    writereg(1, CMDSET_OLED, core#SET_SEG_PINS, (_seg_remap | _seg_pincfg))

PUB phase1_period(clocks)
' Set length of phase 1 of segment waveform of the driver
' Valid values: 0..32 clocks
    _phs1_per := (((2 #> clocks <# 32) >> 1) - 1)
    writereg(1, CMDSET_OLED, core#SET_PHASE_LEN, (_phs2_per | _phs1_per))

PUB phase2period(clocks)
' Set length of phase 2 of segment waveform of the driver
'   Valid values: 1..15 clocks (POR: 7)
    _phs2_per := ((1 #> clocks <# 15) << 4)
    writereg(1, CMDSET_OLED, core#SET_PHASE_LEN, (_phs2_per | _phs1_per))

PUB position = pos_xy
PUB pos_xy(column, row) | offset
' Set current cursor position
    case column
        0..19:
            case row
                0..3:
                    offset := ($20 * row) + column <# ($20 * row) + $13
                other:
                    return
        other:
            return

    writereg(0, CMDSET_FUND, core#SET_DDRAM_ADDR | offset, 0)

PUB tx = putchar
PUB char = putchar
PUB putchar(ch) | col, row, pos
' Display single character.
    if (_char_attrs & CHAR_PROC)                ' interpret control characters
        case ch
            7:
                { bell; flash display }
                visibility(INVERT)
                time.msleep(50)
                visibility(NORM)
                return
            BS, $7F:
                { backspace }
                pos := get_pos{}                ' get current display pointer
                row := (pos / $20)              '   extract row from it
                col := pos - (row * $20)        '   extract column from it
                if (col > 0)                    ' not left-most column?
                    pos_xy(col-1, row)          '   then back up one
                    wr_data(" ")                '   erase it with a space
                    pos_xy(col-1, row)          '   move back again
                else                            ' otherwise, see if the cursor
                    if (row > 0)                '   can move back a row
                        pos_xy(_disp_xmax, row-1)'   but limit to (0, 0)
                        wr_data(" ")
                        pos_xy(_disp_xmax, row-1)
                return
            LF:
                { line-feed }
                pos := get_pos{}
                row := (pos / $20)
                col := pos - (row * $20)
                if (col > 0)                    ' not already on the first col?
                    col--                       '   move to col below prev char
                if (row < _disp_ymax)           ' not already on the last row?
                    pos_xy(col, row+1)          '   go to same col, next row
                else                            ' otherwise, go to same col,
                    pos_xy(col, 0)              '   first row
                return
            CB:
                { clear display }
                clear{}
                return
            CR:
                { carriage-return }
                pos := get_pos{}
                row := (pos / $20)
                col := pos - (row * $20)
                pos_xy(0, row)
                return

    { displayable character }
    wr_data(ch)

PUB reset{}
' Send reset signal to display controller
    outa[_RESET] := 0
    dira[_RESET] := 1
    time.usleep(core#TRES)
    outa[_RESET] := 1
    time.msleep(1)

PUB seg_voltage_ref(ref)
' Select segment voltage reference
'   Valid values:
'       INT (0): Internal VSL (POR)
'       EXT (1): External VSL
    _ext_vsl := (INT #> ref <# EXT) << core#VSL
    writereg(1, CMDSET_OLED, core#FUNCT_SEL_C, (_ext_vsl | _gpio_state))

PUB supply_voltage(v)
' Set supply voltage (enable/disable internal regulator)
'   Valid values:
'       5: Enable internal regulator (use for 5V operation; POR)
'       other: Disable internal regulator (3.3V/low-voltage operation)
    if (v)
        v := core#INT_REG_EN
    else
        v := core#INT_REG_DIS

    writereg(2, CMDSET_EXTD, core#FUNCT_SEL_A, v)

PUB text_dir(tdir)
' Change mapping between display data column address and segment driver.
'   Valid values:
'       0: Disable SEG left/right remap (POR)
'       1: Enable SEG left/right remap
'   NOTE: Only affects subsequent data input. Data already displayed/in DDRAM will be unchanged.
    _seg_remap := ((0 #> tdir <# 1) << core#SEG_LR_REMAP)
    writereg(1, CMDSET_OLED, core#SET_SEG_PINS, (_seg_remap | _seg_pincfg))

PUB visibility(mode)
' Set display visibility
'   Valid values:
'       OFF (0): Display off
'       NORM (1): Normal display
'       INVERT (2): Inverted display
'   NOTE: Takes effect immediately. Does not affect display RAM contents
'   NOTE: Display may appear dimmer, overall, when inverted
    case mode
        OFF:
            _disp_en := 0
        NORM:
            _disp_en := core#DISP_ON
            _disp_invert := core#NORM_DISP
        INVERT:
            _disp_en := core#DISP_ON
            _disp_invert := core#REV_DISP
        other:
            return

    writereg(1, CMDSET_FUND, core#DISP_ONOFF | (_disp_en |_curs_en | _blink_en), 0)
    writereg(1, CMDSET_EXTD, core#FUNCT_SET_1 | (_cgram_blink | _disp_invert), 0)

PRI wr_data(dbyte) | cmd_pkt
' Write bytes with the DATA control byte set
    cmd_pkt.byte[0] := (SLAVE_WR | _addr_bits)
    cmd_pkt.byte[1] := core#CTRLBYTE_DATA
    cmd_pkt.byte[2] := dbyte

    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, 3)
    i2c.stop{}

PRI writereg(nr_bytes, cmd_set, cmd, val) | cmd_pkt[4]
' Write cmd with param 'val' from command set
    cmd_pkt.word[0] := CMD_HDR | _addr_bits
    case cmd_set
        CMDSET_FUND:
            cmd_pkt.byte[2] := cmd
            nr_bytes := 3
        CMDSET_EXTD:
            case nr_bytes
                1:
                    cmd_pkt.byte[2] := core#CMDSET_EXTD | _disp_lines_n | _dblht_en
                    cmd_pkt.byte[3] := core#CTRLBYTE_CMD
                    cmd_pkt.byte[4] := cmd
                    cmd_pkt.byte[5] := core#CTRLBYTE_CMD
                    cmd_pkt.byte[6] := core#CMDSET_FUND | _disp_lines_n | _dblht_en
                    nr_bytes := 7
                2:
                    cmd_pkt.byte[2] := core#CMDSET_EXTD | _disp_lines_n | _dblht_en
                    cmd_pkt.byte[3] := core#CTRLBYTE_CMD
                    cmd_pkt.byte[4] := cmd
                    cmd_pkt.byte[5] := core#CTRLBYTE_DATA
                    cmd_pkt.byte[6] := val
                    cmd_pkt.byte[7] := core#CTRLBYTE_CMD
                    cmd_pkt.byte[8] := core#CMDSET_FUND | _disp_lines_n | _dblht_en
                    nr_bytes := 9
                other:
                    return
        CMDSET_EXTD_IS:
            case nr_bytes
                1:
                    cmd_pkt.byte[2] := core#CMDSET_EXTD | _disp_lines_n | _dblht_en | 1
                    cmd_pkt.byte[3] := core#CTRLBYTE_CMD
                    cmd_pkt.byte[4] := cmd
                    cmd_pkt.byte[5] := core#CTRLBYTE_CMD
                    cmd_pkt.byte[6] := core#CMDSET_FUND | _disp_lines_n | _dblht_en
                    nr_bytes := 7
                2:
                    cmd_pkt.byte[2] := core#CMDSET_EXTD | _disp_lines_n | _dblht_en
                    cmd_pkt.byte[3] := core#CTRLBYTE_CMD
                    cmd_pkt.byte[4] := cmd
                    cmd_pkt.byte[5] := core#CTRLBYTE_DATA
                    cmd_pkt.byte[6] := val
                    cmd_pkt.byte[7] := core#CTRLBYTE_CMD
                    cmd_pkt.byte[8] := core#CMDSET_FUND | _disp_lines_n | _dblht_en
                    nr_bytes := 9
                other:
                    return
        CMDSET_OLED:
            cmd_pkt.byte[2] := core#CMDSET_EXTD | _disp_lines_n | _dblht_en
            cmd_pkt.byte[3] := core#CTRLBYTE_CMD
            cmd_pkt.byte[4] := core#OLED_CMDSET_ENA
            cmd_pkt.byte[5] := core#CTRLBYTE_CMD
            cmd_pkt.byte[6] := cmd
            cmd_pkt.byte[7] := core#CTRLBYTE_CMD
            cmd_pkt.byte[8] := val
            cmd_pkt.byte[9] := core#CTRLBYTE_CMD
            cmd_pkt.byte[10] := core#OLED_CMDSET_DIS
            cmd_pkt.byte[11] := core#CTRLBYTE_CMD
            cmd_pkt.byte[12] := core#CMDSET_FUND | _disp_lines_n | _dblht_en
            nr_bytes := 13

    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, nr_bytes)
    i2c.stop{}

DAT
{
Copyright 2022 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

