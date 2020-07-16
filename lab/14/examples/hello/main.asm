;
; Модуль main.asm.
;
; Пример вызова библиотечной функции x64.
;
; Маткин Илья Александрович 27.11.2013
;

option casemap:none

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
sym db y,13,10,0
	.code
	exitm <offset sym>
endm


extern printf:proc


.data

.data?

var qword ?

.const

.code


main proc

    local a:dq
    
    sub rsp, 30h

    mov rax, CStr("test1")
    mov [rsp+20h], rax
    mov rax, CStr("test2")
    mov [rsp+28h], rax
    
    mov rcx, CStrn("%s %s %d %s %s")
    mov rdx, CStr("Hello")
    mov r8, CStr("World!")
    mov r9, 10
    call printf
    add rsp, 30h
    
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

    ret

main endp


end
