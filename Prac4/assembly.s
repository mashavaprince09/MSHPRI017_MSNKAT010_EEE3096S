.syntax unified
    .text
    .global ASM_Main
    .thumb_func

vectors:
    .word 0x20002000
    .word ASM_Main + 1

ASM_Main:
    LDR R0, RCC_BASE
    LDR R1, [R0, #0x14]
    LDR R2, AHBENR_GPIOAB
    ORRS R1, R1, R2
    STR R1, [R0, #0x14]

    LDR R0, GPIOA_BASE
    MOVS R1, #0b01010101
    STR R1, [R0, #0x0C]
    LDR R1, GPIOB_BASE

    LDR R2, MODER_OUTPUT
    STR R2, [R1, #0]
    MOVS R2, #0
