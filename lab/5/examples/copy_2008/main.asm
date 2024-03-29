;
; ������ main.asm.
;
; ������ �������.
;
; ������ ���� ������������� 15.09.2015
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc
includelib c:\masm32\lib\msvcrt.lib

include Strings.mac

;printf proto c :VARARG
fopen proto C path:dword, mode:dword
fclose proto C fp:dword
fread proto C array:dword, _size:dword, count:dword, stream:dword
fwrite proto C array:dword, _size:dword, count:dword, stream:dword

.data?

buffer db 4096 dup (?)

.data

.const

mode_read db "r", 0
mode_write db "w", 0
open_failed_msg db "Open failed!", 10, 13, 0
close_failed_msg db "Close failed!", 10, 13, 0

.code
copy proc dstFileName:dword, srcFileName:dword

	mov esi, srcFileName
	mov edi, dstFileName


	invoke fopen, esi, addr mode_read
	;cmp eax, 0
	;je open_failed
	mov esi, eax

	invoke fopen, edi, addr mode_write
	;cmp eax, 0
	;je open_failed
	mov edi, eax

	copy_loop:

	invoke fread, addr buffer, 1, 4096, esi
	invoke fwrite, addr buffer, 1, eax, edi

	cmp eax, 4096
	je copy_loop

	invoke fclose, esi
	;jne close_failed

	invoke fclose, edi
	;jne close_failed

	open_failed:

	;invoke printf, addr open_failed_msg
	jmp copy_end

	close_failed:

	;invoke printf, addr close_failed_msg
	jmp copy_end
	
	copy_end:
	ret

copy endp

end


main proc c argc:DWORD, argv:DWORD, envp:DWORD

	mov eax, argv
	push dword ptr [eax + 4]
	push dwrod ptr [eax + 8]
	call copy
	add esp, 8
	
	mov eax, 0
	ret

main endp


end
