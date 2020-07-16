;
; Модуль main.asm.
;
; Пример порождения процесса с помощью Win API
;
; Маткин Илья Александрович 09.10.2013
;

.686
.model flat, stdcall
option casemap:none


include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\windows.inc
include c:\masm32\include\msvcrt.inc


include Strings.mac


.data

.data?

.const

.code


main proc c argc:DWORD, argv:DWORD, envp:DWORD

	local startupInfo:STARTUPINFO
	local procInfo:PROCESS_INFORMATION
	local progName:dword

	mov eax, [argv]
	add eax,4
	mov eax, [eax]
	mov [progName], eax
	
	invoke crt_memset, addr [startupInfo], 0, sizeof(STARTUPINFO)
	
	.if [argc] >= 2
		invoke CreateProcess, NULL, [progName], NULL, NULL, TRUE, NORMAL_PRIORITY_CLASS, NULL, NULL, addr startupInfo, addr [procInfo]
	.endif
	
	invoke crt_getchar
	
	invoke TerminateProcess, [procInfo].hProcess, 0
	
	invoke OpenProcess, PROCESS_TERMINATE, FALSE, 896
	invoke TerminateProcess, eax, 0
	
	mov eax, 0
	ret

main endp

end
