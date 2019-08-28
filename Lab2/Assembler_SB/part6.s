.define LED_ADDRESS 0x1000
.define SW_ADDRESS 0x3000

//program displays a counter to the LED port
            mvi r0, #0              //count starts from 0
            mvi r1, #1              //increment by 1
            mvi r2, #LED_ADDRESS

MAIN:       st r0, [r2]             //light up LEDS
            mv r5, r7               //get return address
            mvi r7, #DELAY
            add r0, r1
            mvi r7, #MAIN

DELAY:      mvi r3, #SW_ADDRESS 
            ld r4, [r3]
            mv r6, r7
            sub r4, r1
            mvnz r7, r6             //count down until r4 == 0
            add r5, r1
            add r5, r1
            mv r7, r5