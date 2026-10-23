	.file	"test_prog.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.type	seg7_display_all, @function
seg7_display_all:
	andi	a0,a0,0xff
	slli	a5,a0,8
	add	a5,a5,a0
	slli	a2,a5,16
	li	a3,-14680064
	add	a2,a5,a2
	sw	a2,32(a3)
	sw	a5,48(a3)
	ret
	.size	seg7_display_all, .-seg7_display_all
	.align	2
	.type	delay, @function
delay:
	li	a4,24576
	addi	a4,a4,424
.L4:
	mv	a5,a4
 #APP
# 102 "test_prog.c" 1
	1: addi a5, a5, -1 
   bnez a5, 1b     

# 0 "" 2
 #NO_APP
	addi	a0,a0,-1
	bne	a0,zero,.L4
	ret
	.size	delay, .-delay
	.align	2
	.type	count_displays, @function
count_displays:
	addi	sp,sp,-64
	li	t3,192
	li	t1,249
	li	a7,164
	li	a6,176
	li	a0,153
	li	a1,146
	li	a2,130
	li	a3,248
	li	a4,128
	li	a5,144
	sw	s0,56(sp)
	sw	ra,60(sp)
	sw	t3,8(sp)
	sw	t1,12(sp)
	sw	a7,16(sp)
	sw	a6,20(sp)
	sw	a0,24(sp)
	sw	a1,28(sp)
	sw	a2,32(sp)
	sw	a3,36(sp)
	sw	a4,40(sp)
	sw	a5,44(sp)
	addi	s0,sp,8
.L7:
	lw	a0,0(s0)
	addi	s0,s0,4
	call	seg7_display_all
	li	a0,1000
	call	delay
	addi	a5,sp,48
	bne	s0,a5,.L7
	lw	ra,60(sp)
	lw	s0,56(sp)
	addi	sp,sp,64
	jr	ra
	.size	count_displays, .-count_displays
	.align	2
	.type	led_sweep, @function
led_sweep:
	addi	sp,sp,-32
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	ra,28(sp)
	li	s0,9
	li	s3,1
	li	s1,-14680064
	li	s2,-1
.L11:
	sll	a5,s3,s0
	xori	a5,a5,1023
	sw	a5,0(s1)
	li	a0,250
	addi	s0,s0,-1
	call	delay
	bne	s0,s2,.L11
	lw	ra,28(sp)
	lw	s0,24(sp)
	li	a5,1023
	sw	a5,0(s1)
	lw	s2,16(sp)
	lw	s1,20(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
	.size	led_sweep, .-led_sweep
	.align	2
	.type	switches_to_leds, @function
switches_to_leds:
	li	a4,-14680064
	addi	a4,a4,64
	li	a3,-14680064
.L15:
	lw	a5,0(a4)
	not	a5,a5
	andi	a5,a5,1023
	sw	a5,0(a3)
	j	.L15
	.size	switches_to_leds, .-switches_to_leds
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	call	count_displays
	li	a0,255
	call	seg7_display_all
	call	led_sweep
	call	switches_to_leds
	.size	main, .-main
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
