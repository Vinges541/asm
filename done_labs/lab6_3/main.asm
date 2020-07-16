;
; Модуль main.asm.
;
; Шаблон задания для инвертирования списка чисел.
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


; Инвертирование массива чисел
InvertBuf proc buf:dword, bufSize:dword

	local middle:DWORD
	local sizeofint:DWORD
	mov eax, bufSize
	mov [middle], 2
	xor edx, edx
	div [middle]
	mov [middle], eax
	mov ecx, 0
	mov edi, buf
	mov esi, buf
	mov eax, bufSize
	mov [sizeofint], 4
	xor edx, edx
	mul [sizeofint]
	add esi, eax
	sub esi, 4
	.while ecx < [middle]
		mov eax, [edi]
		mov edx, [esi]
		mov [edi], edx
		mov [esi], eax
		add edi, 4
		sub esi, 4
		inc ecx
	.endw
    ret

InvertBuf endp


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


main proc c argc:DWORD, argv:DWORD, envp:DWORD

    local buf:DWORD
    
    invoke crt_malloc, 4*100
    mov buf, eax            ; buf = malloc (1000)
    ;mov byte ptr [buf][0], 0   ; buf[0] = 0
    invoke GenerateRandomBuf, buf, 100
    invoke PrintBuf, buf, 100
    invoke InvertBuf, buf, 100
    invoke PrintBuf, buf, 100
	invoke crt_free, buf
	mov eax, 0
	ret

main endp


end
