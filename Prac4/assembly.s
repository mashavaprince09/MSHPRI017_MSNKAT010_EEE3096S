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
main_loop:
	@load the default delay
    LDR R6, LONG_DELAY_CNT
    LDR R0, GPIOA_BASE
	@load the input value from the GPIO
    LDR R1, [R0, #0x10]
	@check if the sw0 is pressed
    MOVS R3, #0x01
    ANDS R3, R1
    BEQ increment_by_2
	@check if the sw1 is pressed 
    MOVS R3, #0x02
    ANDS R3, R1
    BEQ change_delay
	@check if the sw2 is pressed
    MOVS R3, #0x04
    ANDS R3, R1
    BEQ set_pattern_AA
	@check if the sw3 is pressed
    MOVS R3, #0x08
    ANDS R3, R1
    BEQ freeze

    B default_mode

increment_by_2:
    LSRS R2, R2, #2
    CMP R2, #0
    BNE write_leds
    MOVS R2, #0x80       @ If all bits shifted out, reset to leftmost LED
    B write_leds
change_delay:
    LDR R6, SHORT_DELAY_CNT
    B default_mode
set_pattern_AA:
    MOVS R2, #0xAA
    B write_leds
freeze:
    LDR R1, [R0, #0x10]
    MOVS R3, #0x08
    ANDS R3, R1
    BEQ freeze
    B main_loop

default_mode:
    LSRS R2, R2, #1
    CMP R2, #0
    BNE write_leds
    MOVS R2, #0x80       @ If all bits shifted out, reset to leftmost LED
