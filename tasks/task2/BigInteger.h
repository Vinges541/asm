#pragma once
#include <vector>
const unsigned long long base = 4294967296;
class BigInteger
{
	std::vector<unsigned int> digits;
public:
	BigInteger(unsigned int num);
	~BigInteger();
	BigInteger& operator*=(const unsigned int& rhs);
	void print();
	void print_hex();
};

