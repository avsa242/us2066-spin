This is a driver/object, for the Parallax Propeller MCU (https://www.parallax.com/product/p8x32a-q44) to drive US2066-based OLED character displays, such as Newhaven Display's NHD-0420-CW-Ax3 series (http://www.newhavendisplay.com/nhd0420cway3-p-7829.html).

Currently, only the I2C interface of this chip is supported (it can also be interfaced with using SPI and parallel busses). When I feel the driver is ready to be called "version 1.0," I will attempt an SPI version. I have no immediate plans for a parallel-bus version.


NOTES:
------

* This uses a few other objects from an external repository, Parallax's spin-standard-library (https://github.com/parallaxinc/spin-standard-library.git)
* Additional cores/cogs used: 1, for the I2C driver (the demo uses a 2nd for the serial terminal)


THANKS:
-------

Jon McPhalen

Parallax Forums

Newhaven Displays Forums
