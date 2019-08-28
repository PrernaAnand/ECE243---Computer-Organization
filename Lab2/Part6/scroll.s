.define LED_ADDRESS 0x1000
.define HEX_ADDRESS 0x2000
.define SW_ADDRESS 0x3000
.define DELAY 8888
.define STACK 256							// bottom of memory

// This code scrolls back and forth the letters dE10 across the 7-segment displays
// and also displays a count on the red LEDs
			mvi	r6, #STACK				// used as a stack pointer
 			mvi	r1, #1
			mv		r0, r1					// constant K for -- and ++ of character pointer
 			mvi	r2, #FIRST				// point to the character '0' 

MAIN:		mv		r5, r2					// point to the first letter in this loop iteration
 			mvi	r4, #HEX_ADDRESS		// address of HEX0 

			sub	r6, r1					// save value of r0 on the stack
			st		r0, [r6]
			sub	r6, r1					// save value of r2 on the stack
			st		r2, [r6]

// Loop over the six HEX displays
			mvi	r0, #6					// used to count the HEX displays
			mv		r2, r7					// used for looping
LOOP:		ld		r3, [r5]					// get letter 
 			st		r3, [r4]					// send to HEX display
 			add	r5, r1					// ++increment character pointer 
 			add	r4, r1					// point to next HEX display
			sub	r0, r1
			mvnz	r7, r2					// next loop iteration
			
			ld		r2, [r6]					// restore saved values of r0 and r2
			add	r6, r1
			ld		r0, [r6]
			add	r6, r1

 			sub	r2, r0					// use K to scroll the characters
 			mvi	r5, #LEFT	 			// reverse direction condition 
 			mvi	r4, #SKIP 			
 			sub	r5, r2					// scrolled all the way to the left?
 			mvnz	r7, r4					// no, so don't reverse direction yet
 			add	r2, r1 					// yes, so reverse to scroll to the right
 			add	r2, r1
 			mvi	r5, 0xffff		 		// needed for making -K 
 			sub	r5, r0  					// r5 = complement of r0 
 			add	r5, r1  					// r5 = -r0 
 			mv		r0, r5					// K = -K 
SKIP:		mvi	r5, #RIGHT	 			// reverse direction condition 
 			mvi	r4, #CONT 			
 			sub	r5, r2					// scrolled all the way to the right?
 			mvnz	r7, r4					// no, so don't reverse direction yet 
 			sub	r2, r1 					// yes, so reverse to scroll to the left
 			sub	r2, r1
 			mvi	r5, #0xffff		 		// needed for making -K 
 			sub	r5, r0  					// r5 = complement of r0 
 			add	r5, r1  					// r5 = -r0 
 			mv		r0, r5					// K = -K 

CONT:		sub	r6, r1					// save r0 onto stack
			st		r0, [r6]
			mvi	r3, #LED_ADDRESS		// LED reg address 
 			st		r2, [r3]					// write address pointer to LEDs 

// Delay loop for controlling speed of scrolling
 			mvi	r3, #DELAY				// delay counter 
 			mv		r5, r7					// save address of next instruction 
OUTER:	mvi	r0, #SW_ADDRESS			// point to SW port 
			ld		r4, [r0]					// load inner loop delay from SW 
			add	r4, r1					// in case 0 was read
 			mv		r0, r7					// save address of next instruction 
INNER:	sub	r4, r1					// decrement inner loop counter 
 			mvnz	r7, r0					// continue inner loop 
 			sub	r3, r1					// decrement outer loop counter 
 			mvnz	r7, r5					// continue outer loop 

			ld		r0, [r6]					// restore r0
			add	r6, r1
			mvi	r7, #MAIN 				// execute again 

LEFT: 	.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0b0000000001001111	// '3'
			.word 0b0000000001100110	// '4'
      	.word 0b0000000001011011	// '2'
FIRST:	.word 0b0000000001000000	// '-'
			.word	0b0000000001111001	// 'E'
			.word	0b0000000000111001	// 'C'
			.word	0b0000000001111001	// 'E'
			.word	0
			.word	0
RIGHT:	.word	0
