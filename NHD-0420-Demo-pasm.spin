{
    --------------------------------------------
    Filename: NHD-0420-Demo.spin
    Version: 0.2
    Author: Jesse Burt
    Copyright (c) 2018
    See end of file for terms of use.
    --------------------------------------------
}

CON

  _clkmode = cfg#_clkmode
  _xinfreq = cfg#_xinfreq

  SCL       = 28
  SDA       = 29
  RESET     = 26
  I2C_HZ    = 400_000

OBJ

  cfg   : "core.con.client.flip"
  time  : "time"
  oled  : "display.oled.4x20.i2c-pasm"
  int   : "string.integer"

VAR


PUB Main

  Setup

  repeat
    Greet_Demo
    time.Sleep (4)
    oled.Clear

    Count_Demo
    time.Sleep (4)
    oled.Clear

    DoubleHeight_Demo
    time.Sleep (4)
    oled.Clear

    Contrast_Demo
    time.Sleep (4)
    oled.Clear
    
    oled.SetDoubleHeight (0)

    Position_Demo
    time.Sleep (4)
    oled.Clear

    Cursor_demo
    time.Sleep (4)
    oled.Clear

    oled.SetDoubleHeight (0)
    oled.SetDisplayCursorBlink (TRUE, FALSE, FALSE)
  repeat

PUB Contrast_Demo | i

  oled.Position (0, 0)
  oled.Str (string("Change contrast", oled#NL, "level:"))
  oled.Newline
  oled.SetDoubleHeight (1)

  repeat i from -255 to 255 step 1
    oled.Position (0, 2)
    oled.SetContrast (i)
    oled.Str (int.DecPadded (||i, 3))
    oled.Char_Literal (32)
    oled.Str (int.Hex(||i, 2))
    oled.Char_Literal (32)
    oled.Str (int.Bin(||i, 8))
    time.MSleep (10)

PUB Count_Demo | i

  oled.Position (0, 0)
  oled.Str (string("Rapidly changing", oled#NL, "display contents", oled#NL, "(compare to LCD!)"))
  repeat i from 0 to 3000
    oled.Position (0, 3)
    oled.Str (string("i = "))
    oled.Str (int.Dec (i))

PUB Cursor_demo | delay

  delay := 50
  oled.SetDisplayCursorBlink (1, 1, 0)
  oled.StrDelay (string("Cursor: no blinking"), delay)
  time.Sleep (3)
  oled.Newline
  oled.SetDisplayCursorBlink (1, 1, 1)
  oled.StrDelay (string("Cursor: blinking"), delay)
  time.Sleep (3)

  oled.SetDoubleHeight (3)
  oled.Clear
  oled.SetDisplayCursorBlink (1, 1, 0)
  oled.StrDelay (string("Cursor: no blinking"), delay)
  time.Sleep (3)
  oled.Newline
  oled.SetDisplayCursorBlink (1, 1, 1)
  oled.StrDelay (string("Cursor: blinking"), delay)

PUB DoubleHeight_Demo | mode, line

  repeat mode from 0 to 4
    oled.SetDoubleHeight (mode)
    oled.Position (14, 0)
    oled.Str (string("Mode "))
    oled.Str (int.Dec(mode))
    repeat line from 0 to 3
      oled.Position (0, line)
      oled.Str (string("Double-height"))
    time.Sleep (1)

PUB Greet_Demo

  oled.Position (0, 0)
  oled.Str (@line1)
  time.Sleep (1)
  
  oled.Position (0, 1)
  oled.Str (@line2)
  time.Sleep (1)
  
  oled.Position (0, 2)
  oled.Str (@line3)
  time.Sleep (1)
  
  oled.Position (0, 3)
  oled.Str (@line4)

PUB Position_Demo | x, y
  
  repeat y from 0 to 3
    repeat x from 0 to 19
      oled.Position(0, 0)
      oled.Str (string("Position "))
      oled.Str (int.DecPadded(x, 2))
      oled.Char_Literal (",")
      oled.Str (int.Dec(y))
      oled.Position(x-1, y)
      oled.Char($20)
      oled.Char("-")
      time.MSleep (50)

PUB Setup

  oled.start (SCL, SDA, RESET, I2C_HZ)

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
 
DAT

  line1 byte  "  Parallax P8X32A   ", 0
  line2 byte  "       on the       ", 0
  line3 byte  "  Newhaven Display  ", 0
  line4 byte  "  NHD420 4x20 OLED  ", 0

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
