This is a driver, or object, for the Parallax Propeller MCU (https://www.parallax.com/product/p8x32a-q44) to drive US2066-based OLED character displays, such as Newhaven Display's NHD-0420-CW-Ax3 series (http://www.newhavendisplay.com/nhd0420cway3-p-7829.html).

It was written using I2C as the low-level communication interface (thanks to Jon McPhalen for the I2C object!)

The object uses one extra cog/core for the I2C interface.
