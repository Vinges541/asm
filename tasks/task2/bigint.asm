.686
.model flat, C
option casemap:none

;----------------------------------------
include c:\masm32\include\msvcrt.inc

include Strings.mac
include bigint.inc

DEBUG equ 0

.code

;Вывод большого числа
bignum_printf proc uses esi ebx edx ecx bn:ptr bignum

	mov esi,[bn]
	assume esi:ptr bignum
	
	.if [esi].sign != 0
		invoke crt_printf, $CTA0("%c"), 45
	.endif
	invoke crt_printf, $CTA0("0x")
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
		invoke crt_printf, $CTA0("%x"), dword ptr [ecx]
		popad
		sub ecx, sizeof(dword);sizeof ptr digit

		.while	ecx >= edx

			pushad
			invoke crt_printf, $CTA0("%08x"), dword ptr [ecx]
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
		.elseif eax >= 'a' && eax <= 'f'
			sub eax, 'a'
			add eax, 10
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
bignum_init_null proc uses edi edx bn:dword
	
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
	mov edx, [edi].container
	.if [edi].digits == 1 && [edi].sign == NEGATIVE && dword ptr [edx] == 0
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
		
	mov eax, esi
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
	push esi
	add esi, 8
	.if eax > esi
		sub eax, 8
		pop esi
	.else
		pop esi
		mov eax, esi
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
		push esi
		add esi, 8
		.if eax > esi
			pop esi
			sub [start_substr], 8
		.else
			pop esi
			mov eax, esi
			mov [start_substr], eax
		.endif
		
		.if eax > [end_substr]
			mov [end_substr], eax
		.endif		
		
		inc [i]
	.endw
	invoke bignum_zeronull_fix, bn
	xor eax, eax
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

bignum_zero_extend proc uses edi eax ebx bn:ptr bignum, add_digits:dword

	.if add_digits == 0
		ret
	.endif
	mov edi, bn
	assume edi:ptr bignum
	mov eax, add_digits
	push [edi].digits
	add [edi].digits, eax
	mov eax, [edi].digits
	shl eax, 2
	invoke crt_realloc, [edi].container, eax
	mov [edi].container, eax
	pop eax
	dec eax
	shl eax, 2
	add eax, [edi].container
	mov ebx, [edi].digits
	dec ebx
	shl ebx, 2
	add ebx, [edi].container
	.while ebx > eax
		mov dword ptr [ebx], 0
		sub ebx, sizeof(digit)
	.endw
	ret

bignum_zero_extend endp

bignum_less proc uses edi esi ecx edx lhs:ptr bignum, rhs:ptr bignum
	
	mov eax, 0
	mov edi, lhs
	mov esi, rhs
	assume edi:ptr bignum
	assume esi:ptr bignum
	mov ecx, [edi].digits
	mov edx, [esi].digits
	.if ecx < edx
		mov eax, 1
		ret
	.elseif ecx > edx
		ret
	.endif
	mov ecx, [edi].digits
	dec ecx
	mov edi, [edi].container
	mov esi, [esi].container
	push ecx
	shl ecx, 2
	add edi, ecx
	add esi, ecx
	pop ecx
	start_cycle:
	cmp ecx, 0
	jl end_cycle
	mov edx, dword ptr [esi]
	.if dword ptr [edi] < edx
		mov eax, 1
		ret
	.endif
	sub edi, sizeof(digit)
	sub esi, sizeof(digit)
	dec ecx
	jmp start_cycle
	end_cycle:
	ret
bignum_less endp

;Сложение двух больших чисел; res = lhs + rhs
bignum_add proc uses edi esi ebx ecx edx res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

	local result:ptr bignum
	local change_sign:dword
	mov eax, [lhs]
	mov eax, [eax].bignum.sign

	mov ebx, [rhs]
	mov ebx, [ebx].bignum.sign
	.if eax == ebx

	mov edi, res
	assume edi:ptr bignum
	assume esi:ptr bignum

	.if edi == lhs
		mov esi, rhs
		mov eax, [edi].digits
		sub eax, [esi].digits
		.if CARRY?
			neg eax
		.endif
		inc eax
		invoke bignum_zero_extend, edi, eax
	.elseif edi == rhs
		mov esi, lhs
		mov eax, [edi].digits
		sub eax, [esi].digits
		.if CARRY?
			neg eax
		.endif
		inc eax
		invoke bignum_zero_extend, edi, eax
	.else 
		mov eax, [lhs]
		mov eax, [eax].bignum.digits

		mov ebx, [rhs]
		mov ebx, [ebx].bignum.digits
		.if eax < ebx
			push lhs
			push rhs
			pop lhs
			pop rhs
		.endif
		mov esi, rhs
		invoke bignum_cpy, res, lhs
		invoke bignum_zero_extend, res, 1
	.endif

	mov ecx, 0
	mov edx, [esi].container
	mov eax, [edi].container
	clc
	pushf
	.while ecx < [esi].digits
		
		mov ebx, dword ptr [edx]
		popf
		adc dword ptr [eax], ebx
		pushf
		add edx, sizeof(digit)
		add eax, sizeof(digit)
		inc ecx
	.endw
	popf
	adc dword ptr [eax], 0

	invoke bignum_shrink_to_fit, res
	invoke bignum_zeronull_fix, res

.else
	
	mov change_sign, 0
	invoke bignum_init_null, addr result
	mov edi, result
	assume edi:ptr bignum

	.if eax == NEGATIVE
		invoke bignum_less, rhs, lhs
		.if eax == 1
			mov change_sign, 1
		.else
			push lhs
			push rhs
			pop lhs
			pop rhs
		.endif
	.else
		invoke bignum_less, lhs, rhs
		.if eax == 1
			mov change_sign, 1
			push lhs
			push rhs
			pop lhs
			pop rhs
		.endif
	.endif

	invoke bignum_cpy, result, lhs
	mov esi, rhs
	assume esi:ptr bignum
	mov ecx, 0
	mov edx, [esi].container
	mov eax, [edi].container
	clc
	pushf
	.while ecx < [esi].digits
		
		mov ebx, dword ptr [edx]
		popf
		sbb dword ptr [eax], ebx
		.if CARRY?
			neg dword ptr [eax]
		.endif
		pushf
		add edx, sizeof(digit)
		add eax, sizeof(digit)
		inc ecx
	.endw
	popf

	.if CARRY?
		xor [edi].sign, NEGATIVE ;change sign
	.endif

	;.if change_sign == 1
	;	xor [edi].sign, NEGATIVE
	;.endif
	invoke bignum_shrink_to_fit, result
	invoke bignum_zeronull_fix, result
	invoke bignum_move, res, result
	
.endif

	xor eax, eax
	ret
bignum_add endp

;Вычитание двух больших чисел; res = lhs - rhs
bignum_sub proc uses edi res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum
	
	mov edi, rhs
	assume edi:ptr bignum
	xor [edi].sign, NEGATIVE ;change sign
	invoke bignum_add, res, lhs, rhs
	xor [edi].sign, NEGATIVE
	ret

bignum_sub endp

;Побитовое ИСКЛЮЧАЮЩЕЕ ИЛИ двух больших чисел; res = lhs ^ rhs
bignum_xor proc uses ebx edi esi ecx edx res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

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
bignum_or proc uses ebx edi esi ecx edx res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

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
bignum_and proc uses ebx edi esi ecx edx res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

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

bignum_shl proc uses edi ecx edx bn:ptr bignum, number:dword
	mov edi, bn
	assume edi:ptr bignum
	mov eax, number
	.if number == 0
		ret
	.endif
	push [edi].digits
	add [edi].digits, eax
	mov eax, [edi].digits
	shl eax, 2 ;*sizeof(digit)
	invoke crt_realloc, [edi].container, eax
	mov [edi].container, eax
	mov ecx, eax
	mov edx, [edi].digits
	dec edx
	shl edx, 2
	add edx, [edi].container
	pop eax
	dec eax
	shl eax, 2
	add ecx, eax
	push edx
	.while edx > ecx
		mov dword ptr [edx], 0
		sub edx, sizeof(digit)
	.endw
	pop edx
	.while ecx >= [edi].container
		mov eax, dword ptr [edx]
		xchg dword ptr [ecx], eax
		mov dword ptr [edx], eax
		sub edx, sizeof(digit)
		sub ecx, sizeof(digit)
	.endw
	xor eax, eax
	ret
bignum_shl endp

;Умножение двух больших чисел; res = lhs * rhs
bignum_mul proc uses edi esi ebx ecx res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

	local inter_res:ptr bignum
	invoke bignum_init_null, addr inter_res
	invoke bignum_set_ui, res, 0

	mov eax, [rhs]
	mov eax, [eax].bignum.digits

	mov ebx, [lhs]
	mov ebx, [ebx].bignum.digits
	.if ebx < eax
		push rhs
		push lhs
		pop rhs
		pop lhs
	.endif
	mov eax, res
	mov ebx, lhs
	mov ebx, [ebx].bignum.sign
	mov [eax].bignum.sign, ebx
	mov ecx, 0
	mov esi, rhs
	assume esi:ptr bignum
	.while ecx < [esi].digits
		push esi
		mov esi, [esi].container
		invoke bignum_mul_ui, inter_res, lhs, dword ptr [esi + ecx*4]
		invoke bignum_shl, inter_res, ecx
		invoke bignum_add, res, res, inter_res
		pop esi
		inc ecx
	.endw
	mov edi, res
	mov eax, rhs
	mov eax, [eax].bignum.sign
	xor [edi].bignum.sign, eax
	invoke bignum_free, inter_res
	xor eax, eax
	ret
bignum_mul endp

;Копирование больших чисел; dst = src
bignum_cpy proc uses edi esi ebx dst:ptr bignum, src:ptr bignum

	mov edi,[dst]
	assume edi:ptr bignum

	mov esi,[src]
	assume esi:ptr bignum
	
	.if edi == esi
		ret
	.endif

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

bignum_move proc uses eax edi esi lhs:ptr bignum, rhs:ptr bignum

	mov edi, lhs
	mov esi, rhs
	assume edi:ptr bignum
	assume esi:ptr bignum
	mov eax, [esi].digits
	mov [edi].digits, eax
	
	mov eax, [esi].sign
	mov [edi].sign, eax

	mov eax, [esi].container
	mov [edi].container, eax

	mov [esi].container, NULL
	invoke bignum_free, rhs
	ret
bignum_move endp

bignum_shrink_to_fit proc uses edi ecx bn:ptr bignum

	mov edi, [bn]
	assume edi:ptr bignum
	mov ecx, [edi].digits
	dec ecx
	shl ecx, 2
	.while ecx > 0
		mov eax, [edi].container
		add eax, ecx
		.if dword ptr [eax] != 0
			.break
		.endif
		sub ecx, sizeof(digit)
	.endw
	shr ecx, 2
	inc ecx

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

bignum_free proc uses edi bn:ptr bignum
	
	mov edi, bn
	assume edi:ptr bignum
	.if [edi].container != NULL
		invoke crt_free, [edi].container
	.endif
	invoke crt_free, bn
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