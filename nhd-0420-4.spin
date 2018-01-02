{
    --------------------------------------------
    Filename:
    Author:
    Copyright (c) 20__
    See end of file for terms of use.
    --------------------------------------------
}

CON

  _clkmode  = cfg#_clkmode
  _xinfreq  = cfg#_xinfreq

  SCL           = 28
  SDA           = 29
  RESET         = 26
  I2C_RATE      = 400_000

  NHD           = %0111_100 << 1    '($78) - Default slave address of NHD420/US2066
  NHD_WR        = NHD | %0000_0000
  NHD_RD        = NHD | %0000_0001


OBJ

  cfg   : "config.flip"
  ser   : "com.serial.terminal"
  time  : "time"
  i2c   : "jm_i2c_fast"
  us2066: "com.i2c.us2066"
  debug : "debug"

VAR

  long delay

PUB Main | i, j, ackbit, data_in

  delay := 50
  setup
'WORKS: CLEAR, HOME, RTL, LTR, COM31_0, COM0_31, DISPLAY_ONOFF, DISP_ON, DISP_OFF, CURSOR_ON, BLINK_ON
  ser.Str (string("Running..."))
  time.MSleep (500)
  command(us2066#DISPLAY_ONOFF | us2066#DISP_ON | us2066#CURSOR_ON | us2066#BLINK_ON)

'  repeat
    Clear
    time.Sleep (1)
 '   StrDelay (string("Contrast test..."))
    output1to4_test
'    contrast_test
    dump_display
  debug.LEDFast (cfg#LED2)

PUB newline_test
    Str(string("Test", 13))
    time.mSleep (100)
    Str(string("1234", 13))
    time.mSleep (100)
    Str(string("5678", 13))
    time.mSleep (100)
    Str(string("9ABC", 13))
    time.mSleep (100)
    Str(string("DEF1", 13))


PUB pos_test | i, j

  repeat
    repeat i from 0 to 3
      repeat j from 0 to 19
        Position(j, i)
        Char($20)
        Char("-")
        time.MSleep (10)


PUB dblht_test

  DoubleHeight(0)
  Position(0, 0)
  Str(string("Testing"))
  Position(0, 1)
  Str(string("Mode 0"))
  Position(0, 2)
  Str(string("Line 3"))
  Position(0, 3)
  Str(string("Line 4"))
  time.Sleep (2)
  Clear
    
  DoubleHeight(1)
  Position(0, 0)
  Str(string("Testing"))
  Position(0, 1)
  Str(string("Mode 1"))
  Position(0, 2)
  Str(string("Line 3"))
  Position(0, 3)
  Str(string("Line 4"))
  time.Sleep (2)
  Clear

  DoubleHeight(2)
  Position(0, 0)
  Str(string("Testing"))
  Position(0, 1)
  Str(string("Mode 2"))
  Position(0, 2)
  Str(string("Line 3"))
  Position(0, 3)
  Str(string("Line 4"))
  time.Sleep (2)
  Clear

  DoubleHeight(3)
  Position(0, 0)
  Str(string("Testing"))
  Position(0, 1)
  Str(string("Mode 3"))
  Position(0, 2)
  Str(string("Line 3"))
  Position(0, 3)
  Str(string("Line 4"))
  time.Sleep (2)
  Clear
  
  DoubleHeight(4)
  Position(0, 0)
  Str(string("Testing"))
  Position(0, 1)
  Str(string("Mode 4"))
  Position(0, 2)
  Str(string("Line 3"))
  Position(0, 3)
  Str(string("Line 4"))
  time.Sleep (2)
  Clear

PUB contrast_test | i

  command(us2066# FUNCTION_SET_0 | us2066#EXT_REG_RE )
  command(us2066# OLED_CMDSET_ENA )
  
  repeat i from 0 to 255 step 16
    command( $81 )
    command( i )
    ser.Str (string("Contrast level "))
    ser.Dec (i)
    ser.NewLine
    time.MSleep (250)

  repeat i from 255 to 0 step 16
    command( $81 )
    command( i )

    ser.Str (string("Contrast level "))
    ser.Dec (i)
    ser.NewLine
    time.MSleep (250)
  
  command(us2066# OLED_CMDSET_DIS )
  command(us2066# FUNCTION_SET_0 )
  
PUB dump_display | r, c, ackbit, data_in

  ser.Str (string("Dump display data: ", ser#NL))
  
  i2c.start
  ackbit := i2c.write (NHD_RD)        'Dummy read first byte, according to p.40, sec 7.1.15
  i2c.read (TRUE)

  repeat r from 0 to 3
    ser.Dec (r)
    ser.Str (string(": "))
    repeat c from 0 to 19
      i2c.start
      ackbit := i2c.write (NHD_RD)
      data_in := i2c.read (TRUE)
      ser.Char (data_in)
'      ser.Hex (data_in, 2)
'      ser.Char (" ")
    ser.NewLine
  i2c.stop

PUB home_test | i 'WORKS

  command($01)
  time.MSleep(2)
  repeat i from 0 to 19
    data(text1.byte[i])

  time.MSleep (2000)
  
  command($02)
  repeat i from 0 to 19
    data(text2.byte[i])

  time.MSleep (2000)

PUB output1to4_test | i

  command($01)
  time.MSleep(2)
  repeat i from 0 to 19
    data(line1.byte[i])
  command($A0)
  repeat i from 0 to 19
    data(line2.byte[i])
  command($C0)
  repeat i from 0 to 19
    data(line3.byte[i])
  command($E0)
  repeat i from 0 to 19
    data(line4.byte[i])


PUB output_test | i 'WORKS

  command($01)
  time.MSleep(2)
  repeat i from 0 to 19
    data(text1.byte[i])

  command($A0)
  repeat i from 0 to 19
    data(text2.byte[i])

  command($C0)
  repeat i from 0 to 19
    data(text3.byte[i])

  command($E0)
  repeat i from 0 to 19
    data(text4.byte[i])

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

PUB GetPos: addr | data_in
'Gets current position in DDRAM
  command($00)
  i2c.start
  i2c.write (NHD_RD)
  addr := i2c.read (TRUE)
  i2c.stop
  

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

PUB Char(ch) 'WORKS

  case ch
    10, 13:
      Newline
    OTHER:
      data(ch)

PUB Str(stringptr) 'WORKS
{{
    Send zero-terminated string.
    Parameter:
        stringptr - pointer to zero terminated string to send.
}}

  repeat strsize(stringptr)
    Char(byte[stringptr++])

PUB StrDelay(stringptr) 'WORKS
{{
    Send zero-terminated string with inter-character delay.
    Parameter:
        stringptr - pointer to zero terminated string to send.
}}

  repeat strsize(stringptr)
    Char(byte[stringptr++])
    time.MSleep (delay)

PUB Clear 'WORKS

  command(us2066#CLEAR_DISPLAY)

PUB Home 'WORKS

  command(us2066#HOME_DISPLAY)

PUB ClearLine(line) 'WORKS

  if lookdown (line: 0..4)
    Position(0, line)
    repeat 20
      Char(" ")

PUB SetCursor(type)
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


PUB Position(column, row) | offset 'WORKS

  case row
    0: offset := $00 + column <# $13
    1: offset := $20 + column <# $33
    2: offset := $40 + column <# $53
    3: offset := $60 + column <# $73
    OTHER: offset := 0

  command(us2066# SET_DDRAM_ADDR|offset )


PUB command(cmd) | ackbit

  i2c.start
  ackbit := i2c.write (NHD_WR)            'US2066 Slave address
  if ackbit == i2c#ACK
    ackbit := i2c.write (us2066#CTRLBYTE_CMD)    'US2066 Control Byte: Command
  else
    i2c.stop
    ser.Str (string("OLED NAKed!", ser#NL))
    return ackbit                         'NAK

  if ackbit == i2c#ACK
    ackbit := i2c.write (cmd)
  else
    i2c.stop
    ser.Str (string("OLED NAKed!", ser#NL))
    return ackbit                         'NAK
  i2c.stop

  if ackbit == i2c#NAK
    ser.Str (string("OLED NAKed!", ser#NL))

PUB data(databyte) | ackbit

  i2c.start
  ackbit := i2c.write (NHD_WR)            'US2066 Slave address
  if ackbit == i2c#ACK
    ackbit := i2c.write (us2066#CTRLBYTE_DATA)    'US2066 Control Byte: Command
  else
    i2c.stop
    ser.Str (string("OLED NAKed!", ser#NL))
    return ackbit                         'NAK

  if ackbit == i2c#ACK
    ackbit := i2c.write (databyte)
  else
    i2c.stop
    ser.Str (string("OLED NAKed!", ser#NL))
    return ackbit                         'NAK
  i2c.stop

  if ackbit == i2c#NAK
    ser.Str (string("OLED NAKed!", ser#NL))

PUB Display(enable)

  if enable
    command(us2066#CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
    command(us2066#DISPLAY_ONOFF | us2066#DISP_ON)
  else
    command(us2066#CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
    command(us2066#DISPLAY_ONOFF | us2066#DISP_OFF)
  
PUB InternalReg(enable)
' Enables the internal regulator (5V operation) if non-zero, disables it otherwise (low-voltage operation)
  if enable
    command(us2066#CMDSET_EXTENDED)                'function set (extended command set)
    command(us2066#FUNCTION_SEL_A)                   'function selection A, disable internal Vdd regualtor
    data(us2066#INT_REG_ENABLE)
  else
    command(us2066#CMDSET_EXTENDED)                'function set (extended command set)
    command(us2066#FUNCTION_SEL_A)                   'function selection A, disable internal Vdd regualtor
    data(us2066#INT_REG_DISABLE)

PUB SetClockDivOscFreq(Frequency, Divisor)
'  DISP_CLKDIV_OSC = $D5 ' %A7..A0
' %A3..A0: Define divide ratio (D) of display clocks (DCLK): divide ratio = %A3..A0 + 1 (POR %0000) Range %0000-%1111
' %A7..A4: Set oscillator frequency, Fosc. Oscillator frequency increases with the value of %A7..A4 (POR %0111) Range %0000-%1111
  if Divisor =< %1111 AND Frequency =< %1111  
    command(us2066#CMDSET_EXTENDED)                'function set (extended command set)
    command(us2066#OLED_CMDSET_ENA)                  'OLED command set enabled
    command(us2066#DISP_CLKDIV_OSC)                  'set display clock divide ratio/oscillator frequency
    command((Frequency<<4) | Divisor)                              'set display clock divide ratio/oscillator frequency
    command(us2066#OLED_CMDSET_DIS)                  'OLED command set disabled
  else
    return

PUB Setup

  dira[cfg#LED1] := 1
  dira[cfg#LED2] := 1

  dira[RESET] := 1
  outa[RESET] := 0

  ser.Start (115_200)

  ser.Clear
  
  outa[RESET] := 1
  time.MSleep (10)
  i2c.setup (I2C_RATE)
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
  command(us2066#VSL_INTERNAL | us2066#GPIO_HIZ_INP_DIS)    'function selection C
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

'  ser.Clear
  ser.Str (string("I2C Bus setup on SCL: "))
  ser.Dec (SCL)
  ser.Str (string(", SDA: "))
  ser.Dec (SDA)
  ser.Str (string(" @"))
  ser.Dec (I2C_RATE/1000)
  ser.Str (string("kHz", ser#NL))
  ser.Str (string("Press any key when ready.", ser#NL))
  ser.CharIn

DAT

  line1 byte "1------------------1", 0
  line2 byte "2------------------2", 0
  line3 byte "3------------------3", 0
  line4 byte "4------------------4", 0
  
  text1 byte "Newhaven Display----", 0
  text2 byte "TEST----------------", 0
  text3 byte "16/20 Characters----", 0
  text4 byte "!@#$%^&*()_+{}[]<>?~", 0

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
