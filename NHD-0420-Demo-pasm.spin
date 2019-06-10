{
    --------------------------------------------
    Filename: NHD-0420-Demo.spin
    Description: Demonstrates functionality of the
     4x20 OLED Display object
    Author: Jesse Burt
    Copyright (c) 2018
    Created Dec 30, 2017
    Updated Jun 10, 2019
    See end of file for terms of use.
    --------------------------------------------
}
CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

    RESET       = 25        'I/O pin attached to display's RESET pin

    DEMO_DELAY  = 2         'Delay (sec) between different demos
    MODE_DELAY  = 1         'Delay (sec) between different modes within a particular demo

    LED         = cfg#LED1

OBJ

    cfg : "core.con.boardcfg.flip"
    time: "time"
    oled: "display.oled.4x20.i2c-pasm"
    int : "string.integer"
    ser : "com.serial.terminal"

PUB Main

    Setup

    Greet_Demo
    time.Sleep (DEMO_DELAY)
    oled.Clear

    Count_Demo
    time.Sleep (DEMO_DELAY)
    oled.Clear

    DoubleHeight_Demo
    time.Sleep (DEMO_DELAY)
    oled.Clear

    Contrast_Demo
    time.Sleep (DEMO_DELAY)
    oled.Clear

    Position_Demo
    time.Sleep (DEMO_DELAY)
    oled.Clear

    Cursor_demo
    time.Sleep (DEMO_DELAY)
    oled.Clear

    Invert_demo
    time.Sleep (DEMO_DELAY)
    oled.Clear

    FontWidth_Demo
    time.Sleep (DEMO_DELAY)
    oled.Clear

    Mirror_Demo
    time.Sleep (DEMO_DELAY)
    oled.Clear

    oled.Stop
    Flash (LED, 100)

PUB Contrast_Demo | i

    oled.Position (0, 0)
    oled.Str (string("Change contrast", oled#NL, "level:"))
    oled.Newline
    oled.DoubleHeight (1)

    repeat i from -255 to 255 step 1
        oled.Position (0, 2)
        oled.Contrast (||i)
        oled.Str (int.DecPadded (||i, 3))
        oled.Char_Literal (32)
        oled.Str (int.Hex(||i, 2))
        oled.Char_Literal (32)
        oled.Str (int.Bin(||i, 8))
        time.MSleep (10)

    oled.DoubleHeight (0)

PUB Count_Demo | i

    oled.Position (0, 0)
    oled.Str (string("Rapidly changing", oled#NL, "display contents", oled#NL, "(compare to LCD!)", oled#NL, "i = "))

    repeat i from 0 to 3000
        oled.Position (4, 3)
        oled.Str (int.Dec (i))

PUB Cursor_demo | delay, dbl_mode

    delay := 25
    repeat dbl_mode from 0 to 2 step 2
        oled.Clear
        oled.DoubleHeight (dbl_mode)
        oled.SetCursor (0)
        oled.Position (0, 0)
        oled.StrDelay (string("Cursor:"), delay)

        oled.Position (0, 1)
        oled.StrDelay (string("None            (0)"), delay)
        time.Sleep (2)
        oled.ClearLine (1)

        oled.SetCursor (1)
        oled.Position (0, 1)
        oled.StrDelay (string("Block/blink     (1)"), delay)
        time.Sleep (2)
        oled.ClearLine (1)

        oled.SetCursor (2)
        oled.Position (0, 1)
        oled.StrDelay (string("Underscore      (2)"), delay)
        time.Sleep (2)
        oled.ClearLine (1)

        oled.SetCursor (3)
        oled.Position (0, 1)
        oled.StrDelay (string("Underscore/blink(3)"), delay)
        time.Sleep (2)

    oled.DoubleHeight (0)
    oled.SetCursor (0)

PUB DoubleHeight_Demo | mode, line

    repeat mode from 0 to 4
        oled.DoubleHeight (mode)
        oled.Position (14, 0)
        oled.Str (string("Mode "))
        oled.Str (int.Dec(mode))
        repeat line from 0 to 3
            oled.Position (0, line)
            oled.Str (string("Double-height"))
        time.Sleep (MODE_DELAY)

PUB FontWidth_demo | px, dbl_mode

    oled.Clear
    oled.Str (string("Font width..."))
    oled.Position (2, 1)
    oled.Str (string("pixels"))

    repeat dbl_mode from 0 to 2 step 2
        oled.DoubleHeight (dbl_mode)
        repeat 2
            repeat px from 6 to 5
                oled.Position (0, 1)
                oled.FontWidth (px)
                oled.Str (int.Dec (px))
                time.Sleep (MODE_DELAY)

    oled.FontWidth (5)
    oled.DoubleHeight (0)

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

    time.Sleep (1)

PUB Invert_demo | i

    oled.Clear
    oled.DoubleHeight (1)
    oled.Position (0, 0)
    oled.Str (string("Display..."))

    repeat i from 1 to 3
        oled.InvertDisplay (TRUE)
        oled.Position (0, 2)
        oled.Str (string("INVERTED"))
        time.Sleep (MODE_DELAY)
        oled.InvertDisplay (FALSE)
        oled.Position (0, 2)
        oled.Str (string("NORMAL  "))
        time.Sleep (MODE_DELAY)

    oled.DoubleHeight (0)

PUB Mirror_Demo | i

    oled.Clear
    oled.DoubleHeight (2)
    oled.Str (string("Mirror..."))

    oled.MirrorH (FALSE)
    oled.MirrorV (FALSE)
    oled.ClearLine (1)
    oled.Position (0, 1)
    oled.Str (string("OFF"))
    time.Sleep (2)

    oled.MirrorH (TRUE)
    oled.MirrorV (FALSE)
    oled.ClearLine (1)
    oled.Position (0, 1)
    oled.Str (string("HORIZONTAL"))
    time.Sleep (2)

    oled.MirrorH (FALSE)
    oled.MirrorV (TRUE)
    oled.ClearLine (1)
    oled.Position (0, 1)
    oled.Str (string("VERTICAL"))
    time.Sleep (2)

    oled.MirrorH (TRUE)
    oled.MirrorV (TRUE)
    oled.ClearLine (1)
    oled.Position (0, 1)
    oled.Str (string("BOTH"))
    time.Sleep (2)

    oled.Clear
    oled.MirrorH (FALSE)
    oled.MirrorV (FALSE)
    oled.DoubleHeight (0)

PUB Position_Demo | x, y

    repeat y from 0 to 3
        repeat x from 0 to 19
            oled.Position(0, 0)
            oled.Str (string("Position "))
            oled.Str (int.DecPadded(x, 2))
            oled.Char_Literal (",")
            oled.Str (int.Dec(y))
            oled.Position((x-1 #> 0), y)
            oled.Char($20)
            oled.Char("-")
            time.MSleep (25)

PUB Setup

    repeat until ser.Start (115_200)
    ser.Clear
    ser.Str (string("Serial terminal started", ser#NL))
    if oled.Start (RESET)                               'Change RESET CONstant at the top of this file to match your connection
'    if oled.Startx (scl, sda, resetpin, hz, slave_bit) 'Alternatively, Use this line instead of the above to use all custom settings
        ser.Str (string("us2066 object started", ser#NL))
    else
        ser.Str (string("us2066 object failed to start", ser#NL))
        oled.stop
        time.MSleep (500)
        ser.Stop
        Flash (cfg#LED1, 500)

    oled.MirrorH (FALSE)
    oled.MirrorV (FALSE)
    oled.Clear
    oled.Position (0, 0)
    oled.EnableDisplay (TRUE)
    time.MSleep (100)

PUB Flash(led_pin, delay_ms)

    dira[led_pin] := 1
    repeat
        !outa[led_pin]
        time.MSleep (delay_ms)

DAT
'                0|    |    |    |   |19
    line1 byte{0}"  Parallax P8X32A   ", 0
    line2 byte{1}"       on the       ", 0
    line3 byte{2}"  Newhaven Display  ", 0
    line4 byte{3}"  NHD420 4x20 OLED  ", 0

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
