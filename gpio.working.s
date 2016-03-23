@todo - see if this mess is still working
@ if it is cut over to the global MMGPIOBASE
@ and see if it breaks

	.include "symbols.s"
    	
	.global main
main:
	SUB SP,SP,#16	@reserve 4 stack words
openfile:
	LDR R0, .addr_file
	LDR R1, .flags
	BL open		@get a file handle to a file in /dev/mem
map:
	LDR R3, ADD_MMFH
	STR R0,[R3]  @saved copy of fh for tidy_up
	
	STR R0, [SP, #0] @ fh copy for mmap callq
	LDR R3, ADD_PAGPIOBASE
	LDR R3, [R3]
	STR R3, [SP, #4] @ GPIOBase passed as offset to mmap
	MOV R0, #0	@preferred address null (ie any)
	MOV R1, #0x1000 @page size
	MOV R2, #3	@access - presumably rw-x
	MOV R3, #1	@flags - presumably MAP_SHARED
	BL mmap @ See http://man7.org/linux/man-pages/man2/mmap.2.html
			@ calls mmap(r0,r1,r2,r3,sp[0],sp[4])
			@ r0 - enters with 0, returns with an actual pointer assigned by mmap
			@ r1 - flags for mmap
			@ r2 - access mode of the pseudo-file - needs to be r/w
			@ r3 - size of memory to map must be a whole number of pages, one page is adequate here
			@ sp[0] the file descriptor in /dev/mem previously obtained
			@ sp[4] the 'offset' within that, in this case the address of GPIOBASE
	
			@after this syscall , the pointer in R0 is *equivalent* to GPIOBASE

	LDR R3, ADD_MMGPIOBASE
	STR R0, [R3]
	@set a pin (21) as output
	@Enter here with 21 in R0
	
	@Preserve R4-R6
	@@@STMFD SP!, {R4-R6, LR} 		@Planning to use R4/5/6 as scratch space. Also preserve original LR
	@@@BL PMM10		
	LDR R3, ADD_MMGPIOBASE
	LDR R3, [R3]			@fetch and stash GPIOBASE, keep a working copy in R3
	
	LDR R2, [R3, #GPSEL2]		@fetch GPSEL2
	BIC R2, R2, #0x7 << 3	@clear bits b3 b4 b5
	STR R2, [R3, #GPSEL2]		@write it back
	ORR R2, R2, #0x1 << 3	@set b3
	STR R2, [R3, #GPSEL2]		@write it back
					
	MOV R0, #21
	MOV R1, #PIN_ON
	BL change_pin_state	@Turn on p21
	
	MOV R0, #1
	BL sleep		@wait one second
								
	MOV R0, #21
	MOV R1, #PIN_OFF
	BL change_pin_state	@turn off p21

tidy_up:
	LDR R0, ADD_MMFH	@retrieve file handle
	LDR R0, [R0]
	BL close		@ and close (deletes mmap)

	@@@LDMFD SP!, {R4-R6, LR} @Pull original values from stack

	ADD SP, SP, #16		@restore SP
	MOV R7, #1		@and bail
	SWI 0

	
@Enter with pin number in R0
@Function in R1 - 0 = off, 1 = on
change_pin_state:
	LDR R3, ADD_MMGPIOBASE
	LDR R3, [R3]
	MOV R2, #1
	MOV R2, R2, LSL R0
	CMP R1, #PIN_ON
	STREQ R2, [R3, #GPSET0]	@gpiobase+28 = GPSET0
	STRNE R2, [R3, #GPCLR0]
	MOV PC, LR
	
PMM10:
	@ Poor man's modulo 10
	@ On exit R0 = R0 Mod 10
	@ On exit R1 = R0 Div 10
	MOV R1, #0
loop:
	SUBS R0, R0, #10
	ADDPL R1, R1, #1
	BPL loop
	ADD R0, R0, #10
	MOV PC, LR

.addr_file: 		.word .file
.flags: 		.word 0x00181002
ADD_PAGPIOBASE:		.word PAGPIOBASE
ADD_MMGPIOBASE:		.word MMGPIOBASE
ADD_MMFH:		.word MMFH	
	
    	.data
PAGPIOBASE:
	.word GPIOBASE
MMGPIOBASE:
	.word 0
MMFH:
	.word 0
	.data
.file:
	.asciz "/dev/mem"

	


	
	
