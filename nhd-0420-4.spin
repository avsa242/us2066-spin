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

  SLAVE_ADDR    =              %0111_100 << 1    '($78) - Default slave address of NHD420/US2066
  SLAVE_WR      = SLAVE_ADDR | %0000_0000
  SLAVE_RD      = SLAVE_ADDR | %0000_0001


OBJ

  cfg   : "config.flip"
  ser   : "com.serial.terminal"
  time  : "time"
  debug : "debug"
  oled  : "display.oled.4x20.i2c"

VAR

  long delay

PUB Main | i, j, ackbit, data_in

  delay := 50
  setup
'WORKS: CLEAR, HOME, RTL, LTR, COM31_0, COM0_31, DISPLAY_ONOFF, DISP_ON, DISP_OFF, CURSOR_ON, BLINK_ON
  ser.Str (string("Running..."))
  time.MSleep (500)
  oled.Display (TRUE)
  oled.SetCursor (0)
  oled.Clear
  oled.StrDelay (string("Contrast test..."))
  time.Sleep (2)
  oled.Clear
  output1to4_test
  repeat 5
    contrast_test
  debug.LEDFast (cfg#LED2)

PUB newline_test
    oled.Str(string("Test", 13))
    time.mSleep (100)
    oled.Str(string("1234", 13))
    time.mSleep (100)
    oled.Str(string("5678", 13))
    time.mSleep (100)
    oled.Str(string("9ABC", 13))
    time.mSleep (100)
    oled.Str(string("DEF1", 13))


PUB pos_test | i, j

  repeat
    repeat i from 0 to 3
      repeat j from 0 to 19
        oled.Position(j, i)
        oled.Char($20)
        oled.Char("-")
        time.MSleep (10)


PUB dblht_test

  oled.DoubleHeight(0)
  oled.Position(0, 0)
  oled.Str(string("Testing"))
  oled.Position(0, 1)
  oled.Str(string("Mode 0"))
  oled.Position(0, 2)
  oled.Str(string("Line 3"))
  oled.Position(0, 3)
  oled.Str(string("Line 4"))
  time.Sleep (2)
  oled.Clear
    
  oled.DoubleHeight(1)
  oled.Position(0, 0)
  oled.Str(string("Testing"))
  oled.Position(0, 1)
  oled.Str(string("Mode 1"))
  oled.Position(0, 2)
  oled.Str(string("Line 3"))
  oled.Position(0, 3)
  oled.Str(string("Line 4"))
  time.Sleep (2)
  oled.Clear

  oled.DoubleHeight(2)
  oled.Position(0, 0)
  oled.Str(string("Testing"))
  oled.Position(0, 1)
  oled.Str(string("Mode 2"))
  oled.Position(0, 2)
  oled.Str(string("Line 3"))
  oled.Position(0, 3)
  oled.Str(string("Line 4"))
  time.Sleep (2)
  oled.Clear

  oled.DoubleHeight(3)
  oled.Position(0, 0)
  oled.Str(string("Testing"))
  oled.Position(0, 1)
  oled.Str(string("Mode 3"))
  oled.Position(0, 2)
  oled.Str(string("Line 3"))
  oled.Position(0, 3)
  oled.Str(string("Line 4"))
  time.Sleep (2)
  oled.Clear
  
  oled.DoubleHeight(4)
  oled.Position(0, 0)
  oled.Str(string("Testing"))
  oled.Position(0, 1)
  oled.Str(string("Mode 4"))
  oled.Position(0, 2)
  oled.Str(string("Line 3"))
  oled.Position(0, 3)
  oled.Str(string("Line 4"))
  time.Sleep (2)
  oled.Clear

PUB contrast_test | i

  repeat i from 0 to 255 step 16
    oled.SetContrast (i)
    ser.Str (string("Contrast level "))
    ser.Dec (i)
    ser.NewLine
    time.MSleep (250)

  repeat i from 255 to 0 step 16
    oled.SetContrast (i)
    ser.Str (string("Contrast level "))
    ser.Dec (i)
    ser.NewLine
    time.MSleep (250)
  
{PUB dump_display | r, c, ackbit, data_in

  ser.Str (string("Dump display data: ", ser#NL))
  
  i2c.start
  ackbit := i2c.write (SLAVE_RD)        'Dummy read first byte, according to p.40, sec 7.1.15
  i2c.read (TRUE)

  repeat r from 0 to 3
    ser.Dec (r)
    ser.Str (string(": "))
    repeat c from 0 to 19
      i2c.start
      ackbit := i2c.write (SLAVE_RD)
      data_in := i2c.read (TRUE)
      ser.Char (data_in)
'      ser.Hex (data_in, 2)
'      ser.Char (" ")
    ser.NewLine
  i2c.stop
}
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

  oled.Clear
  time.MSleep(2)
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

  oled.Clear
  time.MSleep(2)
  repeat i from 0 to 19
    oled.Char(text1.byte[i])

  oled.Position (0, 1)
  repeat i from 0 to 19
    oled.Char(text2.byte[i])

  oled.Position (0, 1)
  repeat i from 0 to 19
    oled.Char(text3.byte[i])

  oled.Position (0, 1)
  repeat i from 0 to 19
    oled.Char(text4.byte[i])

PUB Setup

  dira[cfg#LED1] := 1
  dira[cfg#LED2] := 1

  dira[RESET] := 1
  outa[RESET] := 0

  ser.Start (115_200)

  ser.Clear
  
  outa[RESET] := 1
  time.MSleep (10)
  oled.start (SCL, SDA, RESET, I2C_RATE)
  time.MSleep (10)

  oled.InternalReg(FALSE)
  oled.Display(FALSE)
  
  oled.SetClockDivOscFreq(7, 0)

  oled.SetupBlob
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
