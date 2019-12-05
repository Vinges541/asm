.686
.model flat, C
option casemap:none

;----------------------------------------
include c:\masm32\include\msvcrt.inc

include Strings.mac
include bigint.inc

.data

.data?

.const

.code

;Вывод большого числа
bignum_printf proc uses esi edx bn:ptr bignum

	mov esi,[bn]
	assume esi:ptr bignum
	
	.if [esi].sign != 0
		invoke crt_printf, $CTA0("%c"), 45
	.endif

	.if [esi].container != 0

		mov eax, [esi].digits
		dec eax
		mov ebx, sizeof(dword)
		mul ebx
		mov ecx, eax

		mov edx, [esi].container
		mov ecx, edx
		add ecx, eax
		
		pushad
		invoke crt_printf, $CTA0("%X"), dword ptr [ecx]
		popad
		sub ecx, sizeof(dword);sizeof ptr digit

		.while	ecx >= edx

			pushad
			invoke crt_printf, $CTA0("%08X"), dword ptr [ecx]
			popad
			sub ecx, sizeof(dword)

		.endw
	.endif
	xor eax, eax
	ret
bignum_printf endp

; Нуль-терминированная строка -> long
my_strtoul proc uses esi start_str:ptr byte, end_str:ptr byte

	local num:dword
	local base:dword
	local radix:dword

	mov num, 0
	mov base, 1
	mov radix, 16
	
	mov esi, end_str

	.while  esi >= start_str
		xor eax, eax
		mov  al, byte ptr [esi]
		
		.if eax >= '0' && eax <= '9'
			sub eax, '0' 	
		.elseif eax >= 'A' && eax <= 'F'
			sub eax, 55 ;eax-='A'+10
		.endif
		mul base
		add num, eax

		mov eax, base
		mul radix
		mov base, eax
		sub esi, sizeof(byte)
	.endw

	mov eax, num
	ret

my_strtoul endp

;Инициализация нулём
bignum_init_null proc uses edi bn:dword
	
	invoke crt_malloc, sizeof(bignum)
	.if eax == NULL
		mov eax, 1
		ret
	.endif
	mov edi, bn
	mov dword ptr [edi], eax
	mov edi, dword ptr [edi]
	assume edi:ptr bignum

	mov [edi].digits, 1
	mov [edi].sign, NONNEG

	invoke crt_malloc, sizeof(dword)
	.if eax == NULL
		mov eax, 1
		ret
	.endif
	mov [edi].container, eax

	mov edx, [edi].container
	mov dword ptr [edx], 0


	xor eax, eax
	ret
bignum_init_null endp

;Устранение "минус нуля"
bignum_zeronull_fix proc uses edi edx bn:ptr bignum

	mov edi,[bn]
	assume edi:ptr bignum
	.if [edi].digits == 1 && [edi].sign == NEGATIVE && dword ptr [[edi].container] == 0
		mov [edi].sign, NONNEG
	.endif
	ret

bignum_zeronull_fix endp

;Инициализация большого числа строкой шестнадцатиричных символов
bignum_set_str proc uses ebx ecx esi edi bn:ptr bignum, cstr:ptr byte
				
	local i:dword
	local len:dword
	local tmp:ptr byte
	local end_substr:ptr byte
	local start_substr:ptr byte
	
	xor eax, eax
	mov edi, [bn]
	mov esi, [cstr]
	mov al, byte ptr [esi]
	
	.if al == '-'
		mov [edi].sign, NEGATIVE ; negative
		inc esi
	.else
		mov [edi].sign, NONNEG ; positive
	.endif
	
	invoke crt_strlen, esi
	mov [len], eax
	
	.if [len] < 8
		mov [edi].digits, 1
	.else
		xor edx, edx
		mov eax, [len]
		mov ebx, 8
		div ebx		; eax = eax/ebx, edx = eax%ebx
		mov [edi].digits, eax
		.if edx != 0
			inc [edi].digits
		.endif
	.endif
		
	mov eax, [cstr]
	mov [tmp], eax
	mov al, byte ptr [eax]
	.while al
		invoke crt_isxdigit, al
		.if al == 0
			mov eax, 1
			ret
		.endif
		inc [tmp]
		mov eax, [tmp]
		mov al, byte ptr [eax]
	.endw
	dec [tmp]
	
	.if [edi].container != 0 
		invoke crt_free, [edi].container
	.endif
	mov eax, [edi].digits
	mov ebx, sizeof(dword)
	mul ebx
	invoke crt_malloc, eax
	.if eax == 0
		mov eax, 1
		ret
	.endif
	mov [edi].container, eax
	
	mov eax, [tmp]
	mov [end_substr], eax
	.if eax > [cstr] + 8
		sub eax, 8
	.else
		mov eax, [cstr]
	.endif
	mov [start_substr], eax
	
	.if eax > [end_substr]
		mov [end_substr], eax
	.endif
	
	mov [i], 0
	mov ecx, [edi].digits
	.while [i] < ecx
		
		mov eax, [i]
		mov ebx, sizeof(dword)
		mul ebx
		add eax, [edi].container
		mov ebx, eax
		invoke my_strtoul, [start_substr], [end_substr]
		mov [ebx], eax
		
		sub [end_substr], 8
		mov eax, [start_substr]
		.if eax > [cstr] + 8
			sub [start_substr], 8
		.else
			mov eax, [cstr]
			mov [start_substr], eax
		.endif
		
		.if eax > [end_substr]
			mov [end_substr], eax
		.endif		
		
		inc [i]
	.endw
	
	ret
bignum_set_str endp

;Инициализация большого числа числом типа unsigned int
bignum_set_ui proc uses edi ebx edx bn:ptr bignum, number:dword

	mov edi,[bn]
	assume edi:ptr bignum
	mov [edi].digits, 1
	mov [edi].sign, NONNEG
	.if [edi].container != NULL
		invoke crt_free, [edi].container
	.endif

	mov eax, [edi].digits
	mov ebx, sizeof(dword)
	mul ebx
	invoke crt_malloc, eax
	.if eax == NULL
		mov eax, 1
		ret
	.endif
	mov [edi].container, eax
	
	mov eax, number
	mov edx, [edi].container
	mov dword ptr [edx], eax

	xor eax, eax
	ret

bignum_set_ui endp

;Инициализация большого числа числом типа int
bignum_set_i proc uses edi ebx edx bn:ptr bignum, number:dword

	mov edi,[bn]
	assume edi:ptr bignum
	mov [edi].digits, 1

	cmp dword ptr [number], 0
	jge less_zero
	mov [edi].sign, NEGATIVE
	neg number
	jmp end_less_zero

	less_zero:
	mov [edi].sign, NONNEG
	
	end_less_zero:

	.if [edi].container != NULL
		invoke crt_free, [edi].container
	.endif

	mov eax, [edi].digits
	mov ebx, sizeof(digit)
	mul ebx
	invoke crt_malloc, eax
	.if [edi].container == NULL
		mov eax, 1
		ret
	.endif
	mov [edi].container, eax

	mov eax, number
	mov edx, [edi].container
	mov dword ptr [edx], eax
	xor eax, eax
	ret

bignum_set_i endp

;Сложение двух больших чисел; res = lhs + rhs
bignum_add proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

bignum_add endp

;Вычитание двух больших чисел; res = lhs - rhs
bignum_sub proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum
	
	xor [rhs].bignum.sign, NEGATIVE
	invoke bignum_add, res, lhs, rhs
	xor [rhs].bignum.sign, NEGATIVE
	ret

bignum_sub endp

;Побитовое ИСКЛЮЧАЮЩЕЕ ИЛИ двух больших чисел; res = lhs ^ rhs
bignum_xor proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

	mov eax, lhs
	assume eax:ptr bignum
	mov eax, [eax].digits
	assume eax:nothing

	mov ebx, rhs
	assume ebx:ptr bignum
	mov ebx, [ebx].digits
	assume ebx:nothing

	.if eax > ebx

		invoke bignum_cpy, res, lhs

	.else 

		invoke bignum_cpy, res, rhs
		mov eax, lhs
		mov rhs, eax

	.endif

	mov edi, res
	assume edi:ptr bignum

	mov esi, rhs
	assume esi:ptr bignum

	mov ecx, 0
	.while ecx < [esi].digits
		mov eax, ecx
		mov ebx, sizeof(digit)
		mul ebx
		
		mov ebx, [esi].container
		add ebx, eax
		mov edx, [edi].container
		add edx, eax
		mov ebx, dword ptr [ebx]
		xor dword ptr[edx], ebx
		inc ecx
	.endw

	mov eax,  [esi].sign
	xor [edi].sign, eax

	invoke bignum_shrink_to_fit, res
	invoke bignum_zeronull_fix, res

	xor eax, eax
	ret

bignum_xor endp

;Побитовое ИЛИ двух больших чисел; res = lhs | rhs
bignum_or proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

	mov eax, lhs
	assume eax:ptr bignum
	mov eax, [eax].digits
	assume eax:nothing

	mov ebx, rhs
	assume ebx:ptr bignum
	mov ebx, [ebx].digits
	assume ebx:nothing

	.if eax > ebx

		invoke bignum_cpy, res, lhs

	.else 

		invoke bignum_cpy, res, rhs
		mov eax, lhs
		mov rhs, eax

	.endif

	mov edi, res
	assume edi:ptr bignum

	mov esi, rhs
	assume esi:ptr bignum

	mov ecx, 0
	.while ecx < [esi].digits
		mov eax, ecx
		mov ebx, sizeof(digit)
		mul ebx
		
		mov ebx, [esi].container
		add ebx, eax
		mov edx, [edi].container
		add edx, eax
		mov ebx, dword ptr [ebx]
		or dword ptr[edx], ebx
		inc ecx
	.endw

	mov eax,  [esi].sign
	or [edi].sign, eax

	invoke bignum_shrink_to_fit, res
	invoke bignum_zeronull_fix, res

	xor eax, eax
	ret

bignum_or endp

;Побитовое И двух больших чисел; res = lhs & rhs
bignum_and proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

	mov eax, lhs
	assume eax:ptr bignum
	mov eax, [eax].digits
	assume eax:nothing

	mov ebx, rhs
	assume ebx:ptr bignum
	mov ebx, [ebx].digits
	assume ebx:nothing

	.if eax > ebx

		invoke bignum_cpy, res, lhs

	.else 

		invoke bignum_cpy, res, rhs
		mov eax, lhs
		mov rhs, eax

	.endif

	mov edi, res
	assume edi:ptr bignum

	mov esi, rhs
	assume esi:ptr bignum

	mov ecx, 0
	.while ecx < [esi].digits
		mov eax, ecx
		mov ebx, sizeof(digit)
		mul ebx
		
		mov ebx, [esi].container
		add ebx, eax
		mov edx, [edi].container
		add edx, eax
		mov ebx, dword ptr [ebx]
		and dword ptr[edx], ebx
		inc ecx
	.endw

	mov eax,  [esi].sign
	and [edi].sign, eax

	invoke bignum_shrink_to_fit, res
	invoke bignum_zeronull_fix, res

	xor eax, eax
	ret

bignum_and endp

;Умножение большого числа на unsigned int; res = bn * num
bignum_mul_ui proc uses edi ecx ebx res:ptr bignum, bn:ptr bignum, num:dword

	local mult_res:qword
	local carry:qword
	local total_res:qword
	local i:dword

	mov dword ptr [mult_res],0
	mov dword ptr [mult_res+4],0

	mov dword ptr [carry],0
	mov dword ptr [carry+4],0

	mov dword ptr [total_res],0
	mov dword ptr [total_res+4],0

	invoke bignum_cpy, res, bn
	mov edi, res
	assume edi:ptr bignum

	mov i, 0

	main_cycle:
	mov ecx, i
	.if ecx < [edi].digits

		mov eax, ecx
		mov ebx, sizeof(digit)
		mul ebx
		add eax, [edi].container
		push eax
		;mult_res = digits[i]*num = FFFF FFFF * FFFF FFFF = FFFF FFFE 0000 0001
		mov eax, dword ptr [eax]
		mul num
		mov dword ptr [mult_res], eax
		mov dword ptr [mult_res + 4], edx 
		
		;total_res = mult_res % base + carry = 0000 0001 + 0 = 0000 0001
		mov eax, dword ptr [mult_res]
		clc
		add eax, dword ptr [carry]
		mov dword ptr [total_res], eax
		mov eax, dword ptr [carry + 4]
		adc eax, 0
		mov dword ptr [total_res + 4], eax

		;carry = mult_res / base + total_res / base = FFFF FFFE + 0 = FFFF FFFE
		mov eax, dword ptr [mult_res + 4]
		mov ebx, dword ptr [total_res + 4]
		clc
		add eax, ebx
		mov dword ptr [carry], eax
		mov eax, 0
		adc eax, 0
		mov dword ptr [carry + 4], eax

		;digits[i] = total_res % base = 0000 0001;
		pop eax
		mov ebx, dword ptr [total_res]
		mov dword ptr [eax], ebx 
		
	.else

		inc [edi].digits
		mov eax, [edi].digits
		mov ebx, sizeof(digit)
		mul ebx
		push eax
		invoke crt_realloc, [edi].container, eax
		mov [edi].container, eax
		pop eax
		sub eax, sizeof(digit)
		add eax, [edi].container
		mov ebx, dword ptr [carry]
		mov dword ptr [eax], ebx
		mov eax, dword ptr [carry+4]
		mov dword ptr [carry], eax
		mov dword ptr [carry+4], 0

	.endif

	inc i
	mov ecx, i
	cmp dword ptr [carry], 0
	jne main_cycle
	ret

bignum_mul_ui endp

;Умножение двух больших чисел; res = lhs * rhs
bignum_mul proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

bignum_mul endp

;Деление двух больших чисел; res = lhs / rhs;
bignum_div proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

bignum_div endp

;Остаток от деления двух больших чисел; res = lhs % rhs
bignum_mod proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

bignum_mod endp

;Копирование больших чисел; dst = src
bignum_cpy proc uses edi esi ebx dst:ptr bignum, src:ptr bignum

	mov edi,[dst]
	assume edi:ptr bignum

	mov esi,[src]
	assume esi:ptr bignum

	mov eax, [esi].digits
	mov [edi].digits, eax

	.if [edi].container != NULL
		invoke crt_free, [edi].container
	.endif

	mov eax, [edi].digits

	mov ebx, sizeof(dword)
	mul ebx
	push eax
	invoke crt_malloc, eax
	.if eax == NULL
		mov eax, 1
		ret
	.endif
	mov [edi].container, eax
	
	mov eax, [esi].sign;
	mov [edi].sign, eax

	pop eax
	invoke crt_memcpy, [edi].container, [esi].container, eax
	ret

bignum_cpy endp

bignum_shrink_to_fit proc uses edi ecx bn:ptr bignum

	mov edi, [bn]
	assume edi:ptr bignum
	mov ecx, [edi].digits
	dec ecx
	.while ecx >= 0
		.if dword ptr [[edi].container+ecx*sizeof(digit)] != 0
			.break
		.endif
		dec ecx
	.endw
	.if ecx < 0
		mov ecx, 1
	.else
		inc ecx
	.endif
	.if [edi].digits == ecx
		ret
	.endif
	mov [edi].digits, ecx
	mov eax, ecx
	mov ecx, sizeof(digit)
	mul ecx
	invoke crt_realloc, [edi].container, eax
	mov [edi].container, eax
	ret

bignum_shrink_to_fit endp

bignum_free proc uses esi bn:ptr bignum
	
	mov esi,[bn]
	assume esi:ptr bignum
	.if [esi].container != NULL
		invoke crt_free, [esi].container
	.endif
	invoke crt_free, esi
	ret
bignum_free endp

;Возведение большого числа в n-ную степень; res = lhs^exp
bignum_pow proc uses ecx res:ptr bignum, lhs:ptr bignum, exp:dword

	.while dword ptr [exp] > 0

		invoke bignum_mul, res, res, lhs
		dec exp

	.endw
	ret

bignum_pow endp

end