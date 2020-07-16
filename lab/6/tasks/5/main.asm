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
format db "%s",13,10,0
buffer dd 1234141,12341234,234532,349689,9897132,198

.code

; Генерация массива случайных чисел
GenerateRandomBuf proc buf:dword, bufSize:dword

    invoke crt_rand, 100000
    mov ebx, [buf]
    mov [ebx], eax
    
    ret

GenerateRandomBuf endp


; Вывод массива чисел
PrintBuf proc buf:dword, bufSize:dword


    ret
    
PrintBuf endp



;Функцию сохраняет в первом буфере элементы второго,
;удовлетворяющие условию
;Возвращает количество элементов в первом буфере,
;т.е. удовлетворяющих условию.
FilterBuf proc dstBuf:dword, srcBuf:dword, srcBufSize:dword, cmpFun:dword


FilterBuf endp


BUF_SIZE = 100

main proc c argc:DWORD, argv:DWORD, envp:DWORD

    local srcBuf:DWORD
    local dstBuf:DWORD
    
    invoke crt_malloc, 4*BUF_SIZE
    mov [srcBuf], eax
    
    invoke crt_malloc, 4*BUF_SIZE
    mov [dstBuf], eax
    
    invoke GenerateRandomBuf, [srcBuf], BUF_SIZE
    invoke PrintBuf, [srcBuf], BUF_SIZE
    invoke FilterBuf, [dstBuf], [srcBuf], BUF_SIZE
    invoke PrintBuf, [dstBuf], BUF_SIZE
	
	mov eax, 0
	ret

main endp


end
