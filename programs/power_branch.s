	.file	"power_branch.c"
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
	li	a3,1
	li	a5,-559038464
	sw	a3,240(a4)
	addi	a5,a5,-273
	li	a2,500
	li	a3,0
	li	a4,0
	j	.L8
.L13:
	andi	a1,a5,256
	add	a4,a4,a0
	beq	a1,zero,.L4
.L14:
	slli	a1,a5,15
	xor	a4,a4,a3
	bge	a1,zero,.L6
.L15:
	addi	a2,a2,-1
	sub	a3,a3,a4
	beq	a2,zero,.L12
.L8:
	slli	a1,a5,13
	xor	a5,a5,a1
	srli	a1,a5,17
	xor	a5,a5,a1
	slli	a0,a5,5
	andi	a1,a5,1
	xor	a5,a5,a0
	srli	a0,a5,7
	bne	a1,zero,.L13
	andi	a1,a5,256
	xor	a3,a3,a5
	bne	a1,zero,.L14
.L4:
	slli	a1,a5,15
	addi	a3,a3,3
	blt	a1,zero,.L15
.L6:
	addi	a2,a2,-1
	addi	a4,a4,1
	bne	a2,zero,.L8
.L12:
	li	a5,-14680064
	xor	a4,a4,a3
	sw	a4,244(a5)
	li	a4,2
	sw	a4,240(a5)
.L9:
	j	.L9
	.size	main, .-main
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
