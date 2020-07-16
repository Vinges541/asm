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
f2 dq 1.5
f3 dt 2.33

d1 dw 1
d2 dd 2
d3 dq 3

.data?

.const

.code


main proc c argc:DWORD, argv:DWORD, envp:DWORD

    mov eax, f1
    
    finit
    
    fldz
    fld1
    fldpi
    fldl2t
    fldl2e
    fldlg2
    fldln2
    fld1
    fldpi
    
    fldpi
    fldpi
    fldpi
    
    finit
    
    fld f1
    fld f2
    fld f3
    
    fild d1
    fild d2
    fild d3
    
    fst f1
    fst f2
    ;fst f3
    
    fstp f3
    fstp f2
    fstp f1
    
    fistp d3
    fistp d2
    fistp d1
	
	mov eax, 0
	ret

main endp


end
