	.file	"power_spin.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	li	a4,-14680064
	addi	a4,a4,240
	li	a3,1
	li	a5,4096
	addi	a5,a5,-763
	sw	a3,0(a4)
 #APP
# 16 "power/power_spin.c" 1
	1: addi a5, a5, -1 
   bnez a5, 1b     

# 0 "" 2
 #NO_APP
	li	a3,-14680064
	sw	a5,244(a3)
	li	a5,2
	sw	a5,0(a4)
.L2:
	j	.L2
	.size	main, .-main
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
