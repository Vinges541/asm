;
; Модуль main.asm.
;
; Пример использования заголовочных файлов masm64.
;
; Маткин Илья Александрович 26.11.2013
;

option casemap:none
option dotname


include temphls.inc
include win64.inc
include user32.inc
;include msvcrt.inc

extern printf:proc

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

    push rbp
    mov rbp, rsp
    sub rsp, 30h
    
    ;.while rcx
	;	nop
    ;.endw

	invoke MessageBox, 0, CStr ("Hello, World!"), CStr ("Info"), 0
	;invoke printf, CStrn ("Hello, World")
	
	mov rax, CStr("test1")
    push rax
    mov rax, CStr("test2")
    push rax
    sub rsp, 20h
    mov rcx, CStrn("%s %s %d %s %s")
    mov rdx, CStr("Hello")
    mov r8, CStr("World!")
    mov r9, 10
    call printf
    add rsp, 30h

	xor rax, rax
	mov rsp, rbp
	pop rbp
	ret

main endp




end
