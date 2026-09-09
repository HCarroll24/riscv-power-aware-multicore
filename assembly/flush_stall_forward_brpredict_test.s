/************************************************
 * filename: flush_stall_forward_brpredict_test.s
 * author: carrollh@msoe.edu <Hunter Carroll>
 * date: 8 Sep 2026
 * provides:
 * - Flush test cases
 * - Stall test cases
 * - Forwarding test cases
 * - Branch predictin test cases for 16 entry
 *   BHT and 2-bit saturating counter
************************************************/
.global _start
_start:
    # Test 1: Basic EX/MEM Forwarding (1-cycle)
    # Forwards from Ex/Mem to next instruction
    addi    x1, x0, 10      # x1 = 10
    add     x2, x1, x1      # x2 = 2 * x1, requires forwarding

    # Test 2: MEM/WB Forwarding (2-cycle)
    # Tests forwarding 2 instructions after
    addi    x3, x0, 5       # x3 = 5
    nop                     # filler
    add     x5, x3, x3      # x5 = 2 * x3

    # Test 3: WB (3-cycle)
    # Tests forwarding 3 instructions after
    addi    x6, x0, 100     # x6 = 100
    nop                     # filler
    nop                     # filler
    add     x9, x6, x6      # x9 = 2 * x6

    # Test 4: Back to Back dependencies
    # Tests forwarding in chain of dependent instructions
    addi    x10, x0, 1      # x10 = 1
    addi    x11, x10, 1     # x11 = x10 + 1
    addi    x12, x11, 1     # x12 = x11 + 1
    addi    x13, x12, 1     # x13 = x12 + 1
    addi    x14, x13, 1     # x14 = x13 + 1

    # Test 5: Both operands need forwarding
    # Tests simultaneous forwarding
    addi    x15, x0, 30     # x15 = 30
    addi    x16, x0, 12     # x16 = 12
    add     x17, x15, x16   # x17 = x15 + x16 = 42