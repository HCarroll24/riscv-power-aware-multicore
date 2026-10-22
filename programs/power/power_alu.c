/**
 * @file    power_alu.c
 * @author  Hunter Carroll (carrollh@msoe.edu)
 * @brief   Power of compute heavy/fully busy processor metric
 * @version 0.1
 * @date    2026-10-21
 */
#include "bench.h"

#define ALU_LOOPS 3000u

int main(void) {
    uint32_t x = 0x12345678u;   // seed for random number generator
    uint32_t acc = 0x9E3779B9u; // 2^32 / golden ratio

    bench_start();
    for(int i = 0; i < ALU_LOOPS; i++) {
        // random number generator, xorshift32
        x ^= x << 13;
        x ^= x >> 17;
        x ^= x << 5;

        // add random number to accumulator to prevent optimization
        acc += x;
        acc ^= (acc << 3) | (acc >> 29);
        acc -= i;
        acc = (acc >> 1) + (x & 0xFFFFu);
    }
    bench_done(acc ^ x);
    while(1){}   // spin forever
}