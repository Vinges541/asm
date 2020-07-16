;
; Модуль main.asm.
;
; 
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
text db "Hello, World!",0
caption db "Info",0

.code

;TestFun:
	;push ebp
	;mov ebp, esp
	;sub esp, 4
	;
	;mov [ebp - 4], 0
	;
	;mov esp, ebp
	;pop ebp
	;ret


TestFun proc c a:dword

	mov [a], 0

	ret
TestFun endp


main proc c argc:DWORD, argv:DWORD, envp:DWORD

	mov eax, [argv]	; mov eax, [ebp + 12]
	mov eax, [eax + 4]
	invoke MessageBox, 0, eax, addr caption, 0

	invoke TestFun, 0
	
	mov eax, 0
	ret

main endp


end
