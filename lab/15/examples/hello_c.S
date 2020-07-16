	.arch armv4t
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 18, 4
	.file	"hello.c"
	.comm	buf,40,4
	.section	.rodata
	.align	2
.LC0:
	.ascii	"Hello, World\000"
	.text
    @.code
	.align	2
	.global	main
	.type	main, %function
main:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #32
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	str	r2, [fp, #-24]
	ldr	r3, .L3 @ ldr r3, [pc + ...]
	str	r3, [fp, #-8]
	ldr	r3, .L3+4
	mov	r2, #1
	str	r2, [r3, #0]
	ldr	r3, .L3+4
	mov	r2, #7
	str	r2, [r3, #20]
	ldr	r0, .L3+8
	bl	puts
	ldr	r3, [fp, #-20]
	add	r3, r3, #4
	ldr	r3, [r3, #0]
	cmp	r3, #0
	beq	.L2
	ldr	r3, [fp, #-20]
	add	r3, r3, #4
	ldr	r3, [r3, #0]
	mov	r0, r3
	bl	printf
.L2:
	ldr	ip, .L3+12
	mov	r3, #5
	str	r3, [sp, #0]
	mov	r0, #1
	mov	r1, #2
	mov	r2, #3
	mov	r3, #4
	mov	lr, pc
	bx	ip
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	ldmfd	sp!, {fp, lr}
	bx	lr
.L4:
	.align	2
.L3:
	.word	287454020
	.word	buf
	.word	.LC0
	.word	fun
	.size	main, .-main
	.align	2
	.global	fun
	.type	fun, %function
fun:
	@ Function supports interworking.
	@ args = 4, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #20
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	str	r2, [fp, #-16]
	str	r3, [fp, #-20]
	add	sp, fp, #0
	ldmfd	sp!, {fp}
	bx	lr
	.size	fun, .-fun
	.ident	"GCC: (Debian 4.6.3-14) 4.6.3"
	.section	.note.GNU-stack,"",%progbits
