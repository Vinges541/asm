;
; Модуль main.asm.
;
; Пример использования сопроцессора.
;
; Маткин Илья Александрович 13.11.2013
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc

include Strings.mac

.data

f1 dd 11.25
f2 dd 0.1125e2
f3 dq 1.5
f4 dt 2.33

d1 dw 1
d2 dd 2
d3 dq 3

.data?

.const

.code


main proc c argc:DWORD, argv:DWORD, envp:DWORD

    
    finit 
    fldz
    ftst
    fstsw ax
    sahf
    je @f
    mov eax, 0 
    jmp m1
@@:
    mov eax, 1
m1:
    
    finit
    fild d1
    ficomp d2
    fstsw ax
    sahf
    je @f
    mov eax, 0 
    jmp m2
@@:
    mov eax, 1
m2:

    finit
    fild d1
    fild d1
    fcompp
    fstsw ax
    sahf
    je @f
    mov eax, 0 
    jmp m3
@@:
    mov eax, 1
m3:    
	
	mov eax, 0
	ret

main endp


end
