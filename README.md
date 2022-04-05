# us2066-spin
-------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for US2066-based alphanumeric OLED displays

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* I2C connection at up to 400kHz
* Set contrast level
* Set cursor attributes: blinking, inverted, shape
* Set text attributes: double-height, 5 and 6-pixel width text
* Inverted/normal display
* Display mirroring (horizontal/vertical/both)
* Uses lib.terminal for standard terminal routines

## Requirements

P1/SPIN1:
* spin-standard-library
* P1/SPIN1: 1 extra core/cog for the PASM I2C engine

P2/SPIN2:
* p2-spin-standard-library

## Compiler Compatibility

* P1/SPIN1 FlexSpin (bytecode): OK, tested with 5.9.10-beta
* P1/SPIN1 FlexSpin (native): OK, tested with 5.9.10-beta
* P2/SPIN2 FlexSpin (nu-code): Untested
* P2/SPIN2 FlexSpin (native): OK, tested with 5.9.10-beta
* P1/SPIN1 OpenSpin (bytecode): Untested (deprecated)
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* No scrolling support (chipset has horizontal scrolling support)
* No support for custom characters
* No support for parallel interface (not planned)

