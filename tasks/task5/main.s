format_dn: .asciz "%d\n"
format_sn: .asciz "%s\n"
format_atoi_wrong_format: .asciz "atoi wrong forma\n"
format_atoi_owerflow: .asciz "atoi owerflow\n"
format_operation_wrong_format: .asciz "operation wrong format\n"
format_operation_div_by_zero: .asciz "div by zero\n"
format_wrong_input_str: .asciz "wrong input str\n"

.text
.align 4
.global main

my_atoi:
	stmfd sp!, {fp, lr}
	add fp, sp, #4
	sub sp, sp, #32
	
	str r0, [fp, #-8] @str
	mov r1, #0
	str r1, [fp, #-12] @number
	mov r1, #1
	str r1, [fp, #-16] @p^0=1 p=10 etc
	str r9, [fp, #-20] @save r9
	mov r9, #1
	b b_ind_minus_loop
	ind_plus:
		add r1, r1, #1
		str r1, [fp, #-8]
		b b_ind_minus_loop
	ind_minus:
		add r1, r1, #1
		str r1, [fp, #-8]
		mov r1, #-1
		mul r9, r1, r9
	b_ind_minus_loop:
		ldr r1, [fp, #-8]
		ldrb r0, [r1]
		strb r0, [fp, #-24]
		cmp r0, #45
		beq ind_minus
		ldrb r0, [fp, #-24]
		cmp r0, #0
		beq atoi_wrong_format
		ldrb r0, [fp, #-24]
		cmp r0, #43
		beq ind_plus
		ldrb r0, [fp, #-24]
		cmp r0, #48
		blt atoi_wrong_format
		ldrb r0, [fp, #-24]
		cmp r0, #57
		bgt atoi_wrong_format
	str r9, [fp, #-28]
	ldr r0, [fp, #-8]
	bl strlen
	ldr r1, [fp, #-8]
	add r1, r1, r0
	sub r1, r1, #1
	str r1, [fp, #-32]
	ldr r0, [fp, #-8]
	sub r0, r0, #1
	str r0, [fp, #-8]
	b_get_digits:
		ldr r0, [fp, #-32]
		ldr r1, [fp, #-8]
		cmp r0, r1
		beq atoi_success
		ldr r1, [fp, #-32]
		ldrb r0, [r1]
		strb r0, [fp, #-24]
		sub r1, r1, #1
		str r1, [fp, #-32]
		ldrb r0, [fp, #-24]
		cmp r0, #48
		blt atoi_wrong_format
		ldrb r0, [fp, #-24]
		cmp r0, #57
		bgt atoi_wrong_format
		ldr r1, [fp, #-12]
		cmp r1, #0x7fffffff
		bhi atoi_owerflow
		ldrb r0, [fp, #-24]
		ldr r1, [fp, #-16]
		ldr r9, [fp, #-12]
		sub r0, r0, #48
		mul r0, r1, r0
		add r9, r9, r0
		str r9, [fp, #-12]
		mov r9, #10
		mul r1, r9, r1
		str r1, [fp, #-16]
		b b_get_digits
	atoi_success:
		ldr r0, [fp, #-12]
		ldr r9, [fp, #-28]
		mul r0, r0, r9
		mov r1, #0
		b my_atoi_end
	atoi_wrong_format:
		mov r1, #1
		b my_atoi_end
	atoi_owerflow:
		ldr r0, [fp, #-12]
		mov r1, #2
	my_atoi_end:
		ldr r9, [fp, #-20]
		add sp, sp, #32
		ldmfd sp!, {lr, fp}
		bx lr
op_from_str:
	stmfd sp!, {fp, lr}
	add fp, sp, #4
	sub sp, sp, #24
	
	mov r9, #0
	str r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #0
	beq op_from_str_err
	ldr r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #32
	ldr r0, [fp, #-8]
	bne do_not_add_1
	add r0, r0, #1
	do_not_add_1:
	str r0, [fp, #-12]
	bl find_end_of_word
	str r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #0
	beq op_from_str_err
	ldr r0, [fp, #-8]
	mov r1, #0
	strb r1, [r0]
	add r0, r0, #1
	bl skip_spaces
	str r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #0
	beq op_from_str_err
	ldr r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #32
	ldr r0, [fp, #-8]
	bne do_not_add_2
	add r0, r0, #1
	do_not_add_2:
	str r0, [fp, #-16]
	bl find_end_of_word
	str r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #0
	beq op_from_str_err
	ldr r0, [fp, #-8]
	mov r1, #0
	strb r1, [r0]
	add r0, r0, #1
	bl skip_spaces
	str r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #0
	beq op_from_str_err
	ldr r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #32
	ldr r0, [fp, #-8]
	bne do_not_add_3
	add r0, r0, #1
	do_not_add_3:
	str r0, [fp, #-20]
	bl find_end_of_word
	str r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #0
	beq op_from_str_ex
	ldr r0, [fp, #-8]
	mov r1, #0
	strb r1, [r0]
	b op_from_str_ex
	
	op_from_str_err:
		ldr r0, [fp, #-8]
		ldr r1, [fp, #-8]
		ldr r2, [fp, #-8]
		mov r9, #1
	op_from_str_ex:	
		ldr r0, [fp, #-12]
		ldr r1, [fp, #-16]
		ldr r2, [fp, #-20]
		add sp, sp, #24
		ldmfd sp!, {lr, fp}
		bx lr
		
skip_spaces:
	stmfd sp!, {fp, lr}
	add fp, sp, #4
	sub sp, sp, #8
	
	str r0, [fp, #-8]
	spaces_l:
		ldr r0, [fp, #-8]
		ldrb r0, [r0]
		cmp r0, #32
		ldr r0, [fp, #-8]
		add r0, r0, #1
		str r0, [fp, #-8]
	beq spaces_l
	sub r0, r0, #1
	add sp, sp, #8
	ldmfd sp!, {lr, fp}
	bx lr
find_end_of_word:
	stmfd sp!, {fp, lr}
	add fp, sp, #4
	sub sp, sp, #8
	str r0, [fp, #-8]
	find_end_of_word_loop:
		ldr r0, [fp, #-8]
		ldrb r0, [r0]
		cmp r0, #0
		beq founded
		ldr r0, [fp, #-8]
		ldrb r0, [r0]
		cmp r0, #32
		ldr r0, [fp, #-8]
		add r0, r0, #1
		str r0, [fp, #-8]
		bne find_end_of_word_loop
		sub r0, r0, #1
		str r0, [fp, #-8]
	founded:
		ldr r0, [fp,#-8]
	find_end_of_word_ex:
		add sp, sp, #8
		ldmfd sp!, {lr, fp}
		bx lr
		
operation:
	stmfd sp!, {fp, lr}
	add fp, sp, #4
	sub sp, sp, #16
	
	str r0, [fp, #-8] @operation
	str r1, [fp, #-12] @op1
	str r2, [fp, #-16] @op2
	bl strlen
	cmp r0, #1
	bne wrong_operation
	ldr r0, [fp, #-8]
	ldrb r0, [r0]
	str r0, [fp, #-8]
	ldr r1, [fp, #-12] @op1
	ldr r2, [fp, #-16] @op2
	cmp r0, #45
	beq operation_minus
	ldr r0, [fp, #-8] @operation
	cmp r0, #43
	beq operation_plus
	ldr r0, [fp, #-8] @operation
	cmp r0, #120
	beq operation_mult
	ldr r0, [fp, #-8] @operation
	cmp r0, #100
	beq operation_div
	b wrong_operation
	operation_mult:
		mul r0, r1, r2
		mov r1, #0
		b operation_end
	operation_div:
		mov r0, r1
		mov r1, r2
		bl _div
		b operation_end
	operation_plus:
		add r0, r1, r2
		mov r1, #0
		b operation_end
	operation_minus:
		sub r0, r1, r2
		mov r1, #0
		b operation_end
	wrong_operation:
		mov r1, #1
	
	operation_end:
		add sp, sp, #16
		ldmfd sp!, {lr, fp}
		bx lr
		
_div:
	stmfd sp!, {fp, lr}
	add fp, sp, #4
	sub sp, sp, #28
	
	str r0, [fp, #-8]
	str r1, [fp, #-12]
	mov r2, #1
	str r2, [fp, #-20]
	cmp r0, #0
	bge div_minus_1
	mov r1, #-1
	mul r2, r2, r1
	ldr r0, [fp, #-8]
	mul r0, r0, r1
	str r0, [fp, #-8]
	div_minus_1:
	ldr r1, [fp, #-12]
	cmp r1, #0
	bge div_minus_2
	mov r0, #-1
	mul r2, r2, r0
	ldr r1, [fp, #-12]
	mul r1, r1, r0
	str r1, [fp, #-12]
	div_minus_2:
	str r2, [fp, #-20]
	mov r2, #0
	str r2, [fp, #-16] @res
	
	ldr r0, [fp, #-8]
	ldr r1, [fp, #-12]

	
	cmp r1, #0
	beq div_by_zero_error
	ldr r1, [fp, #-12]
	ldr r0, [fp, #-8]
	cmp r0, r1
	blt div_success
	ldr r1, [fp, #-12]
	ldr r0, [fp, #-8]
	str r0, [fp, #-16]
	cmp r1, #1
	beq div_success
	mov r0, #0
	str r0, [fp, #-16]

	div_loop_b:
		ldr r0, [fp, #-8]
		ldr r1, [fp, #-12]
		cmp r0, r1
		blt div_success
		mov r9, #1
		str r9, [fp, #-24]
		mov r2, #1
		find_digit:
			ldr r0, [fp, #-8]
			ldr r1, [fp, #-12]
			mul r1, r1, r9
			cmp r1, r0
			bge find_div_mult
			str r9, [fp, #-24]
			mov r1, #10
			mul r9, r9, r1
		b find_digit
		find_div_mult:
			ldr r1, [fp, #-12]
			ldr r0, [fp, #-8]
			ldr r9, [fp, #-24]
			mul r9, r9, r2
			mul r1, r1, r9
			cmp r0, r1
			add r2, r2, #1
		bge find_div_mult
		ldr r9, [fp, #-24]
		sub r2, r2, #2
		mul r9, r9, r2
		ldr r0, [fp, #-8]
		ldr r1, [fp, #-16]
		add r1, r1, r9
		str r1, [fp, #-16]
		ldr r1, [fp, #-12]
		mul r9, r9, r1
		sub r0, r0, r9
		str r0, [fp, #-8]	
	b div_loop_b
	div_success:
		mov r1, #0
		ldr r2, [fp, #-20]
		ldr r0, [fp, #-16]
		mul r0, r0, r2
		b div_ex
	div_by_zero_error:
		mov r1, #2
	div_ex:
		add sp, sp, #28
		ldmfd sp!, {lr, fp}
		bx lr
main:
	stmfd sp!, {fp, lr}
	add fp, sp, #4
	sub sp, sp, #16
	str r0, [fp, #-8] @argc
	cmp r0, #4
	bge from_args
	from_input:
		mov r0, #20
		bl malloc
		str r0, [fp, #-8]
		bl gets
		ldr r0, [fp, #-8]
		bl op_from_str
		str r0, [fp, #-8] @op1
		str r1, [fp, #-12] @operation
		str r2, [fp, #-16] @op2
		cmp r9, #1
		beq wrong_input_str_format
		b calc
	from_args:
		ldr r0, [r1, #4] @arg1
		str r0, [fp, #-8] @op1
		ldr r0, [r1, #8] @arg2
		str r0, [fp, #-12] @operation
		ldr r0, [r1, #12] @arg3
		str r0, [fp, #-16] @op2
		ldr r0, [fp, #-8]
	calc:
		ldr r0, [fp, #-8]
		bl my_atoi
		str r0, [fp, #-8]
		mov r0, r1
		cmp r0, #1
		beq atoi_format_error
		mov r0, r1
		cmp r0, #2
		beq atoi_owerflow_error
		ldr r0, [fp, #-16]
		bl my_atoi
		str r0, [fp, #-16]
		mov r0, r1
		cmp r0, #1
		beq atoi_format_error
		mov r0, r1
		cmp r0, #2
		beq atoi_owerflow_error
		ldr r0, [fp, #-12]
		ldr r1, [fp, #-8]
		ldr r2, [fp, #-16]
		bl operation
		mov r2, r1
		cmp r1, #1
		beq operation_format_error
		cmp r2, #2
		beq operation_div_by_zero
		mov r1, r0
		ldr r0, ptr_format_dn
		bl printf
		b ex
	operation_div_by_zero:
		ldr r0, ptr_format_operation_div_by_zero
		bl printf
		b ex		
	wrong_input_str_format:
		ldr r0, ptr_format_wrong_input_str
		bl printf
		b ex	
	operation_format_error:
		ldr r0, ptr_format_operation_wrong_format
		bl printf
		b ex
	atoi_owerflow_error:
		ldr r0, ptr_format_atoi_owerflow
		bl printf
		b ex
	atoi_format_error:
		ldr r0, ptr_format_atoi_wrong_format
		bl printf
	ex:
	add sp, sp, #16
	ldmfd sp!, {lr, fp}
	bx lr
	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
strlen:
  	stmfd sp!, {fp, lr}
	add fp, sp, #4
	sub sp, sp, #12

	str r0, [fp, #-8]
	str r9, [fp, #-12]
	sub r9, r9, r9
	b l_strlen_b

l_strlen_t:
	add r9, r9, #1
	ldr r0, [fp, #-8]
	add r0, r0, #1
	str r0, [fp, #-8]

l_strlen_b:
	ldr r0, [fp, #-8]
	ldrb r0, [r0]
	cmp r0, #0
	bne l_strlen_t

	mov r0, r9
	ldr r9, [fp, #-12]
	add sp, sp, #12
	ldmfd sp!, {lr, fp}
	bx lr
	
ptr_format_sn: .word format_sn
ptr_format_dn: .word format_dn
ptr_format_atoi_wrong_format: .word format_atoi_wrong_format
ptr_format_atoi_owerflow: .word format_atoi_owerflow
ptr_format_operation_wrong_format: .word format_operation_wrong_format
ptr_format_operation_div_by_zero: .word format_operation_div_by_zero
ptr_format_wrong_input_str: .word format_wrong_input_str