;
; ������ main.asm.
;
; ������ ������� ��� �������������� ������ �����.
;
; ������ ���� ������������� 03.10.2014
;

.686
.model flat, stdcall
option casemap:none

include C:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc

include Strings.mac

.data


.data?

.const
format db "%s",13,10,0
buffer dd 1234141,12341234,234532,349689,9897132,198

.code

; ��������� ������� ��������� �����
GenerateRandomBuf proc buf:dword, bufSize:dword

    invoke crt_rand
    mov ebx, [buf]
    mov [ebx], eax
    
    ret

GenerateRandomBuf endp


; �������������� ������� �����
InvertBuf proc buf:dword, bufSize:dword


    ret

InvertBuf endp


; ����� ������� �����
PrintBuf proc buf:dword, bufSize:dword


    ret
    
PrintBuf endp


main proc c argc:DWORD, argv:DWORD, envp:DWORD

    local buf:DWORD
    
    invoke crt_malloc, 4*100
    mov buf, eax            ; buf = malloc (1000)
    mov byte ptr [buf][0], 0   ; buf[0] = 0
    
    invoke GenerateRandomBuf, [buf], 100
    invoke PrintBuf, [buf], 100
    invoke InvertBuf, [buf], 100
    invoke PrintBuf, [buf], 100
	
	mov eax, 0
	ret

main endp


end
