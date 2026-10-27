	.file	"power_mem.c"
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
	addi	sp,sp,-352
	li	a5,-14680064
	li	a4,1
	sw	a4,240(a5)
	addi	a1,sp,12
	li	a5,0
	li	a2,85
.L2:
	slli	a4,a5,2
	xor	a3,a4,a5
	add	a4,a1,a4
	sw	a3,0(a4)
	addi	a5,a5,1
	bne	a5,a2,.L2
	li	a7,2
	addi	a6,sp,97
	li	a0,85
	li	t1,1
.L3:
	li	a4,1
.L4:
	slli	a5,a4,2
	slli	a3,a4,2
	add	a3,a1,a3
	add	a5,a1,a5
	lw	a2,0(a3)
	lw	a5,-4(a5)
	addi	a4,a4,1
	add	a5,a2,a5
	sw	a5,0(a3)
	bne	a4,a0,.L4
	mv	a5,a0
.L5:
	sub	a3,a6,a5
	lbu	a4,0(a3)
	sub	a2,a0,a5
	addi	a5,a5,-1
	xor	a4,a4,a2
	andi	a4,a4,0xff
	sb	a4,0(a3)
	bne	a5,zero,.L5
	beq	a7,t1,.L8
	li	a7,1
	j	.L3
.L8:
	li	a4,0
	li	a2,85
.L6:
	slli	a3,a4,2
	add	a3,a1,a3
	lw	a3,0(a3)
	addi	a4,a4,1
	add	a5,a5,a3
	bne	a4,a2,.L6
	li	a3,-14680064
	sw	a5,244(a3)
	li	a4,2
	sw	a4,240(a3)
.L7:
	j	.L7
	.size	main, .-main
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
