.686
.model flat, c

.data
format_str db "%d", 0Dh, 0Ah, 0
format_sym db "%c", 0
TestStr db "Test string", 0Dh, 0Ah, 0

; сегмент кода
.code

printf proto c :dword, :vararg

; print_str (char *str)
print_str:
    push ebp
    mov ebp, esp
    sub esp, 4

    mov eax, [ebp + 8]
    mov [ebp - 4], eax

start_loop:
    cmp byte ptr [eax], 0
    je end_loop
    
    ;mov eax, dword ptr [ebp - 4]
    
    invoke printf, offset format_sym, dword ptr [eax]

    inc dword ptr [ebp - 4]
    mov eax, [ebp - 4]
    jmp start_loop
        
end_loop:
    
    mov esp, ebp
    pop ebp
    ret
    

main proc
    
    push offset TestStr
    call print_str
    add esp, 4
    
    ;invoke printf, offset TestStr

    nop
    ret
main endp

end
