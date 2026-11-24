/*************************************************************************
 * filename: count.s
 * author: carrollh@msoe.edu <Hunter Carroll>
 * date: 23 Nov 2026
 * provides:
 * - Grabs initial value from switches
 * - Counts up from the initial value every 1 second
 * - uses subroutines for the delay and to read the switches
*************************************************************************/
.equ SWITCHES, 0xFF200040
.equ HEX5_HEX4, 0xFF200030
.equ HEX3_HEX0, 0xFF200020
.equ KEY, 0xFF200050

.section .text
.globl _start

_start:
    # Grab initial value from switches