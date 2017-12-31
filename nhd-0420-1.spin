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
  NHD_DC        = %1000_0000|CMDBIT

  DATABIT       = %01_000000        'OR your data byte with one of these two to tell the US2066 whether the following byte is a data byte
  CMDBIT        = %00_000000        ' or a command byte
  CONTBIT       = %10_000000        'Continuation bit

  CTRLBYTE_CMD  = CONTBIT | CMDBIT
  CTRLBYTE_DATA = DATABIT

'  US2066_PWRON  = $0C
'  US2066_PWROFF = $08

'  US2066_FUNCSEL_C  = $00  'function selection C
  US2066_DISP_CLEAR = $01  'Clear Display
  US2066_DISP_HOME  = $02  'Return Home (set DDRAM address to $00 and return cursor to its original position if shifted. The contents of DDRAM are not changed.
  US2066_ENTRY_MODE = $04  'Entry Mode Set
   LTR              = %10  '(POR) Cursor/blink moves to right and DDRAM addr is inc by 1
   RTL              = %00  ' Cursor/blink moves to left and DDRAM addr is dec by 1
   SHIFT            = %01  ' Make display shift of the enabled lines by the DS4 to DS1 bits in the shift enable instruction. Left/right direction depends on I/D bit selection
   NOSHIFT          = %00  '(POR) Display shift disable

  US2066_COMSEG_DIR = $06  'COM SEG direction
  US2066_DISP_OFF   = $08  'display off, cursor off, blink off
  US2066_EXT_FUNCSET= $09  'extended function set (4-lines)
  US2066_DISP_ON    = $0C  'display ON
'  US2066_SEGPINS_CNF= $10  'set SEG pins hardware configuration   ' <--------- Change
  US2066_CMDSET_FUND= $28  'function set (fundamental command set)
  US2066_CMDSET_EXT = $2A  'function set (extended command set)
'  US2066_VCOMH_DESEL= $40  'set VCOMH deselect level
'  US2066_SET_CLKDIV = $70  'set display clock divide ratio/oscillator frequency
  US2066_EXTA_DISINT= $71  'function selection A, disable internal Vdd regualtor
  US2066_EXTB_DISINT= $72  'function selection B, disable internal Vdd regualtor
  US2066_CMDSET_DIS = $78  'OLED command set disabled
  US2066_CMDSET_ENA = $79  'OLED command set enabled
'  US2066_CONTRAST   = $7F  'set contrast control
  US2066_DDRAM_ADDR = $80  'set DDRAM address to $00
'  US2066_CONTRAST   = $81  'set contrast control
'  US2066_SET_CLKDIV = $D5  'set display clock divide ratio/oscillator frequency
'  US2066_PHS_LEN    = $D9  'set phase length
'  US2066_SEGPINS_CNF= $DA  'set SEG pins hardware configuration
'  US2066_VCOMH_DESEL= $DB  'set VCOMH deselect level
'  US2066_FUNCSEL_C  = $DC  'function selection C
'  US2066_PHS_LEN    = $F1  'set phase length
{{
7.2.1
 Function Selection A [71h] (IS = X, RE = 1, SD=0)
This double byte command enable or disable the internal VDD regulator at 5V I/O application mode.
The internal VDD is enabled as default by data 5Ch, whereas it is disabled if the data sequence is set as 00h.
7.2.2
 Function Selection B [72h] (IS = X, RE = 1, SD=0)
Beside using ROM[1:0] and OPR[1:0] hardware pins, the character number of the Character Generator RAM and the character
ROM can be selected through this command, details refer to
7.2.3
 OLED Characterization [78H/ 79h] (IS = X, RE = 1, SD= 0 or 1)
This single byte command is used to select the OLED command set. When SD is set to 0b , OLED command set is disabled. When
SD is set to 1b, OLED command set is enabled.
}}
 
OBJ

  cfg   : "config.flip"
  ser   : "com.serial.terminal"
  time  : "time"
  i2c   : "jm_i2c_fast"
  debug : "debug"

VAR


PUB Main | i, j, ackbit

  setup

  repeat
    hometest1
'    output

PUB hometest1 | i

  command($01)
  time.MSleep(2)
  repeat i from 0 to 19
    data(text1.byte[i])

  time.MSleep (2000)
  
  command($02)
  repeat i from 0 to 19
    data(text2.byte[i])

  time.MSleep (2000)

PUB output | i

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

  time.MSleep(2000)

	command($01)
  time.MSleep(2)
	repeat i from 0 to 19
		data(text3.byte[i])

	command($A0)
	repeat i from 0 to 19
		data(text4.byte[i])

	command($C0)
	repeat i from 0 to 19
		data(text1.byte[i])

	command($E0)
	repeat i from 0 to 19
		data(text2.byte[i])

  time.MSleep (2000)

PUB command(cmd) | ackbit

  i2c.start
  ackbit := i2c.write (NHD_WR)            'US2066 Slave address
  if ackbit == i2c#ACK
    ackbit := i2c.write (CTRLBYTE_CMD)    'US2066 Control Byte: Command
  else
    i2c.stop
    return ackbit                         'NAK

  if ackbit == i2c#ACK
    ackbit := i2c.write (cmd)
  else
    i2c.stop
    return ackbit                         'NAK
  i2c.stop

  if ackbit == i2c#ACK
'    ser.Str (string("OLED ACKed!", ser#NL))
  else
    ser.Str (string("OLED NAKed!", ser#NL))

PUB data(databyte) | ackbit

  i2c.start
  ackbit := i2c.write (NHD_WR)            'US2066 Slave address
  if ackbit == i2c#ACK
    ackbit := i2c.write (CTRLBYTE_DATA)    'US2066 Control Byte: Command
  else
    i2c.stop
    return ackbit                         'NAK

  if ackbit == i2c#ACK
    ackbit := i2c.write (databyte)
  else
    i2c.stop
    return ackbit                         'NAK
  i2c.stop

  if ackbit == i2c#ACK
'    ser.Str (string("OLED ACKed!", ser#NL))
  else
    ser.Str (string("OLED NAKed!", ser#NL))

PUB Setup

  dira[cfg#LED1] := 1
  dira[cfg#LED2] := 1

  dira[RESET] := 1
  outa[RESET] := 0

  ser.Start (115_200)

  outa[RESET] := 1
  time.MSleep (10)
  i2c.setup (I2C_RATE)
  time.MSleep (10)

  command(US2066_CMDSET_EXT)  'function set (extended command set)
  command($71)                'function selection A, disable internal Vdd regualtor
  data($00)
  command(US2066_CMDSET_FUND) 'function set (fundamental command set)
  command(US2066_DISP_OFF)    'display off, cursor off, blink off
  command(US2066_CMDSET_EXT)  'function set (extended command set)
  command($79)                'OLED command set enabled
  command($D5)                'set display clock divide ratio/oscillator frequency
  command($70)                'set display clock divide ratio/oscillator frequency
  command($78)                'OLED command set disabled
  command($09)                'extended function set (4-lines)
  command($06)                'COM SEG direction
  command($72)                'function selection B, disable internal Vdd regualtor
  data($00)                   'ROM CGRAM selection
  command(US2066_CMDSET_EXT)  'function set (extended command set)
  command($79)                'OLED command set enabled
  command($DA)                'set SEG pins hardware configuration
  command($10)                'set SEG pins hardware configuration   ' <--------- Change
  command($DC)                'function selection C
  command($00)                'function selection C
  command($81)                'set contrast control
  command($7F)                'set contrast control
  command($D9)                'set phase length
  command($F1)                'set phase length
  command($DB)                'set VCOMH deselect level
  command($40)                'set VCOMH deselect level
  command($78)                'OLED command set disabled
  command(US2066_CMDSET_FUND) 'function set (fundamental command set)
  command($01)                'clear display
  command($80)                'set DDRAM address to $00
  command(US2066_DISP_ON)     'display ON
  time.MSleep(100)

  ser.Clear
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

  text1 byte "Newhaven Display----"
  text2 byte "Test----------------"
  text3 byte "16/20 Characters----"
  text4 byte "!@#$%^&*()_+{}[]<>?~"

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
