{
    --------------------------------------------
    Filename: display.oled.4x20.i2c-pasm.spin
    Author: Jesse Burt
    Description: I2C driver for US2066-based OLED
     alphanumeric displays
    Copyright (c) 2018
    Created Dec 30, 2017
    Updated Mar 10, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON
'' I2C Defaults
    SLAVE_WR        = core#SLAVE_ADDR
    SLAVE_RD        = SLAVE_WR|1
    R               = %1

    DEF_SCL         = 28
    DEF_SDA         = 29
    DEF_HZ          = core#I2C_MAX_FREQ
    I2C_MAX_FREQ    = core#I2C_MAX_FREQ

'' Build some basic headers for I2C transactions
    CMD_HDR         = ((core#CTRLBYTE_CMD << 8) | SLAVE_WR)
    DAT_HDR         = ((core#CTRLBYTE_DATA << 8) | SLAVE_WR)

    TRANSTYPE_CMD   = 0
    TRANSTYPE_DATA  = 1

    CMDSET_FUND     = 0
    CMDSET_EXTD     = 1
    CMDSET_EXTD_IS  = 2
    CMDSET_OLED     = 3

    CR              = 10  'Carriage-return
    NL              = 13  'Newline
    SP              = 32  'Space

    LEFT            = core#DISP_LEFT
    RIGHT           = core#DISP_RIGHT

'' Constants for compatibility with display.lcd.serial.spin object
    LCD_BKSPC       = $08                                   ' move cursor left
    LCD_RT          = $09                                   ' move cursor right
    LCD_LF          = $0A                                   ' move cursor down 1 line
    LCD_CLS         = $0C                                   ' clear LCD (follow with 5 ms delay)
    LCD_CR          = $0D                                   ' move pos 0 of next line
    LCD_BL_ON       = $11                                   ' backlight on
    LCD_BL_OFF      = $12                                   ' backlight off
    LCD_OFF         = $15                                   ' LCD off
    LCD_ON1         = $16                                   ' LCD on; cursor off, blink off
    LCD_ON2         = $17                                   ' LCD on; cursor off, blink on
    LCD_ON3         = $18                                   ' LCD on; cursor on, blink off
    LCD_ON4         = $19                                   ' LCD on; cursor on, blink on
    LCD_LINE0       = $80                                   ' move to line 1, column 0
    LCD_LINE1       = $94                                   ' move to line 2, column 0
    LCD_LINE2       = $A8                                   ' move to line 3, column 0
    LCD_LINE3       = $BC                                   ' move to line 4, column 0
'' Flag top-level objects can use to tell this is the PASM version
    PASM            = TRUE

VAR

    byte _reset
    byte _sa0_addr
'' Variables to hold US2066 register states
    byte _mirror_h, _mirror_v
    byte _char_predef, _char_set
    byte _fontwidth, _cursor_invert, _disp_lines_NW
    byte _frequency, _divisor
    byte _disp_en, _cursor_en, _blink_en
    byte _disp_lines_N, _dblht_en
    byte _seg_remap, _seg_pincfg
    byte _ext_vsl, _gpio_state
    byte _contrast
    byte _phs1_per, _phs2_per
    byte _vcomh_des_lvl
    byte _dblht_mode
    byte _cgram_blink, _disp_invert
    byte _fadeblink

OBJ

    i2c     : "com.i2c"
    core    : "core.con.us2066"
    time    : "time"

PUB null
'' This is not a top-level object

PUB Start(resetpin): okay
'' Use default I2C settings - only have to specify the OLED display's reset pin
    okay := Startx (DEF_SCL, DEF_SDA, resetpin, core#I2C_MAX_FREQ, 0)

PUB Startx(SCL_PIN, SDA_PIN, RESET_PIN, I2C_HZ, SLAVE_BIT): okay
'' Start with custom settings
''  SCL         - I2C Serial Clock pin
''  SDA         - I2C Serial Data pin
''  resetpin    - OLED display's assigned reset pin
''  hz          - I2C Bus Frequency (max 400kHz)
''  slave_bit   - Flag to indicate optional alternative slave address
    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if I2C_HZ =< core#I2C_MAX_FREQ
            if okay := i2c.setupx (SCL_PIN, SDA_PIN, I2C_HZ)    'I2C Object Started?
                time.MSleep (1)
                _reset := RESET_PIN
                case ||slave_bit
                        1: _sa0_addr := 1 << 1
                        0: _sa0_addr := 0
                        OTHER:
                            i2c.terminate
                            return FALSE
                Reset
                Defaults
                if i2c.present (SLAVE_WR)
                    return okay
    return FALSE                                                'If we got here, something went wrong

PUB Stop
'' Turn the display visibility off and stop the I2C cog
    EnableDisplay (FALSE)
    i2c.terminate

PUB finalize
'' Alias for Stop
    EnableDisplay (FALSE)
    i2c.terminate

PUB Defaults
'' Set some sane defaults
    _fontwidth := core#FONTWIDTH_5
    _cursor_invert := core#CURSOR_NORMAL
    _disp_lines_NW := core#NW_3_4_LINE

    _disp_lines_N := core#DISP_LINES_2_4
    _dblht_en := 0

    _disp_en := 0
    _cursor_en := 0
    _blink_en := 0

    _char_predef := core#CG_ROM_RAM_240_8
    _char_set := core#CHAR_ROM_A

    _frequency := %0111
    _divisor := %0000

    _mirror_h := core#SEG0_99
    _mirror_v := core#COM0_31

    _seg_remap := core#SEG_LR_REMAP_DIS
    _seg_pincfg := core#ALT_SEGPINCFG

    _ext_vsl := core#VSL_INTERNAL
    _gpio_state := core#GPIO_OUT_LOW

    _contrast := 127

    _phs1_per := 8
    _phs2_per := 7

    _vcomh_des_lvl := 2

    _cgram_blink := core#CGRAM_BLINK_DIS
    _disp_invert := core#NORMAL_DISPLAY

    _fadeblink := 0

PUB Backspace | pos, col, row
'' Query the controller for the current cursor position in DDRAM and write a space over the previous location.
    pos := GetPos
    case pos
        $00..$13:
            if pos > $00
                Position(pos-1, 0)
                Char_Literal ($20)
                Position(pos-1, 0)
            else
                Position (0, 0)     'Stop upper-left / HOME
                Char_Literal ($20)
                Position (0, 0)
'                Position(19, 3)    'Wrap around to end of display
'                Char_Literal ($20)
'                Position(19, 3)

        $20..$33:
            if pos > $20
                col := pos-$20
                Position(col-1, 1)
                Char_Literal ($20)
                Position(col-1, 1)
            else
                Position(19, 0)
                Char_Literal ($20)
                Position(19, 0)
        $40..$53:
            if pos > $40
                col := pos-$40
                Position(col-1, 2)
                Char_Literal ($20)
                Position(col-1, 2)
            else
                Position(19, 1)
                Char_Literal ($20)
                Position(19, 1)
        $60..$73:
            if pos > $60
                col := pos-$60
                Position (col-1, 3)
                Char_Literal ($20)
                Position (col-1, 3)
            else
                Position (19, 2)
                Char_Literal ($20)
                Position (19, 2)
        OTHER: return

PUB Busy | flag
'' Returns Busy Flag (bit 7 of $00)
    writeRegX (TRANSTYPE_CMD, 0, CMDSET_FUND, $00, 0)
    i2c.start
    i2c.write (SLAVE_RD | _sa0_addr)
    flag := i2c.read (TRUE)
    i2c.stop

    if (flag >> 7) & %1
        return TRUE
    else
        return FALSE

PUB CarriageReturn | pos, row
'' Carriage-return / return to beginning of line
    pos := GetPos
    case pos
        $00..$13: row := 0
        $20..$33: row := 1
        $40..$53: row := 2
        $60..$73: row := 3
        OTHER: row := 0
    Position (0, row)

PUB Char(ch)
'' Display single character.
'' Process/interpret unprintable/control characters
    case ch
        7:
            InvertDisplay (TRUE)
            time.MSleep (50)
            InvertDisplay (FALSE)
        8, $7F:
            Backspace
        10:
            CarriageReturn
        12:
            Clear
        13:
            Newline
        OTHER:
            wrdata(ch)

PUB PutC(ch)
'' Alias for Char
    case ch
        7:
            InvertDisplay (TRUE)
            time.MSleep (50)
            InvertDisplay (FALSE)
        8, $7F:
            Backspace
        10:
            CarriageReturn
        12:
            Clear
        13:
            Newline
        OTHER:
            wrdata(ch)

PUB Char_Literal(ch)
'' Display single character (pass data through without processing it first)
    wrdata(ch)

PUB CharGen(count)
'' Select number of pre-defined vs free user-defined character cells
'' Valid values:
''  240 (leaves 8 available user-defined characters)
''  248 (leaves 8 available user-defined characters)
''  250 (leaves 6 available user-defined characters)
''  256 (leaves 0 available user-defined characters)
    case count
        240: _char_predef := core#CG_ROM_RAM_240_8
        248: _char_predef := core#CG_ROM_RAM_248_8
        250: _char_predef := core#CG_ROM_RAM_250_6
        256: _char_predef := core#CG_ROM_RAM_256_0
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_EXTD, core#FUNCTION_SEL_B, _char_predef | _char_set)

PUB CharROM(char_set)
'' Select ROM font / character set
''  0: ROM A
''  1: ROM B
''  2: ROM C
    case char_set
        0: _char_set := core#CHAR_ROM_A
        1: _char_set := core#CHAR_ROM_B
        2: _char_set := core#CHAR_ROM_C
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_EXTD, core#FUNCTION_SEL_B, _char_predef | _char_set)

PUB Clear
'' Clear display
    writeRegX (TRANSTYPE_CMD, 1, CMDSET_FUND, core#CLEAR_DISPLAY, 0)

PUB CLS
'' Alias for Clear
    writeRegX (TRANSTYPE_CMD, 1, CMDSET_FUND, core#CLEAR_DISPLAY, 0)

PUB ClearLine(line)
'' Clear 'line'
    if lookdown (line: 0..4)
        Position(0, line)
        repeat 20
            Char(" ")

PUB ClearLN(line)
'' Alias for ClearLine
    if lookdown (line: 0..4)
        Position(0, line)
        repeat 20
            Char(" ")

PUB Contrast(level)
'' Set display contrast level
'' level: 00..$FF
'' POR: $7F
    case level
        0..255: _contrast := level
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_OLED, core#SET_CONTRAST, _contrast)

PUB CursorBlink(enable)
'' Enable/Disable cursor blinking
    case ||enable
        0: _blink_en := core#BLINK_OFF
        1: _blink_en := core#BLINK_ON
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_FUND, core#DISPLAY_ONOFF | _disp_en | _cursor_en | _blink_en, 0)

PUB CursorInvert(enable)
'' Enable/disable black/white inverting of cursor
'' POR: 0
    case ||enable
        1: _cursor_invert := core#CURSOR_INVERT
        0: _cursor_invert := core#CURSOR_NORMAL
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_EXTD, core#EXTENDED_FUNCSET | _fontwidth | _cursor_invert | _disp_lines_NW, 0)

PUB DisplayBlink(delay)
'' Gradually fade out/in display
''  'delay' is in frames
''  Pass 0 to disable
    case delay
        0: _fadeblink := core#FADE_BLINK_DIS
        8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128: _fadeblink := (core#BLINK_ENA | ((delay / 8) - 1))
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_OLED, core#FADEOUT_BLINK, _fadeblink)

PUB DisplayFade(delay)
'' Gradually fade out display (just once)
''  'delay' is in frames
''  Pass 0 to disable
    case delay
        0: _fadeblink := core#FADE_BLINK_DIS
        8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128: _fadeblink := (core#FADE_OUT_ENA | ((delay / 8) - 1))
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_OLED, core#FADEOUT_BLINK, _fadeblink)

PUB DisplayLines(lines)
'' Set 1, 2, 3 or 4-line display mode
    case lines
        1:
            _disp_lines_N := core#DISP_LINES_1_3
            _disp_lines_NW := core#NW_1_2_LINE
        2:
            _disp_lines_N := core#DISP_LINES_2_4
            _disp_lines_NW := core#NW_1_2_LINE
        3:
            _disp_lines_N := core#DISP_LINES_1_3
            _disp_lines_NW := core#NW_3_4_LINE
        4:
            _disp_lines_N := core#DISP_LINES_2_4
            _disp_lines_NW := core#NW_3_4_LINE

        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_FUND, core#FUNCTION_SET_0 | _disp_lines_N | _dblht_en, 0)
    writeRegX (TRANSTYPE_CMD, 1, CMDSET_EXTD, core#EXTENDED_FUNCSET | _fontwidth | _cursor_invert | _disp_lines_NW, 0)

PUB DisplayShift(direction)
'' Shift the display left or right by one character cell's width
'' Suggestion: Use the constants LEFT and RIGHT as parameters
''  or, if you prefer, LEFT is %10 (2) and RIGHT is %11 (3)
'' All other values ignored
    case direction
        LEFT:             ' As long as the value passed is valid,
        RIGHT:            '  leave it alone, and use it directly in the cmd_Fund line below
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_FUND, core#CURS_DISP_SHIFT | direction, 0)

PUB DoubleHeight(mode) | cmd_packet
'' Set double-height font style mode
''  0: Standard height font all 4 lines / double-height disabled
''  1: Bottom two lines form one double-height line (top 2 lines standard height, effectively 3 lines)
''  2: Middle two lines form one double-height line (top and bottom lines standard height, effectively 3 lines)
''  3: Top and bottom lines each form a double-height line (effectively 2 lines)
''  4: Top two lines form one double-height line (bottom 2 lines standard height, effectively 3 lines)
''  Any other value ignored
'' NOTE: Takes effect immediately, _will_ affect screen contents
    case mode
        0:
            _dblht_mode := 0
            _dblht_en := 0
            writeRegX (TRANSTYPE_CMD, 1, CMDSET_EXTD, core#FUNCTION_SET_0 | core#DISP_LINES_2_4 | core#DBLHT_FONT_DIS, 0)
            return
        1: _dblht_mode := core#DBLHEIGHT_BOTTOM
        2: _dblht_mode := core#DBLHEIGHT_MIDDLE
        3: _dblht_mode := core#DBLHEIGHT_BOTH
        4: _dblht_mode := core#DBLHEIGHT_TOP
        OTHER: return

    _dblht_en := core#DBLHT_FONT_EN

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_EXTD, core#DBLHEIGHT | _dblht_mode, 0)

PUB EnableBacklight(enable)
'' Alias for EnableDisplay
    case ||enable
        0: _disp_en := 0
        1: _disp_en := core#DISP_ON
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_FUND, core#DISPLAY_ONOFF | _disp_en | _cursor_en | _blink_en, 0)

PUB EnableDisplay(enable)
'' Turn the display on or off
'' NOTE: Does not affect display contents
    case ||enable
        0: _disp_en := 0
        1: _disp_en := core#DISP_ON
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_FUND, core#DISPLAY_ONOFF | _disp_en | _cursor_en | _blink_en, 0)

PUB DisplayOff
'' Alias for EnableDisplay(FALSE)
    EnableDisplay (FALSE)

PUB DisplayOn
'' Alias for EnableDisplay(TRUE) - also turns off cursor
    EnableDisplay (TRUE)
    Cursor (0)

PUB EnableExtVSL(enabled)
'' External Segment Voltage Reference
'' POR: 0
    case ||enabled
        1: _ext_vsl := core#VSL_EXTERNAL
        0: _ext_vsl := core#VSL_INTERNAL
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_OLED, core#FUNCTION_SEL_C, _ext_vsl | _gpio_state)

PUB EnableInternalReg(enable)
'' Internal regulator setting
''  1 or TRUE: Enable (use for 5V operation)
''  0 or FALSE: Disable (3.3V/low-voltage operation)
''  all other values ignored
'' POR: 1
    case ||enable
        0:
        1: enable := core#INT_REG_ENABLE
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 2, CMDSET_EXTD, core#FUNCTION_SEL_A, enable)

PUB FontWidth(dots)
'' Set Font width (5 or 6 dots)
'' POR: 5
    case dots
        5: _fontwidth := core#FONTWIDTH_5
        6: _fontwidth := core#FONTWIDTH_6
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 0, CMDSET_EXTD, core#EXTENDED_FUNCSET | _fontwidth | _cursor_invert | _disp_lines_NW, 0)

PUB GetPos: addr | data_in
'' Gets current position in DDRAM
    writeRegX (TRANSTYPE_CMD, 0, CMDSET_FUND, $00, 0)
    i2c.start
    i2c.write (SLAVE_RD | _sa0_addr)
    addr := i2c.read (TRUE)
    i2c.stop

PUB GPIOState(state)
'' 0: GPIO pin HiZ, input disabled (always read as low)
'' 1: GPIO pin HiZ, input enabled
'' 2: GPIO pin output, low
'' 3: GPIO pin output, high
'' POR: 2
    case state
        0: _gpio_state := core#GPIO_HIZ_INP_DIS
        1: _gpio_state := core#GPIO_HIZ_INP_ENA
        2: _gpio_state := core#GPIO_OUT_LOW
        3: _gpio_state := core#GPIO_OUT_HIGH
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_OLED, core#FUNCTION_SEL_C, _ext_vsl | _gpio_state)

PUB Home
'' Returns cursor to home position (0, 0), without clearing the display
    writeRegX (TRANSTYPE_CMD, 0, CMDSET_FUND, core#HOME_DISPLAY, 0)

PUB InvertDisplay(enable)
'' Enable/disable inverted display
'' POR: 0
'' NOTE:
''  1. Takes effect immediately
''  2. Display will appear dimmer, overall
    case ||enable
        1: _disp_invert := core#REVERSE_DISPLAY
        0: _disp_invert := core#NORMAL_DISPLAY
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 0, CMDSET_EXTD, core#FUNCTION_SET_1 | _cgram_blink | _disp_invert, 0)

PUB MirrorH(enable)
'' Mirror display, horizontally
    case ||enable
        0: _mirror_h := core#SEG99_0
        1: _mirror_h := core#SEG0_99
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 0, CMDSET_EXTD, core#ENTRY_MODE_SET | _mirror_h | _mirror_v, 0)

PUB MirrorV(enable)
'' Mirror display, vertically
    case ||enable
        0: _mirror_v := core#COM0_31
        1: _mirror_v := core#COM31_0
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 0, CMDSET_EXTD, core#ENTRY_MODE_SET | _mirror_h | _mirror_v, 0)

PUB Newline: row | pos
'' Query the controller for the current cursor position in DDRAM and increment the row (wrapping to row 0)
    pos := GetPos
    case pos
        $00..$13: row := 0
        $20..$33: row := 1
        $40..$53: row := 2
        $60..$73: row := 3
        OTHER: return

    row := (row + 1) <# 3
    Position (0, row)

PUB PartID: pid
'' Gets Part ID
'' *** US2066 Datasheet p.39 says this should return %0100001 ($21),
''     but it seems to return %0000001 ($01)
'    cmd_Fund ($00)
    writeRegX (TRANSTYPE_CMD, 0, CMDSET_FUND, $00, 0)

    i2c.start
    i2c.write (SLAVE_RD | _sa0_addr)
    i2c.read (FALSE)          'First read gets the address counter register - throw it away
    pid := i2c.read (TRUE)    'Second read gets the Part ID
    i2c.stop

PUB PinCfg(cfg)
'' Change mapping between display data column address and segment driver.
'' 0: Sequential SEG pin cfg
'' 1: Alternative (odd/even) SEG pin cfg
'' NOTE: Only affects subsequent data input. Data already displayed/in DDRAM will be unchanged.
    case cfg
        0: _seg_pincfg := core#SEQ_SEGPINCFG
        1: _seg_pincfg := core#ALT_SEGPINCFG
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_OLED, core#SET_SEG_PINS, _seg_remap | _seg_pincfg)

PUB Phs1Period(clocks)
'' Set length of phase 1 of segment waveform of the driver
'' Valid values: 0 to 32 clocks
    case clocks
        2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32: _phs1_per := (clocks >> 1) - 1
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_OLED, core#SET_PHASE_LEN, _phs2_per | _phs1_per)

PUB Phs2Period(clocks)
'' Set length of phase 2 of segment waveform of the driver
'' Valid values: 1 to 15 clocks
'' POR: 7
    case clocks
        1..15: _phs2_per := (clocks << 4)
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 1, CMDSET_OLED, core#SET_PHASE_LEN, _phs2_per | _phs1_per)

PUB Position(column, row) | offset
'' Sets current cursor position
    case column
        0..19:
            case row
                0..3: offset := ($20 * row) + column <# ($20 * row) + $13
                OTHER: return
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 0, CMDSET_FUND, core#SET_DDRAM_ADDR|offset, 0)

PUB GotoXY(column, line) | offset
'' Alias for Position
    case column
        0..19:
            case line
                0..3: offset := ($20 * line) + column <# ($20 * line) + $13
                OTHER: return
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 0, CMDSET_FUND, core#SET_DDRAM_ADDR|offset, 0)

PUB Reset

    dira[_reset] := 1
    outa[_reset] := 0
    outa[_reset] := 1
    time.MSleep (1)

PUB SetCursor(type)
'' Selects cursor type
'' 0: No cursor
'' 1: Block, blinking
'' 2: Underscore, no blinking
'' 3: Underscore, block blinking
    case type
        0:  _cursor_invert := _blink_en := _cursor_en := FALSE
        1:
            _cursor_en := core#CURSOR_OFF
            _cursor_invert := core#CURSOR_INVERT
            _blink_en := core#BLINK_ON
        2:
            _cursor_en := core#CURSOR_ON
            _cursor_invert := core#CURSOR_NORMAL
            _blink_en := core#BLINK_OFF
        3:
            _cursor_en := core#CURSOR_ON
            _cursor_invert := core#CURSOR_NORMAL
            _blink_en := core#BLINK_ON
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 0, CMDSET_FUND, core#DISPLAY_ONOFF | _disp_en | _cursor_en | _blink_en, 0)
    CursorInvert (_cursor_invert >> 1)

PUB Cursor(type)
'' Alias for SetCursor
    case type
        0:  _cursor_invert := _blink_en := _cursor_en := FALSE
        1:
            _cursor_en := core#CURSOR_OFF
            _cursor_invert := core#CURSOR_INVERT
            _blink_en := core#BLINK_ON
        2:
            _cursor_en := core#CURSOR_ON
            _cursor_invert := core#CURSOR_NORMAL
            _blink_en := core#BLINK_OFF
        3:
            _cursor_en := core#CURSOR_ON
            _cursor_invert := core#CURSOR_NORMAL
            _blink_en := core#BLINK_ON
        OTHER: return

    writeRegX (TRANSTYPE_CMD, 0, CMDSET_FUND, core#DISPLAY_ONOFF | _disp_en | _cursor_en | _blink_en, 0)
    CursorInvert (_cursor_invert >> 1)

PUB SetupOsc(frequency, divisor)
'' Set display clock oscillator frequency and divide ratio
'' frequency:   Range 0..15 (POR 7)
'' divisor:     Range 1..16 (POR 1)
    case frequency
        0..15: _frequency := frequency << 4
        OTHER: return

    case divisor
        1..16: _divisor := divisor - 1
        OTHER: return

    cmd8_OLED (core#DISP_CLKDIV_OSC, _frequency | _divisor)

PUB Str(stringptr)
'' Display zero-terminated string (use if you want to be able to use newline characters in the string)
    repeat strsize(stringptr)
        Char(byte[stringptr++])

PUB Str_Literal(stringptr)
'' Display zero-terminated string. Don't process input.
    repeat strsize(stringptr)
        Char_Literal(byte[stringptr++])

PUB StrDelay(stringptr, delay)
'' Display zero-terminated string with inter-character delay, in ms
    repeat strsize(stringptr)
        Char(byte[stringptr++])
        time.MSleep (delay)

PUB StrDelay_Literal(stringptr, delay)
'' Display zero-terminated string with inter-character delay, in ms. Don't process input.
    repeat strsize(stringptr)
        Char_Literal(byte[stringptr++])
        time.MSleep (delay)

PUB TextDirection(direction)
'' Change mapping between display data column address and segment driver.
'' 0: Disable SEG left/right remap
'' 1: Enable SEG left/right remap
'' NOTE: Only affects subsequent data input. Data already displayed/in DDRAM will be unchanged.
    case direction
        0: _seg_remap := core#SEG_LR_REMAP_DIS
        1: _seg_remap := core#SEG_LR_REMAP_EN
        OTHER: return

    cmd8_OLED ( core#SET_SEG_PINS, _seg_remap | _seg_pincfg)

PUB VcomhDeselectLev(level)
'' Adjust Vcomh regulator output
'' 0: ~0.65*Vcc
'' 1: ~0.71*Vcc
'' 2: ~0.77*Vcc
'' 3: ~0.83*Vcc
'' 4: 1*Vcc
'' POR: 2
    case level
        0..4: _vcomh_des_lvl := level << 4
        OTHER: return
 
    cmd8_OLED ( core#SET_VCOMH_DESEL, _vcomh_des_lvl)

PRI cmd_Ext(cmd, extReg_IS) | cmd_packet[2]
'' Access Extended Command Set
'' Single-byte commands
'' Flags: RE = 1, IS = 0 or 1
    cmd_packet.word[0] := CMD_HDR | _sa0_addr
    cmd_packet.byte[2] := core#CMDSET_EXTENDED | _disp_lines_N | _dblht_en | extReg_IS
    cmd_packet.byte[3] := core#CTRLBYTE_CMD
    cmd_packet.byte[4] := cmd
    cmd_packet.byte[5] := core#CTRLBYTE_CMD
    cmd_packet.byte[6] := (core#CMDSET_FUNDAMENTAL | _disp_lines_N | _dblht_en)

'    WriteX (@cmd_packet, 7)

PRI cmd8_Ext(cmd, val) | cmd_packet[3]
'' Access Extended Command Set
'' Two-byte commands
'' Flags: RE = 1, IS = 0
    cmd_packet.word[0] := CMD_HDR | _sa0_addr
    cmd_packet.byte[2] := core#CMDSET_EXTENDED | _disp_lines_N | _dblht_en
    cmd_packet.byte[3] := core#CTRLBYTE_CMD
    cmd_packet.byte[4] := cmd
    cmd_packet.byte[5] := core#CTRLBYTE_DATA
    cmd_packet.byte[6] := val
    cmd_packet.byte[7] := core#CTRLBYTE_CMD
    cmd_packet.byte[8] := core#CMDSET_FUNDAMENTAL | _disp_lines_N | _dblht_en

'    WriteX (@cmd_packet, 9)

PRI cmd8_OLED(cmd, val) | cmd_packet[4]
'' Access OLED Characterization Command Set
'' Two-byte commands
'' Flags: RE = 1, IS = 0, SD = 1
    cmd_packet.word[0] := CMD_HDR | _sa0_addr
    cmd_packet.byte[2] := core#CMDSET_EXTENDED | _disp_lines_N | _dblht_en
    cmd_packet.byte[3] := core#CTRLBYTE_CMD
    cmd_packet.byte[4] := core#OLED_CMDSET_ENA
    cmd_packet.byte[5] := core#CTRLBYTE_CMD
    cmd_packet.byte[6] := cmd
    cmd_packet.byte[7] := core#CTRLBYTE_CMD
    cmd_packet.byte[8] := val
    cmd_packet.byte[9] := core#CTRLBYTE_CMD
    cmd_packet.byte[10] := core#OLED_CMDSET_DIS
    cmd_packet.byte[11] := core#CTRLBYTE_CMD
    cmd_packet.byte[12] := core#CMDSET_FUNDAMENTAL | _disp_lines_N | _dblht_en

'    WriteX (@cmd_packet, 13)

PRI cmd_Fund(cmd) | ackbit, cmd_packet
'' Fundamental Command Set
    cmd_packet := (cmd << 16) | (CMD_HDR | _sa0_addr)
'    WriteX (@cmd_packet, 3)

PRI wrdata(databyte) | cmd_packet
'' Write bytes with the DATA control byte set
    cmd_packet.byte[0] := SLAVE_WR | _sa0_addr
    cmd_packet.byte[1] := core#CTRLBYTE_DATA
    cmd_packet.byte[2] := databyte

    i2c.start
    i2c.wr_block (@cmd_packet, 3)
    i2c.stop
  
{PRI readX(ptr_buff, num_bytes)
'' Read num_bytes from the bus into ptr_buff
    i2c.start
    i2c.write (SLAVE_ADDR | _sa0_addr | R)
    i2c.pread (ptr_buff, num_bytes, TRUE)
    i2c.stop
}
{PRI WriteX(ptr_buff, num_bytes)
'' Write num_bytes from ptr_buff to the bus
    i2c.start
    i2c.pwrite (ptr_buff, num_bytes)
    i2c.stop
}
PUB readRegX(reg, bytes, dest) | cmd_packet

    case reg
        0:
            i2c.start
            i2c.write (SLAVE_RD | _sa0_addr)
            result := i2c.read (TRUE)
            i2c.stop
            return

    case bytes
        1:
'            writeRegX (reg, 0, 0)
'            writeRegX (trans_type, nr_bytes, cmd_set, cmd, val)
        OTHER:
            return

    i2c.start
    i2c.wr_block (@cmd_packet, 2)

    i2c.start
    i2c.write (SLAVE_RD)
    i2c.rd_block (dest, bytes, TRUE)
    i2c.stop

PUB writeRegX(trans_type, nr_bytes, cmd_set, cmd, val) | cmd_packet[2]

    case trans_type
        TRANSTYPE_CMD:
            cmd_packet.byte[0] := CMD_HDR | _sa0_addr

            case cmd_set
                CMDSET_FUND:
                    cmd_packet.byte[2] := cmd
                    nr_bytes := 3

                CMDSET_EXTD:
                    case nr_bytes
                        1:
                            cmd_packet.byte[2] := core#CMDSET_EXTENDED | _disp_lines_N | _dblht_en
                            cmd_packet.byte[3] := core#CTRLBYTE_CMD
                            cmd_packet.byte[4] := cmd
                            cmd_packet.byte[5] := core#CTRLBYTE_CMD
                            cmd_packet.byte[6] := core#CMDSET_FUNDAMENTAL | _disp_lines_N | _dblht_en
                            nr_bytes := 7

                        2:
                            cmd_packet.byte[2] := core#CMDSET_EXTENDED | _disp_lines_N | _dblht_en
                            cmd_packet.byte[3] := core#CTRLBYTE_CMD
                            cmd_packet.byte[4] := cmd
                            cmd_packet.byte[5] := core#CTRLBYTE_DATA
                            cmd_packet.byte[6] := val
                            cmd_packet.byte[7] := core#CTRLBYTE_CMD
                            cmd_packet.byte[8] := core#CMDSET_FUNDAMENTAL | _disp_lines_N | _dblht_en
                            nr_bytes := 9
                        OTHER:
                            return

                CMDSET_EXTD_IS:
                    case nr_bytes
                        1:
                            cmd_packet.byte[2] := core#CMDSET_EXTENDED | _disp_lines_N | _dblht_en | %1{IS = 1}
                            cmd_packet.byte[3] := core#CTRLBYTE_CMD
                            cmd_packet.byte[4] := cmd
                            cmd_packet.byte[5] := core#CTRLBYTE_CMD
                            cmd_packet.byte[6] := core#CMDSET_FUNDAMENTAL | _disp_lines_N | _dblht_en
                            nr_bytes := 7

                        2:
                            cmd_packet.byte[2] := core#CMDSET_EXTENDED | _disp_lines_N | _dblht_en
                            cmd_packet.byte[3] := core#CTRLBYTE_CMD
                            cmd_packet.byte[4] := cmd
                            cmd_packet.byte[5] := core#CTRLBYTE_DATA
                            cmd_packet.byte[6] := val
                            cmd_packet.byte[7] := core#CTRLBYTE_CMD
                            cmd_packet.byte[8] := core#CMDSET_FUNDAMENTAL | _disp_lines_N | _dblht_en
                            nr_bytes := 9
                        OTHER:
                            return

                CMDSET_OLED:
                    cmd_packet.byte[2] := core#CMDSET_EXTENDED | _disp_lines_N | _dblht_en
                    cmd_packet.byte[3] := core#CTRLBYTE_CMD
                    cmd_packet.byte[4] := core#OLED_CMDSET_ENA
                    cmd_packet.byte[5] := core#CTRLBYTE_CMD
                    cmd_packet.byte[6] := cmd
                    cmd_packet.byte[7] := core#CTRLBYTE_CMD ' Yes, command - not data
                    cmd_packet.byte[8] := val
                    cmd_packet.byte[9] := core#CTRLBYTE_CMD
                    cmd_packet.byte[10] := core#OLED_CMDSET_DIS
                    cmd_packet.byte[11] := core#CTRLBYTE_CMD
                    cmd_packet.byte[12] := core#CMDSET_FUNDAMENTAL | _disp_lines_N | _dblht_en
                    nr_bytes := 13

        TRANSTYPE_DATA:
            cmd_packet.byte[0] := SLAVE_WR | _sa0_addr
            cmd_packet.byte[1] := core#CTRLBYTE_DATA
            cmd_packet.byte[2] := val
            nr_bytes := 3

    i2c.start
    i2c.wr_block (@cmd_packet, nr_bytes)
    i2c.stop

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
