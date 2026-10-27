/**
 * @file    power_branch.c
 * @author  Hunter Carroll (carrollh@msoe.edu)
 * @brief   unpredictable branches, BHT mispredicts about half, power of wasted work
 * @version 0.1
 * @date    2026-10-21
 */
#include "bench.h"

#define BRANCH_LOOPS 500u

int main(void) {
    uint32_t x = 0xDEADBEEFu;   // "magic number"
    uint32_t a = 0u;
    uint32_t b = 0u;

    // start measurement
    bench_start();
    for (int i = 0; i < BRANCH_LOOPS; i++) {
        x ^= x << 13;
        x ^= x >> 17;
        x ^= x << 5;    // xorshift32 random number generator

        if (x & 0x1u) {
            a += x >> 7;
        } else {
            b ^= x;
        }
        if (x & 0x100u) {
            a ^= b;
        } else {
            b += 3u;
        }
        if (x & 0x10000u) {
            b -= a;
        } else {
            a += 1u;
        }
    }

    // publish checksum and end measurement
    bench_done(a ^ b);
    while(1){}   // spin forever
}