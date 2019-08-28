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

                  BL       CONFIG_GIC       // configure the ARM generic
                                            // interrupt controller
                  BL       CONFIG_TIMER     // configure the Interval Timer
                  BL       CONFIG_KEYS      // configure the pushbutton
                                            // KEYs port

/* Enable IRQ interrupts in the ARM processor */
                  MOV     R0, #0b01010011
                  MSR     CPSR_c, R0
                  LDR      R5, =0xFF200000  // LEDR base address
LOOP:                                          
                  LDR      R3, COUNT        // global variable
                  STR      R3, [R5]         // write to the LEDR lights
                  B        LOOP                

/* Configure the Interval Timer to create interrupts at 0.25 second intervals */
CONFIG_TIMER:                             
                LDR R0, =0xFF202000
                LDR R1, =250000 // 1/(100 MHz) x 5x10^6 = 50 msec
                STR R1, [R0, #0x8] // store the low half word of counter
                // start value
                LSR R1, R1, #16
                STR R1, [R0, #0xC] // high half word of counter start value
                // start the interval timer, enable its
                MOV R1, #0x7 // START = 1, CONT = 1, ITO = 1
                STR R1, [R0, #0x4]
                BX       LR

/* Configure the pushbutton KEYS to generate interrupts */
CONFIG_KEYS:                                    
                LDR     R0, =0xFF200050
                MOV     R1, #0xF
                STR     R1, [R0, #0x8]
                BX       LR

SERVICE_IRQ:    PUSH     {R0-R7, LR}
                LDR      R4, =0xFFFEC100 // GIC CPU interface base address
                LDR      R5, [R4, #0x0C] // read the ICCIAR in the CPU

KEYS_HANDLER:   CMP      R5, #73         // check the interrupt ID
                BEQ      CHANGERUN
                CMP      R5, #72
                BEQ      CHANGECOUNT

//CHANGERUN:

CHANGECOUNT:    LDR     R4, #RUN
                LDR     R4, [R4]
                BL      CONFIG_TIMER
                CMP     R4, #1
                BNE     EXIT_IRQ
                LDR     R4, #COUNT
                ADD     R4, #1
                B       EXIT_IRQ

EXIT_IRQ:       STR      R5, [R4, #0x10]
                POP      {R0-R7, LR}
                SUBS     PC, LR, #4      // return from exception

/* Global variables */
                  .global  COUNT                           
COUNT:            .word    0x0              // used by timer
                  .global  RUN              // used by pushbutton KEYs
RUN:              .word    0x1              // initial value to increment
                                            // COUNT
                  .end                                        
