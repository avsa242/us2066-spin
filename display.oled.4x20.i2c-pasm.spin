{
    --------------------------------------------
    Filename: display.oled.4x20.i2c.spin
    Author: Jesse Burt
    Version: 0.2
    Description: Object for driving displays
     based on the US2066 driver, such as
     Newhaven Display's NHD-0420CW-A*3
    Copyright (c) 2018
    See end of file for terms of use.
    --------------------------------------------
}

CON

  SLAVE_ADDR    =              %0111_100 << 1    '($78) - Default slave address of NHD420/US2066
  SLAVE_WR      = SLAVE_ADDR | %0000_0000
  SLAVE_RD      = SLAVE_ADDR | %0000_0001

  CR            = 10  'Carriage-return
  NL            = 13  'Newline
  SP            = 32  'Space

OBJ

  us2066: "core.con.us2066"
  time  : "time"
  i2c   : "jm_i2c_fast"

VAR

  byte  _dblht_mode

PUB null
''This is not a top-level object

PUB start(scl, sda, reset, hz): okay
'' I2C Effective Bus rates from 1221 up to 400000
  okay := i2c.setupx (scl, sda, hz)

  dira[reset] := 1
  outa[reset] := 0

  outa[reset] := 1
  time.MSleep (1)

PUB stop

  i2c.terminate

PUB Backspace | pos, col, row
'' The display controller doesn't seem to handle Backspace by itself, so we have to implement it in software
'' We query the controller for the current cursor position in DDRAM and write a space over the previous location.
  pos := GetPos
  case pos
    $00..$13:
      if pos > $00
        Position(pos-1, 0)
        Char_Literal ($20)
        Position(pos-1, 0)
      else
        Position (0, 0)     'Stop upper-left / HOME
        Char_Literal ($20)
        Position (0, 0)
'        Position(19, 3)    'Wrap around to end of display
'        Char_Literal ($20)
'        Position(19, 3)

    $20..$33:
      if pos > $20
	col := pos-$20
        Position(col-1, 1)
        Char_Literal ($20)
        Position(col-1, 1)
      else
        Position(19, 0)
        Char_Literal ($20)
        Position(19, 0)
    $40..$53:
      if pos > $40
	col := pos-$40
        Position(col-1, 2)
        Char_Literal ($20)
        Position(col-1, 2)
      else
        Position(19, 1)
        Char_Literal ($20)
        Position(19, 1)
    $60..$73:
      if pos > $60
	col := pos-$60
        Position (col-1, 3)
        Char_Literal ($20)
        Position (col-1, 3)
      else
        Position (19, 2)
        Char_Literal ($20)
        Position (19, 2)
    OTHER: Position (0, 0)     'Not sure how else to handle this, atm


PUB Char_Literal(ch)
'' Display single character (pass data through without processing it first)
  data(ch)

PUB Char(ch)
'' Display single character. Display controller doesn't handle control characters
''  on its own, so we have to implement processing to handle some of them.
  case ch
    8, $7F:
      Backspace
    10:
      CarriageReturn
    12:
      Clear
    13:
      Newline
    OTHER:
      data(ch)

PUB Clear
'' Clear display
  command(us2066#CLEAR_DISPLAY)

PUB ClearLine(line)
'' Clear / erase 'line'
  if lookdown (line: 0..4)
    Position(0, line)
    repeat 20
      Char(" ")

PUB CMDSet_Extended
'' Enable Extended command set
'' We have to store the state of the double-height font setting on the host,
''  otherwise, when switching back and forth between command sets, the setting
''  gets lost.
  if _dblht_mode
    command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN | us2066#EXT_REG_RE)
  else
    command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#EXT_REG_RE)

PUB CMDSet_Extended_IS
'' Enable Extended command set
'' We have to store the state of the double-height font setting on the host,
''  otherwise, when switching back and forth between command sets, the setting
''  gets lost.
  if _dblht_mode
    command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN | us2066#EXT_REG_RE | us2066#EXT_REG_IS)
  else
    command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#EXT_REG_RE)

PUB CMDSet_Fundamental
'' Enable Fundemental command set
'' We have to store the state of the double-height font setting on the host,
''  otherwise, when switching back and forth between command sets, the setting
''  gets lost.
  if _dblht_mode
    command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
  else
    command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4)

PUB CMDSet_OLED(enabled)
'' Enable OLED command set
'' enable: %0: OLED command set is disabled (POR)   %1: OLED command set is enabled
  enabled := (||enabled <# 1)
  command(us2066#OLED_CHARACTERIZE | enabled)

PUB CarriageReturn | pos, row
'' Carriage-return / return to beginning of line
  pos := GetPos
  case pos
    $00..$13: row := 0
    $20..$33: row := 1
    $40..$53: row := 2
    $60..$73: row := 3
    OTHER: row := 0     'Not sure how else to handle this, atm
  Position (0, row)

PUB GetPos: addr | data_in
'' Gets current position in DDRAM
  command($00)
  i2c.start
  i2c.write (SLAVE_RD)
  addr := i2c.read (TRUE)
  i2c.stop

PUB Home
'' Returns cursor to home position (0, 0), without clearing the display
  command(us2066#HOME_DISPLAY)

PUB Newline: row | pos
'' The display controller doesn't seem to handle newline by itself, so we have to implement it in software
'' We query the controller for the current cursor position in DDRAM and increment the row (wrapping to row 0)
  pos := GetPos
  case pos
    $00..$13: row := 0
    $20..$33: row := 1
    $40..$53: row := 2
    $60..$73: row := 3
    OTHER: row := 0     'Not sure how else to handle this, atm

  row := (row + 1) & 3
  Position (0, row)

PUB Position(column, row) | offset
'' Sets current cursor position
'' *The displayable memory locations aren't contiguous from row to row
  case row
    0: offset := $00 + column <# $13
    1: offset := $20 + column <# $33
    2: offset := $40 + column <# $53
    3: offset := $60 + column <# $73
    OTHER: offset := 0

  command(us2066#SET_DDRAM_ADDR|offset )

PUB SetBiDirection(com, seg)
'' Common (com) and Segment (seg) Bi-direction function
'' com: %1: COM0 -> COM31   %0: COM31 -> COM0
'' seg: %1: SEG99 -> SEG0   %1: SEG0 -> SEG99
  com := (||com <# 1) << 1
  seg := (||seg <# 1)

  CMDSet_Extended
  command(us2066#ENTRY_MODE_SET | com | seg)
  CMDSet_Fundamental

PUB SetCharGenCharROM(char_gen, char_rom)
'' Select number of pre-defined vs free user-defined character cells (char_gen)
'' Select ROM font / character set (char_rom)
'' char_gen:  %00 CGROM: 240 CGRAM: 8
''            %01 CGROM: 248 CGRAM: 8
''            %10 CGROM: 250 CGRAM: 6
''            %11 CGROM: 256 CGRAM: 0
'' char_rom:  %00 ROM A
''            %01 ROM B
''            %10 ROM C
''            %11 Invalid (ignored)
  char_gen := (||char_gen <# 3)
  char_rom := (||char_rom <# 2) << 2
  
  CMDSet_Extended
  command(us2066#FUNCTION_SEL_B)
  data(char_gen | char_rom)
  CMDSet_Fundamental

PUB SetClockDivOscFreq(frequency, divisor)
'' Set display clock oscillator frequency
'' Set display clock divide ratio
'' divisor:    DCLKs   Range %0000..%1111 (POR %0000)
'' frequency:  (Freq)  Range %0000..%1111 (POR %0111)
  CMDSet_Extended
  CMDSet_OLED (TRUE)

  frequency := (||frequency <# 15) << 4
  divisor   := (||divisor <# 15)

  command(us2066#DISP_CLKDIV_OSC)
  command(frequency | divisor)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB SetContrast(level)
'' Set display contrast level
'' level: 00..$FF (POR $7F)
  level := (||level <# $FF)

  CMDSet_Extended
  CMDSet_OLED (TRUE)
  command(us2066#SET_CONTRAST)
  command(level)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB SetDisplayCursorBlink(disp_onoff, cursor_onoff, blink_onoff)
'' Set display visibility on / off
'' Set cursor visibility on / off
'' Set cursor blink on / off
''
'' disp_onoff:    %0: Display Off (POR)   %1: Display On
'' cursor_onoff:  %0: Cursor Off (POR)    %1: Cursor On
'' blink_onoff:   %0: Blink Off (POR)     %1: Blink On
  disp_onoff := (||disp_onoff <# 1) << 2
  cursor_onoff := (||cursor_onoff <# 1) << 1
  blink_onoff := (||blink_onoff <# 1)

  command(us2066#DISPLAY_ONOFF | disp_onoff | cursor_onoff | blink_onoff)

PUB SetDisplayLines(lines)
'' Set number of visible lines (3 or 4)
  case lines
    1: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_1_3)
    2: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4)
    3: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_1_3)
    4: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4)
    OTHER: command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4)

PUB SetDoubleHeight(mode)
'' Set double-height font style mode
''  0: Standard height font all 4 lines / double-height disabled
''  1: Bottom two lines form one double-height line (top 2 lines standard height, effectively 3 lines)
''  2: Middle two lines form one double-height line (top and bottom lines standard height, effectively 3 lines)
''  3: Top and bottom lines each form a double-height line (effectively 2 lines)
''  4: Top two lines form one double-height line (bottom 3 lines standard height, effectively 3 lines)
''  Any other value will be treated the same as 0
'' *Takes effect immediately, i.e., current screen contents will change!
  _dblht_mode := mode
  CMDSet_Extended
  command(us2066#EXTENDED_FUNCSET | us2066#NW_3_4_LINE)
  case (_dblht_mode)
    0:
      CMDSet_Fundamental
    1:
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_BOTTOM)
      command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    2:
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_MIDDLE)
      command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    3:
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_BOTH)
      command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    4:
      command(us2066#DBLHEIGHT | us2066#DBLHEIGHT_TOP)
      command(us2066#FUNCTION_SET_0 | us2066#DISP_LINES_2_4 | us2066#DBLHT_FONT_EN)
    OTHER:
      CMDSet_Fundamental

PUB SetFadeOut_Blinking(fade_blink_mode, interval)
'' Set Fade Out and Blinking mode
''  fade_blink_mode
''    0: Disable fade out / blinking (RESET)
''    1: Enable fade out (contrast fades out until display off, and stays off)
''    2: Enable blink (contrast fades out until display off, then fades back on)
''    Any other value is treated as 0
''  interval - Time interval for each fade step
''    %0000..%1111 = 8 frames..128 frames
  case fade_blink_mode
    0: fade_blink_mode := %00 << 4
    1: fade_blink_mode := %10 << 4
    2: fade_blink_mode := %11 << 4
    OTHER: fade_blink_mode := %00 << 4
  interval := (||interval <# 15)

  CMDSet_Extended
  CMDSet_OLED (TRUE)
  command(us2066#FADEOUT_BLINK)
  command(fade_blink_mode | interval)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB SetFontCursorLineMode(fw_fontwidth, bw_cursor_inverting, nw_4line_dispmode)
'' Set Font width (5 or 6 dots)
'' Enable/disable black/white inverting of cursor
'' Set 3 or 4-line display mode, or 1 or 2-line display mode
'' FW:  %1: 6-dot font width            %0: 5-dot font width (POR)
'' BW:  %1: B/W cursor invert enabled   %0: B/W cursor invert disabled (POR)
'' NW:  %1: 3 or 4-line display mode    %0: 1 or 2-line display mode
  fw_fontwidth :=         (||fw_fontwidth         <# 1) << 2
  bw_cursor_inverting :=  (||bw_cursor_inverting  <# 1) << 1
  nw_4line_dispmode :=    (||nw_4line_dispmode    <# 1)
  
  CMDSet_Extended
  command(us2066#EXTENDED_FUNCSET | fw_fontwidth | bw_cursor_inverting | nw_4line_dispmode)
  CMDSet_Fundamental

PUB SetInternalReg(enable)
'' Enables the internal regulator (5V operation) if non-zero, disables it otherwise (low-voltage operation)
  CMDSet_Extended
  command(us2066#FUNCTION_SEL_A)
  case enable
    0:     data($00)
    OTHER: data(us2066#INT_REG_ENABLE)
  CMDSet_Fundamental

PUB SetPhaseLength(phase2, phase1)
'' Set length of phase 1 and 2 of segment waveform of the driver
'' phase2:  1..15 (1 to 15 DCLK, 0 is invalid and ignored, POR=7)   phase1: 0..15 (0 to 32 DCLK)
  phase2  := (1#> ||phase2 <# 15) << 4
  phase1  := (||phase1 <# 15) << 1

  CMDSet_Extended
  CMDSet_OLED (TRUE)
  command(us2066#SET_PHASE_LEN)
  command(phase2 | phase1)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental
  
PUB SetSEGPinCFG(seg_lr_remap, pin_cfg)
'' Change mapping between display data column address and segment driver.
'' NOTE: Only affects subsequent data input. Data already displayed/in DDRAM will be unchanged.
'' seg_lr_remap:  %0: Disable SEG left/right remap  %1: Enable SEG left/right remap
'' pin_cfg:       %0: Sequential SEG pin cfg        %1: Alternative (odd/even) SEG pin cfg
  seg_lr_remap  := (||seg_lr_remap <# 1) << 5
  pin_cfg       := (||pin_cfg <# 1) << 4

  CMDSet_Extended
  CMDSet_OLED (TRUE)  
  command(us2066#SET_SEG_PINS)
  command(seg_lr_remap | pin_cfg)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB SetScrollQty(pixels)

  pixels := (||pixels <# 48)
  CMDSet_Extended
  command(us2066#SET_SCROLL_QTY | pixels)
  CMDSet_Fundamental

PUB SetShiftScroll(lines)
'' Which lines to enable scrolling
'' MSB: line 4 -> %0000 <- LSB: line 1
  lines := (||lines <# 15)
  CMDSet_Extended_IS
  command(us2066#SHIFT_SCROLL_ENA | lines)
  CMDSet_Fundamental

PUB SetVcomhDeselectLevel(level)
'' Adjust Vcomh regulator output
'' level: %000: ~0.65*Vcc
''        %001: ~0.71*Vcc
''        %010: ~0.77*Vcc (POR)
''        %011: ~0.83*Vcc
''        %100: 1*Vcc
  level := (||level <# 4) << 4

  CMDSet_Extended
  CMDSet_OLED (TRUE)
  command(us2066#SET_VCOMH_DESEL)
  command(level)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB SetVSLGPIO(vsl, gpio)
'' Set internal or external VSL
'' Set state of GPIO pin
'' vsl:    %0: Internal VSL (POR)  %1: Enable external VSL
'' gpio:  %00: GPIO pin HiZ, input disabled (always read as low)
'' gpio:  %01: GPIO pin HiZ, input enabled
'' gpio:  %10: GPIO pin output, low (RESET)
'' gpio:  %11: GPIO pin output, high 
  vsl   := (||vsl <# 1) << 7
  gpio  := (||gpio <# 3)
  
  CMDSet_Extended
  CMDSet_OLED (TRUE)
  command(us2066#FUNCTION_SEL_C)
  command(vsl | gpio)
  CMDSet_OLED (FALSE)
  CMDSet_Fundamental

PUB Str(stringptr)
'' Display zero-terminated string (use if you want to be able to use newline characters in the string)
  repeat strsize(stringptr)
    Char(byte[stringptr++])

PUB Str_Literal(stringptr)
'' Display zero-terminated string. Don't process input.
  repeat strsize(stringptr)
    Char_Literal(byte[stringptr++])

PUB StrDelay(stringptr, delay)' XXX May be removed in the future
'' Display zero-terminated string with inter-character delay, in ms
  repeat strsize(stringptr)
    Char(byte[stringptr++])
    time.MSleep (delay)

PUB StrDelay_Literal(stringptr, delay)' XXX May be removed in the future
'' Display zero-terminated string with inter-character delay, in ms. Don't process input.
  repeat strsize(stringptr)
    Char_Literal(byte[stringptr++])
    time.MSleep (delay)

PRI command(cmd) | ackbit

  i2c.start
  ackbit := i2c.write (SLAVE_WR)            'US2066 Slave address
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
  ackbit := i2c.write (SLAVE_WR)            'US2066 Slave address
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
