/************************************************
 * filename: brpredict_test.s
 * author: carrollh@msoe.edu <Hunter Carroll>
 * date: 10 Sep 2026
 * provides:
 * - Branch prediction test cases for 16 entry
 *   BHT and 2-bit saturating counter
 * - Always taken baseline
 * - Always not taken baseline
 * - alternating baseline
 * - JAL never learned baseline
************************************************/
.global _start
_start:
    # Test 1: Always Taken baseline
    # First and Last iteration need flush
    nop                     # drain + align
    nop
    nop

    addi    x1, x0, 16      # x1 = 16
    addi    x2, x0, 0       # x2 = i
T1_LOOP:
    addi    x2, x2, 1       # i++
    blt     x2, x1, T1_LOOP # i < 16

    nop                     # drain + align
    nop
    nop

    # Test 2: Always not taken baseline
    # Condition is never true
    addi    x3, x0, 16      # x3 = 16
    addi    x4, x0, 0       # x4 = i
    addi    x5, x0, 0       # x5 = completion?
T2_LOOP:
    addi    x4, x4, 1       # i++
    beq     x4, x0, T2_SKIP # NEVER TAKEN, entry 14
    blt     x4, x3, T2_LOOP # entry 15
T2_SKIP:
    addi x5, x0, 1          # test 2 complete

    nop                     # align + drain
    nop
    nop
    nop
    nop

    # Test 3: Alternating baseline
    # 2-bit saturating counter alternates
    # predicts not everytime
    addi    x6, x0, 16      # x6 = 16
    addi    x7, x0, 0       # x7 = i
    addi    x8, x0, 0       # x8 = toggle bit
T3_LOOP:
    xori    x8, x8, 1       # flip outcome
    beq     x8, x0, T3_SKIP # alternates N,T,N,T -> entry 10
    nop
T3_SKIP:
    addi    x7, x7, 1       # i++
    blt     x7, x6, T3_LOOP # LOOP CONTROL

    nop                     # drain + align x 6
    nop
    nop
    nop
    nop
    nop

    # Test 4: Entry Overwrite baseline
    addi    x9, x0, 32      # x9 = total iterations
    addi    x10, x0, 16     # x10 = direction flip
    addi    x11, x0, 0      # x11 = i
    addi    x12, x0, 0      # not-taken path count
T4_LOOP:
    addi    x11, x11, 1     # i++
    blt     x11, x10, T4_SKIP
    addi    x12, x12, 1     # only runs on not-taken path
T4_SKIP:
    blt     x11, x9, T4_LOOP

    nop                     # drain + align * 3
    nop
    nop

    # Test 5: Separate BHT entry baseline
    # JAL is unconditional, BHT should never learn
    addi    x13, x0, 16     # total iterations
    addi    x14, x0, 0      # i
    addi    x15, x0, 0      # flush check
    addi    x16, x0, 0      # completion marker
T5_LOOP:
    addi    x14, x14, 1     # i++
    beq     x14, x0, T5_SKIP
    nop                     # drain + align spacer * 15
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jal     x0, T5_TGT      # forward unconditional
    addi    x15, x15, 1     # must never retire
T5_TGT:
    blt     x14, x13, T5_LOOP
T5_SKIP:
    addi    x16, x0, 1      # test 5 complete

    nop
    nop
    nop
    nop

DONE:
    beq     x0, x0, DONE