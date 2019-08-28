/* Program that counts consecutive 1's */
//Prerna
          .text                   // executable code follows
          .global _start  
                
_start:       MOV     R0, #TEST_NUM   // load the data word ...
              MOV     R1, #ALT
              LDR     R8, [R1]        //R8 contains alternating 1's and 0's

              MOV     R5, #0          // R0 will hold the result for ONES
              MOV     R6, #0          // R0 will hold the result for ZEROS
              MOV     R7, #0          // R0 will hold the result for ALTERNATE
             
LOOP:         LDR     R1, [R0], #4    //Read and then advance
              CMP     R1, #0          // loop until the data contains no more words - reaches the end
              BEQ     END  
              MOV     R4, R1
    
              MOV     R3, #0          //R3 counts
              BL      ONES
              CMP     R5, R3
              MOVLT   R5, R3 

              MOV     R3, #0          //R3 counts
              MOV     R1, R4          //To make sure that original value of R1 is restored before entering each loop
              BL      ZEROS
              CMP     R6, R3
              MOVLT   R6, R3 

              MOV     R3, #0          //R9 counts
              MOV     R1, R4
              BL      ALTERNATE
              CMP     R7, R3
              MOVLT   R7, R3 
              
              ADD     R0, R0, #4
              B       LOOP  

END:          B       END        
   
ONES:         CMP     R1, #0
              BEQ     ENDONES
              LSR     R2, R1, #1      // perform SHIFT, followed by AND
              AND     R1, R1, R2      
              ADD     R3, #1          // count the string length so far
              B       ONES

ENDONES:      BX      LR              //return

ZEROS:        CMP     R1, #1
              BEQ     ENDZEROS
              LSR     R2, R1, #1      // perform SHIFT, followed by AND
              ORR     R1, R1, R2      
              ADD     R3, #1          // count the string length so far
              B       ONES

ENDZEROS:     BX      LR 

ALTERNATE:    CMP     R1, #0
              BEQ     ENDALTERNATE
              EOR     R1, R1, R8      //To get continues 1's which determine number of alternating nos
              B       ONES    
            
ENDALTERNATE: BX      LR 

TEST_NUM: .word   0x103fe00f     
ALT:      .word   0xAAAAAAAA          //1010
          .end                            
