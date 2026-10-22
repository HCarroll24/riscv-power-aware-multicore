/*************************************************************************
 * @file:   test_prog.c
 * @author: carrollh@msoe.edu <Hunter Carroll>
 * @date:   21 October 2026
 * @brief:  Test program for RV32I pipelined processor to confirm proper
 *          funcitonality without "toy" test programs where I choose what
 *          happens. Confirming working with actual program.
*************************************************************************/
#include <stdint.h>

#define LEDR        (*(volatile uint32_t *)0xFF200000u)   // red LEDs
#define HEX3_HEX0   (*(volatile uint32_t *)0xFF200020u)   // 7-seg HEX3-HEX0
#define HEX5_HEX4   (*(volatile uint32_t *)0xFF200030u)   // 7-seg HEX5-HEX4
#define SW          (*(volatile uint32_t *)0xFF200040u)   // slide switches
#define KEY         (*(volatile uint32_t *)0xFF200050u)   // KEY3 - KEY0

#define SEG7_0      0b11000000  // active-low zero
#define SEG7_1      0b11111001  // active-low one
#define SEG7_2      0b10100100  // active-low two
#define SEG7_3      0b10110000  // active-low three
#define SEG7_4      0b10011001  // active-low four
#define SEG7_5      0b10010010  // active-low five
#define SEG7_6      0b10000010  // active-low six
#define SEG7_7      0b11111000  // active-low seven
#define SEG7_8      0b10000000  // active-low eight
#define SEG7_9      0b10010000  // active-low nine

#define CLK_HZ      50000000    // 50 MHz
#ifndef LOOPS_PER_MS
#define LOOPS_PER_MS    25000
#endif

#define LED_MASK    0X3FF

#define NOINLINE    __attribute__((noinline))

// function prototypes
static void count_displays(void);
static void seg7_display_all(uint32_t pattern);
static void delay(uint32_t time);
static void led_sweep(void);
static void switches_to_leds(void);

/**
 * @brief main function
 * 
 * @return int 0, should never reach this
 */
int main(void) {
    count_displays();
    seg7_display_all(0xFF);
    led_sweep();
    switches_to_leds();
    return 0;
}

/**
 * @brief Counts 0 to 9 on all six 7-segment displays
 */
static NOINLINE void count_displays(void) {
    uint32_t disp[10];

    disp[0] = SEG7_0;
    disp[1] = SEG7_1;
    disp[2] = SEG7_2;
    disp[3] = SEG7_3;
    disp[4] = SEG7_4;
    disp[5] = SEG7_5;
    disp[6] = SEG7_6;
    disp[7] = SEG7_7;
    disp[8] = SEG7_8;
    disp[9] = SEG7_9;

    for (int i = 0; i < 10; i++) {
        seg7_display_all(disp[i]);
        delay(1000);
    }
}

/**
 * @brief Shows the same segment pattern on all six displays
 * @param pattern 7-segment pattern
 */
static NOINLINE void seg7_display_all(uint32_t pattern) {
    uint32_t byte = pattern & 0xFF; // masking
    // shift onto lowest two bytes
    uint32_t two = byte | (byte << 8);

    // shift onto every byte
    HEX3_HEX0 = two | (two << 16);  // HEX3, HEX2, HEX1, HEX0
    HEX5_HEX4 = two;                // HEX5, HEX4
}

/**
 * @brief Delays the function for milliseconds
 * 
 * @param time ms to delay
 */
static NOINLINE void delay(uint32_t time) {
    while (time > 0) {
        uint32_t loops = LOOPS_PER_MS;
        __asm__ volatile (
            "1: addi %0, %0, -1 \n"
            "   bnez %0, 1b     \n"
            : "+r"(loops));
        time--;
    }
}

/**
 * @brief LED sweeps from LEDR9 to LEDR0
 */
static NOINLINE void led_sweep(void) {
    for (int i = 0; i < 10; i++) {
        LEDR = ~(1 << (9 - i)) & LED_MASK;
        delay(250);
    }
    LEDR = LED_MASK;
}

/**
 * @brief Each LED follows its slide switch, forever
 */
static NOINLINE void switches_to_leds(void) {
    while(1) {
        LEDR = ~SW & LED_MASK;
    }
}