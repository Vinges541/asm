;
; ������ main.asm.
;
; ������ ������ ����� � ������� Win API
;
; ������ ���� ������������� 09.10.2013
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\kernel32.inc
include c:\masm32\include\windows.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\msvcrt.inc

include Strings.mac

.data
format db "%s",13,10,0
msg db "Hello",0

.data? 

.const


.code


ReadFileToStdout proc stdcall fileName:DWORD

	local fileHandle:dword
	local fileSize:dword
	local fileMem:dword
	local stdout:dword
	local readBytes:dword

    ; �������� ����� ��� ������
    invoke CreateFile, [fileName], GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0

    ; ������� ���������� ���������� ��������� �����
    mov [fileHandle], eax
    .if [fileHandle] == INVALID_HANDLE_VALUE
        invoke crt_puts, $CTA0 ("Error open file\n")
        xor eax, eax
        ret
    .endif

	; ��������� ������� �����
    invoke GetFileSize, [fileHandle], 0
    mov [fileSize], eax

	; ��������� ������
    ;invoke crt_malloc, [fileSize]
    ;invoke HeapAlloc,  GetProcessHeap(), 0, [fileSize]
    invoke VirtualAlloc, 0, [fileSize], MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE
    mov [fileMem], eax
    .if [fileMem] == 0
		invoke crt_puts, $CTA0 ("Error alloc memory\n")
		invoke CloseHandle, [fileHandle]
		xor eax, eax
		ret
    .endif

    ; ������ �����
    invoke ReadFile, [fileHandle], [fileMem], [fileSize], addr [readBytes], NULL

	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov [stdout], eax
	
	; ��������� ����������� ������������ ������
	.if [stdout] == INVALID_HANDLE_VALUE
		invoke crt_free, [fileMem]
        invoke CloseHandle, [fileHandle]
        invoke crt_puts, $CTA0 ("Error get stdout\n")
        xor eax, eax
        ret
	.endif
    
	; ������ �� ����������� �����
	invoke WriteFile, [stdout], [fileMem], [readBytes], NULL, NULL

	; ������������ ��������
    ;invoke crt_free, [fileMem]
    invoke VirtualFree, [fileMem], [fileSize], MEM_DECOMMIT or MEM_RELEASE
    invoke CloseHandle, [fileHandle]

    mov eax, [fileSize]
    ret    

ReadFileToStdout endp


ReadFileToStdout2 proc stdcall fileName:DWORD

	local fileHandle:dword
	local fileSize:dword
	local mapHandle:dword
	local fileMem:dword
	local stdout:dword
    
    ; �������� ����� ��� ������
    invoke CreateFile, [fileName], GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0
    
    ; ������� ���������� ���������� ��������� �����
    mov [fileHandle], eax
    .if [fileHandle] == INVALID_HANDLE_VALUE
        invoke crt_puts, $CTA0 ("Error open file\n")
        xor eax, eax
        ret
    .endif
    
    ; ��������� ������� �����
    invoke GetFileSize, [fileHandle], 0
    mov [fileSize], eax

	; �������� �������� ����� � ������ � ������� ��� ������
    invoke CreateFileMapping, [fileHandle], 0, PAGE_READONLY, 0, [fileSize], 0
    
    ; ������� ���������� ���������� ��������
    mov [mapHandle], eax
    .if [mapHandle] == 0
        invoke CloseHandle, [fileHandle]
        invoke crt_puts, $CTA0 ("Error create file mapping\n")
        xor eax, eax
        ret
    .endif
    
    ; ���������� ���� � ������ � ������� ��� ������
    invoke MapViewOfFile, [mapHandle], FILE_MAP_READ, 0, 0, 0
    
    ; �������� ��������� �� ���������� ������
    mov [fileMem], eax
    .if [fileMem] == 0
		;invoke UnmapViewOfFile, [fileMem]
        invoke CloseHandle, [mapHandle]
        invoke CloseHandle, [fileHandle]
        invoke crt_puts, $CTA0 ("Error mapping file\n")
        xor eax, eax
        ret
    .endif

	; ��������� ����������� ������������ ������
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov [stdout], eax
	
	.if [stdout] == INVALID_HANDLE_VALUE
		invoke CloseHandle, [mapHandle]
        invoke CloseHandle, [fileHandle]
        invoke crt_puts, $CTA0 ("Error get stdout\n")
        xor eax, eax
        ret
	.endif
	
	; ������ �� ����������� �����
	invoke WriteFile, [stdout], [fileMem], [fileSize], NULL, NULL

	; ������������ ��������
    invoke UnmapViewOfFile, [fileMem]
    invoke CloseHandle, [mapHandle]
    invoke CloseHandle, [fileHandle]

    mov eax, [fileSize]
    ret    

ReadFileToStdout2 endp



main proc c argc:DWORD, argv:DWORD, envp:DWORD

	mov eax, [argv]
	add eax,4
	
	.if [argc] >= 2
		invoke ReadFileToStdout, [eax]
	.endif
	
	mov eax, [argv]
	add eax,8
	.if [argc] >= 3
		invoke ReadFileToStdout2, [eax]
	.endif
	
	invoke crt_printf, addr format, addr msg
	
	mov eax, 0
	ret

main endp

end
