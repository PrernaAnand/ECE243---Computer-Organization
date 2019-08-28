/* Program that converts a binary number to decimal */
	.text // executable code follows
	.global _start

_start:
		MOV	R4, #N			// R4 points to the decimal number to be converted
		MOV 	R5, #Digits		// R5 points to the decimal digits storage location
		MOV	R6, #Divisor		// R6 points to the divisor
		
	        LDR 	R4, [R4] 		// R4 holds N
		LDR	R6, [R6]		// R6 holds Divisor
            
	        MOV 	R0, R4			// parameter for DIVIDE goes in R0	
		BL 	DIVIDE			// branches to DIVIDE subroutine
            
	        STRB 	R0, [R5]		// Ones digit from R0 is stored in Digits
		
		MOV	R0, R1			
		BL	DIVIDE			// DIVISION subroutine is repeated with the quotient value

		STRB 	R0, [R5, #1]		// Tens digit from R0 is stored in Digits
		
		MOV 	R0, R1
		BL 	DIVIDE			// DIVISION subroutine is repeated with the quotient value

		STRB 	R0, [R5, #2]		// Hundreds digit from R0 is stored in Digits
		STRB 	R1, [R5, #3]		// Thousands digit from R1 is stored in Digits
        
END:		B 	END			// end of the program


/* Subroutine to perform the integer division R0 / 10.
* Returns: quotient in R1, and remainder in R0
*/

DIVIDE:		MOV	R2, #0			// counter = quotient

CONT:		CMP	R0, R6			// compares the remainder with the divisor
		BLT 	DIV_END			// if (R0 < R6), branch to DIV_END
		SUB 	R0, R6			// remainder = quotient - divisor
		ADD 	R2, #1			// increment counter
		B 	CONT			// branches to CONT

DIV_END:	MOV 	R1, R2			// quotient in R1 (remainder in R0)
		MOV 	PC, LR			// branches back to _start


/* Declaring constants */

N:		.word 9876			// the decimal number to be converted
Divisor:	.word 10			// the divisor

Digits: 	.space 4			// storage space for the decimal digits

		.end