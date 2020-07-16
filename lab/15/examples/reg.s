@ объявление символа main доступным извне
.global main

@ начало секции данных
.data
@ bval db 0
bval: .byte 0
@ dval dd 0x11223344
dval: .word 0x11223344

@ начало секции неинициализированных данных
.bss
.word 0

@ начало секции кода
.text

@ выравнивание секции
.align 4



main:

    eor r0, r0, r0  @r0 = 0
    eor r1, r1, r1  @r1 = 0
    add r2, r0, r1  @r2 = r0 + r1
    add r2, r0, #10
    sub r1, r2, r3
    sub r1, r2, #0x10
    and r1, r2, r3
    mov r1, r2

    @ так сделать нельзя
    @and r1, r2, #0x77777777
    @mov r1, #0xFFFFFFFF


    add r1, r2, r3, lsl #8  @ r1 = r2 + (r3 << 8)
    add r1, r2, r3, asl #8
    
    mov r1, r2
    mov r1, #0xFF

    mov r1, #0x11
    @mov r1, #0x11, lsl 8
    @add r1, r1, 0x11 ror #8
    add r1, r1, #0x2200     @ add r1, r1, 0x22 ror 24
    add r1, r1, #0x330000   @ add r1, r1, 0x33 ror 16
    add r1, r1, #0x44000000 @ add r1, r1, 0x44 ror 8
    @mov r1, #0x44332211


    mov r1, r2, lsl #1
    mov r1, r2, asl #2
    mov r1, r2, lsr #3
    mov r1, r2, asr #4

    ldr r0, [sp]
    ldrb r0, [ip]
    str r0, [sp]
    strb r0, [sp]


    @ непосредственно к памяти обратиться нельзя
    @ldr r0, dval
    @ можно обратиться через вспомогательную переменную,
    @ которая будет хранить нужный адрес, а до неё
    @ можно дотянуться через относительную адресацию
    ldr r1, pdval @ ldr r1, [ip, #0]
    @ldr r1, [PC, #4]
    @ldr r1, [r1]
    @mov r1, offset dval
    str r1, [r1]

    @ две инструкции по сути эквивалентны
    ldr r1, =0x11223344
    ldr r1, tmp

    ldr r1, [r2],#12
    ldr r1, [r2, #12]

    pdval: .word dval
    tmp: .word 0x11223344

