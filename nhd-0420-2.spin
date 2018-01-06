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

'Command set: (POR) indicates Power On Reset, or default value.
'-FUNDAMENTAL COMMAND SET-------
  'SD bit set 0
  CLEAR_DISPLAY     = %0000_0001  '$01 Clear Display
  'RE bit set 0, SD bit set 0
  HOME_DISPLAY      = %0000_0010  '$02 Return Home (set DDRAM address to $00 and return cursor to its original position if shifted. The contents of DDRAM are not changed.
' OR ( | ) bitmasks below together in a command, to set individual flags
' Example:
' command(ENTRY_MODE_SET | LTR | NOSHIFT)
  ENTRY_MODE_SET    = %0000_0100  '$04 Entry Mode Set
   LTR              =        %10  '(POR) Cursor/blink moves to right and DDRAM addr is inc by 1
   RTL              =        %00  ' Cursor/blink moves to left and DDRAM addr is dec by 1
   SHIFT            =        %01  ' Make display shift of the enabled lines by the DS4 to DS1 bits in the shift enable instruction. Left/right direction depends on I/D bit selection
   NOSHIFT          =        %00  '(POR) Display shift disable

  'RE bit set 1, SD bit set 0
   COM31_0          = %0000_0000  'Common bi-direction function COM31 > COM0
   COM0_31          = %0000_0010  'COM0 > COM31
   SEG99_0          = %0000_0000  'Segment bi-direction function SEG99 > SEG0
   SEG0_99          = %0000_0001  'SEG0 > SEG99

  'RE bit set 0, SD bit set 0
  DISPLAY_ONOFF     = %0000_1000  'Display ON/OFF control
    DISP_ON         =       %100  'Display ON
    DISP_OFF        =       %000  '(POR) Display OFF
    CURSOR_ON       =       %010  'Cursor ON
    CURSOR_OFF      =       %000  '(POR) Cursor OFF
    BLINK_ON        =       %001  'Blink ON
    BLINK_OFF       =       %000  '(POR) Blink OFF

  'RE bit set 1, SD bit set 0
  EXTENDED_FUNCSET  = %0000_1000  'Assign font width, black/white inverting of cursor, and 4-line display mode control bit
    FONTWIDTH_6     =       %100  '6-dot font width
    FONTWIDTH_5     =       %000  '(POR) 5-dot font width
    CURSOR_INVERT   =       %010  'Black/white inverting of cursor enabled
    CURSOR_NORMAL   =       %000  '(POR) Black/white inverting of cursor disabled
    NW_3_4_LINE     =       %001  '3 line or 4 line display mode
    NW_1_2_LINE     =       %000  '1 line or 2 line display mode

  'IS bit set 0, RE bit set 0, SD bit set 0
  CURS_DISP_SHIFT   = %0001_0000  'Set cursor moving and display shift control bit, and the direction, without changing DDRAM data
    CURS_LEFT       =      %00 << 2
    CURS_RIGHT      =      %01 << 2
    DISP_LEFT       =      %10 << 2
    DISP_RIGHT      =      %11 << 2
  'IS bit set 0, RE bit set 1, SD bit set 0
  DBLHEIGHT         = %0001_0000  'Assign different double height format (POR=%xxxx_11xx) (See US2066 p.38, Table 7-2 for illustrations UD2_UD1_X_DH (UD1=0 UD2=0 forbidden in 2 line display, UD1=0 forbidden in 3-line display)
    DBLHEIGHT_BOTTOM=      %000 << 1 'Top two rows standard-height, Bottom row double height
    DBLHEIGHT_MIDDLE=      %010 << 1 'Top row standard-height, middle row double-height, bottom row standard-height
    DBLHEIGHT_BOTH  =      %100 << 1 'Two double-height rows
    DBLHEIGHT_TOP   =      %110 << 1 'TOP row double height, bottom two rows standard-height
    DISP_SHIFT_EN   =         %1     'Display shift enable
    DOT_SCROLL_EN   =         %0     '(POR) Dot scroll enable

  'IS bit set 1, RE bit set 1, SD bit set 0
  SHIFT_SCROLL_ENA  = %0001_0000  'Determine the line for display shift (DS[4:1] = %1111 (POR). Shift when DH = 1, Scroll when DH = 0 (DISP_SHIFT_EN, DOT_SCROLL_EN)
    SHFT_SCRL_LINE1 =         %1  '1st line display shift/scroll enable
    SHFT_SCRL_LINE2 =        %1 << 1 '2nd line display shift/scroll enable
    SHFT_SCRL_LINE3 =       %1  << 2  '3rd line display shift/scroll enable
    SHFT_SCRL_LINE4 =      %1   << 3  '4th line display shift/scroll enable

  'RE bit set 0, SD bit set 0  
  FUNCTION_SET_0    = %0010_0000  'Function set 0
    DISP_LINES_2_4  =      %1   << 3  '2-line (NW=%0) or 4 line (NW=%1)
    DISP_LINES_1_3  =      %0   << 3  '1-line (NW=%0) or 3 line (NW=%1)
    DBLHT_FONT_EN   =       %1  << 2  'Double height font control for 2-line mode
    DBLHT_FONT_DIS  =       %0  << 2  '(POR) Double height font control for 2-line mode

    EXT_REG_RE      =      %0010  'Extension register RE (POR 0)
    EXT_REG_IS      =      %0001  'Extension register IS

  'RE bit set 1, SD bit set 0  
  FUNCTION_SET_1    = %0010_0000 | EXT_REG_RE 'Function set 1 (RE register 1)
    CGRAM_BLINK_EN  =       %1  << 2 'CGRAM blink enable
    CGRAM_BLINK_DIS =       %0  << 2 '(POR) CGRAM blink disable
    REVERSE_DISPLAY =         %1  'Reverse display
    NORMAL_DISPLAY  =         %0  '(POR) Normal display

  SET_CGRAM_ADDR    = %01_000000  ' Set CGRAM address in address counter (POR=%00_0000)
  SET_DDRAM_ADDR    = %1_0000000  ' Set DDRAM address in address counter (POR=%000_0000)
  SET_SCROLL_QTY    = %1_0000000  ' Set the quantity of horizontal dot scroll (POR=%00_0000 - Maximum: %11_0000)

'-EXTENDED COMMAND SET---
''To use, first set RE to 1
''These are two-byte commands.
''First send the command, then a data byte appropriate to your application, as prescribed by the comment next to the command.
''Example:
''  command (FUNCTION_SEL_A)
''  data ($00)

  FUNCTION_SEL_A    = $71 '%A7..A0
' $00 - Disable internal regulator (Low-voltage I/O mode). $5C(POR) - Enable internal regulator (5V I/O mode)
    INT_REG_DISABLE = $00
    INT_REG_ENABLE  = $5C
  FUNCTION_SEL_B    = $72 '%xxxx_ROM1_ROM0_OPR1_OPR0
' OPR: Select the character no. of character generator.  ROM: Select character ROM
'       CGROM   CGRAM                                       ROM
'   %00 240     8                                       %00 A
'   %01 248     8                                       %01 B
'   %10 250     6                                       %10 C
'   %11 256     0                                       %11 Invalid


'-OLED COMMAND SET-----
  OLED_CMDSET_DIS = $78 ' %0111_100_SD  SD = %0: (POR) OLED Command set disabled
  OLED_CMDSET_ENA = $79 ' %0111_100_SD  SD = %1: OLED Command set enabled

''These are two-byte commands.
''First send the command, then a second command byte appropriate to your application, as prescribed by the comment next to the command.
''Example:
''  command (SET_CONTRAST)
''  command ($7F)
  SET_CONTRAST    = $81 ' Select contrast. Range $00..$FF (POR=$7F)
  DISP_CLKDIV_OSC = $D5 ' Oscillator freq (4 MSBs, POR=%0111). Display clock divisor (4 LSBs, POR=%0000, divisor=value+1). Range for both is %0000-%1111
  SET_PHASE_LEN   = $D9 ' Segment waveform length (unit=DCLKs). Phase 2 (MSBs, POR=%0111) range %0001..%1111, Phase 1 (LSBs, POR=%1000) range %0010..%1111
' NOTE: Phase 1 period up to 32 DCLK. Clock 0 is a valid entry with 2 DCLK
' NOTE: Phase 2 period up to 15 DCLK. Clock 0 is invalid
  SET_SEG_PINS    = $DA ' Set SEG pins hardware configuration
' Bit 5: %0(POR) Disable SEG L/R Remap %1: Enable L/R Remap
' Bit 4: %0 Sequential SEG pin cfg     %1(POR) Alternating (odd/even) SEG pin cfg
  SET_VCOMH_DESEL = $DB ' Adjust Vcomh regulator output
' %A6..A4:  (Hex)   Vcomh deselect level
' %000      $00     ~0.65 * Vcc
' %001      $10     ~0.71 * Vcc
' %010      $20     ~0.77 * Vcc (POR)
' %011      $30     ~0.83 * Vcc
' %100      $40     ~1.00 * Vcc

  FUNCTION_SEL_C    = %1101_1100 'Set VSL/GPIO
    VSL_INTERNAL    = %0        << 7
    VSL_EXTERNAL    = %1        << 7
    GPIO_HIZ_INP_DIS=        %00
    GPIO_HIZ_INP_ENA=        %01
    GPIO_OUT_LOW    =        %10
    GPIO_OUT_HIGH   =        %11
'Set VSL & GPIO
' %A7=0: (POR) Internal VSL %A7=1: Enable external VSL
' %A1..A0   Condition
' %00       GPIO pin HiZ, input disabled (always read as low)
' %01       GPIO pin HiZ, input enabled
' %10       GPIO pin output low (RESET)
' %11       GPIO pin output high

  FADEOUT_BLINK     = $23 ' %xx_A5..A0
' %A5..A4=%00: Disable Fade Out/Blinking (RESET)
' %A5..A4=%10: Enable Fade Out. Once fade mode is enabled, contrast decreases gradually until all pixels OFF. Output follows RAM content when fade mode disabled.
' %A3..A0: Time interval for each fade step
'   %0000: 8 Frames
'   %0001: 16 Frames
'   %0010: 24 Frames
'   .
'   .
'   %1110: 120 Frames
'   %1111: 128 Frames

  US2066_COMSEG_DIR = $06  'COM SEG direction
  US2066_DISP_OFF   = $08  'display off, cursor off, blink off
'  US2066_EXT_FUNCSET= $09  'extended function set (4-lines)
  US2066_DISP_ON    = $0C  'display ON
'  US2066_SEGPINS_CNF= $10  'set SEG pins hardware configuration   ' <--------- Change
  CMDSET_FUNDAMENTAL= $28  'function set (fundamental command set)
  CMDSET_EXTENDED = $2A  'function set (extended command set)
'  US2066_VCOMH_DESEL= $40  'set VCOMH deselect level
'  US2066_SET_CLKDIV = $70  'set display clock divide ratio/oscillator frequency
  US2066_EXTA_DISINT= $71  'function selection A, disable internal Vdd regualtor
  US2066_EXTB_DISINT= $72  'function selection B, disable internal Vdd regualtor
  US2066_CMDSET_DIS = $78  'OLED command set disabled
  US2066_CMDSET_ENA = $79  'OLED command set enabled
 
OBJ

  cfg   : "config.flip"
  ser   : "com.serial.terminal"
  time  : "time"
  i2c   : "jm_i2c_fast"
  debug : "debug"

VAR

  long delay

PUB Main | i, j, ackbit, data_in

  delay := 100
  setup
'WORKS: CLEAR, HOME, RTL, LTR, COM31_0, COM0_31, DISPLAY_ONOFF, DISP_ON, DISP_OFF, CURSOR_ON, BLINK_ON
  ser.Str (string("Running..."))
  time.MSleep (500)
  command(DISPLAY_ONOFF | DISP_ON | CURSOR_ON | BLINK_ON)

{  repeat
    Str(string("Test", 13))
'    time.mSleep (100)
    Str(string("1234", 13))
'    time.mSleep (100)
    Str(string("5678", 13))
'    time.mSleep (100)
    Str(string("9ABC", 13))
'    time.mSleep (100)
    Str(string("DEF1", 13))
'    hometest1
'    output
}
  Position(0, 3)
  Str(string("test"))
  debug.LEDFast (cfg#LED2)

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

PUB DoubleHeight(Mode) 'WORKS

  command(CMDSET_EXTENDED)
  command(EXTENDED_FUNCSET | FONTWIDTH_5 | CURSOR_NORMAL | NW_3_4_LINE)
  case (Mode)
    0:                            ' Normal 4-line
      command(CMDSET_FUNDAMENTAL)
    1:                            ' Bottom half double-height
      command(DBLHEIGHT | DBLHEIGHT_BOTTOM)
      command(FUNCTION_SET_0 | DISP_LINES_2_4 | DBLHT_FONT_EN)
    2:                            ' Middle Double-Height
      command(DBLHEIGHT | DBLHEIGHT_MIDDLE)
      command(FUNCTION_SET_0 | DISP_LINES_2_4 | DBLHT_FONT_EN)
    3:                            ' Both top & bottom double-height (2 lines)
      command(DBLHEIGHT | DBLHEIGHT_BOTH)
      command(FUNCTION_SET_0 | DISP_LINES_2_4 | DBLHT_FONT_EN)
    4:                            ' Top Double-Height
      command(DBLHEIGHT | DBLHEIGHT_TOP)
      command(FUNCTION_SET_0 | DISP_LINES_2_4 | DBLHT_FONT_EN)
    OTHER:
      command(CMDSET_FUNDAMENTAL)

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

PUB Clear 'WORKS

  command(CLEAR_DISPLAY)

PUB Home 'WORKS

  command(HOME_DISPLAY)

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
      command(DISPLAY_ONOFF | DISP_ON | CURSOR_OFF | BLINK_OFF)
    1:
      command(DISPLAY_ONOFF | DISP_ON | CURSOR_OFF | BLINK_ON)
    2:
      command(DISPLAY_ONOFF | DISP_ON | CURSOR_ON | BLINK_OFF)
    3:
      command(DISPLAY_ONOFF | DISP_ON | CURSOR_ON | BLINK_ON)
    OTHER:
      command(DISPLAY_ONOFF | DISP_ON | CURSOR_OFF | BLINK_OFF)


PUB Position(column, row) | offset 'WORKS

  case row
    0: offset := $00 + column <# $13
    1: offset := $20 + column <# $33
    2: offset := $40 + column <# $53
    3: offset := $60 + column <# $73
    OTHER: offset := 0

  command( SET_DDRAM_ADDR|offset )

PUB contrast_test | i

  command( FUNCTION_SET_0 | EXT_REG_RE )
  command( OLED_CMDSET_ENA )
  
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
  
  command( OLED_CMDSET_DIS )
  command( FUNCTION_SET_0 )
  
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
    ackbit := i2c.write (CTRLBYTE_DATA)    'US2066 Control Byte: Command
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
    command(CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
    command(DISPLAY_ONOFF | DISP_ON)
  else
    command(CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
    command(DISPLAY_ONOFF | DISP_OFF)
  
PUB InternalReg(enable)
' Enables the internal regulator (5V operation) if non-zero, disables it otherwise (low-voltage operation)
  if enable
    command(CMDSET_EXTENDED)                'function set (extended command set)
    command(FUNCTION_SEL_A)                   'function selection A, disable internal Vdd regualtor
    data(INT_REG_ENABLE)
  else
    command(CMDSET_EXTENDED)                'function set (extended command set)
    command(FUNCTION_SEL_A)                   'function selection A, disable internal Vdd regualtor
    data(INT_REG_DISABLE)

PUB SetClockDivOscFreq(Frequency, Divisor)
'  DISP_CLKDIV_OSC = $D5 ' %A7..A0
' %A3..A0: Define divide ratio (D) of display clocks (DCLK): divide ratio = %A3..A0 + 1 (POR %0000) Range %0000-%1111
' %A7..A4: Set oscillator frequency, Fosc. Oscillator frequency increases with the value of %A7..A4 (POR %0111) Range %0000-%1111
  if Divisor =< %1111 AND Frequency =< %1111  
    command(CMDSET_EXTENDED)                'function set (extended command set)
    command(OLED_CMDSET_ENA)                  'OLED command set enabled
    command(DISP_CLKDIV_OSC)                  'set display clock divide ratio/oscillator frequency
    command((Frequency<<4) | Divisor)                              'set display clock divide ratio/oscillator frequency
    command(OLED_CMDSET_DIS)                  'OLED command set disabled
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

  command(EXTENDED_FUNCSET | NW_3_4_LINE | CURSOR_INVERT) 'extended function set (4-lines)
  command($06)                              'COM SEG direction
  command(FUNCTION_SEL_B)                   'function selection B, disable internal Vdd regualtor
  data($00)                                 'ROM CGRAM selection

  command(CMDSET_EXTENDED)                'function set (extended command set)
  command(OLED_CMDSET_ENA)                  'OLED command set enabled
  command(SET_SEG_PINS)                     'set SEG pins hardware configuration
  command($10)                              'set SEG pins hardware configuration
  command(FUNCTION_SEL_C)                   'function selection C
  command(VSL_INTERNAL | GPIO_HIZ_INP_DIS)    'function selection C
  command(SET_CONTRAST)                     'set contrast control
  command($7F)                              'set contrast control
  command(SET_PHASE_LEN)                    'set phase length
  command($F1)                              'set phase length
  command(SET_VCOMH_DESEL)                  'set VCOMH deselect level
  command($40)                              'set VCOMH deselect level
  command(OLED_CMDSET_DIS)                  'OLED command set disabled

  command(CMDSET_FUNDAMENTAL)               'function set (fundamental command set)
  command(CLEAR_DISPLAY)                    'clear display
  command($80)                              'set DDRAM address to $00
  command(US2066_DISP_ON)                   'display ON
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
