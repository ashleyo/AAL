.include "symbols.s"
	.global main
main:
	STMFD SP!, {LR}	    @preserve any necessary registers

	BL init
	
	MOV R0, #21
	BL set_pin_as_output
						
	MOV R0, #21
	MOV R1, #PIN_ON
	BL change_pin_state	@Turn on p21
	
	MOV R0, #1
	BL sleep		@wait one second
								
	MOV R0, #21
	MOV R1, #PIN_OFF
	BL change_pin_state	@turn off p21

	BL clean_up
    
	LDMFD SP!, {LR}	    	@restore stacked registers
	MOV R7, #1		@and bail
	SWI 0

	
@Enter with pin number in R0
@Function in R1 - 0 = off, 1 = on
	.global change_pin_state
change_pin_state:
	LDR R3, ADD_MMGPIOBASE
	LDR R3, [R3]
	MOV R2, #1
	MOV R2, R2, LSL R0
	CMP R1, #PIN_ON
	STREQ R2, [R3, #GPSET0] 
	STRNE R2, [R3, #GPCLR0]
	MOV PC, LR
    
@No parameters
@Clears memory mapping of GPIO
	.global clean_up
clean_up:
	STMFD SP!, {LR}
	LDR R0, ADD_MMFH	@retrieve file handle
	LDR R0, [R0]
	BL close		@ and close (deletes mmap)
	LDMFD SP!, {LR}
	MOV PC, LR

@No parameters
@Sets up memory mapping of GPIO
@needs sudo equivalence (to access /dev/mem)
	.global init
init:
	STMFD SP!, {LR}
	SUB SP, SP, #16
openfile:
	LDR R0, .addr_file
	LDR R1, .flags
	BL open		@get a file handle to a file in /dev/mem
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
	BL mmap 	@ See http://man7.org/linux/man-pages/man2/mmap.2.html
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
	ADD SP, SP, #16
	LDMFD SP!, {LR}
	MOV PC, LR  

@R0 contains target pin number
	.global set_pin_as_output
set_pin_as_output:
	STMFD SP!, {LR}
	
	BL PMM10 @ R0 = pin mod 10, R1 = pin div 10	
    
	MOV R1, R1, LSL #2 @ multiply R1 by 4 to give GPIO reg offset in words
	ADD R0, R0, R0, LSL #1 @ multiply R0 by 3 to give bit offset inside register
	
	LDR R3, ADD_MMGPIOBASE
	ADD R3, R3, R1		@adjust R3 to point at GPSELn
	LDR R2, [R3]	    	@fetch correct GPSEL register
	MOV R1, #0x7
	MOV R1, R1, LSL R0
	BIC R2, R2, R1
	STR R2, [R3]		@write it back
	MOV R1, #0x1	
	ORR R2, R2, R1, LSL R0
	STR R2, [R3]		@write it back
	
	LDMFD SP!, {LR}
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

.addr_file:		.word .file
.flags:			.word 0x00181002
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

	


	
	
