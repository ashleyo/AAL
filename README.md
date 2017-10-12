# AAL
## Purpose
A pure ARMv7 Assembler library for controlling GPIO on a Raspberry Pi 3 under Raspbian
## Goals
+ Completeness
+ Python callable via ctype

## Issues
+ Incomplete
+ needs root permissions as GPIO is being mapped to /dev/mem - should be possible to move this to user space

## Status, Progress, Immediate Goals
Early alpha. What's there is tested, but there is much to yet implement.

The following functions are/are being implemented
+ void init() - memory maps the GPIO
+ void set_pin_as(int pin, enum INPUT|OUTPUT) - sets a GPIO pin as an input or output
+ void change_pin_state(int pin, enum ON|OFF) -
+ void clean_up() - releases resources etc

All implemented but set_pin_as is currently present as set_pin_as_output(int pin) - lack hardware to test input is 
working right now!

Tested working with pins 4,21 as o/p. Need more patch wires to make testing easier!
Added makefile to build as shared library - tested and working from c

Next: test from python using ctype

## Installation and use
The library is intended to be installed as a shared library and linked as such. Installation is best achieved by using the included makefile and `make install`. Note that this will require admin priviliges so probably `sudo make install` in practice. 

In use, the gcc link stage command should include `-lgpiot` to reference the shared library: notice that neither the 'lib' prefix nor the file extension (both are assumed) should be provided to gcc. 

To use any of the symbolic names and enums in your own code you would also want to `.include symbols.s` in your own source file.
