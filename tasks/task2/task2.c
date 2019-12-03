#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

const unsigned long long BIGNUM_BASE = 0x100000000;
#define NEG 1
#define NONNEG 0

typedef unsigned int digit;

typedef struct _bignum {

	unsigned int size;
	unsigned int sign;
	digit* container;
}bignum;

void bignum_printf (FILE* const _Stream, const bignum *bn)
{
	if(bn->sign == NEG)
		fprintf(_Stream, "\-");

	if (bn->container != NULL) 
	{
		fprintf(_Stream, "%X", bn->container[bn->size - 1]);
		for (int i = bn->size - 2; i >= 0; --i)
		{
			fprintf(_Stream, " %08X", bn->container[i]);
		}
	}
}

unsigned int my_strtoul(const char* start, const char* end) 
{
	unsigned int num = 0, base = 1, tmp, radix = 16;
	for (char* curr = end; curr >= start; --curr)
	{
		if (*curr >= '0' && *curr <= '9')
		{
			tmp = (*curr - '0');
			num += tmp * base;
		}
		else if (*curr >= 'A' && *curr <= 'F')
		{
			tmp = (*curr - 'A'+ 10);
			num += tmp * base;
		}
		base *= radix;
	}
	return num;
}

void bignum_init_null(bignum* bn) 
{
	bn->size = 0;
	bn->sign = NONNEG;
	bn->container = NULL;
}

void bignum_shrink_to_fit(bignum* bn) 
{
	int i = bn->size - 1;
	while (i >= 0) 
	{
		if (bn->container[i] != 0)
			break;
		--i;
	}
	if (i < 0) 
	{
		i = 1;
	}
	else 
	{
		++i;
	}
	bn->size = i;
	bn->container = (digit*)realloc(bn->container, bn->size * sizeof(digit));
}

void bignum_zeronull_fix(bignum* bn) 
{
	if (bn->size == 1 && bn->sign == NEG && bn->container[0] == 0)
		bn->sign = NONNEG;
}
//Инициализация большого числа строкой шестнадцатиричных символов
errno_t bignum_set_str (bignum *bn, const char *str) 
{
	if (*str == '-')
	{
		bn->sign = NEG;
		++str;
	}
	else
	{
		bn->sign = NONNEG;
	}
	size_t length = strlen(str);
	if (length < 8)
	{
		bn->size = 1;
	}
	else
	{
		//8 16-ых разрядов умещается в 1 unsigned int
		bn->size = length / 8;
		if (length % 8 != 0)
		{
			++bn->size;
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

	if (bn->container != NULL)
		free(bn->container);
	bn->container = (digit*)malloc(bn->size * sizeof(digit));

	if (bn->container == NULL)
		return 1;

	char* end_substr = tmp;
	char* start_substr = tmp - 8 > str ? tmp - 8 : str;
	if (end_substr < start_substr)
		end_substr = start_substr;
	unsigned int i = 0;
	while (i < bn->size)
	{
		bn->container[i] = my_strtoul(start_substr, end_substr);
		
		end_substr -= 8;
		start_substr = start_substr - 8 > str ? start_substr - 8 : str;
		if (end_substr < start_substr)
			end_substr = start_substr;
		++i;
	}
	return 0;
}

//Инициализация большого числа числом типа unsigned int
errno_t bignum_set_ui (bignum *bn, unsigned int number)
{
	bn->size = 1;
	bn->sign = NONNEG;
	if (bn->container != NULL)
		free(bn->container);
	bn->container = (digit*)malloc(bn->size * sizeof(digit));
	if (bn->container == NULL)
		return 1;
	bn->container[0] = number;
	return 0;
}

//Инициализация большого числа числом типа int
errno_t bignum_set_i (bignum *bn, int number)
{
	bn->size = 1;
	bn->sign = number < 0 ? NEG : NONNEG;
	if (bn->container != NULL)
		free(bn->container);
	bn->container = (digit*)malloc(bn->size*sizeof(digit));
	if (number < 0) 
	{
		bn->container[0] = -number;
	}
	else
	{
		bn->container[0] = number;
	}
	if (bn->container == NULL)
		return 1;
	return 0;
}

//Сложение двух больших чисел; res = lhs + rhs
errno_t bignum_add (bignum *res, const bignum *lhs, const bignum *rhs)
{

}

//Вычитание двух больших чисел; res = lhs - rhs
errno_t bignum_sub ( bignum *res, const bignum *lhs, /*const*/ bignum *rhs)
{
	rhs->sign = rhs->sign == NONNEG ? NEG : NONNEG;
	errno_t ret = bignum_add(res, lhs, rhs);
	rhs->sign = rhs->sign == NONNEG ? NEG : NONNEG;
	return ret;
}

//Побитовое ИСКЛЮЧАЮЩЕЕ ИЛИ двух больших чисел; res = lhs ^ rhs
errno_t bignum_xor ( bignum *res, const bignum *lhs, const bignum *rhs)
{
	if (lhs->size > rhs->size) 
	{
		bignum_cpy(res, lhs);
	}
	else 
	{
		bignum_cpy(res, rhs);
		rhs = lhs;
	}
	unsigned int i;
	for (i = 0; i < rhs->size; ++i) 
	{
		res->container[i] ^= rhs->container[i];
	}
	res->sign ^= rhs->sign;
	bignum_shrink_to_fit(res);
	bignum_zeronull_fix(res);
	return 0;
}

//Побитовое ИЛИ двух больших чисел; res = lhs | rhs
errno_t bignum_or( bignum *res, const bignum *lhs, const bignum *rhs)
{
	if (lhs->size > rhs->size)
	{
		bignum_cpy(res, lhs);
	}
	else
	{
		bignum_cpy(res, rhs);
		rhs = lhs;
	}
	unsigned int i;
	for (i = 0; i < rhs->size; ++i)
	{
		res->container[i] |= rhs->container[i];
	}
	res->sign |= rhs->sign;
	bignum_shrink_to_fit(res);
	bignum_zeronull_fix(res);
	return 0;
}

//Побитовое И двух больших чисел; res = lhs & rhs
errno_t bignum_and ( bignum *res, const bignum *lhs, const bignum *rhs)
{
	if (lhs->size > rhs->size)
	{
		bignum_cpy(res, lhs);
	}
	else
	{
		bignum_cpy(res, rhs);
		rhs = lhs;
	}
	unsigned int i;
	for (i = 0; i < rhs->size; ++i)
	{
		res->container[i] &= rhs->container[i];
	}
	res->sign &= rhs->sign;
	bignum_shrink_to_fit(res);
	bignum_zeronull_fix(res);
	return 0;
}

//Умножение большого числа на unsigned int; res = lhs * rhs
errno_t bignum_mul_ui ( bignum *res, const bignum *lhs, unsigned int rhs)
{
	bignum_cpy(res, lhs);
	unsigned long long mult_res = 0, transfer = 0, total_res = 0;
	unsigned int i = 0;
	unsigned int new_size = res->size;
	do
	{
		if (i < res->size)
		{
			mult_res = (unsigned long long)res->container[i]*(unsigned long long)rhs;
			total_res = mult_res % BIGNUM_BASE + transfer;
			transfer = mult_res / BIGNUM_BASE + total_res / BIGNUM_BASE;
			res->container[i] = total_res % BIGNUM_BASE;
		}
		else
		{
			++res->size;
			res->container = (digit*)realloc(res->container, res->size * sizeof(digit));
			res->container[i] = transfer % BIGNUM_BASE;
			transfer /= BIGNUM_BASE;
		}
		++i;
	} while (transfer != 0);
}

//Умножение двух больших чисел; res = lhs * rhs
errno_t bignum_mul ( bignum *res, const bignum *lhs, const bignum *rhs)
{

}

//Деление двух больших чисел; res = lhs / rhs;
errno_t bignum_div ( bignum *res, const bignum *lhs, const bignum *rhs)
{

}

//Остаток от деления двух больших чисел; res = lhs % rhs
errno_t bignum_mod ( bignum *res,  bignum *lhs, const bignum *rhs)
{

}

errno_t bignum_cpy(bignum* dst, const bignum* src)
{
	dst->size = src->size;
	if (dst->container != NULL)
		free(dst->container);
	dst->container = (digit*)malloc(dst->size * sizeof(digit));
	dst->sign = src->sign;
	memcpy_s(dst->container, dst->size*sizeof(digit), src->container, src->size * sizeof(digit));
}

void bignum_free(bignum* bn) 
{
	free(bn->container);
	free(bn);
}

//Возведение большого числа в n-ную степень; res = lhs^n
errno_t bignum_pow ( bignum *res, const bignum *lhs, unsigned int n)
{
	for (;n > 0;--n) 
	{
		bignum_mul(res, res, lhs);
	}
	return 0;
}

int main() 
{
	bignum* res = (bignum*)malloc(sizeof(bignum));
	bignum_init_null(res);
	bignum_set_str(res, "FFFFFFFF");
	bignum_mul_ui(res, res, 0xFFFFFFFF);
	bignum_printf(stdout, res);
	bignum_free(res);
	
	return 0;
}