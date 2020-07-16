;
; Модуль main.asm.
;
; Пример реализации функций встроенными средствами.
;
; Маткин Илья Александрович 25.09.2013
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc

include Strings.mac

s struct
    field1 dd ?
    field2 dd ?
s ends

.data
adr dd 0

.data?
array db 256 dup(?)

.const
format db "%s",13,10,0


.code

fun1:
    push ebp
    mov ebp,esp
    sub esp,16
    
    mov esp,ebp
    pop ebp
    ret

fun proc c uses esi edi ebx, arg1:DWORD, arg2:DWORD

    local i :DWORD
    local a[10] :DWORD
    local b :s
    
    ;mov eax, format ; mov eax, [format]
    mov eax, dword ptr [format]
    mov eax, offset format
    
    push ebp
    mov ebp,esp
    sub esp,16
    
    mov [b.field1], 0
    mov [i], 0
    mov dword ptr [eax], 0

    mov a[0], 0
    mov a[ebx*4], 1
    mov a[2*4], 1
    mov a[4], 2
	mov [i], 0
	
	mov eax, 0
    ret

fun endp


;db 1024 dup(0)


main proc c argc:DWORD, argv:DWORD, envp:DWORD


	mov eax, 0FFFFFFFFh
	mul ebx

    je fun

    mov [adr], offset fun
    call dword ptr [adr]

    ;call [eax]
    ;jmp [eax]

    mov eax, offset fun
    jmp eax
    call eax

    jmp fun
    
    call fun

	invoke fun, [argv], [envp]
	
	;push [envp]
	;push [argv]
	;call fun
	;add esp,8
	
	mov eax, 0
	ret

main endp

end
