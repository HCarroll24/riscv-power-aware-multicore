/**
 * @file    power_chase.c
 * @author  Hunter Carroll (carrollh@msoe.edu)
 * @brief   Power of pipeline stalls and stall frequency, chasing data dependency stalls
 * @version 0.1
 * @date    2026-10-21
 */
#include "bench.h"

// 256 linked list nodes on stack
#define NODES 256u
#define CHASE_LAPS 24u

typedef struct node {
    struct node *next;
    uint32_t val;
} node_t;

int main(void) {
    // initialize linked list
    node_t list[NODES];
    uint32_t sum = 0u;

    // start measurement
    bench_start();

    // node i -> node (i + 97) mod 256: 97 is odd, so it visits all 256
    for (int i = 0; i < NODES; i++) {
        list[i].next = &list[(i + 97) % (NODES - 1)];
        list[i].val = i ^ 0x5Au;
    }
    for (int lap = 0; lap < CHASE_LAPS; lap++) {
        node_t *cur = &list[0];
        do {
            cur = cur->next;    // lw cur, 0(cur)
            sum += cur->val;    // lw val, 4(cur): needs p right away
        } while (cur != &list[0]);
        sum = (sum << 1) | (sum >> 31); // rotate left to prevent optimization
    }

    // publish checksum and end measurement
    bench_done(sum);
    while(1){}   // spin forever
}