{
----------------------------------------------------------------------------------------------------
    Filename:       core.con.us2066.spin
    Description:    US2066-specific constants
    Author:         Jesse Burt
    Started:        Dec 30, 2017
    Updated:        Oct 10, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    SLAVE_ADDR          = $3C << 1 '$3C - Default slave address of US2066
    I2C_MAX_FREQ        = 400_000  '400kHz - Max operating freq

    TRES                = 2        ' Reset low width (microseconds)
    T_POR               = 1_000                 ' usec

    DEVID_RESP          = $21

    DATABIT             = $40
    CMDBIT              = $00
    CONTBIT             = $80
    CTRLBYTE_CMD        = CONTBIT | CMDBIT
    CTRLBYTE_DATA       = DATABIT

'Command set: (POR) indicates Power On Reset, or default value.
'-FUNDAMENTAL COMMAND SET-------
'SD bit set 0
    CLEAR_DISP          = $01      '$01 Clear Display
'RE bit set 0, SD bit set 0
    HOME_DISP           = $02      '$02 Return Home

'RE bit set 0, SD bit set 0
    ENTRY_MODE_SET      = $04      '$04 Entry Mode Set
    ENTRY_MODE_SET_MASK = $03
        ID              = 1
        ID_MASK         = (1 << ID) ^ ENTRY_MODE_SET_MASK
        S               = 0
        S_MASK          = 1 ^ ENTRY_MODE_SET_MASK
        LTR             = 1 << 1
        RTL             = 0 << 1
        SHIFT           = 1
        NOSHIFT         = 0       '(POR)

'RE bit set 1, SD bit set 0
    COM31_0             = %0 << 1
    COM0_31             = %1 << 1
    SEG99_0             = %0
    SEG0_99             = %1

'RE bit set 0, SD bit set 0
    DISP_ONOFF          = $08      '$08 Display ON/OFF, Cursor ON/OFF, Cursor Blink ON/OFF control
        DISP_ON         = %1 << 2
        DISP_OFF        = %0 << 2  '(POR)
        CURS_ON         = %1 << 1
        CURS_OFF        = %0 << 1  '(POR)
        BLINK_ON        = %1
        BLINK_OFF       = %0       '(POR)

'RE bit set 1, SD bit set 0
    EXTD_FUNCSET        = $08
        FNTWIDTH        = 2
        FNTWIDTH_6      = %1 << FNTWIDTH
        FNTWIDTH_5      = %0 << FNTWIDTH
        CURS_INVERT     = %1 << 1
        CURS_NORM       = %0 << 1  '(POR)
        NW_3_4_LINE     = %1
        NW_1_2_LINE     = %0

'IS bit set 0, RE bit set 0, SD bit set 0
    CURS_DISP_SHIFT     = $10      '$10 Set cursor moving and display shift control and direction (doesn't change DDRAM data)
        CURS_LEFT       = %00 << 2
        CURS_RIGHT      = %01 << 2
        DISP_LEFT       = %10 << 2
        DISP_RIGHT      = %11 << 2

'IS bit set 0, RE bit set 1, SD bit set 0
    DBLHT               = $10      '$10 Double-height font setting (POR=%xxxx_11xx)
        DBLHT_BOTTOM    = %00 << 2
        DBLHT_MIDDLE    = %01 << 2
        DBLHT_BOTH      = %10 << 2
        DBLHT_TOP       = %11 << 2
        DISP_SHIFT_EN   = %1
        DOT_SCROLL_EN   = %0       '(POR)

'IS bit set 1, RE bit set 1, SD bit set 0
    SHIFT_SCROLL_ENA    = $10      '$10 Set line(s) with display shift enabled (%1111 (POR). Shift when DH = 1, Scroll when DH = 0 (DISP_SHIFT_EN, DOT_SCROLL_EN)
        SHFT_SCRL_LINE1 = %1
        SHFT_SCRL_LINE2 = %1 << 1
        SHFT_SCRL_LINE3 = %1 << 2
        SHFT_SCRL_LINE4 = %1 << 3

'RE bit set 0, SD bit set 0
    FUNCT_SET_0         = $20      ' $20 Function set 0
        DISP_LINES_2_4  = %1 << 3
        DISP_LINES_1_3  = %0 << 3
        DBLHT_FNT_EN    = %1 << 2
        DBLHT_FNT_DIS   = %0 << 2  ' (POR)
        EXT_REG_RE      = %1 << 1  ' Extension register RE (POR 0)
        EXT_REG_IS      = %1       ' Extension register IS

    CMDSET_EXTD         = FUNCT_SET_0 | EXT_REG_RE
    CMDSET_FUND         = FUNCT_SET_0

'RE bit set 1, SD bit set 0
    FUNCT_SET_1         = $22      ' $22 Function set 1 (RE register 1)
    FUNCT_SET_1_MASK    = $0f
        N               = 3                     ' same as FUNCT_SET_0
        BE              = 2
        RE              = 1                     ' same as FUNCT_SET_0
        REV_EN          = 0
        BE_MASK         = (1 << BE) ^ FUNCT_SET_1_MASK
        REV_EN_MASK     = 1 ^ FUNCT_SET_1_MASK
        CGRAM_BLINK_EN  = 1 << BE
        CGRAM_BLINK_DIS = 0 << BE               ' POR
        REV_DISP        = 1 << REV_EN
        NORM_DISP       = 0 << REV_EN           ' POR

    SET_CGRAM_ADDR      = $40      ' $40 Set CGRAM address in address counter (POR=%00_0000)
    SET_DDRAM_ADDR      = $80      ' $80 Set DDRAM address in address counter (POR=%000_0000)
    SET_SCROLL_QTY      = $80      ' $80 (with RE bit set) Set the quantity of horizontal dot scroll (POR=%00_0000 - Maximum: %11_0000)

'-EXTENDED COMMAND SET---
''To use, first set RE to 1

    FUNCT_SEL_A         = $71      ' $71 Enable/Disable internal 5V regulator
        INT_REG_DIS     = $00
        INT_REG_EN      = $5C

    FUNCT_SEL_B         = $72      ' $72 %xxxx_ROM1_ROM0_OPR1_OPR0
    FUNCT_SEL_B_MASK    = $0f
        ROM             = 2
        ROM_BITS        = %11
        ROM_MASK        = (ROM_BITS << ROM) ^ FUNCT_SEL_B_MASK
        CHAR_ROM_A      = %00 << ROM
        CHAR_ROM_B      = %01 << ROM
        CHAR_ROM_C      = %10 << ROM
        OPR             = 0
        OPR_BITS        = %11
        OPR_MASK        = OPR_BITS ^ FUNCT_SEL_B_MASK
        CG_ROM240_RAM8  = %00
        CG_ROM248_RAM8  = %01
        CG_ROM250_RAM6  = %10
        CG_ROM256_RAM0  = %11

'-OLED COMMAND SET-----
    OLED_CHR            = $78      ' OLED Characterization
        OLED_CMDSET_ENA = OLED_CHR|%1       ' $79 %0111_100_1   SD = %1: OLED Command set enabled
        OLED_CMDSET_DIS = OLED_CHR|%0       ' $78 %0111_100_0   SD = %0: (POR) OLED Command set disabled

    SET_CONTRAST        = $81      ' $81 Select contrast. %0000_0000 .. %1111_1111 (POR %0111_1111)

    DISP_CLKDIV_OSC     = $D5
    DISP_CLKDIV_OSC_MASK= $FF
        OSC_FREQ        = 4
        CLK_DIV         = 0
        OSC_FREQ_BITS   = %1111
        CLK_DIV_BITS    = %1111
        OSC_FREQ_MASK   = (OSC_FREQ_BITS << OSC_FREQ) ^ DISP_CLKDIV_OSC_MASK
        CLK_DIV_MASK    = (CLK_DIV_BITS ^ DISP_CLKDIV_OSC_MASK)

    SET_PHASE_LEN       = $D9
    SET_PHASE_LEN_MASK  = $ff
        PHASE2          = 4
        PHASE1          = 0
        PHASE2_BITS     = %1111
        PHASE1_BITS     = %1111
        PHASE2_MASK     = (PHASE2_BITS << PHASE2) ^ SET_PHASE_LEN_MASK
        PHASE1_MASK     = PHASE1_BITS ^ SET_PHASE_LEN_MASK

    SET_SEG_PINS            = $DA      ' $DA Set SEG pins hardware configuration
    SET_SEG_PINS_MASK       = $30
        SEG_LR_REMAP        = 5
        SEG_PINCFG          = 4
        SEG_LR_REMAP_MASK   = (1 << SEG_LR_REMAP) ^ SET_SEG_PINS_MASK
        SEG_PINCFG_MASK     = (1 << SEG_PINCFG) ^ SET_SEG_PINS_MASK
        SEG_LR_REMAP_EN     = 1 << SEG_LR_REMAP
        SEG_LR_REMAP_DIS    = 0 << SEG_LR_REMAP
        ALT_SEGPINCFG       = 1 << SEG_PINCFG
        SEQ_SEGPINCFG       = 0 << SEG_PINCFG

    SET_VCOMH_DESEL     = $DB
    SET_VCOMH_DESEL_MASK= $70
        VCOMH           = 4
        VCOMH_BITS      = %111
        VCOMH_MASK      = (VCOMH_BITS << VCOMH) ^ SET_VCOMH_DESEL_MASK

    FUNCT_SEL_C         = $DC      ' $DC Set VSL/GPIO
    FUNCT_SEL_C_MASK    = $83
        VSL             = 7
        GPIO            = 0
        GPIO_BITS       = %11
        VSL_MASK        = (1 << VSL) ^ FUNCT_SEL_C_MASK
        GPIO_MASK       = GPIO_BITS ^ FUNCT_SEL_C_MASK

    FADE_BLINK          = $23      '$23 Set fade out and blinking.
    FADE_BLINK_MASK     = $3f
        FB_MODE         = 4
        FB_TIMEINT      = 0
        FB_MODE_BITS    = %11
        FB_TIMEINT_BITS = %1111
        FB_MODE_MASK    = (FB_MODE_BITS << FB_MODE) ^ FADE_BLINK_MASK
        FB_TIMEINT_MASK = (FB_TIMEINT_BITS << FB_TIMEINT) ^ FADE_BLINK_MASK


PUB null()
' This is not a top-level object


DAT
{
Copyright 2024 Jesse Burt

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

