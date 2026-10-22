/**
 * @file    power_mem.c
 * @author  Hunter Carroll (carrollh@msoe.edu)
 * @brief   memory heavy to isolate power of data memory
 * @version 0.1
 * @date    2026-10-21
 */
#include "bench.h"

#define BUFFER_WORDS 512u
#define MEM_PASSES 2u

int main(void) {
    // buffer with size of 512 words (2KB)
    volatile uint32_t buf[BUFFER_WORDS];
    volatile uint8_t *bytes = (volatile uint8_t *)buf;  // cast to byte pointer for byte access
    uint32_t sum = 0u;

    bench_start();

    for (int i = 0; i < BUFFER_WORDS; i++) {
        // store word instruction
        buf[i] = (i << 2) ^ i;  // some data pattern
    }
    for (int pass = 0; pass < MEM_PASSES; pass++) {
        // lw, lw, sw
        for (int i = 1; i < BUFFER_WORDS; i++) {
            buf[i] = buf[i] + buf[i - 1u];
        }
        for (int i = 0; i < BUFFER_WORDS; i++) {
            bytes[i] = (uint8_t)(bytes[i] ^ (uint8_t)i);  // lbu, sb
        }
    }
    for (int i = 0; i < BUFFER_WORDS * 4u; i++) {
        sum += buf[i];  // lw
    }

    // publish checksum and end measurement
    bench_done(sum);
    while(1){}   // spin forever
}