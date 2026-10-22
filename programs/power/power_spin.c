/**
 * @file    power_spin.c
 * @author  Hunter Carroll (carrollh@msoe.edu)
 * @brief   Power of Idling measurement program
 * @version 0.1
 * @date    2026-10-21
 */
#include "bench.h"

#define SPIN_LOOPS 20000u

int main(void) {
    uint32_t loops = SPIN_LOOPS;
    bench_start();

    __asm__ volatile (
        "1: addi %0, %0, -1 \n"
        "   bnez %0, 1b     \n"
        : "+r"(loops));
    bench_done(loops);
    while(1){}   // spin forever
}