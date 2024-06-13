![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout 8: Rotary Encoder Controlling WS2812B

This is a verilog project to be realised in a "rideshare" open source ASIC organised by Tiny Tapeout.

For more, read the [Tiny Tapeout documentation](docs/info.md)

## How to use

Read the docs linked above, TBD

The rotary encoder adds/subtracts from a variable that determines which LED to turn on. Periodically, the chip sends out a signal for 12 LEDs out via ``uo0``, according to the WS2812B protocol. Further, the register value of the variable will be put out via ``uo2`` to ``uo5``. The button connected to ``in2`` toggles the LEDs.

## What is Tiny Tapeout?

TinyTapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip.
Each run, one or more tiles can be bought on the overall chip and filled with custom designs.

To learn more and get started yourself, visit https://tinytapeout.com and/or [Join the community](https://tinytapeout.com/discord).
