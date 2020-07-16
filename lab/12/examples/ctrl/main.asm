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
	fstcw word ptr [d1]
	or [d1], 0300h
	fldcw word ptr [d1]
	fldz
	fld1
	fldz
	fstp st(1)
	fstp f1
	
	fldpi
	fst f3
	fst f2
	
	invoke crt_printf, $CTA0("f2: %f\n"), f2
	invoke crt_printf, $CTA0("f3: %f\n"), f3
	
	fstcw word ptr [d1]
	or [d1], 0800h
	fldcw word ptr [d1]
	frndint
	
	mov eax, 0
	ret

main endp


end
