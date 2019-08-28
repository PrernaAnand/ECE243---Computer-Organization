.define LEDR_ADDRESS 0x1000
.define SW_ADDRESS 0x3000
.define HEX_ADDRESS 0x2000
.define STACK 255

// Count on the LEDs
			mv	r5, r7
			mvi	r7, #BLANK	

INITIALISE:		mvi 	r1, #1			// add r1 to r2 to count
			mvi 	r0, #0			// this value will be sent to the LEDs
							
READ:			mvi	r3, #HEX_ADDRESS	// point to HEX port
			mvi	r4, #SW_ADDRESS		// point to SW port	
			ld	r2, [r4]		// read SW values
			mvi 	r7, #DELAY		// execute the delay loop
			
MAIN:			add 	r0, r1			// add 1 to the value in register r0	
			mv	r4, r0			// store the value of the counter that is supposed to be displayed on the screen

LOOP:			mv	r5, r7
			mvi 	r7,#DIV10

			mvi	r6, #DATA			//light up a HEX
			add	r6, r0
			ld 	r0, [r6]			// arrange numbers from 0 to 9 (0 at top)
			st 	r0, [r3]			// displaying at HEX0
				
			mvi 	r6, #0
			mv	r0, r2
			add 	r2, r6
			mvi	r6, #INCREMENT
			mvnz 	r7, r6				// to be executed if Quotient from DIV >= 1

			mv 	r0, r4				// restore the value of the counter  

			mvi	r7, #READ			// read the delay rate

DELAY:			mvi	r6, #8888			// store constant value in r6

DELAY2:			sub	r6, r1				// subtract 1 from r6
			mvi 	r5, #DELAY2			// store address of DELAY2 in r5

			mvnz	r7, r5				// do inner delay loop (DELAY2)
			sub	r2, r1				// subtract 1 from value in r2
			mvi 	r5, #DELAY			// store address of DELAY in r5
			mvnz	r7, r5				// continue the delay loop			
			mvi	r7, #MAIN			// after loop is executed go back to turning on HEXs

// subroutine DIV10
// This subroutine divides the number in r0 by 10
// The algorithm subtracts 10 from r0 until r0 < 10, and keeps count in r2
// input: r0
// returns: quotient Q in r2, remainder R in r0

DIV10:			mvi r1, #1
			mvi r6, #STACK
			sub r6, r1 				// save registers that are modified
			st r3, [r6]
			sub r6, r1
			st r4, [r6]				// end of register saving
			mvi r2, #0 				// init Q
			mvi r3, RETDIV 				// for branching

DLOOP: 			mvi r4, #9 				// check if r0 is < 10 yet
			sub r4, r0
			mvnc r7, r3 				// if so, then return

INC: 			add r2, r1 				// but if not, then increment Q
			mvi r4, #10
			sub r0, r4 				// r0 -= 10
			mvi r7, DLOOP 				// continue loop

RETDIV:			ld r4, [r6] 				// restore saved regs
			add r6, r1
			ld r3, [r6] 				// restore the return address
			add r6, r1
			add r5, r1 						// adjust the return address by 2
			add r5, r1
			mv r7, r5 						// return results


// subroutine BLANK
// 	This subroutine clears all of the HEX displays
//	input: none
//	returns: nothing
BLANK:
			mvi	r0, #0					// used for clearing
			mvi	r1, #1					// used to add/sub 1
			mvi	r2, #HEX_ADDRESS				// point to HEX displays
			st	r0, [r2]					// clear HEX0
			add	r2, r1
			st	r0, [r2]					// clear HEX1
			add	r2, r1
			st	r0, [r2]					// clear HEX2
			add	r2, r1
			st	r0, [r2]					// clear HEX3
			add	r2, r1
			st	r0, [r2]					// clear HEX4
			add	r2, r1
			st	r0, [r2]					// clear HEX5

			add	r5, r1
			add	r5, r1
			mv	r7, r5					// return from subroutine

DATA:			.word 0b00111111			// '0'
			.word 0b00000110			// '1'
			.word 0b01011011			// '2'
			.word 0b01001111			// '3'
			.word 0b01100110			// '4'
			.word 0b01101101			// '5'
			.word 0b01111101			// '6'
			.word 0b00000111			// '7'
			.word 0b01111111			// '8'
			.word 0b01100111			// '9'

INCREMENT:		add r3, r1
			mvi r6, #LOOP
			mv r7, r6
