/* Program that finds the largest number in a list of integers	*/

            .text                   // executable code follows
            .global _start                  
_start:                             
            MOV     R4, #RESULT     // R4 points to result location
            LDR     R0, #N          // R0 holds the number of elements in the list
            MOV     R1, #NUMBERS    // R1 points to the start of the list
            BL      LARGE  
         
DONE:       STR     R0, [R4]        // R0 holds the subroutine return value

END:        B       END             

/* Subroutine to find the largest integer in a list
 * Parameters: R0 has the number of elements in the list
 *             R1 has the address of the start of the list
 * Returns: R0 returns the largest item in the list
 */
LARGE:      LDR     R2, [R1]        //R2 holds the largest number so far  
       
LOOP :      SUBS    R0, #1  	    //decrement loop counter
            BEQ     END_LOOP        //if result is equal to zero - empty
            ADD     R1, #4  
            LDR     R3, [R1]        //get the next number
            CMP     R2, R3          //check if larger number found
            BGE     LOOP            //if not large, start again with next number
            MOV     R2, R3          //update the largest number
            B       LOOP              

END_LOOP:   MOV     R0, R2          //R0 holds the largest number
            MOV     PC, LR
 
RESULT:     .word   0           
N:          .word   7               // number of entries in the list
NUMBERS:    .word   4, 5, 3, 6      // the data
            .word   1, 8, 2                 

            .end                               