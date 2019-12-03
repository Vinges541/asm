.686
.model flat, C
option casemap:none

;----------------------------------------
include c:\masm32\include\msvcrt.inc

include Strings.mac
include bigint.inc

.data

.data?

.const

.code

main proc argc:dword, argv:dword, envp:dword
	
	local bn:ptr bignum
	local num:dword
	mov num, 0
	
	invoke bignum_init_null, addr bn
	invoke bignum_printf, bn

	invoke crt_printf, $CTA0("\n")

	invoke bignum_set_ui, bn, num
	invoke bignum_printf, bn

	invoke crt_printf, $CTA0("\n")

	invoke bignum_set_i, bn, num
	invoke bignum_printf, bn

	invoke bignum_free, bn
	mov eax, 0
	ret

main endp

end