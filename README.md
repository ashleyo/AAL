# AAL
Remodelled workflow for AAL
## Purpose
A pure ARMv7 Assembler library for controlling GPIO on a Raspberry Pi 3 under Raspbian
## Goals
+ Completeness
+ Python callable via ctype

## Issues
+ Incomplete
+ lacking extern directives
+ needs root permissions as GPIO is being mapped to /dev/mem - should be possible to move this to user space

Very early alpha

The following functions are/are being implemented
+ void init() - memory maps the GPIO
+ void set_pin_as(int pin, enum INPUT|OUTPUT) - sets a GPIO pin as an input or output
+ void change_pin_state(int pin, enum ON|OFF) -
+ void clean_up() - releases resources etc
