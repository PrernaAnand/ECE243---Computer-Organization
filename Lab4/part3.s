/* Program that counts consecutive 1's, 0's and alternating 1-0 sequences for a single word,
 * in a list of words and stores the greatest number counted from each one
 */

          	.text                   // executable code follows
          	.global _start                  
_start:   

/* Initializing variables
 */                          			
                    MOV		R11, #ONE_STRING		// store pointer to a string of 1's	
                    LDR		R11, [R11]			// load the value from the pointer
								// (R11 holds 32'b1111...)

                    MOV		R12, #ONE_ZERO_STRING		// store pointer to a string of alternating 1's and 0's
                    LDR		R12, [R12]			// load the value from the pointer
								// (R12 holds 32'b101010...)

                    MOV		R3, #TEST_NUM   		// store pointer to the first word in the list of words
                    
                    MOV		R5, #0				// reset R5
                    MOV		R6, #0				// reset R6
                    MOV		R7, #0				// reset R7

/* Main subroutine to count the consecutive 1's, 0's and 10's in a word
 */

MAIN:		    LDR		R1, [R3]			// load the value of the number into R1
		    CMP		R1, #0				// compare R1 to 0 to check if it is at the end of the list
                    BEQ		END				// if (R1 == 0), terminate the program

	            MOV     	R8, #0				// reset counter
                    BL		ONES				// branch to the ONES subroutine

                    CMP		R5, R8				// compare the previous value of 1's to the current count of 1's
                    MOVLT	R5, R8				// if current count is greater, replace previous count
                    LDR		R1, [R3]        		// reload the value of the number into R1
                    MOV		R8, #0				// reset counter
                    BL		ZEROS				// branch to the ZEROS subroutine

                    CMP		R6, R8				// compare the previous value of 0's to the current count of 0's
                    MOVLT	R6, R8				// if current count is greater, replace previous count
                    LDR		R1, [R3]			// reload the value of the number into R1
                    MOV		R8, #0				// reset counter


/* Subroutine that utilizes the ZEROS and ONES subroutines to count the number of 10's in a word
 * The word is XORed with string of alternating 1's and 0's, which results the 10's to turn into
 * consecutive 1's and 0's. Counting the greater one results in the greatest number of 10's 
 */ 

ALTERNATE:	    EOR		R1, R1, R12			// XOR with 32'b101010...
                    BL		ONES				// branch to the ONES subroutine

                    CMP		R7, R8				// compare the previous value of 10's to the current count of 10's
                    MOVLT	R7, R8				// if current count is greater, replace previous count

                    LDR		R1, [R3]			// reload the value of the number into R1
                    EOR		R1, R1, R12			// XOR with 32'b1111...
                    MOV		R8, #0				// reset counter
                    BL		ZEROS				// branch to the ZEROS subroutine

                    CMP		R7, R8				// compare the previous value of 10's to the current count of 10's
                    MOVLT	R7, R8				// if current count is greater, replace previous count
					
                    ADD		R3, #4				// increment the pointer to point to the next work
                    B		MAIN				// branch to the MAIN subroutine

/* Terminates the program */

END:		    B      	END

/* Subroutine that counts the greatest number of consecutive 1's in a word */

ONES:		    CMP     	R1, #0				// compares the value in R1 with 0								
                    MOVEQ   	PC, LR				// if R1==0, there are no more 1's to count, return to previous branch          
                    LSR     	R2, R1, #1			// perform SHIFT, followed by AND
                    AND     	R1, R1, R2      
                    ADD     	R8, #1				// count the string length so far
                    B       	ONES				// loop until the data contains no more 1's 

/* Subroutine that counts the greatest number of consecutive 0's in a word */

ZEROS:		    EOR		R1, R1, R11			// XOR with 32'b1111...
                    MOV		R4, LR				// stores the address of the return to previous branch in R4
                    BL		ONES				// branches to the ONES subroutine
                    MOV		PC, R4				// uses R4 to return to the main subroutine

/* pointers used */

ONE_STRING:	    .word	0xFFFFFFFF
ONE_ZERO_STRING:    .word	0xAAAAAAAA
TEST_NUM:	    .word	0x103fe00f 
                    .word	0x0
                    
            	    .end