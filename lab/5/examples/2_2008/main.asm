;
; Модуль main.asm.
;
; Пример обращения к аргументам функции main.
;
; Маткин Илья Александрович 18.09.2013
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc

include Strings.mac

.data


.data?

.const
format db "%s",13,10,0

.code

print_array proc c arg:DWORD

    local i:DWORD
    local buf[10]:DWORD

	mov [i], 0
	mov [buf], 0
	mov buf[4], 1
	;buf[1] = 1;
	


    ;jmp while_cmp
    ;
;while_body:
    ;mov ecx, [i]
    ;mov ebx, [arg]
    ;invoke crt_printf, addr format, dword ptr[ecx + ebx]
;
    ;add [i], 4
    ;
;while_cmp:
    ;mov ecx, [i]
    ;mov ebx, [arg]
    ;cmp dword ptr [ebx + ecx], 0
    ;jne while_body
	
@@:
    mov ecx, [i]
    mov ebx, [arg]
    cmp dword ptr [ebx + ecx], 0
    je @f
    
    mov ecx, [i]
    mov ebx, [arg]
    invoke crt_printf, addr format, dword ptr[ecx + ebx]

    add [i], 4
    jmp @b
@@:


    ret
    
print_array endp


main proc c argc:DWORD, argv:DWORD, envp:DWORD

	local var:dword
	
	mov byte ptr [var], 41h
	mov byte ptr [var+1], 42h
	mov byte ptr [var+2], 43h
	mov byte ptr [var+3], 0

	invoke crt_printf, addr format, addr var

	invoke print_array, [argv]
	;invoke print_array, [envp]
	
	mov eax, 0
	ret

main endp


end
