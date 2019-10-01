.686
.model flat,c

.data?

.data

.code
Replace proc C _str:dword, _c1:byte, _c2:byte
mov al, _c2
mov ah, _c1
mov edx, _str 
start_cycle:
cmp byte ptr [edx], 0h
je end_cycle
cmp byte ptr [edx], ah
jne next_char
mov byte ptr [edx], al
next_char:
inc edx
jmp start_cycle
end_cycle:
ret
Replace endp

end