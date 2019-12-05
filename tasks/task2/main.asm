.686
.model flat, C
option casemap:none

;----------------------------------------
include c:\masm32\include\msvcrt.inc

include Strings.mac
include bigint.inc

.data

number db "FFFFFFFF", 0

.code

main proc argc:dword, argv:dword, envp:dword
	
	COMMENT @
	local lhs:ptr bignum
	local rhs:ptr bignum
	local res:ptr bignum
	local num:dword
	mov num, 03000000000
	
	invoke bignum_init_null, addr lhs
	invoke bignum_init_null, addr rhs
	invoke bignum_init_null, addr res

	invoke bignum_set_ui, lhs, num
	invoke bignum_printf, lhs

	invoke crt_printf, $CTA0("\n")

	invoke bignum_set_i, rhs, num
	invoke bignum_printf, rhs

	invoke crt_printf, $CTA0("\n")

	invoke bignum_xor, res, lhs, rhs
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")

	invoke bignum_or, res, lhs, rhs
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")

	invoke bignum_and, res, lhs, rhs
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")

	invoke bignum_free, lhs
	invoke bignum_free, rhs
	invoke bignum_free, res
	@

	local bn:ptr bignum
	local res:ptr bignum
	invoke bignum_init_null, addr bn
	invoke bignum_init_null, addr res
	invoke bignum_set_str, bn, offset number
	invoke bignum_mul_ui, res, bn, 0FFFFFFFFh
	invoke bignum_printf, res
	invoke bignum_free, bn
	invoke bignum_free, res
	mov eax, 0
	ret

main endp

end