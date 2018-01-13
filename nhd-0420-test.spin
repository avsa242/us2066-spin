{
    --------------------------------------------
    Filename: nhd-0420-test.spin
    Author: Jesse Burt
    Description: Test fixture for to exercise various
     US2066 functions on the NHD-0420 OLED display
    Copyright (c) 2018
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

  SLAVE_ADDR    =              %0111_100 << 1    '($78) - Default slave address of NHD420/US2066
  SLAVE_WR      = SLAVE_ADDR | %0000_0000
  SLAVE_RD      = SLAVE_ADDR | %0000_0001


OBJ

  cfg   : "core.con.client.flip"
  ser   : "com.serial.terminal"
  time  : "time"
  debug : "debug"
  oled  : "display.oled.4x20.i2c-pasm"
  int   : "string.integer"

VAR

  long delay

PUB Main | i, j, ackbit, data_in

  delay := 10
  setup

  ser.Str (string("Running..."))
  oled.SetDisplayCursorBlink (TRUE, FALSE, FALSE)
  oled.SetDoubleHeight(3)

'  oled.SetShiftScroll (%0000)
  repeat
    repeat i from 48 to 0
      oled.SetScrollQty (i)
      oled.Position (0, 0)
      oled.Str (string("Scrolling"))
      time.MSleep (30)
{
    oled.Clear

    repeat i from 48 to 0
      oled.SetScrollQty (i)
      oled.Position (10, 0)
      oled.Str (string("Scrolling"))
      time.MSleep (30)
    oled.Clear
}
  repeat
'    oled.Position(0, 0)
'    oled.Str(int.Hex(ser.CharIn, 2))

  debug.LEDFast (cfg#LED2)

PUB cr_test

  oled.StrDelay (string("Testing 1 2 3 CR"), 50)
  time.Sleep (2)
  oled.CarriageReturn
  time.Sleep (2)
  oled.Clear

PUB all_chars_test | i

  repeat i from 0 to 255
    oled.Char_Literal (i)
    time.MSleep (delay)

PUB count_test | i

  repeat i from 0 to 65535
    oled.Position (0, 0)
    oled.Str (string("i = "))
    oled.Str (int.Dec (i))

PUB delaychar_test

  oled.StrDelay (string("This is a test of"), delay)
  oled.Newline
  oled.StrDelay (string("the StrDelay method"), delay)
  
PUB newline_test

    oled.Str(string("Test", 13))
    time.mSleep (delay)
    oled.Str (@line1)
    time.mSleep (delay)
    oled.Str (@line2)
    time.mSleep (delay)
    oled.Str (@line3)
    time.mSleep (delay)
    oled.Str (@line4)

PUB pos_test | x, y

  repeat y from 0 to 3
    repeat x from 0 to 19
      oled.Position(0, 0)
      oled.Str (string("Position "))
      oled.Str (int.DecPadded(x, 2))
      oled.Char_Literal (" ")
      oled.Str (int.Dec(y))
      oled.Position(x, y)
      oled.Char($20)
      oled.Char("-")
      time.MSleep (50)

PUB dblht_test | mode, line

  repeat mode from 0 to 4
    oled.SetDoubleHeight (mode)
    oled.Position (14, 0)
    oled.Str (string("Mode "))
    oled.Str (int.Dec(mode))
    repeat line from 0 to 3
      oled.Position (0, line)
      oled.Str (string("Line "))
      oled.Str (int.Dec(line))
    time.Sleep (2)

PUB contrast_test | i

  repeat i from 0 to 255 step 16
    oled.SetContrast (i)
    oled.Position (0, 0)
    oled.Str (string("Contrast level "))
    oled.Str (int.DecPadded (i, 3))
    time.MSleep (250)

  repeat i from 255 to 0 step 16
    oled.SetContrast (i)
    oled.Position (0, 0)
    oled.Str (string("Contrast level "))
    oled.Str (int.DecPadded (i, 3))
    time.MSleep (250)
  
PUB home_test | i 'WORKS

  oled.Clear
  time.MSleep(2)
  repeat i from 0 to 19
    oled.Char(text1.byte[i])

  time.MSleep (2000)
  
  oled.Home
  repeat i from 0 to 19
    oled.Char(text2.byte[i])

  time.MSleep (2000)

PUB output1to4_test | i

  oled.Position(0, 0)
  repeat i from 0 to 19
    oled.Char(line1.byte[i])

  oled.Position(0, 1)
  repeat i from 0 to 19
    oled.Char(line2.byte[i])

  
  oled.Position(0, 2)
  repeat i from 0 to 19
    oled.Char(line3.byte[i])

  oled.Position(0, 3)
  repeat i from 0 to 19
    oled.Char(line4.byte[i])


PUB output_test | i 'WORKS

  oled.Position (0, 0)
  repeat i from 0 to 19
    oled.Char(text1.byte[i])

  oled.Position (0, 1)
  repeat i from 0 to 19
    oled.Char(text2.byte[i])

  oled.Position (0, 2)
  repeat i from 0 to 19
    oled.Char(text3.byte[i])

  oled.Position (0, 3)
  repeat i from 0 to 19
    oled.Char(text4.byte[i])

PUB Setup

  ser.Start (115_200)
  dira[cfg#LED1] := 1
  dira[cfg#LED2] := 1

  ifnot oled.start (SCL, SDA, RESET, I2C_RATE)
    debug.LEDSlow (27)

  oled.SetInternalReg(FALSE)
  oled.SetDisplayCursorBlink (FALSE, FALSE, FALSE)
  oled.SetClockDivOscFreq(7, 0)
  oled.SetFontCursorLineMode (FALSE, FALSE, TRUE)
  oled.SetCharGenCharROM (%11{%00}, %01{%00})     'Changed from recommended initialization sequence
  oled.SetBiDirection (1, 0)
  oled.SetSEGPinCFG ({1}0, {0}1)                  'Changed from recommended initialization sequence
  oled.SetVSLGPIO (0, 0)
  oled.SetContrast ($7F)
  oled.SetPhaseLength ($F, $1)
  oled.SetVcomhDeselectLevel (4)
  oled.Clear
  oled.Position (0, 0)
  oled.SetDisplayCursorBlink (TRUE, FALSE, FALSE)
  time.MSleep (100)
  
  ser.Clear
  ser.Str (string("I2C Bus setup on SCL: "))
  ser.Dec (SCL)
  ser.Str (string(", SDA: "))
  ser.Dec (SDA)
  ser.Str (string(" @"))
  ser.Dec (I2C_RATE/1000)
  ser.Str (string("kHz", ser#NL))
'  ser.Str (string("Press any key when ready.", ser#NL))
'  ser.CharIn

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
