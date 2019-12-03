.686
.model flat, C
option casemap:none

;----------------------------------------
include c:\masm32\include\msvcrt.inc

include Strings.mac
include bigint.inc

NULL equ 0

.data

.data?

.const

.code

;Вывод большого числа
bignum_printf proc uses esi edx bn:ptr bignum

	mov esi,[bn]
	assume esi:ptr bignum
	
	.if [esi].sign != 0
		invoke crt_printf, $CTA0("\-")
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
		
		invoke crt_printf, $CTA0("%X"), dword ptr [ecx]
		sub ecx, sizeof(dword);sizeof ptr digit

		.while	ecx >= edx
			
			invoke crt_printf, $CTA0("%08X"), dword ptr [ecx]
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

	;'0' equ 48
	;'9' equ 57
	;'A' equ 65
	;'F' equ 70

	.while  esi >= start_str
		xor eax, eax
		mov  al, byte ptr [esi]
		
		.if eax >= 48 && eax <= 57
			sub eax, 48 	
		.elseif eax >= 65 && eax <= 70
			sub eax, 55
		.endif
		mul base
		add num, eax

		mov eax, base
		mul radix
		mov base, eax
		sub esi, sizeof(dword);sizeof ptr byte
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
	mov edx, [edi].container
	.if [edi].digits == 1 && [edi].sign == NEGATIVE && dword ptr [edx] == 0
		mov [edi].sign, NONNEG
	.endif
	ret

bignum_zeronull_fix endp

;Инициализация большого числа строкой шестнадцатиричных символов
bignum_set_str proc uses edi bn:ptr bignum, string:ptr byte
COMMENT @
	mov edi,[bn]
	assume edi:ptr bignum
	if (*str == '-')
	{
		[edi].sign = NEG;
		++str;
	}
	else
	{
		[edi].sign = NONNEG;
	}
	size_t length = strlen(str);
	if (length < 8)
	{
		[edi].size = 1;
	}
	else
	{
		;8 16-ых разрядов умещается в 1 unsigned int
		[edi].size = length / 8;
		if (length % 8 != 0)
		{
			++[edi].size;
		}
	}
	char* tmp = str;
	while (*tmp)
	{
		if (isxdigit(*str) == 0)
			return 1;
		++tmp;
	}
	--tmp;
	if ([edi].container != NULL)
		free([edi].container);
	[edi].container = (digit*)malloc([edi].size);
	if ([edi].container == NULL)
		return 1;
	char* end_substr = tmp;
	char* start_substr = tmp - 8 > str ? tmp - 8 : str;
	if (end_substr < start_substr)
		end_substr = start_substr;
	unsigned int i = 0;
	while (i < [edi].size)
	{
		[edi].container[i] = my_strtoul(start_substr, end_substr);
		
		end_substr -= 8;
		start_substr = start_substr - 8 > str ? start_substr - 8 : str;
		if (end_substr < start_substr)
			end_substr = start_substr;
		++i;
	}
	return 0;
@
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
	.if dword ptr [number] < 0
		mov [edi].sign, NEGATIVE
	.else
		mov [edi].sign, NONNEG
	.endif
	
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

	.if dword ptr [number] < 0
		neg number
	.endif
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
COMMENT @
	
	rhs->sign = rhs->sign == NONNEG ? NEG : NONNEG;
	ret = bignum_add(res, lhs, rhs);
	rhs->sign = rhs->sign == NONNEG ? NEG : NONNEG;
	return ret;
@
bignum_sub endp

;Побитовое ИСКЛЮЧАЮЩЕЕ ИЛИ двух больших чисел; res = lhs ^ rhs
bignum_xor proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

bignum_xor endp

;Побитовое ИЛИ двух больших чисел; res = lhs | rhs
bignum_or proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

bignum_or endp

;Побитовое И двух больших чисел; res = lhs & rhs
bignum_and proc res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

bignum_and endp

;Умножение большого числа на unsigned int; res = lhs * rhs
bignum_mul_ui proc res:ptr bignum, lhs:ptr bignum, rhs:dword

	COMMENT @
	const unsigned long long base = 4294967296;
	class BigInteger
	{
		std::vector<unsigned int> digits;
	public:
		BigInteger(unsigned int num);
		~BigInteger();
		BigInteger& operator*=(const unsigned int& rhs);
		void print();
	};
	unsigned __int64 mult_res = 0, transfer = 0, total_res = 0;
	unsigned int i = 0;
	do
	{
		if (i < digits.size())
		{
			mult_res = static_cast<unsigned __int64>(digits[i])*
				static_cast<unsigned __int64>(num);
			total_res = mult_res % base + transfer;
			transfer = mult_res / base + total_res / base;
			digits[i] = total_res % base;
		}
		else
		{
			digits.push_back(transfer % base);
			transfer /= base;
		}
		++i;
	} while (transfer != 0);
	@
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

main proc argc:dword, argv:dword, envp:dword
	
	local bn:ptr bignum
	local num:dword
	mov num, 0FFFFFFFFh
	
	invoke bignum_init_null, addr bn
	invoke bignum_printf, bn

	invoke crt_printf, $CTA0("\n")

	invoke bignum_set_ui, bn, num
	invoke bignum_printf, bn

	invoke bignum_free, bn
	mov eax, 0
	ret

main endp

end
