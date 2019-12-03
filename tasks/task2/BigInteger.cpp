#include "BigInteger.h"
#include <iostream>


BigInteger::BigInteger(unsigned int num)
{
	digits.push_back(num);
}

BigInteger::~BigInteger()
{
	
}

BigInteger& BigInteger::operator*=(const unsigned int& num) {
	int64_t mult_res = 0, transfer = 0, total_res = 0;
	unsigned int i = 0;
	do
	{
		if (i < digits.size()) 
		{
			mult_res = static_cast<int64_t>(digits[i]) *
				static_cast<int64_t>(num);
			total_res = mult_res % base + transfer;
			transfer = mult_res / base + total_res / base;
			digits[i] = total_res % base;
		}
		else
		{
			digits.push_back(transfer%base);
			transfer /= base;
		}
		++i;
	} while (transfer != 0);
	return *this;
}

void BigInteger::print()
{
	for (int i = digits.size() - 1; i >= 0; --i) {
		std::cout << digits[i] << "*((2^32)^" << i << ")";
		if (i > 0)
			std::cout << " + ";
	}
	std::cout << std::endl;
}

void BigInteger::print_hex()
{
	for (int i = digits.size() - 1; i >= 0; --i) {
		printf("%08X", digits[i]);
	}
	std::cout << std::endl;
}
