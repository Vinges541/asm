.686
.model flat,c
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc

CopyFile_ proto C dstFileName:dword, srcFileName:dword

.code
main proc C argc:dword, argv:dword, envp:dword
	mov edx, argv
	push dword ptr [edx+4]  
	push dword ptr [edx+8] 
	call CopyFile_
	add esp,8
	mov eax, 0
	ret
main endp
end