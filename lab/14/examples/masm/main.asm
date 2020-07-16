;
; Модуль main.asm.
;
; Пример использования ассемблера masm x64,
; заголовочных файлов WinInc и макросов из masm64.
;
; Маткин Илья Александрович 26.11.2013
;

option casemap:none
option dotname

WIN32_LEAN_AND_MEAN equ 1
_WIN64	equ 1
_M_IA64 equ 1
;ANYARGS	TYPEDEF PROTO :VARARG
;PANYARGS TYPEDEF PTR ANYARGS

include windows.inc
include stdio.inc

include temphls.inc


include Strings.mac

CStr macro y:req
local sym
	.const
sym db y,0
	.code
	exitm <offset sym>
endm

CStrn macro y:req
local sym
	.const
sym db y, 13, 10, 0
	.code
	exitm <offset sym>
endm

.data


.data?

.const
text db "Hello, World!",0
caption db "Info",0

.code


main proc

    local var:dq
    
    sub rsp, 30h

	and rsp, 0FFFFFFF0h

	invoke MessageBox, 0, addr text, addr caption, 0
	invoke MessageBox, 0, CStr ("Hello, World!"), CStr ("Info"), 0
	
	sub rsp, 20h
	mov r9d, 0
	mov r8, CStr ("Hello")
	mov rdx, CStr ("World")
	xor rcx, rcx
	call MessageBoxA
	add rsp, 20h
		
	invoke printf, CStrn ("Hello, World!")
	
	invoke MessageBox, 0, CStr ("Hello, World!"), CStr ("Info"), 0
	
	xor rax, rax
	ret

main endp


end
