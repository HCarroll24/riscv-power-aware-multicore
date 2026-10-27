	.file	"power_chase.c"
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
	addi	sp,sp,-512
	li	a4,1
	li	a5,-14680064
	sw	a4,240(a5)
	mv	a2,sp
	mv	a3,sp
	li	a4,0
	li	a0,64
.L2:
	addi	a5,a4,97
	andi	a5,a5,63
	slli	a5,a5,3
	xori	a1,a4,90
	add	a5,a2,a5
	sw	a5,0(a3)
	sw	a1,4(a3)
	addi	a4,a4,1
	addi	a3,a3,8
	bne	a4,a0,.L2
	li	a1,16
	li	a4,0
.L4:
	mv	a5,a2
.L3:
	lw	a5,0(a5)
	lw	a3,4(a5)
	add	a4,a4,a3
	bne	a5,a2,.L3
	srli	a5,a4,31
	addi	a1,a1,-1
	slli	a4,a4,1
	or	a4,a5,a4
	bne	a1,zero,.L4
	li	a3,-14680064
	sw	a4,244(a3)
	li	a4,2
	sw	a4,240(a3)
.L5:
	j	.L5
	.size	main, .-main
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
