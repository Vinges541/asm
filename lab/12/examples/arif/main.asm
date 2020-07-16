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

    local t1:tbyte
    local t2:qword
    
    mov eax, [d2]
    lea eax, [d2]
    db 8Dh, 05h, 0, 0, 0, 0
    ;lea eax, dword ptr [0]
    
    fadd st, st(2)
	fadd st(2), st
	faddp st(2), st
	fadd f1

	finit
	
	fld f1
    fld f2
    fld f3
    
    fild d1
    fild d2
    fild d3

	fadd st, st(2)
	fadd st(2), st
	faddp st(2), st
	fadd f1

    fsub st, st(2)      ;st(0) = st(0) - st(2)
    fsub st(2), st
    fsubr st, st(2)     ;st(0) = st(2) - st(0)
    fsubr st(2), st
    fsub f1
    fsubr f1
	
	fmul st, st(2)
	fmul st(2),st
	fmulp st(2), st
	
	fdiv st, st(2)
	fdiv st(2), st
	fdivr st, st(2)
	fdivr st(2), st
	fdivp st(2), st
	fdivrp st(2), st

	frndint
	
	mov eax, 0
	ret

main endp


end
