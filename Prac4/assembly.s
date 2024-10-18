.syntax unified
    .text
    .global main
    .thumb_func

vectors:
    .word 0x20002000
    .word main + 1

main:
    LDR R9, RCC_BASE
    LDR R12, [R9, #0x14]
    LDR R11, AHBENR_GPIOAB
    ORRS R12, R12, R11
    STR R12, [R9, #0x14]

    LDR R9, GPIOA_BASE
    MOVS R12, #0b01010101
    STR R12, [R9, #0x0C]
    LDR R12, GPIOB_BASE

    LDR R11, MODER_OUTPUT
    STR R11, [R12, #0]
    MOVS R11, #0

checker:
    LDR R8, LONG_DELAY_CNT // 0.7s delay
    LDR R9, GPIOA_BASE

    LDR R12, [R9, #0x10] // read input value from GPIO

    MOVS R10, #0x01 // check that SW0 is held down
    ANDS R10, R12
    BEQ increment_by_2 // increment by 2 every  0.7 seconds

    MOVS R10, #0x02  // check that SW1 is held down
    ANDS R10, R12
    BEQ change_delay // change delat to 0.3s

    MOVS R10, #0x04 // check that SW2 is held down
    ANDS R10, R12
    BEQ set_pattern_0xAA

    MOVS R10, #0x08 // check that SW3 is held down
    ANDS R10, R12
    BEQ freeze_pattern // freeze_pattern the pattern

    B default_mode

increment_by_2:
    LSRS R11, R11, #2
    CMP R11, #0
    BNE set_led_pattern
    MOVS R11, #0x80 //reset the bit pattern
    B set_led_pattern

change_delay:
    LDR R8, SHORT_DELAY_CNT
    B default_mode

set_pattern_0xAA:
    MOVS R11, #0xAA
    B set_led_pattern

freeze_pattern:
    LDR R12, [R9, #0x10]
    MOVS R10, #0x08
    ANDS R10, R12
    BEQ freeze_pattern
    B checker

default_mode:
    LSRS R11, R11, #1
    CMP R11, #0
    BNE set_led_pattern
    MOVS R11, #0x80  //reset the bit patterns

set_led_pattern:
    LDR R12, GPIOB_BASE
    STR R11, [R12, #0x14]

delay:
    SUBS R8, #1
    BNE delay
    B checker

    .align
RCC_BASE:           .word 0x40021000
AHBENR_GPIOAB:      .word 0b1100000000000000000
GPIOA_BASE:         .word 0x48000000
GPIOB_BASE:         .word 0x48000400
MODER_OUTPUT:       .word 0x5555
LONG_DELAY_CNT:     .word 140000
SHORT_DELAY_CNT:    .word 60000
