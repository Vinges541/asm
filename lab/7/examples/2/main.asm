;
; Модуль main.asm.
;
; Пример использования строковых инструкций.
;
; Маткин Илья Александрович 02.10.2013
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc

include Strings.mac

string struct
	str1	dword	0
string ends


.data


.data?

.const
new_line db 13,10,0
format_str db "%s",13,10,0
format_number db "%d", 13, 10, 0

.code


str_len proc pstr:dword

	cld
	
	mov edi, pstr
	mov ecx, 0FFFFFFFFh
	mov al,0
	repne scasb
	mov eax, 0FFFFFFFFh - 1
	sub eax, ecx	;	(0FFFFFFFFh - 1) - (0FFFFFFFFh - (strlen + 1)) = strlen
	
	ret

str_len endp


str_cpy proc pdst:dword, psrc:dword

	invoke crt_strlen, [psrc]
	cld ; сброс флага направления строковых инструкций
	lea ecx,[eax + 1]	; сколько копировать
	mov esi, [psrc]		; откуда копировать
	mov edi, [pdst]		; куда копировать
	rep movsb

	mov eax, [pdst]
	ret

str_cpy endp


r_memset proc pstr:dword, symbol:dword, count:dword

	mov ecx, [count]
    cld
	xor eax,eax
	mov al, byte ptr [symbol]
	mov edi, [pstr]
	rep stosb

	mov eax, [pstr]
	ret

r_memset endp


main proc c argc:DWORD, argv:DWORD, envp:DWORD
	
	local buf:dword
	local buf2:dword
	
	invoke crt_printf, $CTA0("Hello, World\n")
	
	mov esi, [argv]
	
	cld
	std
	;scasb/scasw/scasd			; cmp byte/word/dword ptr es:[edi], al/ax/eax
	;movs/movsb/movsw/movsd		; mov es:[edi],ds:[esi]
	; edi +/- 1|2|4	
	; esi +/- 1|2|4
	; ecx--
	
	;lods/lodsb/lodsw/lodsd		al = byte ptr [esi]
	; repz/repnz
	;stos/stosb/stosw/stosd		byte ptr [edi] = al
	
	;[repe | repne] cmps/cmpsb/cmpsw/cmpsd		; cmp es:[edi],ds:[esi]
	; edi +/- 1|2|4	
	; esi +/- 1|2|4
	;repe cmpsb
	;jne 
	;jecxz
	
	; префиксы:
	; rep - пока ecx != 0
	; repe - пока ecx != 0 и ZF == 0
	; repne - пока ecx != 0 и ZF == 1
	; repz = repe
	; repnz = repne
	
	
	
	invoke str_len, dword ptr [esi]
	invoke crt_printf, addr format_number, eax
	
	invoke crt_strlen, dword ptr [esi]
	inc eax
	
	invoke crt_malloc, eax
	mov [buf], eax
	
	invoke str_cpy, [buf], [esi]
	
	invoke crt_printf, addr format_str, [buf]
	
	invoke crt_malloc, 100
	mov [buf2], eax
	invoke r_memset, [buf2], 0, 100

	ret

main endp

end
