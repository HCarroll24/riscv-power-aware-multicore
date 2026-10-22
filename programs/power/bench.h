/**
 * @file    bench.h
 * @author  Hunter Carroll (carrollh@msoe.edu)
 * @brief   Provides markers for every program to use
 * @version 0.1
 * @date 2026-10-21
 */
#ifndef BENCH_H
#define BENCH_H

#include <stdint.h>

#define SIM_MARK    (*(volatile uint32_t *)0xFF2000F0u) // unmapped: testbench watch
#define SIM_RESULT  (*(volatile uint32_t *)0xFF2000F4u) // unmapped: CHECKSUM

#define MARK_START  1u
#define MARK_DONE   2u

/**
 * @brief Opens measurement window
 */
static inline void bench_start(void) {
    SIM_MARK = MARK_START;
}

/**
 * @brief Publishes the checksum and closes measurement window
 * @param result checksum the testbench compares against expected
 */
static inline void bench_done(uint32_t result) {
    SIM_RESULT = result;
    SIM_MARK = MARK_DONE;
}

#endif // BENCH_H