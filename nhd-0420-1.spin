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

  SCL       = 28
  SDA       = 29
  RESET     = 26
'  NHD       = $78 << 1       'Default slave address of NHD420/US2066
  NHD       = %0111_100 << 1
  NHD_WR    = NHD | %0000_0000
  NHD_RD    = NHD | %0000_0001
  NHD_DC    = %1000_0000|CMDBIT
  I2C_CLK   = 100_000

  DATABIT   = %01_000000  'OR your data byte with one of these two to tell the US2066 whether the following byte is a data byte
  CMDBIT    = %00_000000  ' or a command byte
  CONTBIT   = %10_000000 'Continuation bit
  CTRLBYTE  = CONTBIT | DATABIT

  US2066_PWRON  = $0C
  US2066_PWROFF = $08
  
OBJ

  cfg   : "config.flip"
  ser   : "com.serial.terminal"
  time  : "time"
  i2c   : "jm_i2c_fast"
  debug : "debug"

VAR


PUB test1 | i, j, ackbit

  dira[cfg#LED1] := 1
  dira[cfg#LED2] := 1
  
  dira[RESET] := 1
  outa[RESET] := 0

  ser.Start (115_200)
  i2c.setup (I2C_CLK)
  ser.Clear
  
  time.MSleep (100)
  outa[RESET] := 1
  ser.Str (string("Waiting 100ms..."))
  time.MSleep (100)
  
  ser.Str (string("Ready.", ser#NL))
  ser.CharIn

  repeat
    ser.Str (string("Powering on OLED...", ser#NL))
    cmd(US2066_PWRON)
    time.Sleep (2)

    ser.Str (string("Powering off OLED...", ser#NL))
    cmd(US2066_PWROFF)
    time.Sleep (2)

PUB cmd(cmdbyte)|ackbit

  i2c.start
  ackbit := i2c.write (NHD_WR)
  if ackbit == i2c#ACK
    ackbit := i2c.write (%10_000000)  'Co = 1 (1=Continuation bit), D/C = 0 (0=Command bit), 6 0's
  else
    i2c.stop                          'NAK
    return ackbit

  if ackbit == i2c#ACK
    ackbit := i2c.write (cmdbyte)
  else
    i2c.stop                          'NAK
    return ackbit
  i2c.stop

  if ackbit == i2c#ACK
    ser.Str (string("OLED ACKed!", ser#NL))
  else
    ser.Str (string("OLED NAKed!", ser#NL))


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
