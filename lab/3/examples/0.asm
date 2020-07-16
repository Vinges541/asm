.686
.model flat, c

.data
format_str db "%d", 0Dh, 0Ah, 0

; сегмент кода
.code

printf proto c :dword, :vararg

AddFun:
    push ebp
    mov ebp, esp
    sub esp, 8

    mov eax, [ebp + 8]
    add eax, [ebp + 12]
    
    mov esp, ebp
    pop ebp
    ret
    ;retn 8
    

main proc

    push 1
    push 2
    call AddFun
    add esp, 8
    
    invoke printf, offset format_str, eax

    nop
    ret
main endp

end
