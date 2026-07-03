# us2066-spin
-------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for US2066-based alphanumeric OLED displays

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.


## Salient Features

* I2C connection at up to 400kHz (P1, P2)
* SPI connection at up to 1MHz (P1: 25kHz bytecode or 1MHz PASM, P2: up to 1MHz)
* Set contrast level
* Set cursor attributes: blinking, inverted, shape
* Set text attributes: double-height, 5 and 6-pixel width text
* Inverted/normal display
* Display mirroring (horizontal/vertical/both)
* Define custom characters


## Requirements

P1/SPIN1:
* spin-standard-library
* P1/SPIN1: 1 extra core/cog for the PASM I2C/SPI engine (none if the bytecode-based engine is used)
* terminal.common.spinh (provided by spin-standard-library)

P2/SPIN2:
* p2-spin-standard-library
* terminal.common.spin2h (provided by p2-spin-standard-library)


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (7.6.11)      | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (7.6.11)      | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (7.6.11)      | NuCode       | Runtime issues        |
| P2        | SPIN2    | FlexSpin (7.6.11)      | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Hardware compatibility

* Tested with Newhaven displays NHD-0420CW-Ax3 (20x4)
* Tested with Newhaven displays NHD-0216CW-Ax3 (16x2)


## Limitations

* No scrolling support (chipset has horizontal scrolling support)
* No support for parallel interface

