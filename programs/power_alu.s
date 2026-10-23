	.file	"power_alu.c"
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
	li	a2,1
	li	a5,-14680064
	li	a4,-1640529920
	li	a3,305418240
	li	a0,4096
	sw	a2,240(a5)
	addi	a4,a4,-1607
	addi	a3,a3,1656
	addi	a0,a0,-1096
	li	a2,0
.L2:
	slli	a5,a3,13
	xor	a3,a5,a3
	srli	a5,a3,17
	xor	a5,a5,a3
	slli	a3,a5,5
	xor	a3,a3,a5
	add	a4,a3,a4
	srli	a1,a4,29
	slli	a5,a4,3
	or	a5,a5,a1
	xor	a5,a5,a4
	sub	a5,a5,a2
	slli	a4,a3,16
	srli	a4,a4,16
	srli	a5,a5,1
	addi	a2,a2,1
	add	a4,a4,a5
	bne	a2,a0,.L2
	li	a5,-14680064
	xor	a3,a3,a4
	sw	a3,244(a5)
	li	a4,2
	sw	a4,240(a5)
.L3:
	j	.L3
	.size	main, .-main
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
