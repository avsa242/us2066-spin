# us2066-spin
-------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for US2066-based alphanumeric OLED displays

## Salient Features

* I2C connection at up to 400kHz
* Set contrast level
* Set cursor attributes: blinking, inverted, shape
* Set text attributes: double-height, 5 and 6-pixel width text
* Inverted/normal display
* Display mirroring (horizontal/vertical/both)
* Uses lib.terminal for standard terminal routines

## Requirements

* P1/SPIN1: 1 extra core/cog for the PASM I2C driver
* P2/SPIN2: N/A

## Compiler Compatibility

* P1: OpenSpin (tested with 1.00.81)
* P2: FastSpin (tested with 4.1.10-beta)

## Limitations

* No scrolling support (chipset has horizontal scrolling support)
* No support for custom characters
* No support for parallel interface (not planned)

## TODO

- [ ] Customer character sets
- [ ] Scrolling support
- [ ] SPI variant

