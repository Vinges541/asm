mov r0, 0x11223344
push r0
pop r10
push byte r0
pop r11
mov [0x00000000], 0x11111111
push [0x00000000]
pop r12
call 0x00005063
push 0x22222222
pop r13
mov r1, 0xaaaaaaaa
mov r1, byte r0
mov r1, 0xaaaaaaaa
mov byte r1, byte r0
mov r1, 1
mov r2, 2
brk
mov r3, 0x0A414141
mov r4, r3
out r3
out byte r3
mov byte r3, 0x0a
out byte r3
add r4, 0x00020202
mov r5, r4
out r5

add byte r10, 0x10

in byte r10
out byte r10
add byte r10, 1
out byte r10
add byte r10, 0x20
out byte r10
hlt