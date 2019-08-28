.define HEX_ADDRESS 0x2000
.define SW_ADDRESS 0x3000
.deifne STACK 255

//Counter


//Declaration
      mvi r0, #0  //Starts from 0
      mvi r6, #STACK //to store all values
      mvi r1, #1 //increment
       
MAIN:
      st r1, [r6]  //pop content to r1
      mvi r5, r7   //store the next instruction
      mvi r7, #DIV10 //receives remainder in r0 and quotient in r2
      mvi r5, r7     //store the next instruction
      mvi r7, #HEX   //Display Pattern
      


//part6 delay
DELAY:  mvi  r3, #SW_ADDRESS
        ld   r4, [r3]
        mv   r6, r7
        sub  r4, r1
        mvnz r7, r6             //count down until r4 = 0
        add  r5, r1
        add  r5, r1
        mv   r7, r5            //next address


HEX:    mvi r3, r7  // start by clearing the HEX display
        mvi r7, #CLEAR  
        mvi r3, #NUMBERS //Pattern
        add r3, r2 // number to access 

        mvi r1, #1
        add r5, r1
        add r5, r1
        mv  r7, r5   //returns


CLEAR:  mvi r4, #0
        mvi r1, #1
        mvi r6, #HEX_ADDRESS   //points to the first address
        st  r4, [r6]   //HEX0 = 0  //pop content out
        add r6, r1
        st  r4, [r6]   //HEX1 = 0
        add r6, r1
        st  r4, [r6]   //HEX2 = 0
        add r6, r1
        st  r4, [r6]   //HEX3 = 0
        add r6, r1
        st  r4, [r6]   //HEX4 = 0
        add r6, r1
        st  r4, [r6]   //HEX5 = 0
        add r3, r1
        add r3, r1
        mv  r7, r3     //next instructions


//order - h7,h6,h5,h4,h3,h2,h1
NUMBERS:    .word 0b0111111 // 0
            .word 0b0000110 // 1
            .word 0b1011011 // 2
            .word 0b1001111 // 3
            .word 0b1100110 // 4
            .word 0b1101101 // 5
            .word 0b1111101 // 6
            .word 0b0000111 // 7
            .word 0b1111111 // 8
            .word 0b1101111 // 9
 
// subroutine DIV10
// This subroutine divides the number in r0 by 10
// The algorithm subtracts 10 from r0 until r0 < 10, and keeps count in r2
// input: r0
// returns: quotient Q in r2, remainder R in r0

DIV10:
            mvi r1, #1
            sub r6, r1              // save registers that are modified
            st r3, [r6]             //stores address before og address of r6 
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
            mv  r7, r5              //return results