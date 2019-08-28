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
                .global  _start 

_start:                                  
/* Set up stack pointers for IRQ and SVC processor modes */
                MOV      R1, #0b11010010
                MSR      CPSR_c, R1
                LDR      SP, =0xFFFFFFFC

                MOV     R1, #0b11010011
                MSR     CPSR, R1
                LDR     SP, =0x3FFFFFFC

                BL       CONFIG_GIC      // configure the ARM generic
                                         // interrupt controller
/* Configure the KEY pushbuttons port to generate interrupts */
                LDR     R0, =0xFF200050
                MOV     R1, #0xF
                STR     R1, [R0, #0x8]

/* Enable IRQ interrupts in the ARM processor */
                MOV     R0, #0b01010011
                MSR     CPSR_c, R0
IDLE:                                    
                B        IDLE            // main program simply idles

/* Define the exception service routines */

SERVICE_IRQ:    PUSH     {R0-R7, LR}     
                LDR      R4, =0xFFFEC100 // GIC CPU interface base address
                LDR      R5, [R4, #0x0C] // read the ICCIAR in the CPU
                                         // interface

KEYS_HANDLER:                       
                CMP      R5, #73         // check the interrupt ID

UNEXPECTED:     BNE      UNEXPECTED      // if not recognized, stop here
                BL       KEY_ISR         

EXIT_IRQ:       STR      R5, [R4, #0x10] // write to the End of Interrupt
                                         // Register (ICCEOIR)
                POP      {R0-R7, LR}     
                SUBS     PC, LR, #4      // return from exception


KEY_ISR:    LDR R0, =0xFF200050
LDR R1, [R0, #0xC]
STR R1, [R0, #0xC]
LDR R0, =KEY_HOLD
LDR R2, [R0]
EOR R1, R2, R1
STR R1, [R0]

LDR R0, =0xFF200020
MOV R2, #0

CHECK_KEY0: MOV R3, #0b0001
ANDS R3, R3, R1
BEQ CHECK_KEY1
MOV R2, #0b00111111

CHECK_KEY1: MOV R3, #0b0010
ANDS R3, R3, R1
BEQ CHECK_KEY2
MOV R3, #0b00000110
ORR R2, R2, R3, LSL #8

CHECK_KEY2: MOV R3, #0b0100
ANDS R3, R3, R1
BEQ CHECK_KEY3
MOV R3, #0b01011011
ORR R2, R2, R3, LSL #16

CHECK_KEY3: MOV R3, #0b1000
ANDS R3, R3, R1
BEQ END_KEY_ISR
MOV R3, #0b01001111
ORR R2, R2, R3, LSL #24

END_KEY_ISR: STR R2, [R0]
BX LR

KEY_HOLD:   .word   0b0000

.end
