;
; Модуль main.asm.
;
; Пример реализации ветвления стандартными средствами.
;
; Маткин Илья Александрович 25.09.2013
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc


.data


.data?

.const
format db "%s",13,10,0
s1 db "11111111111",0
s2 db "22222222222",0
s3 db "33333333333",0
offsets dd offset s1, offset s2, offset s3, offset s2, offset s1, 0

.code


print_str proc c n:DWORD


	.if [n] == 1
	    invoke crt_printf, offset format, offset s1
	.elseif [n] == 2
	    invoke crt_printf, offset format, offset s2
	.elseif [n] == 3
	    invoke crt_printf, offset format, offset s3
	.else
	    invoke crt_printf, offset format, offset s3
	    invoke crt_printf, offset format, offset s2
	    invoke crt_printf, offset format, offset s1
	.endif

    ret
    
print_str endp


main proc c argc:DWORD, argv:DWORD, envp:DWORD

	invoke print_str, 1
	invoke print_str, 2
	invoke print_str, 3
	invoke print_str, 12341234
	
	mov eax, 0
	ret

main endp


end
