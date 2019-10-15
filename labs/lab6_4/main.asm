;
; Модуль main.asm.
;
; Шаблон задания для сложения элементов массивов.
;
; Маткин Илья Александрович 03.10.2014
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
endl db 13, 10, 0
format db "%d ", 0

.code

; Генерация массива случайных чисел
GenerateRandomBuf proc uses edi edx eax ecx buf:dword, bufSize:dword
	
	local diapason:DWORD
	invoke crt_time, 0
	invoke crt_srand, eax
	mov diapason, 100
    mov edi, buf
	mov ecx, 0
	.while ecx < dword ptr [bufSize]
		push ecx
		invoke crt_rand
		pop ecx
		;xor edx, edx
		div diapason
		mov [edi], edx
		add edi, 4
		inc ecx
	.endw
    ret

GenerateRandomBuf endp


; Вывод массива чисел
PrintBuf proc buf:dword, bufSize:dword

    mov edi, buf
	mov ecx, 0
	.while ecx < dword ptr [bufSize]
		push ecx
		invoke crt_printf, addr format, dword ptr [edi]
		pop ecx
		add edi, 4
		inc ecx
	.endw
	invoke crt_printf, addr endl
    ret
    
PrintBuf endp



; Функция сложения элементов массива.
AddBuf proc resBuf:dword, op1Buf:dword, op2Buf:dword, bufSize:dword

    local arr1:dword
	local arr2:dword
	mov edx, resBuf
	mov edi, op1Buf
	mov esi, op2Buf
	mov ecx, 0
	.while ecx < dword ptr [bufSize]
		mov eax, [edi]
		mov ebx, [esi]
		add eax, ebx
		mov [edx], eax
		add edx, 4
		add edi, 4
		add esi, 4
		inc ecx
	.endw
    ret

AddBuf endp


BUF_SIZE = 100

main proc c argc:DWORD, argv:DWORD, envp:DWORD

    local resBuf:DWORD
    local op1Buf:DWORD
    local op2Buf:DWORD
    
    invoke crt_malloc, 4*BUF_SIZE
    mov [resBuf], eax
    
    invoke crt_malloc, 4*BUF_SIZE
    mov [op1Buf], eax
    
    invoke crt_malloc, 4*BUF_SIZE
    mov [op2Buf], eax

    
    invoke GenerateRandomBuf, op1Buf, BUF_SIZE
    invoke GenerateRandomBuf, op2Buf, BUF_SIZE
    invoke PrintBuf, op1Buf, BUF_SIZE
    invoke PrintBuf, op2Buf, BUF_SIZE
    invoke AddBuf, resBuf, op1Buf, op2Buf, BUF_SIZE
    invoke PrintBuf, resBuf, BUF_SIZE
	
	mov eax, 0
	ret

main endp


end
