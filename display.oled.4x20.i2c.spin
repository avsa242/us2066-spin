{
    --------------------------------------------
    Filename: display.oled.4x20.i2c.spin
    Author: Jesse Burt
    Version: 0.1
    Description: Object for driving displays
     based on the US2066 driver, such as
     Newhaven Display's NHD-0420CW-A*3
    Copyright (c) 2018
    See end of file for terms of use.
    --------------------------------------------
}

CON

  SLAVE_ADDR    =              %0111_100 << 1    '($78) - Default slave address of NHD420/US2066
  SLAVE_WR      = SLAVE_ADDR | %0000_0000
  SLAVE_RD      = SLAVE_ADDR | %0000_0001

OBJ

  us2066: "core.con.us2066"
  time  : "time"
  i2c   : "jm_i2c_fast"

VAR

  long delay

PUB null
'This is not a top-level object

PUB start(scl, sda, reset, hz): okay
' I2C Effective Bus rates from 1221 up to 400000
  okay := i2c.setupx (scl, sda, hz)

  'dira[reset] := 1
  'outa[reset] := 0

  'outa[reset] := 1
  'time.MSleep (1)
{
  command(us2066#EXTENDED_FUNCSET | us2066#NW_3_4_LINE) 'extended function set (4-lines)
  command($06)                                          'COM SEG direction
  command(us2066#FUNCTION_SEL_B)                        'function selection B, disable internal Vdd regualtor
  data($00)                                             'ROM CGRAM selection

  command(us2066#CMDSET_EXTENDED)                       'function set (extended command set)
  command(us2066#OLED_CMDSET_ENA)                       'OLED command set enabled
  command(us2066#SET_SEG_PINS)                          'set SEG pins hardware configuration
  command($10)                                          'set SEG pins hardware configuration
  command(us2066#FUNCTION_SEL_C)                        'function selection C
  command(us2066#VSL_INTERNAL | us2066#GPIO_HIZ_INP_DIS)'function selection C
  command(us2066#SET_CONTRAST)                          'set contrast control
  command($7F)                                          'set contrast control
  command(us2066#SET_PHASE_LEN)                         'set phase length
  command($F1)                                          'set phase length
  command(us2066#SET_VCOMH_DESEL)                       'set VCOMH deselect level
  command($40)                                          'set VCOMH deselect level
  command(us2066#OLED_CMDSET_DIS)                       'OLED command set disabled

  command(us2066#CMDSET_FUNDAMENTAL)                    'function set (fundamental command set)
  command(us2066#CLEAR_DISPLAY)                         'clear display
  command($80)                                          'set DDRAM address to $00
  command(us2066#US2066_DISP_ON)                        'display ON
  time.MSleep(100)
}
PUB stop

  i2c.terminate

PUB Char_Literal(ch) 'WORKS
'' Display single character (pass data through)

  data(ch)

PUB Char(ch) 'WORKS
'' Display single character. Display controller doesn't handle newline
''  on its own, so we have to implement one.
  case ch
    10, 13:
      Newline
    OTHER:
      data(ch)

PUB Clear 'WORKS

  command(us2066#CLEAR_DISPLAY)

PUB ClearLine(line) 'WORKS

  if lookdown (line: 0..4)
    Position(0, line)
    repeat 20
      Char(" ")

PUB Display(enable)

  if enable
    command(us2066#CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
    command(us2066#DISPLAY_ONOFF | us2066#DISP_ON)
  else
    command(us2066#CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
    command(us2066#DISPLAY_ONOFF | us2066#DISP_OFF)

PUB DoubleHeight(Mode) 'WORKS

  command(us2066#CMDSET_EXTENDED)
  command(us2066#EXTENDED_FUNCSET | us2066#FONTWIDTH_5 | us2066#CURSOR_NORMAL | us2066#NW_3_4_LINE)
  case (Mode)
    0:                            ' Normal 4-line
      command(us2066#CMDSET_FUNDAMENTAL)
    1:                            ' Bottom half double-height
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_BOTTOM)
      command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    2:                            ' Middle Double-Height
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_MIDDLE)
      command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    3:                            ' Both top & bottom double-height (2 lines)
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_BOTH)
      command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    4:                            ' Top Double-Height
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_TOP)
      command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    OTHER:
      command(us2066#CMDSET_FUNDAMENTAL)

PUB GetPos: addr | data_in
'Gets current position in DDRAM
  command($00)
  i2c.start
  i2c.write (SLAVE_RD)
  addr := i2c.read (TRUE)
  i2c.stop

PUB Home 'WORKS

  command(us2066#HOME_DISPLAY)


PUB Newline: row | pos
'' The display controller doesn't seem to handle newline by itself, so we have to implement it in software
'' We query the controller for the current cursor position in its DDRAM and make a decision as to which
  pos := GetPos
  case pos
    $00..$13: row := 0
    $20..$33: row := 1
    $40..$53: row := 2
    $60..$73: row := 3
    OTHER: row := 0     'Not sure how else to handle this, atm

  row := (row + 1) & 3
  Position (0, row)

PUB Position(column, row) | offset 'WORKS

  case row
    0: offset := $00 + column <# $13
    1: offset := $20 + column <# $33
    2: offset := $40 + column <# $53
    3: offset := $60 + column <# $73
    OTHER: offset := 0

  command(us2066#SET_DDRAM_ADDR|offset )

PUB SetContrast(level)
'' level: 00..$FF (POR $7F)
  level := (||level <# $FF)

  CMDSet_Extended
  CMDSet_OLED (TRUE)
  command(us2066#SET_CONTRAST)
  command(level)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB SetCharGenCharROM(char_gen, char_rom)
'' char_gen:  %00 CGROM: 240 CGRAM: 8
''            %01 CGROM: 248 CGRAM: 8
''            %10 CGROM: 250 CGRAM: 6
''            %11 CGROM: 256 CGRAM: 0
'' char_rom:  %00 ROM A
''            %01 ROM B
''            %10 ROM C
''            %11 Invalid (ignored)
  char_gen := (||char_gen <# 3)
  char_rom := (||char_rom <# 2) << 2
  
  CMDSet_Extended
  command(us2066#FUNCTION_SEL_B)
  data(char_gen | char_rom)
  CMDSet_Fundamental

PUB SetCursor(type) 'WORKS, BUT NOT AS EXPECTED
{{
    Selects cursor type

    - 0 : cursor off, blink off
    - 1 : cursor off, blink on
    - 2 : cursor on, blink off
    - 3 : cursor on, blink on
}}
  case type
    0:
      command(us2066#DISPLAY_ONOFF | us2066#DISP_ON | us2066#CURSOR_OFF | us2066#BLINK_OFF)
    1:
      command(us2066#DISPLAY_ONOFF | us2066#DISP_ON | us2066#CURSOR_OFF | us2066#BLINK_ON)
    2:
      command(us2066#DISPLAY_ONOFF | us2066#DISP_ON | us2066#CURSOR_ON | us2066#BLINK_OFF)
    3:
      command(us2066#DISPLAY_ONOFF | us2066#DISP_ON | us2066#CURSOR_ON | us2066#BLINK_ON)
    OTHER:
      command(us2066#DISPLAY_ONOFF | us2066#DISP_ON | us2066#CURSOR_OFF | us2066#BLINK_OFF)

PUB SetDisplayCursorBlink(disp_onoff, cursor_onoff, blink_onoff)
'' disp_onoff:    %0: Display Off (POR)   %1: Display On
'' cursor_onoff:  %0: Cursor Off (POR)    %1: Cursor On
'' blink_onoff:   %0: Blink Off (POR)     %1: Blink On

  disp_onoff := (||disp_onoff <# 1) << 2
  cursor_onoff := (||cursor_onoff <# 1) << 1
  blink_onoff := (||blink_onoff <# 1)
  
  command(us2066#DISPLAY_ONOFF | disp_onoff | cursor_onoff | blink_onoff)

PUB SetClockDivOscFreq(frequency, divisor)
' divisor:    DCLKs   Range %0000..%1111 (POR %0000) 
' frequency:  (Freq)  Range %0000..%1111 (POR %0111)

  CMDSet_Extended
  CMDSet_OLED (TRUE)

  frequency := (||frequency <# 15) << 4
  divisor   := (||divisor <# 15)

  command(us2066#DISP_CLKDIV_OSC)
  command(frequency | divisor)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB SetBiDirection(com, seg)
'' Common (com) and Segment (seg) Bi-direction function
'' com: %1: COM0 -> COM31   %0: COM31 -> COM0
'' seg: %1: SEG99 -> SEG0   %1: SEG0 -> SEG99
  com := (||com <# 1) << 1
  seg := (||seg <# 1)
  
  CMDSet_Extended
  command(us2066#ENTRY_MODE_SET | com | seg)
  CMDSet_Fundamental

PUB SetDisplayLines(lines)

  case lines
    1: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_1_3)
    2: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4)
    3: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_1_3)
    4: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4)
    OTHER: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4)

PUB SetFontCursorLineMode(fw_fontwidth, bw_cursor_inverting, nw_4line_dispmode)
'' FW:  %1: 6-dot font width            %0: 5-dot font width (POR)
'' BW:  %1: B/W cursor invert enabled   %0: B/W cursor invert disabled (POR)
'' NW:  %1: 3 or 4-line display mode    %0: 1 or 2-line display mode
  fw_fontwidth :=         (||fw_fontwidth         <# 1) << 2
  bw_cursor_inverting :=  (||bw_cursor_inverting  <# 1) << 1
  nw_4line_dispmode :=    (||nw_4line_dispmode    <# 1)
  
  CMDSet_Extended
  command(us2066#EXTENDED_FUNCSET | fw_fontwidth | bw_cursor_inverting | nw_4line_dispmode)
  CMDSet_Fundamental

PUB SetInternalReg(enable)
' Enables the internal regulator (5V operation) if non-zero, disables it otherwise (low-voltage operation)

    CMDSet_Extended
    command(us2066#FUNCTION_SEL_A)
    case enable                           'This method was written differently from the others that set registers
      0:     data($00)                    ' because of the two possible states: $00 or $5C, rather than a simple $00 or $01
      OTHER: data(us2066#INT_REG_ENABLE)
    CMDSet_Fundamental

PUB SetPhaseLength(phase2, phase1)
'' phase2:  1..15 (1 to 15 DCLK, 0 is invalid and ignored, POR=7)   phase1: 0..15 (0 to 32 DCLK)

  phase2  := (1#> ||phase2 <# 15) << 4
  phase1  := (||phase1 <# 15) << 1

  CMDSet_Extended
  CMDSet_OLED (TRUE)
  command(us2066#SET_PHASE_LEN)
  command(phase2 | phase1)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental
  
PUB SetSEGPinCFG(seg_lr_remap, pin_cfg)
'' seg_lr_remap:  %0: Disable SEG left/right remap  %1: Enable SEG left/right remap
'' pin_cfg:       %0: Sequential SEG pin cfg        %1: Alternative (odd/even) SEG pin cfg

  seg_lr_remap  := (||seg_lr_remap <# 1) << 5
  pin_cfg       := (||pin_cfg <# 1) << 4

  CMDSet_Extended
  CMDSet_OLED (TRUE)  
  command(us2066#SET_SEG_PINS)
  command(seg_lr_remap | pin_cfg)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB SetVcomhDeselectLevel(level)
'' level: %000: ~0.65*Vcc
''        %001: ~0.71*Vcc
''        %010: ~0.77*Vcc (POR)
''        %011: ~0.83*Vcc
''        %100: 1*Vcc
  level := (||level <# 4) << 4

  CMDSet_Extended
  CMDSet_OLED (TRUE)
  command(us2066#SET_VCOMH_DESEL)
  command(level)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB SetVSLGPIO(vsl, gpio)
'' vsl:    %0: Internal VSL (POR)  %1: Enable external VSL
'' gpio:  %00: GPIO pin HiZ, input disabled (always read as low)
'' gpio:  %01: GPIO pin HiZ, input enabled
'' gpio:  %10: GPIO pin output, low (RESET)
'' gpio:  %11: GPIO pin output, high 
  vsl   := (||vsl <# 1) << 7
  gpio  := (||gpio <# 3)
  
  CMDSet_Extended
  CMDSet_OLED (TRUE)
  command(us2066#FUNCTION_SEL_C)
  command(vsl | gpio)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB CMDSet_Extended

  command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#EXT_REG_RE)

PUB CMDSet_Fundamental

  command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4)

PUB CMDSet_OLED(enabled)
'' enable: %0: OLED command set is disabled (POR)   %1: OLED command set is enabled
  enabled := (||enabled <# 1)
  command(us2066#OLED_CHARACTERIZE | enabled)

PUB SetupBlob ' TO BE BROKEN OUT INTO METHODS

'  command(us2066#EXTENDED_FUNCSET | us2066#NW_3_4_LINE) 'extended function set (4-lines)
  command(us2066#ENTRY_MODE_SET | us2066#COM0_31)                              'COM SEG direction
  command(us2066#FUNCTION_SEL_B)                   'function selection B, disable internal Vdd regualtor
  data($00)                                 'ROM CGRAM selection

  command(us2066#CMDSET_EXTENDED)                'function set (extended command set)
'  command(us2066#OLED_CMDSET_ENA)                  'OLED command set enabled
  CMDSet_OLED (TRUE)
  command(us2066#SET_SEG_PINS)                     'set SEG pins hardware configuration
  command($10)                              'set SEG pins hardware configuration
  command(us2066#FUNCTION_SEL_C)                   'function selection C
  command(us2066#VSL_INTERNAL | us2066#GPIO_HIZ_INP_DIS)    'function selection C
  command(us2066#SET_CONTRAST)                     'set contrast control
  command($7F)                              'set contrast control
  command(us2066#SET_PHASE_LEN)                    'set phase length
  command($F1)                              'set phase length
  command(us2066#SET_VCOMH_DESEL)                  'set VCOMH deselect level
  command($40)                              'set VCOMH deselect level
'  command(us2066#OLED_CMDSET_DIS)                  'OLED command set disabled
  CMDSet_OLED (FALSE)
  command(us2066#CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
  command(us2066#CLEAR_DISPLAY)                    'clear display
  command($80)                              'set DDRAM address to $00
  command(us2066#US2066_DISP_ON)                   'display ON
  time.MSleep(100)

PUB Str(stringptr) 'WORKS
{{
    Send zero-terminated string.
    Parameter:
        stringptr - pointer to zero terminated string to send.
}}

  repeat strsize(stringptr)
    Char(byte[stringptr++])


PUB Str_Literal(stringptr) 'WORKS
{{
    Send zero-terminated string. Don't interpret characters for meaning, just send them.
    Parameter:
        stringptr - pointer to zero terminated string to send.
}}

  repeat strsize(stringptr)
    Char_Literal(byte[stringptr++])

PUB StrDelay(stringptr) 'WORKS
{{
    Send zero-terminated string with inter-character delay.
    Parameter:
        stringptr - pointer to zero terminated string to send.
}}

  repeat strsize(stringptr)
    Char(byte[stringptr++])
    time.MSleep (delay)

PUB StrDelay_Literal(stringptr) 'WORKS
{{
    Send zero-terminated string. Don't interpret characters for meaning, just send them.
    Parameter:
        stringptr - pointer to zero terminated string to send.
}}

  repeat strsize(stringptr)
    Char_Literal(byte[stringptr++])
    time.MSleep (delay)

PRI command(cmd) | ackbit

  i2c.start
  ackbit := i2c.write (SLAVE_WR)            'US2066 Slave address
  if ackbit == i2c#ACK
    ackbit := i2c.write (us2066#CTRLBYTE_CMD)    'US2066 Control Byte: Command
  else
    i2c.stop
    return ackbit                         'NAK

  if ackbit == i2c#ACK
    ackbit := i2c.write (cmd)
  else
    i2c.stop
    return ackbit                         'NAK
  i2c.stop

PRI data(databyte) | ackbit

  i2c.start
  ackbit := i2c.write (SLAVE_WR)            'US2066 Slave address
  if ackbit == i2c#ACK
    ackbit := i2c.write (us2066#CTRLBYTE_DATA)    'US2066 Control Byte: Command
  else
    i2c.stop
    return ackbit                         'NAK

  if ackbit == i2c#ACK
    ackbit := i2c.write (databyte)
  else
    i2c.stop
    return ackbit                         'NAK
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
