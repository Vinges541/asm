;
; Модуль main.asm.
;
; Шаблон задания для поиска элементов массива, удовлетворяющих условию.
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

mycmp proc C value:DWORD
	
	.if value < 10
		mov eax, 1
	.else
		mov eax, 0
	.endif
	ret
mycmp endp

;Функцию сохраняет в первом буфере элементы второго,
;удовлетворяющие условию
;Возвращает количество элементов в первом буфере,
;т.е. удовлетворяющих условию.
FilterBuf proc C dstBuf:dword, srcBuf:dword, srcBufSize:dword, cmpFun:dword

	local dstBufSize:dword
	mov [dstBufSize], 0
	mov ecx, 0
	mov edi, dstBuf
	mov esi, srcBuf
	.while ecx < srcBufSize
		push [esi]
		call dword ptr [cmpFun]
		.if eax != 0 
			mov eax, [esi]
			mov [edi], eax
			add edi, 4
			inc [dstBufSize]
		.endif
		add esi, 4
		inc ecx
	.endw
	mov eax, [dstBufSize]
	ret
FilterBuf endp


BUF_SIZE = 100

main proc c argc:DWORD, argv:DWORD, envp:DWORD

    local srcBuf:DWORD
    local dstBuf:DWORD
    
    invoke crt_malloc, 4*BUF_SIZE
    mov [srcBuf], eax
    
    invoke crt_malloc, 4*BUF_SIZE
    mov [dstBuf], eax
    
    invoke GenerateRandomBuf, srcBuf, BUF_SIZE
    invoke PrintBuf, srcBuf, BUF_SIZE
    invoke FilterBuf, dstBuf, srcBuf, BUF_SIZE, mycmp
    invoke PrintBuf, dstBuf, eax
	
	mov eax, 0
	ret

main endp


end
