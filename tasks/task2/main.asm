.686
.model flat, C
option casemap:none

;----------------------------------------
include c:\masm32\include\msvcrt.inc

include Strings.mac
include bigint.inc

.code

main proc argc:dword, argv:dword, envp:dword

	local res:ptr bignum
	local lhs:ptr bignum
	local rhs:ptr bignum
	local num:dword
	.if argc < 4
		invoke crt_printf, $CTA0("Usage: lhs rhs number(dword)")
		mov eax, 2
		ret
	.endif
	
	invoke bignum_init_null, addr res
	invoke bignum_init_null, addr lhs
	invoke bignum_init_null, addr rhs

	mov edx, argv
	add edx, 4
	push edx
	invoke bignum_set_str, lhs, dword ptr [edx]
	.if eax != 0
		invoke crt_printf, $CTA0("Error: lhs initialization")
		ret
	.endif
	invoke crt_printf, $CTA0("lhs = ")
	invoke bignum_printf, lhs
	invoke crt_printf, $CTA0("\n")

	pop edx
	add edx, 4
	push edx
	invoke bignum_set_str, rhs, dword ptr [edx]
	.if eax != 0
		invoke crt_printf, $CTA0("Error: rhs initialization")
		ret
	.endif
	invoke crt_printf, $CTA0("rhs = ")
	invoke bignum_printf, rhs
	invoke crt_printf, $CTA0("\n")

	pop edx
	add edx, 4
	push edx
	invoke crt_strtol, dword ptr [edx], NULL, 16
	mov num, eax
	invoke crt_printf, $CTA0("num = %u\n"), num

	invoke bignum_add, res, lhs, rhs
	invoke crt_printf, $CTA0("lhs + rhs = ")
	invoke bignum_printf, res
	invoke crt_printf, $CTA0("\n")

	invoke bignum_sub, res, lhs, rhs
	invoke crt_printf, $CTA0("lhs - rhs = ")
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