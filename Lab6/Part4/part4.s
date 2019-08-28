                    .include "config_GIC.s"
                    .include "exceptions.s"

                    .section .vectors, "ax"
                    B        _start              // reset vector
                    B        SERVICE_UND         // undefined instruction vector
                    B        SERVICE_SVC         // software interrupt vector
                    B        SERVICE_ABT_INST    // aborted prefetch vector
                    B        SERVICE_ABT_DATA    // aborted data vector
                    .word    0                   // unused vector
                    B        SERVICE_IRQ         // IRQ interrupt vector
                    B        SERVICE_FIQ         // FIQ interrupt vector
                    .text
                    .global _start                              
_start:                                         
/* Set up stack pointers for IRQ and SVC processor modes */
                    MOV     R2, #0 // Count value
                    MOV     R1, #0b11010010
                    MSR     CPSR_c, R1
                    LDR     SP, =0xFFFFFFFC

                    MOV     R1, #0b11010011
                    MSR     CPSR, R1
                    LDR     SP, =0x3FFFFFFC

                    BL      CONFIG_GIC          // configure the ARM generic
                                                // interrupt controller
                    BL      CONFIG_PRIV_TIMER   // configure the private timer
                    BL      CONFIG_KEYS         // configure the pushbutton
                                                // KEYs port
/* Enable IRQ interrupts in the ARM processor */
                    MOV     R0, #0b01010010
                    MSR     CPSR_c, R0

                    LDR     R5, =0xFF200000     // LEDR base address
                    LDR     R6, =0xFF200020     // HEX3-0 base address
LOOP:                                           
                    LDR     R4, COUNT           // global variable
                    STR     R4, [R5]            // light up the red lights
                    LDR     R4, HEX_code        // global variable
                    STR     R4, [R6]            // show the time in format
                                                // SS:DD
                    B       LOOP                

/* Configure the MPCore private timer to create interrupts every 1/100 seconds */
CONFIG_PRIV_TIMER:
                    LDR     R0, =0xFFFEC600
                    MOV     R1, #1
                    STR     R1, [R0, #0xC]
                    LDR     R1, =2000000
                    STR     R1, [R0]
                    LDR     R1, =0b101
                    STR     R1, [R0, #0x8]
                    BX      LR                  
/* Configure the Interval Timer to create interrupts at 0.25 second intervals */

/* Configure the pushbutton KEYS to generate interrupts */
CONFIG_KEYS:                                    
                    LDR     R0, =0xFF200050
                    MOV     R1, #0xF
                    STR     R1, [R0, #0x8]
                    BX      LR                  

SERVICE_IRQ:    PUSH     {R0-R7, LR}
                LDR      R4, =0xFFFEC100 // GIC CPU interface base address
                LDR      R5, [R4, #0x0C] // read the ICCIAR in the CPU

TIMER_HANDLER:  CMP     R5, #29
                BNE     KEYS_HANDLER
                BL      CHANGECOUNT
                B       EXIT_IRQ

KEYS_HANDLER:   CMP      R5, #73

UNEXPECTED:     BNE     UNEXPECTED
                BL      CHECK_KEY

EXIT_IRQ:       STR      R5, [R4, #0x10]
                POP      {R0-R7, LR}
                SUBS     PC, LR, #4      // return from exception

CHANGECOUNT:    LDR     R0, =0xFFFEC600
                MOV     R1, #0b1
                STR     R1, [R0, #0xC]
                LDR     R2, COUNT
                LDR     R3, RUN
                ADD     R2, R3
                STR     R2, COUNT

CHECKCOUNT:     LDR     R3, COUNT
                CMP     R3, #99
                BEQ     INC_TIME
                B       CONTINUE

INC_TIME:       LDR     R1, TIME
                ADD     R1, #1
                CMP     R1, #59
                MOVEQ   R1, #0
                STR     R1, TIME
                MOV     R1, #0
                STR     R1, COUNT

CONTINUE:       LDR     R0, =0xFFFEC600
                LDR     R1, =2000000 // 1/(100 MHz) x 5x10^6 = 50 msec //2000000
                STR     R1, [R0] // store the low half word of counter
                MOV     R1, #0b101 // START = 1, CONT = 0, ITO = 1
                STR     R1, [R0, #0x8]
                B       DISPLAY

CHECK_KEY:      LDR R0, =0xFF200050
                LDR R1, [R0, #0xC]
                STR R1, [R0, #0xC]
                CMP R1, #0b1000
                BEQ CHANGERUN

CHANGERUN:      LDR R2, RUN
                CMP R2, #1
                BEQ CHANGEONE
                B   CHANGEZERO

CHANGEONE:      MOV R2, #0
                STR R2, RUN
                BX  LR

CHANGEZERO:     MOV R2, #1
                STR R2, RUN
                BX  LR

SEG7_CODE:  MOV     R3, #BIT_CODES
            ADD     R3, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R3]       // load the bit pattern (to be returned)
            MOV     PC, LR


DIVIDE:     SUB       R13, #4 //saving registers
            STR       R2, [R13]
            SUB       R13, #4
            STR       R6, [R13]
            MOV       R2, #0
            MOV       R6, #10 // pointing to divisor

TEN:        CMP    R0, R6
            BLT    DIV_END // remainder < divisor
            SUB    R0, R6
            ADD    R2, #1
            B      TEN

DIV_END:    MOV       R1, R2     // quotient in R1 (remainder in R0)
            LDR       R6, [R13] // restoring registers
            ADD       R13, #4
            LDR       R2, [R13]
            ADD       R13, #4
            MOV       PC, LR

DISPLAY:    PUSH    {R0-R7, LR}
            LDR     R0, COUNT          // display R5 on HEX1-0
            BL      DIVIDE

            MOV     R9, R1
            BL      SEG7_CODE
            MOV     R4, R0
            MOV     R0, R9

            BL      SEG7_CODE
            LSL     R0, #8
            ORR     R4, R0

            LDR     R0, TIME            //display R6 on HEX3-2
            BL      DIVIDE
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE
            LSL     R0, #16            // index proper address
            ORR     R4, R0          // save bit code

            MOV     R0, R9          // retrieve the tens digit, get bit
            BL      SEG7_CODE
            LSL     R0, #24            // index proper address
            ORR     R4, R0

            STR     R4, HEX_code
            POP     {R0-R7, LR}
            BX      LR


/* Global variables */

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
.byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
.skip   2      // pad with 2 bytes to maintain word alignment

                    .global COUNT                               
COUNT:              .word   0x0       // used by timer
                    .global RUN       // used by pushbutton KEYs
RUN:                .word   0x1       // initial value to increment COUNT
                    .global TIME                                
TIME:               .word   0x0       // used for real-time clock
                    .global HEX_code                            
HEX_code:           .word   0x0       // used for 7-segment displays

                    .end                                        
