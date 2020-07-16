.global main

.data
res: .word 0
op1: .word 0x11111111
op2: .word 0x22222222

.bss

.text

.align 4



main:

    ldr r0, p_op1   @ ldr r0, [PC, #0]
    ldr r0, [r0]
    ldr r1, p_op2
    ldr r1, [r1]
    add r0, r0, r1
    ldr r1, p_res
    str r0, [r1]

    p_op1: .word op1
    p_op2: .word op2
    p_res: .word res

