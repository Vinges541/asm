//#ifndef USHORT
//typedef unsigned long USHORT;
//#endif /* !defined USHORT */
//#ifndef ULONG 
//typedef unsigned long long ULONG;
//#endif /* !defined ULONG */
//
//
//#define BIGINT_BASE       0x10000UL
//#define BIGINT_MAX_ORDERS 4U
//#define BIGINT_MAX_SIZE   (BIGINT_MAX_ORDERS + 1)
//
//#define BI_BITPERREG (sizeof(USHORT) * 8)
//#define BI_SETLEN(bi, len) (*(bi) = len)
//
//
//typedef unsigned short bigint_t;
//
//typedef bigint_t    BIGINT[BIGINT_MAX_SIZE];
//typedef bigint_t* PBIGINT;
//typedef bigint_t** LPBIGINTT;
//
///* return length of BIGINT */
//#define BIGINT_LENGTH(bigint) \
//    ((USHORT)*(bigint))
//
///* return the most significant digit of BIGINT */
//#define BIGINT_MSDPTR(bigint) \
//    ((bigint) + (BIGINT_LENGTH(bigint)))
//
///* return the least significant digit of BIGINT */
//#define BIGINT_LSDPTR(bigint) \
//    ((bigint) + (1))
//
//#include <stdio.h>
//
//void _bigint_print(PBIGINT n)
//{
//	PBIGINT msdptr, lsdptr;
//
//	for (msdptr = BIGINT_MSDPTR(n), lsdptr = BIGINT_LSDPTR(n); msdptr >= lsdptr; msdptr--)
//		printf("%04X ", *msdptr);
//	printf("\n");
//}
//
//void bi_add(PBIGINT a, PBIGINT b, PBIGINT c)
//{
//	PBIGINT lsda, msda, lsdb, msdb;
//
//	PBIGINT ptrc = BIGINT_LSDPTR(c);
//	ULONG   carry = 0;
//
//	if (BIGINT_LENGTH(a) < BIGINT_LENGTH(b))
//	{
//		lsda = BIGINT_LSDPTR(b);
//		lsdb = BIGINT_LSDPTR(a);
//		msda = BIGINT_MSDPTR(b);
//		msdb = BIGINT_MSDPTR(a);
//	}
//	else
//	{
//		lsda = BIGINT_LSDPTR(a);
//		lsdb = BIGINT_LSDPTR(b);
//		msda = BIGINT_MSDPTR(a);
//		msdb = BIGINT_MSDPTR(b);
//	}
//
//	while (lsdb <= msdb)
//		*ptrc++ = (USHORT)(carry = (ULONG)*lsda++ + *lsdb++ +
//		(ULONG)(USHORT)(carry >> BI_BITPERREG));
//
//	while (lsda <= msda)
//		*ptrc++ = (USHORT)(carry = (ULONG)*lsda++ +
//		(ULONG)(USHORT)(carry >> BI_BITPERREG));
//
//	if (carry >> BI_BITPERREG)
//		*ptrc++ = 1;
//
//	BI_SETLEN(c, ptrc - BIGINT_LSDPTR(c));
//}
//
//void bi_add_us(PBIGINT a, USHORT b, PBIGINT c)
//{
//	PBIGINT lsda = BIGINT_LSDPTR(a), msda = BI_MSDPTR(a);
//	PBIGINT ptrc = BIGINT_LSDPTR(c);
//	ULONG  carry = 0;
//
//	if (lsda <= msda)
//		*ptrc++ = (USHORT)(carry = (ULONG)*lsda++ + (ULONG)b +
//		(ULONG)(USHORT)(carry >> BI_BITPERREG));
//	else
//		*ptrc++ = (USHORT)(b);
//
//	while (lsda <= msda)
//		*ptrc++ = (USHORT)(carry = (ULONG)*lsda++ +
//		(ULONG)(USHORT)(carry >> BI_BITPERREG));
//
//	if (carry >> BI_BITPERREG)
//		*ptrc++ = 1;
//
//	BI_SETLEN(c, ptrc - BIGINT_LSDPTR(c));
//}
//
//void bi_mul(PBIGINT a, PBIGINT b, PBIGINT c)
//{
//	PBIGINT lsda, msda, lsdb, msdb;
//	PBIGINT ptra, ptrb, ptrc, ptrct;
//
//	ULONG carry = 0;
//
//	if (BI_GETLEN(a) < BI_GETLEN(b))
//	{
//		ptra = b;
//		ptrb = a;
//	}
//	else
//	{
//		ptra = a;
//		ptrb = b;
//	}
//
//	msdb = BI_MSDPTR(ptrb);
//	msda = BI_MSDPTR(ptra);
//
//	for (ptrc = BIGINT_LSDPTR(c), lsda = BIGINT_LSDPTR(ptra), lsdb = BIGINT_LSDPTR(ptrb); lsdb <= msdb; ++lsdb, ++ptrc)
//		*ptrc = (USHORT)(carry = (ULONG)*lsda * (ULONG)*lsdb +
//		(ULONG)(USHORT)(carry >> BI_BITPERREG));
//
//	*ptrc = (USHORT)(carry >> BI_BITPERREG);
//
//	for (ptrc = BIGINT_LSDPTR(c) + 1, lsda = BIGINT_LSDPTR(ptra) + 1; lsda <= msda; ++lsda, ++ptrc)
//	{
//		carry = 0;
//		for (ptrct = ptrc, lsdb = BIGINT_LSDPTR(ptrb); lsdb <= msdb; ++lsdb, ++ptrct)
//			*ptrct = (USHORT)(carry = (ULONG)*lsda * (ULONG)*lsdb + (ULONG)*ptrct +
//			(ULONG)(USHORT)(carry >> BI_BITPERREG));
//
//		*ptrct = (USHORT)(carry >> BI_BITPERREG);
//	}
//
//	if (carry >> BI_BITPERREG)
//		++ptrc;
//
//	BI_SETLEN(c, ptrc - BIGINT_LSDPTR(c));
//}
//
//void bi_mul_us(PBIGINT a, USHORT b, PBIGINT c)
//{
//	PBIGINT lsda = BIGINT_LSDPTR(a), msda = BIGINT_MSDPTR(a);
//	PBIGINT ptrc = BIGINT_LSDPTR(c);
//
//	ULONG carry = 0;
//
//	while (lsda <= msda)
//		*ptrc++ = (USHORT)(carry = (ULONG)*lsda++ * (ULONG)b +
//		(ULONG)(USHORT)(carry >> BI_BITPERREG));
//
//	*ptrc = (USHORT)(carry >> BI_BITPERREG);
//
//	if (carry >> BI_BITPERREG)
//		++ptrc;
//
//	BI_SETLEN(c, ptrc - BIGINT_LSDPTR(c));
//}
//
//void bi_sub(PBIGINT a, PBIGINT b, PBIGINT c)
//{
//	PBIGINT lsda = BIGINT_LSDPTR(a), msda = BI_MSDPTR(a);
//	PBIGINT lsdb = BIGINT_LSDPTR(b), msdb = BI_MSDPTR(b);
//	PBIGINT ptrc = BIGINT_LSDPTR(c);
//
//	ULONG carry = 0;
//
//	BI_SETLEN(c, BI_GETLEN(a));
//
//	while (lsdb <= msdb)
//		*ptrc++ = (USHORT)(carry = (ULONG)*lsda++ - (ULONG)*lsdb++ -
//		((carry & BIGINT_BASE) >> BI_BITPERREG));
//
//	while (lsda <= msda)
//		*ptrc++ = (USHORT)(carry = (ULONG)*lsda++ -
//		((carry & BIGINT_BASE) >> BI_BITPERREG));
//
//	BI_DELLDZ(c);
//}
//
//void bi_sub_us(PBIGINT a, USHORT b, PBIGINT c)
//{
//	PBIGINT lsda = BIGINT_LSDPTR(a), msda = BI_MSDPTR(a);
//	PBIGINT ptrc = BIGINT_LSDPTR(c);
//
//	ULONG carry = 0;
//
//	BI_SETLEN(c, BI_GETLEN(a));
//
//	*ptrc++ = (USHORT)(carry = (ULONG)*lsda++ - (ULONG)b -
//		((carry & BIGINT_BASE) >> BI_BITPERREG));
//
//	while (lsda <= msda)
//		*ptrc++ = (USHORT)(carry = (ULONG)*lsda++ -
//		((carry & BIGINT_BASE) >> BI_BITPERREG));
//
//	BI_DELLDZ(c);
//}
//
//int main(void)
//{
//	BIGINT a = { BIGINT_MAX_ORDERS, 0xFFFF };
//	BIGINT b = { BIGINT_MAX_ORDERS, 0x1111, 0x2222, 0x3333, 0x4444 };
//	BIGINT c = { BIGINT_MAX_ORDERS, 0 };
//
//	_bigint_print(a);
//	_bigint_print(b);
//	_bigint_print(c);
//}