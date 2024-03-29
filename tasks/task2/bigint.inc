NONNEG equ 0
NEGATIVE equ 1
NULL equ 0

digit typedef dword

bignum struct 

	digits dword ?
	sign dword ?
	container digit ptr ? ;ptr digit
bignum ends

;����� �������� �����
bignum_printf proto bn:ptr bignum

; ����-��������������� ������ -> long
my_strtoul proto start_str:ptr byte, end_str:ptr byte

;������������� ����
bignum_init_null proto bn:dword ;bn - ���  **bignum

;���������� "����� ����"
bignum_zeronull_fix proto bn:ptr bignum

;������������� �������� ����� ������� ����������������� ��������
bignum_set_str proto bn:ptr bignum, string:ptr byte

;������������� �������� ����� ������ ���� unsigned int
bignum_set_ui proto bn:ptr bignum, number:dword

;������������� �������� ����� ������ ���� int
bignum_set_i proto bn:ptr bignum, number:dword

;�������� ���� ������� �����; res = lhs + rhs
bignum_add proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;��������� ���� ������� �����; res = lhs - rhs
bignum_sub proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;��������� ����������� ��� ���� ������� �����; res = lhs ^ rhs
bignum_xor proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;��������� ��� ���� ������� �����; res = lhs | rhs
bignum_or proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;��������� � ���� ������� �����; res = lhs & rhs
bignum_and proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;��������� �������� ����� �� unsigned int; res = bn * num
bignum_mul_ui proto res:ptr bignum, bn:ptr bignum, num:dword

;��������� ���� ������� �����; res = lhs * rhs
bignum_mul proto res:ptr bignum, lhs:ptr bignum, rhs:ptr bignum

;����������� ������� �����; lhs = rhs
bignum_cpy proto lhs:ptr bignum, rhs:ptr bignum

bignum_move proto lhs:ptr bignum, rhs:ptr bignum

bignum_shrink_to_fit proto bn:ptr bignum

;������������ ������ �������� �����
bignum_free proto bn:ptr bignum

;���������� �������� ����� � n-��� �������; res = lhs^exp
bignum_pow proto res:ptr bignum, lhs:ptr bignum, exp:dword