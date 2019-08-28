/* Program that counts consecutive 1's */
//Prerna
          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R0, #TEST_NUM   // load the data word ...
          MOV     R5, #0          // R0 will hold the result
          

LOOP:     MOV     R3, #0
          LDR     R1, [R0], #4    //Read and then advance
          CMP     R1, #0          // loop until the data contains no more words - reaches the end
          BEQ     DONE   
          BL      ONES         
          CMP     R5, R3
          MOVLT   R5, R3    
          B       LOOP  

DONE:     B       DONE      
   
ONES:     CMP     R1, #0
          BEQ     ENDCOUNT
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R3, R3, #1      // count the string length so far
          B       ONES

ENDCOUNT:  MOV     PC, LR         //return
            

TEST_NUM:	.word 	0x103fe00f	// ANSWER: 9
		.word	0xfee123	// ANSWER: 7
            	.word	0x11111111	// ANSWER: 1
            	.word	0xFFFFFFFF	// ANSWER: 32
            	.word	0x34cca2	// ANSWER: 2
            	.word	0x99aabbcc	// ANSWER: 4
            	.word	0xddeeff88	// ANSWER: 9
            	.word	0x77665544	// ANSWER: 3
            	.word 	0x0		// ANSWER: 0
            
          .end                            
