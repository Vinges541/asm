;
; Модуль main.asm.
;
; Пример использования ассемблера jwasm и набора заголовочный файлов WinInc.
;
; Маткин Илья Александрович 26.11.2013
;

option casemap:none


include windows.inc
include winuser.inc
include stdio.inc

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

    local var:qword
    and rsp, 0FFFFFFFFFFFFFFF0h
    sub rsp, 40h

	invoke MessageBox, 0, addr text, addr caption, 0
	invoke MessageBox, 0, CStr ("Hello, World!"), CStr ("Info"), 0
	invoke printf, CStrn ("Hello, World!")
	
	xor rax, rax
	ret

main endp


end
