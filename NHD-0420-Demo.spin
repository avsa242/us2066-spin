{
    --------------------------------------------
    Filename: NHD-0420-Demo.spin
    Version: 0.1
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
  I2C_HZ    = 1_220

OBJ

  cfg   : "config.flip"
  time  : "time"
  oled  : "display.oled.4x20.i2c"

VAR


PUB Main

  oled.start (SCL, SDA, RESET, I2C_HZ)
  oled.Clear
  
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
  

  repeat
  
DAT

  line1 byte  "Parallax P8X32A     ", 0
  line2 byte  "     on the         ", 0
  line3 byte  "Newhaven Displays   ", 0
  line4 byte  "NHD420 4x20 OLED    ", 0

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
