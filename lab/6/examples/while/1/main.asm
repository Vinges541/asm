;
; Модуль main.asm.
;
; Пример самостоятельной реализации цикла while.
;
; Маткин Илья Александрович 25.09.2013
;

.686
.model flat, stdcall
option casemap:none

include \masm32\include\msvcrt.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

include Strings.mac

.data


.data?

.const
format db "%s",13,10,0

.code


print_array proc c arg:DWORD

    local arrayPointer:DWORD
    local i:DWORD

	mov [i], 0

    jmp while_cmp
    
while_body:
    mov ecx, [i]
    mov ebx, [arg]
    invoke crt_printf, addr format, dword ptr[ecx + ebx]

    add [i], 4
    
while_cmp:
    mov ecx, [i]
    mov ebx, [arg]
    cmp dword ptr [ebx + ecx], 0
    jne while_body

    ret
    
print_array endp


main proc c argc:DWORD, argv:DWORD, envp:DWORD

	invoke print_array, [argv]
	invoke print_array, [envp]
	
	mov eax, 0
	ret

main endp

end
