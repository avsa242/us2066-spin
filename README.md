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

## Requirements

P1/SPIN1:
* spin-standard-library
* P1/SPIN1: 1 extra core/cog for the PASM I2C engine
* terminal.common.spinh (provided by spin-standard-library)

P2/SPIN2:
* p2-spin-standard-library
* terminal.common.spin2h (provided by p2-spin-standard-library)

## Compiler Compatibility

| Processor | Language | Compiler               | Backend     | Status                |
|-----------|----------|------------------------|-------------|-----------------------|
| P1        | SPIN1    | FlexSpin (5.9.14-beta) | Bytecode    | OK                    |
| P1        | SPIN1    | FlexSpin (5.9.14-beta) | Native code | OK                    |
| P1        | SPIN1    | OpenSpin (1.00.81)     | Bytecode    | Untested (deprecated) |
| P2        | SPIN2    | FlexSpin (5.9.14-beta) | NuCode      | FTBFS                 |
| P2        | SPIN2    | FlexSpin (5.9.14-beta) | Native code | Not yet implemented   |
| P1        | SPIN1    | Brad's Spin Tool (any) | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | Propeller Tool (any)   | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | PNut (any)             | Bytecode    | Unsupported           |

## Limitations

* No scrolling support (chipset has horizontal scrolling support)
* No support for custom characters
* No support for parallel interface (not planned)
* No support for SPI interface
