;
; Модуль main.asm.
;
; Реализация функции strlen.
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
format db "%s - %d", 13, 10, 0

.code


my_strlen proc c

	push ebp
	mov ebp, esp
	sub esp, 4

	mov dword ptr [ebp - 4], 0

@@:
	mov eax, [ebp + 8]
	add eax, [ebp - 4]
	cmp byte ptr [eax], 0
	jz @f
	inc dword ptr [ebp - 4]
	jmp @b

@@:

	mov eax, [ebp - 4]

	mov esp, ebp
	pop ebp
	ret

my_strlen endp


main proc c

	push ebp
	mov ebp, esp

	mov eax, [ebp + 12]
	push dword ptr [eax + 4]
	call my_strlen
	add esp, 4

	mov ecx, [ebp + 12]
	invoke crt_printf, addr format, dword ptr [ecx + 4], eax

	mov esp, ebp
	pop ebp
	ret

main endp


end
