#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#define BIGNUM_BASE 0x100000000

typedef unsigned int digit;

typedef struct _bignum {

	unsigned int size;
	char sign;
	digit* container;
}bignum;

errno_t bignum_init_null (bignum *bn, unsigned int chunk_count)
{

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

//Инициализация большого числа строкой шестнадцатиричных символов
errno_t bignum_set_str (bignum *bn, const char *str) 
{
	if (*str == '-')
	{
		bn->sign = -1;
		++str;
	}
	else
	{
		bn->sign = 1;
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
	bn->container = (digit*)malloc(bn->size);
	if (bn->container == NULL)
		return 1;

	return 0;
}

//Инициализация большого числа числом типа unsigned int
errno_t bignum_set_ui (bignum *bn, unsigned int number)
{
	bn->size = 1;
	bn->sign = 1;
	bn->container = (digit*)malloc(bn->size);
	bn->container[0] = number;
	if (bn->container == NULL)
		return 1;
	return 0;
}

//Инициализация большого числа числом типа int
errno_t bignum_set_i (bignum *bn, int number)
{
	bn->size = 1;
	bn->sign = number < 0 ? -1 : 1;
	bn->container = (digit*)malloc(bn->size);
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
	rhs->sign = rhs->sign == 1 ? -1 : 1;
	errno_t ret = bignum_add(res, lhs, rhs);
	rhs->sign = rhs->sign == 1 ? -1 : 1;
	return ret;
}

//Побитовое ИСКЛЮЧАЮЩЕЕ ИЛИ двух больших чисел; res = lhs ^ rhs
errno_t bignum_xor ( bignum *res, const bignum *lhs, const bignum *rhs)
{

}

//Побитовое ИЛИ двух больших чисел; res = lhs | rhs
errno_t bignum_or( bignum *res, const bignum *lhs, const bignum *rhs)
{

}

//Побитовое И двух больших чисел; res = lhs & rhs
errno_t bignum_and ( bignum *res, const bignum *lhs, const bignum *rhs)
{

}

//Умножение большого числа на unsigned int; res = lhs * rhs
errno_t bignum_mul_ui ( bignum *res, const bignum *lhs, unsigned int rhs)
{
	/*
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
	*/
}

//Умножение двух больших чисел; res = lhs * rhs
errno_t bignum_mul ( bignum *res, const bignum *lhs, const bignum *rhs)
{

}

//Деление двух больших чисел; res lhs / rhs;
errno_t bignum_div ( bignum *res, const bignum *lhs, const bignum *rhs)
{

}

//Остаток от деления двух больших чисел; res = lhs % rhs
errno_t bignum_mod ( bignum *res,  bignum *lhs, const bignum *rhs)
{

}

errno_t bignum_cpy(bignum* lhs, const bignum* rhs)
{
	lhs->sign = rhs->sign;
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
	bignum* bn = (bignum*) malloc(sizeof(bignum));
	//bignum_set_str(bn, "FFFFFFFF");
	const char number[] = "FF";
	//printf("%u", my_strtoul(number, number + strlen(number)-1));
	printf("%u", 3244324334 ^ 654789514UL);
}