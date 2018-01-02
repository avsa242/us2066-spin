{
    --------------------------------------------
    Filename:
    Author:
    Copyright (c) 20__
    See end of file for terms of use.
    --------------------------------------------
}

CON

  NHD           = %0111_100 << 1    '($78) - Default slave address of NHD420/US2066
  NHD_WR        = NHD | %0000_0000
  NHD_RD        = NHD | %0000_0001

OBJ

  us2066: "com.i2c.us2066"
  time  : "time"
  i2c   : "jm_i2c_fast"

VAR

  long delay

PUB null
'This is not a top-level object

PUB start(scl, sda, reset, hz): okay
' I2C Effective Bus rates from 1221 up to 400000
  okay := i2c.setupx (scl, sda, hz)

  dira[reset] := 1
  outa[reset] := 0

  outa[reset] := 1
  time.MSleep (10)
  i2c.setup (hz)
  time.MSleep (10)

  InternalReg(FALSE)
  Display(FALSE)
  
  SetClockDivOscFreq(7, 0)

  command(us2066#EXTENDED_FUNCSET | us2066#NW_3_4_LINE) 'extended function set (4-lines)
  command($06)                              'COM SEG direction
  command(us2066#FUNCTION_SEL_B)                   'function selection B, disable internal Vdd regualtor
  data($00)                                 'ROM CGRAM selection

  command(us2066#CMDSET_EXTENDED)                'function set (extended command set)
  command(us2066#OLED_CMDSET_ENA)                  'OLED command set enabled
  command(us2066#SET_SEG_PINS)                     'set SEG pins hardware configuration
  command($10)                              'set SEG pins hardware configuration
  command(us2066#FUNCTION_SEL_C)                   'function selection C
  command(us2066#VSL_INTERNAL | us2066#GPIO_HIZ_INDIS)    'function selection C
  command(us2066#SET_CONTRAST)                     'set contrast control
  command($7F)                              'set contrast control
  command(us2066#SET_PHASE_LEN)                    'set phase length
  command($F1)                              'set phase length
  command(us2066#SET_VCOMH_DESEL)                  'set VCOMH deselect level
  command($40)                              'set VCOMH deselect level
  command(us2066#OLED_CMDSET_DIS)                  'OLED command set disabled

  command(us2066#CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
  command(us2066#CLEAR_DISPLAY)                    'clear display
  command($80)                              'set DDRAM address to $00
  command(us2066#US2066_DISP_ON)                   'display ON
  time.MSleep(100)

PUB stop

  i2c.terminate

PUB Char_Literal(ch) 'WORKS

  data(ch)

PUB Char(ch) 'WORKS

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

PUB DoubleHeight(Mode) 'WORKS

  command(us2066#CMDSET_EXTENDED)
  command(us2066#US2066_EXT_FUNCSET | us2066#FONTWIDTH_5 | us2066#CURSOR_NORMAL | us2066#NW_3_4_LINE)
  case (Mode)
    0:                            ' Normal 4-line
      command(us2066#CMDSET_FUNDAMENTAL)
    1:                            ' Bottom half double-height
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_BOTTOM)
      command(us2066#US2066_FUNCSET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    2:                            ' Middle Double-Height
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_MIDDLE)
      command(us2066#US2066_FUNCSET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    3:                            ' Both top & bottom double-height (2 lines)
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_BOTH)
      command(us2066#US2066_FUNCSET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    4:                            ' Top Double-Height
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_TOP)
      command(us2066#US2066_FUNCSET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    OTHER:
      command(us2066#CMDSET_FUNDAMENTAL)

PUB GetPos: addr | data_in
'Gets current position in DDRAM
  command($00)
  i2c.start
  i2c.write (NHD_RD)
  addr := i2c.read (TRUE)
  i2c.stop

PUB Home 'WORKS

  command(us2066#HOME_DISPLAY)

PUB Newline: row | pos
' The display controller doesn't seem to handle newline by itself, so we have to implement it in software
' We query the controller for the current cursor position in its DDRAM and make a decision 
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
      command(us2066#US2066_DISP_ONOFF | us2066#DISP_ON | us2066#CURSOR_OFF | us2066#BLINK_OFF)
    1:
      command(us2066#US2066_DISP_ONOFF | us2066#DISP_ON | us2066#CURSOR_OFF | us2066#BLINK_ON)
    2:
      command(us2066#US2066_DISP_ONOFF | us2066#DISP_ON | us2066#CURSOR_ON | us2066#BLINK_OFF)
    3:
      command(us2066#US2066_DISP_ONOFF | us2066#DISP_ON | us2066#CURSOR_ON | us2066#BLINK_ON)
    OTHER:
      command(us2066#US2066_DISP_ONOFF | us2066#DISP_ON | us2066#CURSOR_OFF | us2066#BLINK_OFF)

PUB Str(stringptr) 'WORKS
{{
    Send zero-terminated string.
    Parameter:
        stringptr - pointer to zero terminated string to send.
}}

  repeat strsize(stringptr)
    Char(byte[stringptr++])

PRI command(cmd) | ackbit

  i2c.start
  ackbit := i2c.write (NHD_WR)            'US2066 Slave address
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
  ackbit := i2c.write (NHD_WR)            'US2066 Slave address
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

PRI Display(enable)

  if enable
    command(us2066#CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
    command(us2066#US2066_DISP_ONOFF | us2066#DISP_ON)
  else
    command(us2066#CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
    command(us2066#US2066_DISP_ONOFF | us2066#DISP_OFF)
  
PRI InternalReg(enable)

  if enable
    command(us2066#CMDSET_EXTENDED)                'function set (extended command set)
    command(us2066#FUNCTION_SEL_A)                   'function selection A, disable internal Vdd regualtor
    data(us2066#INT_REG_ENABLE)
  else
    command(us2066#CMDSET_EXTENDED)                'function set (extended command set)
    command(us2066#FUNCTION_SEL_A)                   'function selection A, disable internal Vdd regualtor
    data(us2066#INT_REG_DISABLE)

PRI SetClockDivOscFreq(Frequency, Divisor)

  if Divisor =< %1111 AND Frequency =< %1111  
    command(us2066#CMDSET_EXTENDED)                'function set (extended command set)
    command(us2066#OLED_CMDSET_ENA)                  'OLED command set enabled
    command(us2066#DISP_CLKDIV_OSC)                  'set display clock divide ratio/oscillator frequency
    command((Frequency<<4) | Divisor)                              'set display clock divide ratio/oscillator frequency
    command(us2066#OLED_CMDSET_DIS)                  'OLED command set disabled
  else
    return

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
