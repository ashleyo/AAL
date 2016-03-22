
	.equ GPIOBASE, 0x3f200000 @0x20000000 for Pi 1, value given is for Pi 2/3 

	.equ GPSEL0, 0  @ pins 0-9
	.equ GPSEL1, 4  @ pins 10-19
	.equ GPSEL2, 8  @ pins 20-29
	.equ GPSEL3, 12 @ pins 30-39
	.equ GPSEL4, 16 @ pins 40-49
	.equ GPSEL5, 20 @ pins 50-53
	@reserved
	.equ GPSET0, 28 @ pins 0-31 (*)
	.equ GPSET1, 32 @ pins 32-53 (*)
	@reserved
	.equ GPCLR0, 40 @ pins 0-31 (*)
	.equ GPCLR1, 44 @ pins 32-53 (*)
	@reserved * -> write only
	.equ GPLEV0, 52
	.equ GPLEV1, 56
	@reserved
	.equ GPEDS0, 64
	.equ GPEDS1, 68
	@reserved
	.equ GPREN0, 76
	.equ GPREN1, 80
	@reserved
	.equ GPFEN0, 88
	.equ GPFEN1, 92
	@reserved
	.equ GPHEN0, 100
	.equ GPHEN1, 104
	@reserved
	.equ GPLEN0, 112
	.equ GPLEN1, 116
	@reserved
	.equ GPAREN0, 124
	.equ GPAREN1, 128
	@reserved
	.equ GPAFEN0, 136
	.equ GPAFEN1, 140
	@reserved
	.equ GPPUD, 148
	.equ GPPUDCLK0, 152
	.equ GPPUDCLK1, 156
	
	.equ GP_OUTPUT, 1
	.equ GP_INPUT, 0
	.equ GP_FSEL_MASK, 7
	
	.equ PIN_ON, 1
	.equ PIN_OFF, 0
	
	@Use example, eg setting pin n as output leaving all else unaltered
	@[GPIOBASE,#(n DIV 10 * 4)] <- [GPIOBASE,#(n DIV 10 * 4)] 0xFFFF AND NOT (GP_FSEL_MASK << 3*(n MOD 10)) OR ((GP_OUTPUT) << 3*(n MOD 10))
	