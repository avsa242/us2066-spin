{
    --------------------------------------------
    Filename: OLED-US2066-Demo.spin
    Description: Demo of the US2066 driver
    Author: Jesse Burt
    Copyright (c) 2022
    Created Dec 30, 2017
    Updated Sep 16, 2022
    See end of file for terms of use.
    --------------------------------------------
}
CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User modifiable constants
    LED         = cfg#LED1
    SER_BAUD    = 115_200

' uncomment one of the below pairs, depending on your display size
'    WIDTH       = 20
'    HEIGHT      = 4
    WIDTH       = 16
    HEIGHT      = 2

    SCL_PIN     = 28
    SDA_PIN     = 29
    RESET_PIN   = 25        ' I/O pin attached to display's RESET pin
    I2C_FREQ    = 400_000
    SLAVE_BIT   = 0         ' Default slave address
' --

    DEMO_DELAY  = 2         ' Delay (sec) between different demos
    MODE_DELAY  = 1         ' Delay (sec) between different modes within a particular demo

OBJ

    cfg : "core.con.boardcfg.flip"
    time: "time"
    oled: "display.oled-alpha.us2066"
    ser : "com.serial.terminal.ansi"

PUB main{}

    setup{}
    oled.charattrs(oled#CHAR_PROC)              ' process/interpret ctrl chars

    greet_demo{}
    time.sleep(DEMO_DELAY)
    oled.clear{}

    count_demo{}
    time.sleep(DEMO_DELAY)
    oled.clear{}

    doubleheight_demo{}
    time.sleep(DEMO_DELAY)
    oled.clear{}

    contrast_demo{}
    time.sleep(DEMO_DELAY)
    oled.clear{}

    position_demo{}
    time.sleep(DEMO_DELAY)
    oled.clear{}

    cursor_demo{}
    time.sleep(DEMO_DELAY)
    oled.clear{}

    invert_demo{}
    time.sleep(DEMO_DELAY)
    oled.clear{}

    fontwidth_demo{}
    time.sleep(DEMO_DELAY)
    oled.clear{}

    mirror_demo{}
    time.sleep(DEMO_DELAY)
    oled.clear{}

    oled.stop{}
    repeat

PUB contrast_demo{} | i

    oled.position(0, 0)
    oled.printf1(string("Change contrast\nlevel:"), 0)
    case HEIGHT
        2:
            repeat i from -255 to 255 step 1
                oled.position(7, 1)
                oled.contrast(||(i))
                oled.decuns(||(i), 3)
                oled.char(" ")
                oled.hex(||(i), 2)
                time.msleep(10)
        4:
            oled.newline{}
            oled.doubleheight(1)

            repeat i from -255 to 255 step 1
                oled.position(0, 2)
                oled.contrast(||(i))
                oled.decuns(||(i), 3)
                oled.char(" ")
                oled.hex(||(i), 2)
                oled.char(" ")
                oled.bin(||(i), 8)
                time.msleep(10)

    oled.doubleheight(0)

PUB count_demo{} | i

    case HEIGHT
        2:
            oled.position(0, 0)
            oled.strln(string("Rapidly changing"))
            oled.strln(string("display contents"))
            time.sleep(3)
            oled.clear{}
            oled.strln(string("Compare to LCD!"))

            repeat i from 0 to 3000
                oled.position(0, 1)
                oled.printf1(string("i = %d"), i)
        4:
            oled.position(0, 0)
            oled.strln(string("Rapidly changing"))
            oled.strln(string("display contents"))
            oled.strln(string("(compare to LCD!)"))
            repeat i from 0 to 3000
                oled.position(0, 3)
                oled.printf1(string("i = %d"), i)

PUB cursor_demo{} | delay, dbl_mode

    delay := 25                                 ' milliseconds
    case HEIGHT
        2:
            repeat dbl_mode from 0 to 3 step 3
                oled.clear{}
                oled.doubleheight(dbl_mode)
                oled.cursormode(0)
                oled.position(0, 0)
                strdelay(string("No cursor  (0)"), delay)
                time.sleep(2)
                oled.clearline(0)

                oled.cursormode(1)
                oled.position(0, 0)
                strdelay(string("Block/blink(1)"), delay)
                time.sleep(2)
                oled.clearline(0)

                oled.cursormode(2)
                oled.position(0, 0)
                strdelay(string("Underscore (2)"), delay)
                time.sleep(2)
                oled.clearline(0)

                oled.cursormode(3)
                oled.position(0, 0)
                strdelay(string("Under./blink(3)"), delay)
                time.sleep(2)
        4:
            repeat dbl_mode from 0 to 2 step 2
                oled.clear{}
                oled.doubleheight(dbl_mode)
                oled.cursormode(0)
                oled.position(0, 0)
                strdelay(string("Cursor:"), delay)

                oled.position(0, 1)
                strdelay(string("None           (0)"), delay)
                time.sleep(2)
                oled.clearline(1)

                oled.cursormode(1)
                oled.position(0, 1)
                strdelay(string("Block/blink    (1)"), delay)
                time.sleep(2)
                oled.clearline(1)

                oled.cursormode(2)
                oled.position(0, 1)
                strdelay(string("Underscore     (2)"), delay)
                time.sleep(2)
                oled.clearline(1)

                oled.cursormode(3)
                oled.position(0, 1)
                strdelay(string("Underscore/blink(3)"), delay)
                time.sleep(2)

    oled.doubleheight(0)
    oled.cursormode(0)

PUB doubleheight_demo{} | mode, line

    case HEIGHT
        2:
            mode := 0
            repeat 6
                oled.doubleheight(mode)
                repeat line from 0 to 1
                    oled.position(0, line)
                    oled.str(string("Double-height"))
                time.sleep(MODE_DELAY)
                mode += 3
                if mode > 3
                    mode  := 0
            oled.doubleheight(0)
        4:
            repeat mode from 0 to 4
                oled.doubleheight(mode)
                oled.position(14, 0)
                oled.printf1(string("Mode %d"), mode)
                repeat line from 0 to 3
                    oled.position(0, line)
                    oled.str(string("Double-height"))
                time.sleep(MODE_DELAY)

PUB fontwidth_demo{} | px, dbl_mode

    oled.clear{}

    repeat dbl_mode from 0 to 3 step 3
        oled.doubleheight(dbl_mode)
        repeat 2
            repeat px from 6 to 5
                oled.fontwidth(px)
                oled.position(0, 0)
                oled.printf1(string("%d-pixel width"), px)
                time.sleep(MODE_DELAY)

    oled.fontwidth(5)
    oled.doubleheight(0)

PUB greet_demo{}

    case HEIGHT
        2:
            oled.position(0, 0)
            oled.str(@w16l1)
            time.sleep(1)

            oled.position(0, 1)
            oled.str(@w16l2)
            time.sleep(1)

        4:
            oled.position(0, 0)
            oled.str(@w20l1)
            time.sleep(1)

            oled.position(0, 1)
            oled.str(@w20l2)
            time.sleep(1)

            oled.position(0, 2)
            oled.str(@w20l3)
            time.sleep(1)

            oled.position(0, 3)
            oled.str(@w20l4)

    time.sleep(1)

PUB invert_demo{} | i

    oled.clear{}
    oled.position(0, 0)
    oled.str(string("Display"))

    repeat i from 1 to 3
        oled.displayinverted(TRUE)
        oled.position(WIDTH-8, HEIGHT-1)
        oled.str(string("INVERTED"))
        time.sleep(MODE_DELAY)
        oled.displayinverted(FALSE)
        oled.position(WIDTH-8, HEIGHT-1)
        oled.str(string("NORMAL  "))
        time.sleep(MODE_DELAY)

PUB mirror_demo{} | row, col

    oled.clear{}

    case HEIGHT
        2:
            row := 2
            col := WIDTH-12
        4:
            row := 0
            col := WIDTH-13

    oled.mirrorh(FALSE)
    oled.mirrorv(FALSE)
    oled.clearline(0)
    oled.position(0, 0)
    oled.str(string("Mirror OFF"))
    time.sleep(2)

    oled.mirrorh(TRUE)
    oled.mirrorv(FALSE)
    oled.clearline(0)
    oled.position(col, 0)
    oled.str(string("Mirror HORIZ."))
    time.sleep(2)

    oled.mirrorh(FALSE)
    oled.mirrorv(TRUE)
    oled.clearline(0)
    oled.position(0, row)
    oled.str(string("Mirror VERT."))
    time.sleep(2)

    oled.mirrorh(TRUE)
    oled.mirrorv(TRUE)
    oled.clearline(0)
    oled.position(col, row)
    oled.str(string("Mirror BOTH"))
    time.sleep(2)

    oled.clear{}
    oled.mirrorh(FALSE)
    oled.mirrorv(FALSE)

PUB position_demo{} | x, y

    repeat y from 0 to HEIGHT-1
        repeat x from 0 to WIDTH-1
            oled.position(0, 0)
            oled.printf2(string("Position %d,%d "), x, y)
            oled.position((x-1 #> 0), y)
            oled.char(" ")
            oled.char("-")
            time.msleep(25)

PRI strdelay(stringptr, delay)
' Display zero-terminated string with inter-character delay, in ms
    repeat strsize(stringptr)
        oled.char(byte[stringptr++])
        time.msleep(delay)

PUB setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))

    ' use default Propeller I2C pins and 100kHz. Specify reset pin
'    if oled.start(RESET_PIN)

    ' use all custom settings
    if oled.startx(SCL_PIN, SDA_PIN, RESET_PIN, I2C_FREQ, SLAVE_BIT, HEIGHT)
        ser.strln(string("US2066 driver started"))
    else
        ser.strln(string("US2066 driver failed to start - halting"))
        oled.stop{}
        time.msleep(500)
        ser.stop{}
        repeat

    oled.mirrorh(FALSE)
    oled.mirrorv(FALSE)
    oled.clear{}
    oled.position(0, 0)
    oled.displayvisibility(oled#NORM)
    time.msleep(100)

DAT
' Greet text
'                  0|    |    |    |15
    w16l1   byte{0}"Parallax P8X32A", 0
    w16l2   byte{1}"(US2066 2x16)  ", 0

'                  0|    |    |    |   |19
    w20l1   byte{0}"  Parallax P8X32A   ", 0
    w20l2   byte{1}"       on the       ", 0
    w20l3   byte{2}"    US2066 OLED     ", 0
    w20l4   byte{3}"        4x20        ", 0


DAT
{
Copyright 2022 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

