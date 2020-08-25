format_wrong_char: .asciz "wrong_char\n"
format_overflow_error: .asciz "overflow_error\n"
format_decimal_number: .asciz "%d\n"
format_wrong_operation: .asciz "wrong_operation\n"
format_wrong_input_string: .asciz "wrong_input_string\n"
format_divizion_by_zero: .asciz "divizion_by_zero\n"

ptr_format_wrong_char: .word format_wrong_char
ptr_format_overflow_error: .word format_overflow_error
ptr_format_decimal_number: .word format_decimal_number
ptr_format_wrong_operation: .word format_wrong_operation
ptr_format_wrong_input_string: .word format_wrong_input_string
ptr_format_divizion_by_zero: .word format_divizion_by_zero


.text
.align 4
.global main

my_atoi:
    push {fp, lr}
    add fp, sp, #4
    sub sp, sp, #8
    push {r2, r3, r4, r5, r6, r7, r8, r9}

    push {r0}
    bl strlen
    cmp r0, #11
    bge my_atoi_overflow_error
    
    pop {r4} @r4 - указатель на начало строки
    ldrb r5, [r4] @символ строки
    mov r6, #1
    mov r9, #10
    mov r7, #0 @само число

    cmp r5, #'-'
    moveq r0, #0
    subeq r0, #1
    movne r0, #1
    addeq r4, r4, #1 
    str r0, [fp, #-8] @сохраняем  "знак" числа
    mov r8, r4 @r8 - указатель на конец строки 

@ идём до конца строки, заодно проверяем символы
@ на корректность
go_to_end_string:
    ldrb r0, [r8]
    cmp r0, #0 @ '\0'
    beq my_atoi_main_loop
    bl isdigit
    cmp r0, #0
    beq my_atoi_wrong_char
    add r8, r8, #1
    b go_to_end_string

@for(p=1; end >= start; --end) num+=char*p; p*=10    
my_atoi_main_loop:
    sub r8, r8, #1
    ldrb r5, [r8]
    sub r5, r5, #0x30 @ '0'
    mul r0, r5, r6
    adds r7, r0, r7
    bvs my_atoi_overflow_error
    mul r0, r6, r9
    mov r6, r0

    cmp r8, r4
    bne my_atoi_main_loop

    ldr r0, [fp, #-8]
    mul r1, r0, r7
    mov r0, #0
    b my_atoi_exit

my_atoi_overflow_error:
    ldr r0, ptr_format_overflow_error
    bl printf
    mov r0, #1
    b my_atoi_exit

my_atoi_wrong_char:
    ldr r0, ptr_format_wrong_char
    bl printf
    mov r0, #2

my_atoi_exit:
    pop {r2, r3, r4, r5, r6, r7, r8, r9}
    add sp, sp, #8
    pop {fp, lr}
    bx lr

div:
    push {fp, lr}
	add fp, sp, #4
    sub sp, sp, #4

    cmp r1, #0
    beq div_divizion_by_zero
    movgt r10, #1
    movlt r10, #0
    sublt r10, r10, #1
    mullt r3, r1, r10
    movlt r1, r3

    cmp r0, #0
    movgt r9, #1
    movlt r9, #0
    sublt r9, r9, #1
    mullt r3, r0, r9
    movlt r0, r3

    mul r3, r9, r10
    push {r3}

    cmp r0, r1

    movlt r0, #0
    movlt r1, #0
    blt div_exit

    moveq r0, #0
    moveq r1, #1
    beq div_exit

    @ r0 - 1 операнд, r1 - делитель, умноженный на r4*r6, r2 - 2 операнд,
    @ r3 - частное, r5 - 10 в какой-то степени, r4 - предыдущая итерация r5,
    @ r10 = 10, r7 - предыдущая итерация r1, r9 - tmp
    mov r2, r1
    mov r3, #0
    mov r10, #10

div_main_loop:
    cmp r0, r2
    blt div_main_loop_end
    mov r1, r2
    mov r4, #1
    mov r5, #1
    mov r6, #1

div_find_y:
    mul r9, r1, r5
    cmp r0, r9
    movle r7, r1
    ble div_find_z
    mov r1, r9
    mov r4, r5
    mul r9, r5, r10
    mov r5, r9
    b div_find_y

div_find_z:
    add r9, r1, r7
    cmp r0, r9
    ble div_found_z
    mov r1, r9
    add r6, r6, #1
    b div_find_z

div_found_z:
    mul r9, r4, r6
    add r3, r3, r9
    sub r0, r0, r1
    b div_main_loop

div_divizion_by_zero:
    mov r0, #1
    b div_exit

div_main_loop_end:
    mov r0, #0
    pop {r2}
    mul r1, r2, r3

div_exit:
    add sp, sp, #4
	pop {fp, lr}
	bx lr

main:
    push {fp, lr} @ [sp-4]=lr, [sp-8]=fp, sp-=8
	add fp, sp, #4 @ fp указывает на адрес возврата
    sub sp, sp, #20

    cmp r0, #4 @ если у нас дано 4 аргумента,
    bge from_argv @то считываем их оттуда, иначе - из стандартного ввода
from_stdin:
    mov r0, #80
    bl malloc
    bl gets
    mov r9, r0
    mov r0, #0
    sub r4, fp, #8
    str r9, [fp, #-8]
    str r0, [fp, #-12]
    str r0, [fp, #-16]

find_spaces:
    ldrb r0, [r9]
    cmp r0, #0 @ '\0'
    beq find_spaces_end
    bl isspace
    cmp r0, #0
    addeq r9, r9, #1
    beq find_spaces
find_next_nonspace:
    mov r0, #0
    strb r0, [r9]
    add r9, r9, #1
    ldrb r0, [r9]
    cmp r0, #0 @ '\0'
    beq find_spaces_end
    bl isspace
    cmp r0, #0
    bne find_spaces
    str r9, [r4, #-4]!
    b find_spaces

find_spaces_end:
    ldr r0, [fp, #-8]
    cmp r0, #0
    beq wrong_input_string
    str r0, [fp, #-8]

    ldr r0, [fp, #-12]
    cmp r0, #0
    beq wrong_input_string
    str r0, [fp, #-12]

    ldr r0, [fp, #-16]
    cmp r0, #0
    beq wrong_input_string
    str r0, [fp, #-16]
    b calc

from_argv:
    str r1, [fp, #-20]
    ldr r0, [r1, #4]
    str r0, [fp, #-8]

    ldr r0, [r1, #8]
    str r0, [fp, #-12]

    ldr r0, [r1, #12]
    str r0, [fp, #-16]

calc:
    ldr r0, [fp, #-12]
    bl strlen
    cmp r0, #1
    bgt wrong_operation

    ldr r0, [fp, #-8]
    bl my_atoi
    cmp r0, #0
    bne main_exit
    str r1, [fp, #-8]

    ldr r0, [fp, #-16]
    bl my_atoi
    cmp r0, #0
    bne main_exit
    str r1, [fp, #-16]

    ldr r0, [fp, #-8]
    ldr r1, [fp, #-16]
    ldr r2, [fp, #-12]
    ldrb r2, [r2]
    cmp r2, #'+'
    beq addition
    cmp r2, #'-'
    beq subtraction
    cmp r2, #'X'
    beq multiplication
    cmp r2, #'/'
    beq divizion
    b wrong_operation

addition:
    adds r1, r0, r1
    bvs overflow_error
    b print_result
subtraction:
    subs r1, r0, r1
    bvs overflow_error
    b print_result
multiplication:
    mul r2, r0, r1
    mov r1, r2
    b print_result
divizion:
    bl div
    cmp r0, #0
    bne divizion_by_zero
    b print_result
overflow_error:
    ldr r0, ptr_format_overflow_error
    b main_exit

wrong_operation:
    ldr r0, ptr_format_wrong_operation
    b main_exit

wrong_input_string:
    ldr r0, ptr_format_wrong_input_string
    b main_exit

divizion_by_zero:
    ldr r0, ptr_format_divizion_by_zero
    b main_exit

print_result:
    ldr r0, ptr_format_decimal_number
    
main_exit:
    bl printf
    add sp, sp, #20
	pop {fp, lr}
	bx lr
