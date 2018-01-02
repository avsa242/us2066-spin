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

' -US2066 COMMAND SET --FUNDAMENTAL------------------------------
  'SD bit set 0
  US2066_DISP_CLEAR = %0000_0001  '$01 Clear Display

  'RE bit set 0, SD bit set 0
  US2066_DISP_HOME  = %0000_0010  '$02 Return Home (set DDRAM address to $00 and return cursor to its original position if shifted. The contents of DDRAM are not changed.

  US2066_ENTRY_MODE = %0000_0100  '$04 Entry Mode Set
   LTR              = %0000_0010  '(POR) Cursor/blink moves to right and DDRAM addr is inc by 1
   RTL              = %0000_0000  ' Cursor/blink moves to left and DDRAM addr is dec by 1
   SHIFT            = %0000_0001  ' Make display shift of the enabled lines by the DS4 to DS1 bits in the shift enable instruction. Left/right direction depends on I/D bit selection
   NOSHIFT          = %0000_0000  '(POR) Display shift disable

  'RE bit set 1, SD bit set 0
   COM31_0          = %0000_0000  'Common bi-direction function COM31 > COM0
   COM0_31          = %0000_0010  'COM0 > COM31
   SEG99_0          = %0000_0000  'Segment bi-direction function SEG99 > SEG0
   SEG0_99          = %0000_0001  'SEG0 > SEG99

  'RE bit set 0, SD bit set 0
  US2066_DISP_ONOFF = %0000_1000  'Display ON/OFF control
    DISP_ON         = %0000_0100  'Display ON
    DISP_OFF        = %0000_0000  '(POR) Display OFF
    CURSOR_ON       = %0000_0010  'Cursor ON
    CURSOR_OFF      = %0000_0000  '(POR) Cursor OFF
    BLINK_ON        = %0000_0001  'Blink ON
    BLINK_OFF       = %0000_0000  '(POR) Blink OFF

  'RE bit set 1, SD bit set 0
  US2066_EXT_FUNCSET= %0000_1000  'Assign font width, black/white inverting of cursor, and 4-line display mode control bit
    FONTWIDTH_6     = %0000_0100  '6-dot font width
    FONTWIDTH_5     = %0000_0000  '(POR) 5-dot font width
    CURSOR_INVERT   = %0000_0010  'Black/white inverting of cursor enabled
    CURSOR_NORMAL   = %0000_0000  '(POR) Black/white inverting of cursor disabled
    NW_3_4_LINE     = %0000_0001  '3 line or 4 line display mode
    NW_1_2_LINE     = %0000_0000  '1 line or 2 line display mode

  'IS bit set 0, RE bit set 0, SD bit set 0
  US2066_DC_SHIFT   = %0001_0000  'Set cursor moving and display shift control bit, and the direction, without changing DDRAM data
    DISP_SHIFT      = %0000_1000  'Display shift
    CURSOR_SHIFT    = %0000_0000  'Cursor shift
    SHIFT_RIGHT     = %0000_0100  'Shift right
    SHIFT_LEFT      = %0000_0000  'Shift left

  'IS bit set 0, RE bit set 1, SD bit set 0
  US2066_DBLHEIGHT  = %0001_0000  'Assign different double height format (POR=%xxxx_11xx) (See US2066 p.38, Table 7-2 for illustrations UD2_UD1_X_DH (UD1=0 UD2=0 forbidden in 2 line display, UD1=0 forbidden in 3-line display)
    DBLHEIGHT_BOTTOM= %0000_0000  'Top two rows standard-height, Bottom row double height
    DBLHEIGHT_MIDDLE= %0000_0100  'Top row standard-height, middle row double-height, bottom row standard-height
    DBLHEIGHT_BOTH  = %0000_1000  'Two double-height rows
    DBLHEIGHT_TOP   = %0000_1100  'TOP row double height, bottom two rows standard-height
    DISP_SHIFT_EN   = %0000_0001  'Display shift enable
    DOT_SCROLL_EN   = %0000_0000  '(POR) Dot scroll enable

  'IS bit set 1, RE bit set 1, SD bit set 0
  US2066_SHIFT_EN   = %0001_0000  'Determine the line for display shift (DS[4:1] = %1111 (POR) when DH = %1
    DS_LINE1        = %0000_0001  '1st line display shift enable
    DS_LINE2        = %0000_0010  '2nd line display shift enable
    DS_LINE3        = %0000_0100  '3rd line display shift enable
    DS_LINE4        = %0000_1000  '4th line display shift enable

  'IS bit set 1, RE bit set 1, SD bit set 0
  US2066_SCROLL_EN  = %0001_0000  'Determine the line for horizontal smooth scroll (HS[4:1] = %1111 (POR) when DH = %0
    SCROLL_LINE1    = %0000_0001  '1st line dot scroll enable
    SCROLL_LINE2    = %0000_0010  '2nd line dot scroll enable
    SCROLL_LINE3    = %0000_0100  '3rd line dot scroll enable
    SCROLL_LINE4    = %0000_1000  '4th line dot scroll enable

  'RE bit set 0, SD bit set 0  
  US2066_FUNCSET_0  = %0010_0000  'Function set 0
    DISP_LINES_2_4  = %0000_1000  '2-line (NW=%0) or 4 line (NW=%1)
    DISP_LINES_1_3  = %0000_0000  '1-line (NW=%0) or 3 line (NW=%1)
    DBLHT_FONT_EN   = %0000_0100  'Double height font control for 2-line mode
    DBLHT_FONT_DIS  = %0000_0000  '(POR) Double height font control for 2-line mode
    RE              = %0000_0010  'Extension register RE (POR 0)
    IS_X            = %0000_0000  'Extension register IS

  'RE bit set 1, SD bit set 0  
  US2066_FUNCSET_1  = %0010_0010  'Function set 1 (RE register 1)
    CGRAM_BLINK_EN  = %0000_0100  'CGRAM blink enable
    CGRAM_BLINK_DIS = %0000_0000  '(POR) CGRAM blink disable
    REVERSE_DISPLAY = %0000_0001  'Reverse display
    NORMAL_DISPLAY  = %0000_0000  '(POR) Normal display

  'IS bit set 0, RE bit set 0, SD bit set 0
  US2066_CGRAM_ADDR = %0100_0000  'Set CGRAM address in address counter (POR = %00_0000). Lowest 6 bits are address [AC5:AC0]
  
  'RE bit set 0, SD bit set 0
  US2066_DDRAM_ADDR = %1000_0000  'Set DDRAM address in address counter (POR = %000_0000). Lowest 7 bits are address [AC6:AC0]

  'RE bit set 1, SD bit set 0
  US2066_SCROLL_QTY = %1000_0000  'Set quantity of horizontal dot scroll (POR = %00_0000). Lowest 6 bits are quantity [SQ5:SQ0]. Maximum is %11_0000

'READ COMMAND
  'SD bit set 0, R/W bit set 1
  US2066_BF_AC_ID   = %0100_0000  'Read busy state

'DATA COMMANDS
  'SD bit set 0, D/C bit set 1
'  US2066_WRITE      = %0000_0000  'STUB - Write data into internal RAM (DDRAM/CGRAM) - D/C bit set 1, R/W bit set 0
'  US2066_READ       = %0000_0000  'STUB - Read data from internal RAM (DDRAM/CGRAM) - D/C bit set 1, R/W bit set 1

  US2066_COMSEG_DIR = $06  'COM SEG direction
  US2066_DISP_OFF   = $08  'display off, cursor off, blink off
'  US2066_EXT_FUNCSET= $09  'extended function set (4-lines)
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
'  US2066_DDRAM_ADDR = $80  'set DDRAM address to $00
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

  long delay

PUB Main | i, j, ackbit, data_in

  delay := 0
  setup
'WORKS: CLEAR, HOME, RTL, LTR, COM31_0, COM0_31, US2066_DISP_ONOFF, DISP_ON, DISP_OFF, CURSOR_ON, BLINK_ON
  ser.Str (string("Running..."))
  time.MSleep (500)
  command( US2066_DISP_ONOFF | DISP_ON | CURSOR_ON | BLINK_ON)

  output

  command( US2066_FUNCSET_0 | RE )
  command( US2066_CMDSET_ENA )
  
  repeat i from 0 to 255 step 16

'    command( US2066_FUNCSET_0 | RE )
'    command( US2066_CMDSET_ENA )
    command( $81 )
    command( i )
'    command( US2066_CMDSET_DIS )
'    command( US2066_FUNCSET_0 )
    ser.Str (string("Contrast level "))
    ser.Dec (i)
    ser.NewLine
    time.MSleep (250)

  repeat i from 255 to 0 step 16
'    command( US2066_FUNCSET_0 | RE )
'    command( US2066_CMDSET_ENA )
    command( $81 )
    command( i )
'    command( US2066_CMDSET_DIS )
'    command( US2066_FUNCSET_0 )

    ser.Str (string("Contrast level "))
    ser.Dec (i)
    ser.NewLine
    time.MSleep (250)
  
  command( US2066_CMDSET_DIS )
  command( US2066_FUNCSET_0 )
'  command( )
  
  debug.LEDFast (cfg#LED2)
'    dump_display
'    hometest1
'    output
  
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

PUB output1to4 | i

  command($01)
  time.MSleep(2)
  repeat i from 0 to 19
    data(line1.byte[i])
    time.MSleep (delay)
  command($A0)
  repeat i from 0 to 19
    data(line2.byte[i])
    time.MSleep (delay)
  command($C0)
  repeat i from 0 to 19
    data(line3.byte[i])
    time.MSleep (delay)
  command($E0)
  repeat i from 0 to 19
    data(line4.byte[i])
    time.MSleep (delay)

PUB hometest1 | i 'WORKS

  command($01)
  time.MSleep(2)
  repeat i from 0 to 19
    data(text1.byte[i])

  time.MSleep (2000)
  
  command($02)
  repeat i from 0 to 19
    data(text2.byte[i])

  time.MSleep (2000)

PUB output | i 'WORKS

  command($01)
  time.MSleep(2)
  repeat i from 0 to 19
    data(text1.byte[i])
    time.MSleep (delay)

  command($A0)
  repeat i from 0 to 19
    data(text2.byte[i])
    time.MSleep (delay)

  command($C0)
  repeat i from 0 to 19
    data(text3.byte[i])
    time.MSleep (delay)

  command($E0)
  repeat i from 0 to 19
    data(text4.byte[i])
    time.MSleep (delay)

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

  if ackbit == i2c#NAK
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

  line1 byte "1------------------1"
  line2 byte "2------------------2"
  line3 byte "3------------------3"
  line4 byte "4------------------4"
  
  text1 byte "Newhaven Display----"
  text2 byte "TEST----------------"
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
