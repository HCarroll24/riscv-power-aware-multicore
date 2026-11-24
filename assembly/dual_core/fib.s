/*************************************************************************
 * filename: fib.s
 * author: carrollh@msoe.edu <Hunter Carroll>
 * date: 23 Nov 2026
 * provides:
 * - Uses fibonacci sequence to count up from initial value eveyr 1 second
 * - uses subroutines for the delay and to read the switches
*************************************************************************/
.equ LEDR, 0xFF200000
.equ KEY, 0xFF200050

.section .text
.globl _start

_start: