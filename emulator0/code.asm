mov [0x00112233], 0x0A414141
mov r0, [0x00112233]
mov r1, 2
mov [r1], [r0]
out [r1]
mov r3, 0x0A414141
mov r4, r3
out r3
out byte r3
mov byte r3, 0x0a
out byte r3
add r4, 0x00020202
mov r5, r4
out r5
in byte r10
out byte r10
add byte r10, 1
out byte r10
add byte r10, 0x20
out byte r10
