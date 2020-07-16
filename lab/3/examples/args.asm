.686
.model flat,c

printf proto c :dword,:dword,:dword

.data?

.data
msg1 db "Hello",0
msg2 db "test",0
format db "%s",13,10,0

.code
main proc

    push ebp
    mov ebp, esp
    sub esp, 10h
    
    ; char **p = argv
    mov eax, [ebp+12]
    mov dword ptr [ebp-4], eax
    
    jmp end_loop;
    
start_loop:
    
    ;mov eax, dword ptr[ebp-4]
    push dword ptr [eax]
	push offset format
	call printf
	add esp,8
    ;printf (const char *format, ...);
    
    ; p++
    add dword ptr[ebp-4], 4
end_loop:
    ; while (*p)
    mov eax, dword ptr[ebp-4]
    
    cmp dword ptr [eax], 0
    jne start_loop
    
    
    mov esp, ebp
    pop ebp
	ret

main endp

end
