.define HEX_ADDRESS 0x2000
.define SW_ADDRESS 0x3000

.define STACK 255

//program displays a counter to the HEX display
            mvi r0, #0              //count starts from 0
            mvi r6, #STACK
            mvi r1, #5

MAIN:       st r1, [r6]
            mvi r5, r7
            mvi r7, #DIV10 
            mvi r5, r7
            mvi r7, #HEX
            mvi r6, #STACK
            ld r1, [r6]
            mvi r3, #1
            sub r1, r3
            mvnz r7, #MAIN
            mv r5, r7
            mvi r7, #DELAY
            mvi r3, #1
            add r0, r3
            mvi r1, #5
            mvi r6, #STACK
            mvi r7, #MAIN  

DELAY:      
            mvi r3, #SW_ADDRESS
            ld r4, [r3]
            mv r6, r7
            sub r4, r1
            mvnz r7, r6             //count down until r4 == 0
            add r5, r1
            add r5, r1
            mv r7, r5

HEX:
            mvi r3, r7
            mvi r7, #BLANK          // call subroutine to clear HEX displays        
            mvi r3, #DATA           // used to get 7-segment display patterns
            add r6, r2              // point to correct HEX display
            add r3, r2              // point to correct 7-segment pattern
            ld r1, [r3]             // load the 7-segment pattern
            st r1, [r6]             // light up HEX display
            mvi r1, #1
            add r5, r1
            add r5, r1
            mvi r7, r5 

// Subroutine BLANK
// This subroutine clears all of the HEX displays
// input: none
// returns: nothing

BLANK:
            mvi r4, #0              // used for clearing
            mvi r1, #1              // used to add/sub 1
            mvi r6, #HEX_ADDRESS    // point to HEX displays
            st r4, [r6]             // clear HEX0
            add r6, r1
            st r4, [r6]             // clear HEX1
            add r6, r1
            st r4, [r6]             // clear HEX2
            add r6, r1
            st r4, [r6]             // clear HEX3
            add r6, r1
            st r4, [r6]             // clear HEX4
            add r6, r1
            st r4, [r6]             // clear HEX5
            add r3, r1
            add r3, r1
            mv r7, r3               // return from subroutine
            
DATA:       .word 0b00111111 // ’0’
            .word 0b00000110 // ’1’
            .word 0b01011011 // ’2’
            .word 0b01001111 // ’3’
            .word 0b01100110 // ’4’
            .word 0b01101101 // ’5’
            .word 0b01111101 // ’6’
            .word 0b00000111 // ’7’
            .word 0b01101110 // ’8’
            .word 0b01101111 // ’9’

// subroutine DIV10
// This subroutine divides the number in r0 by 10
// The algorithm subtracts 10 from r0 until r0 < 10, and keeps count in r2
// input: r0
// returns: quotient Q in r2, remainder R in r0

DIV10:
            mvi r1, #1
            sub r6, r1              // save registers that are modified
            st r3, [r6]
            sub r6, r1
            st r4, [r6]             // end of register saving
            mvi r2, #0              // init Q
            mvi r3, #RETDIV          // for branching

DLOOP:      mvi r4, #9              // check if r0 is < 10 yet
            sub r4, r0
            mvnc r7, r3             // if so, then return

INC:        add r2, r1              // but if not, then increment Q
            mvi r4, #10
            sub r0, r4              // r0 -= 10
            mvi r7, #DLOOP           // continue loop

RETDIV:
            ld r4, [r6]             // restore saved regs
            add r6, r1
            ld r3, [r6]             // restore the return address
            add r6, r1
            add r5, r1              // adjust the return address by 2
            add r5, r1
            mv r7, r5               // return results