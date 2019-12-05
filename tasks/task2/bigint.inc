NONNEG equ 0
NEGATIVE equ 1
NULL equ 0

digit typedef dword

bignum struct 

	digits dword ?
	sign dword ?
	container digit ptr ? ;ptr digit
bignum ends

;Вывод большого числа
bignum_printf proto bn:ptr bignum

; Нуль-терминированная строка -> long
my_strtoul proto start_str:ptr byte, end_str:ptr byte

;Инициализация нулём
bignum_init_null proto bn:dword ;bn - это  **bignum

;Устранение "минус нуля"
bignum_zeronull_fix proto bn:ptr bignum

;Инициализация большого числа строкой шестнадцатиричных символов
bignum_set_str proto bn:ptr bignum, string:ptr byte

;Инициализация большого числа числом типа unsigned int
bignum_set_ui proto bn:ptr bignum, number:dword

;Инициализация большого числа числом типа int
bignum_set_i proto bn:ptr bignum, number:dword

;Сложение двух больших чисел; res = lhs + rhs
bignum_add proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;Вычитание двух больших чисел; res = lhs - rhs
bignum_sub proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;Побитовое ИСКЛЮЧАЮЩЕЕ ИЛИ двух больших чисел; res = lhs ^ rhs
bignum_xor proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;Побитовое ИЛИ двух больших чисел; res = lhs | rhs
bignum_or proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;Побитовое И двух больших чисел; res = lhs & rhs
bignum_and proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;Умножение большого числа на unsigned int; res = bn * num
bignum_mul_ui proto res:ptr bignum, bn:ptr bignum, num:dword

;Умножение двух больших чисел; res = lhs * rhs
bignum_mul proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;Деление двух больших чисел; res = lhs / rhs;
bignum_div  proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;Остаток от деления двух больших чисел; res = lhs % rhs
bignum_mod proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;Копирование больших чисел; lhs = rhs
bignum_cpy proto lhs:ptr bignum, rhs:ptr bignum


bignum_shrink_to_fit proto bn:ptr bignum

;Освобождение памяти большого числа
bignum_free proto bn:ptr bignum

;Возведение большого числа в n-ную степень; res = lhs^exp
bignum_pow proto res:ptr bignum, lhs:ptr bignum, exp:dword