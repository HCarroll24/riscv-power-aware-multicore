/*************************************************************************
 * File:        shift_iso.S
 * Project:     RISC-V Power Aware
 * Author:      carrollh@msoe.edu <Hunter C>
 * Date:        12 November 2026
 * Provides:
 *    Self-checking RV32I test for the shifters and their operand
 *    isolation hold registers (IDEX_SLL/SRL/SRA_A/_B).
 *
 *    Every CHECK compares a result to its expected value and adds the
 *    result into a signature. A wrong result bumps the fail count and
 *    records that test's ID.
 *
 * Results (written after the last test):
 *    CHECKSUM (0xFF2000F4)   signature, expected 0xC8DFA5DF
 *    LEDR     (0xFF200000)   fail count, expected 0
 *    HEX3_HEX0(0xFF200020)   ID of the last failing test, 0 = none
 *
 * Section numbers are written to HEX3_HEX0 while the test runs, so
 * the HEX0 wave shows which section the pipeline is in.
 *
 * Registers owned by the harness (tests never write them):
 *    s0 fail count   s1 signature   s2 last failing ID
 *    s3 MMIO base    s4 DMEM scratch base
 *
 * Waveform checks (things a register result cannot show):
 *    Section 6: ID_EX_SLL_A / SRA_A must never hold 0x0BAD0BAD.
 *    Section 4: on the load-use stall cycle SH_LD must be 000.
 *    Section 8: ID_EX_SLL_A, SRL_A, SRA_A must stay flat the whole
 *               section (no shifts in it).
 *    Section 1: no SRA yet, so ID_EX_SRA_A must stay 0 until the
 *               first srai in section 2.
*************************************************************************/

    .equ MMIO_BASE,   0xFF200000
    .equ OFF_LEDR,    0x000
    .equ OFF_HEX,     0x020
    .equ OFF_MARK,    0x0F0
    .equ OFF_RESULT,  0x0F4
    .equ DMEM_BASE,   0x00010000

/* CHECK reg, expected, id
 * no shifts in here so the checker never touches the shifters */
    .macro CHECK reg, expected, id
    li      t6, \expected
    beq     \reg, t6, 1f
    addi    s0, s0, 1
    li      s2, \id
1:  add     s1, s1, \reg
    .endm

/* SECTION n: show the section on HEX0 */
    .macro SECTION n
    li      t6, \n
    sw      t6, OFF_HEX(s3)
    .endm

    .text
    .globl  main
main:
    li      s0, 0
    li      s1, 0
    li      s2, 0
    li      s3, MMIO_BASE
    li      s4, DMEM_BASE

    # open the measurement window
    li      t6, 1
    sw      t6, OFF_MARK(s3)

/* ---------------------------------------------------------------
 * Section 1: SLLI / SRLI edge shift amounts (0, 1, 31)
 * ------------------------------------------------------------- */
    SECTION 1
    li      t0, 0x80000001
    slli    t1, t0, 0
    CHECK   t1, 0x80000001, 101
    slli    t1, t0, 1
    CHECK   t1, 0x00000002, 102
    slli    t1, t0, 31
    CHECK   t1, 0x80000000, 103
    srli    t1, t0, 0
    CHECK   t1, 0x80000001, 104
    srli    t1, t0, 1
    CHECK   t1, 0x40000000, 105
    srli    t1, t0, 31
    CHECK   t1, 0x00000001, 106

/* ---------------------------------------------------------------
 * Section 2: SRAI, sign fill on negative and positive operands.
 * SRAI's immediate is 0x400 + shamt; only bits 4..0 may be used.
 * ------------------------------------------------------------- */
    SECTION 2
    li      t0, 0x80000000
    srai    t1, t0, 4
    CHECK   t1, 0xF8000000, 201
    srai    t1, t0, 31
    CHECK   t1, 0xFFFFFFFF, 202
    srai    t1, t0, 0
    CHECK   t1, 0x80000000, 203
    li      t0, 0x7FFFFFFF
    srai    t1, t0, 31
    CHECK   t1, 0x00000000, 204
    srai    t1, t0, 4
    CHECK   t1, 0x07FFFFFF, 205

/* ---------------------------------------------------------------
 * Section 3: register shifts. Only rs2[4:0] is the shift amount.
 * ------------------------------------------------------------- */
    SECTION 3
    li      t0, 0x12345678
    li      t2, 0xFFFFFFE4          # shamt 4, upper bits set
    sll     t1, t0, t2
    CHECK   t1, 0x23456780, 301
    srl     t1, t0, t2
    CHECK   t1, 0x01234567, 302
    li      t2, 0x00000020          # shamt 0 (bit 5 ignored)
    sll     t1, t0, t2
    CHECK   t1, 0x12345678, 303
    li      t2, 0x0000003F          # shamt 31
    srl     t1, t0, t2
    CHECK   t1, 0x00000000, 304
    li      t0, 0x87654321
    li      t2, 0xFFFFFFF0          # shamt 16
    sra     t1, t0, t2
    CHECK   t1, 0xFFFF8765, 305

/* ---------------------------------------------------------------
 * Section 4: forwarding into the hold registers.
 * Producer -> shift with 0, 1 and 2 instructions between them, on
 * rs1, on rs2, and on both. The hold register is loaded from the
 * forwarded SRC1/SRC2, so a wrong forward shows up here.
 * ------------------------------------------------------------- */
    SECTION 4
    # distance 0 (EX -> ID forward)
    addi    t0, zero, 0x123
    slli    t1, t0, 8
    CHECK   t1, 0x00012300, 401
    # distance 1 (MEM forward)
    addi    t0, zero, 0x456
    addi    t3, zero, 0
    srli    t1, t0, 4
    CHECK   t1, 0x00000045, 402
    # distance 2 (WB / regfile bypass)
    addi    t0, zero, -256          # 0xFFFFFF00
    addi    t3, zero, 0
    addi    t4, zero, 0
    srai    t1, t0, 4
    CHECK   t1, 0xFFFFFFF0, 403
    # rs2 forwarded at distance 0
    li      t0, 0x0000000F
    addi    t2, zero, 12
    sll     t1, t0, t2
    CHECK   t1, 0x0000F000, 404
    # both operands from back-to-back producers
    addi    t0, zero, -1
    addi    t2, zero, 28
    srl     t1, t0, t2
    CHECK   t1, 0x0000000F, 405

/* ---------------------------------------------------------------
 * Section 5: load-use stall into a shift.
 * The shift sits in decode for the stall cycle with a stale
 * operand. SH_LD must be 000 that cycle and the hold register must
 * load only the real loaded value on the next cycle.
 * t0 is set to a marker first so a stale load is easy to spot:
 * ID_EX_SLL_A must never show 0x057A1E00.
 * ------------------------------------------------------------- */
    SECTION 5
    li      t1, 0x00ABCDEF
    sw      t1, 0(s4)
    li      t2, 3
    sw      t2, 4(s4)
    li      t0, 0x057A1E00          # stale marker
    lw      t0, 0(s4)
    slli    t3, t0, 4               # load-use on rs1
    CHECK   t3, 0x0ABCDEF0, 501
    li      t0, 0x80000000
    lw      t2, 4(s4)
    sra     t3, t0, t2              # load-use on rs2 (shamt)
    CHECK   t3, 0xF0000000, 502
    lw      t0, 0(s4)
    srli    t3, t0, 8               # load-use, SRL
    CHECK   t3, 0x0000ABCD, 503

/* ---------------------------------------------------------------
 * Section 6: shifts on a flushed path.
 * JALR always redirects in EX, so the two instructions after it
 * are flushed: one in decode (IDEX_FLUSH, must not load), one in
 * fetch (IF/ID flush). Neither may write a register, and neither
 * may load a hold register. s5 holds the marker 0x0BAD0BAD.
 * ------------------------------------------------------------- */
    SECTION 6
    li      s5, 0x0BAD0BAD
    li      t1, 0x11111111
    li      t2, 0x22222222
    la      t0, 1f
    jalr    zero, 0(t0)
    slli    t1, s5, 1               # flushed in decode
    srai    t2, s5, 1               # flushed in fetch
1:  CHECK   t1, 0x11111111, 601
    CHECK   t2, 0x22222222, 602
    # a real shift right after the redirect must still work
    li      t0, 0x00000F00
    la      t3, 2f
    jalr    zero, 0(t3)
    sll     t4, s5, t0              # flushed
2:  srli    t4, t0, 8
    CHECK   t4, 0x0000000F, 603

/* ---------------------------------------------------------------
 * Section 7: back-to-back shifts.
 * Same shifter every cycle (its hold register reloads each cycle)
 * and a dependent chain that rotates through all three shifters.
 * ------------------------------------------------------------- */
    SECTION 7
    li      t0, 1
    slli    t0, t0, 1
    slli    t0, t0, 2
    slli    t0, t0, 3
    CHECK   t0, 0x00000040, 701
    li      t0, 0xF0000000
    srai    t0, t0, 4               # 0xFF000000
    srli    t0, t0, 4               # 0x0FF00000
    slli    t0, t0, 4               # 0xFF000000
    srai    t0, t0, 8               # 0xFFFF0000
    CHECK   t0, 0xFFFF0000, 702

/* ---------------------------------------------------------------
 * Section 8: isolation window, no shifts at all.
 * ID_EX_SLL_A, SRL_A and SRA_A must not change anywhere in here.
 * ------------------------------------------------------------- */
    SECTION 8
    li      t0, 0x13579BDF
    li      t1, 0x2468ACE0
    add     t2, t0, t1
    xor     t2, t2, t0
    sub     t2, t2, t1
    or      t2, t2, t0
    and     t2, t2, t1
    add     t2, t2, t0
    xor     t2, t2, t1
    sub     t2, t2, t0
    slt     t3, t2, t1
    sltu    t4, t2, t1
    add     t2, t2, t3
    add     t2, t2, t4
    CHECK   t2, 0x245148A2, 801

/* ---------------------------------------------------------------
 * Section 9: loop with shifts in the body.
 * The loop exit is a mispredict once the BHT has learned taken, so
 * the first body instruction (a shift) is fetched on the wrong path
 * and flushed at the exit.
 * ------------------------------------------------------------- */
    SECTION 9
    li      t0, 1                   # value
    li      t1, 0                   # counter
    li      t2, 5
3:  slli    t0, t0, 1
    srli    t3, t0, 1
    add     t0, t0, t3
    addi    t1, t1, 1
    bne     t1, t2, 3b
    CHECK   t0, 0x000000F3, 901

/* ---------------------------------------------------------------
 * Section 10: x0 rules. A shift into x0 writes nothing, and a shift
 * of x0 is 0.
 * ------------------------------------------------------------- */
    SECTION 10
    li      t0, 0xFFFFFFFF
    slli    zero, t0, 3
    add     t1, zero, zero
    CHECK   t1, 0x00000000, 1001
    srai    t1, zero, 5
    CHECK   t1, 0x00000000, 1002

/* ---------------------------------------------------------------
 * Publish results. CHECKSUM goes out before the DONE marker because
 * the testbench waits for them in that order.
 * ------------------------------------------------------------- */
    sw      s0, OFF_LEDR(s3)        # fail count
    sw      s2, OFF_HEX(s3)         # last failing test ID
    sw      s1, OFF_RESULT(s3)      # CHECKSUM
    li      t6, 2
    sw      t6, OFF_MARK(s3)        # close the window
4:  j       4b
