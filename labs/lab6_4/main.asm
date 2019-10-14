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



; Функция сложения элементов массива.
AddBuf proc resBuf:dword, op1Buf:dword, op2Buf:dword, bufSize:dword

    local tmp:dword
    
    mov eax, [op1Buf]
    mov eax, [eax]
    mov [tmp], eax
    mov eax, [op2Buf]
    mov eax, [eax]
    add [tmp], eax
    
    mov eax, resBuf
    mov ebx, [tmp]
    mov [eax], ebx

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

    
    invoke GenerateRandomBuf, [op1Buf], BUF_SIZE
    invoke GenerateRandomBuf, [op2Buf], BUF_SIZE
    invoke PrintBuf, [op1Buf], BUF_SIZE
    invoke PrintBuf, [op2Buf], BUF_SIZE
    invoke AddBuf, [resBuf], [op1Buf], [op2Buf], BUF_SIZE
    invoke PrintBuf, [resBuf], BUF_SIZE
	
	mov eax, 0
	ret

main endp


end
