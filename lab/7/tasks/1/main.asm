;
; Модуль main.asm.
;
; Шаблон для задания.
;
; Маткин Илья Александрович 24.10.2017
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc

include Strings.mac

string struct
	str_length	dd ?
	str_ptr		dd ?
string ends

.data


.data?

.const

.code


str_len proc pstr:ptr string
	mov eax,[pstr]
	mov eax,[eax].string.str_length
	ret
str_len endp


;
; Принимает указатель на структуру и размер выделяемой памяти.
;
str_init proc pstr:ptr string, count:dword
str_init endp



;
; Принимает указатель на структуру и указатель на строку, завершающуюся нулем.
; Указатель внутри структуры должен указывать на копию переданной строки.
;
str_init_by_str proc pstr:ptr string, pchar:ptr byte
str_init_by_str endp



;
; Освобождает динамически выделенную память.
;
str_free proc pstr:ptr string
str_free endp



str_cat proc pdst:ptr string, psrc:ptr string
str_cat endp




main proc c uses ebx argc:DWORD, argv:DWORD, envp:DWORD
	
	local str1:string
	local str2:string
	local str3:string
	
	mov ebx, [argv]
	
	add ebx, 4
	invoke str_init_by_str, addr str1, dword ptr [ebx]
	
	add ebx, 4
	invoke str_init_by_str, addr str2, dword ptr [ebx]
	
	
	mov eax, 0
	ret

main endp

end


