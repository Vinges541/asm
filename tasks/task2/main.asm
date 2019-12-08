.686
.model flat, C
option casemap:none

;----------------------------------------
include c:\masm32\include\msvcrt.inc

include Strings.mac
include bigint.inc

bignum_shl proto bn:ptr bignum, number:dword

.data

number db "-FFFFFFFFFFFFFFFF", 0

.code

main proc argc:dword, argv:dword, envp:dword

	local res:ptr bignum
	local lhs:ptr bignum
	local rhs:ptr bignum
	local num:dword
	mov num, 0FFFFFFFFh
	invoke crt_printf, $CTA0("num = %X\n"), num

	invoke bignum_init_null, addr res
	invoke bignum_init_null, addr lhs
	invoke bignum_init_null, addr rhs

	invoke bignum_set_str, lhs, offset number
	invoke crt_printf, $CTA0("lhs = ")
	invoke bignum_printf, lhs
	invoke crt_printf, $CTA0("\n")

	invoke bignum_set_str, rhs, offset number
	invoke crt_printf, $CTA0("rhs = ")
	invoke bignum_printf, rhs
	invoke crt_printf, $CTA0("\n")
	
	comment @
	invoke bignum_add, res, lhs, rhs
	invoke crt_printf, $CTA0("lhs + rhs = ")
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")

	invoke bignum_xor, res, lhs, rhs
	invoke crt_printf, $CTA0("lhs ^ rhs = ")
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")

	invoke bignum_or, res, lhs, rhs
	invoke crt_printf, $CTA0("lhs | rhs = ")
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")

	invoke bignum_and, res, lhs, rhs
	invoke crt_printf, $CTA0("lhs & rhs = ")
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")

	invoke bignum_mul_ui, res, lhs, num
	invoke crt_printf, $CTA0("lhs*num = ")
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")
	@

	invoke bignum_mul, res, lhs, rhs
	invoke crt_printf, $CTA0("lhs * rhs = ")
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")

	invoke bignum_free, lhs
	invoke bignum_free, rhs
	invoke bignum_free, res
	mov eax, 0
	ret

main endp

end