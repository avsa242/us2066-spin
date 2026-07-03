{
----------------------------------------------------------------------------------------------------
    Filename:       US2066-CustomCharDemo.spin
    Description:    Demo of the US2066 driver
        * custom character definition functionality
    Author:         Jesse Burt
    Started:        Dec 27, 2024
    Updated:        Jul 3, 2026
    Copyright (c) 2026 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}
' Uncomment the two lines below to use the driver with an SPI-connected display
'#define US2066_SPI
'#pragma exportdef(US2066_SPI)

' Same as the above, but with a bytecode-based SPI engine
'#define US2066_SPI_BC
'#pragma exportdef(US2066_SPI_BC)

' Uncomment the two lines below to use the driver with a bytecode-based I2C engine
'#define US2066_I2C_BC
'#pragma exportdef(US2066_I2C_BC)

' The default is to use the driver with a PASM-based I2C engine
' The bytecode-based engines are slow, but don't require an extra cog

con

    _clkmode    = xtal1+pll16x
    _xinfreq    = 5_000_000

' -- User modifiable constants
' uncomment one of the below pairs, depending on your display size
    WIDTH       = 20
    HEIGHT      = 4
'    WIDTH       = 16
'    HEIGHT      = 2
' --


obj

    time:   "time"
    oled:   "display.oled-alpha.us2066" |   {I2C} SCL=28, SDA=29, I2C_FREQ=400_000, I2C_ADDR=0, ...
                                            {SPI} CS=0, SCK=1, MOSI=2, MISO=3, ...
                                            RST=24, HEIGHT=HEIGHT
    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200


dat

    ' 5x8 custom character
    custom_char byte %11100
                byte %10100
                byte %10100
                byte %11000
                byte %10001
                byte %10011
                byte %10001
                byte %10001


pub main() | i

    setup()

    oled.clear()

    oled.char_attrs(0)                          ' don't interpret any chars as control-codes
    oled.char_rom(oled.ROM_A)                   ' select ROM character set A
    oled.char_gen(240)                          ' select number of pre-defined characters

    ' define up to 8 (0..7) custom characters
    oled.def_chars(0, @custom_char)             ' char_num, ptr_char_glyph
'    oled.def_chars(1, @custom_char)             ' char_num, ptr_char_glyph
'    oled.def_chars(2, @custom_char)             ' char_num, ptr_char_glyph
'    oled.def_chars(3, @custom_char)             ' char_num, ptr_char_glyph
'    oled.def_chars(4, @custom_char)             ' char_num, ptr_char_glyph
'    oled.def_chars(5, @custom_char)             ' char_num, ptr_char_glyph
'    oled.def_chars(6, @custom_char)             ' char_num, ptr_char_glyph
'    oled.def_chars(7, @custom_char)             ' char_num, ptr_char_glyph

    oled.clear()
    oled.pos_xy(0, 0)
    oled.strln(@"Custom characters: ")
    i := 0
    repeat 8
        oled.putchar(i++)

    repeat


pub setup()

    ser.start()
    time.msleep(30)
    ser.clear()
    ser.strln(@"Serial terminal started")

    if ( oled.start() )
        ser.strln(@"US2066 driver started")
    else
        ser.strln(@"US2066 driver failed to start - halting")
        repeat

    oled.mirror_h(FALSE)
    oled.mirror_v(FALSE)
    oled.visibility(oled.NORM)


dat
{
Copyright 2026 Jesse Burt

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

