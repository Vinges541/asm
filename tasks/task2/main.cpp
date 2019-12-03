#include "BigInteger.h"
#include <iostream>
int main() 
{
	BigInteger res(0xFFFFFFFF);
	res *= 0xFFFFFFFF;
	res.print_hex();
	return 0;
}