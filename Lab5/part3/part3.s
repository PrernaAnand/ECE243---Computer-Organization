	  .text                   // executable code follows
          .global _start          
		  
_start:         ldr	 r5,  =0xff200020     //hex address
		ldr	 r6,  =50000000       //load 50 mill
		ldr	 r9,  =0xfffec600
		str	 r6,  [r9]            //str 50 mill in load register 
		mov	 r6,  #3              //011
		str	 r6,  [r9,#0x8]       //load A bit and E bit
		mov	 r7,  #0              //count register
		mov	 r12, #0              //state register
		mov	 r10, #0xf            //overwrite


display:        ldr 	 r4,  [r5,#0x3C]        //EdgeCapture	
		cmp	 r4, #0
	        blne	 set_bit

check:          ldr      r1, =0xff200050 
                ldr      r1, [r1]
                cmp      r1, #0
                bne      check            
       
                mov      r12, #0                          
              
                cmp 	 r12, #0
		beq 	 count
		b   	 display
	
//Display on HEX0 and HEX1
            
count:          cmp      r7, #99
		moveq 	 r7, #0

		add 	 r7, #1
		mov      r0, r7
		bl       DIVIDE
		mov      r8, r1
		bl       SEG7_CODE
		mov      r4, r0

		mov      r0, r8
		bl       SEG7_CODE
                lsl      r0, #8
                orr      r4, r0

		str      r4, [r5]

delay: 		ldr 	 r4, [r9,#0xc]
		and	 r4, #1
		cmp	 r4, #1
		bne 	 delay
		str	 r4, [r9,#0xc]
		b 	 display
		

set_bit: 	str      r10, [r5,#0x3C]  //reset to zero
                mov      r12, #1 
		mov 	 pc,  lr


DIVIDE:     	MOV    	 R2, #0
CONT:       	CMP    	 R0, #10
		BLT      DIV_END
		SUB      R0, #10
		ADD      R2, #1
		B        CONT
DIV_END: 	MOV      R1, R2     // quotient in R1 (remainder in R0)
		MOV      PC, LR       




SEG7_CODE:  	MOV     R1, #BIT_CODES  
            	ADD     R1, R0         // index into the BIT_CODES "array"
            	LDRB    R0, [R1]       // load the bit pattern (to be returned)
            	MOV     PC, LR              
		
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment	