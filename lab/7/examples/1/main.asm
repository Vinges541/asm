;
; Модуль main.asm.
;
; Пример работы со структурами.
;
; Маткин Илья Александрович 02.10.2013
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc

include Strings.mac

strings struct
	str1 dword	?
	str2 dword	?
	str3 dword	?
	;b db ?
	;d dd ?
strings ends

strings2 struct
	s strings <>
strings2 ends




.data


.data?

.const
new_line db 13,10,0
format db "size strings: %d",13,10,0
format_number db "%s", 13, 10, 0
s1 db "str1: %s",13,10,0
s2 db "str2: %s",13,10,0
s3 db "str3: %s",13,10,0
typecast_str db "typecast", 0
hello db "Hello %08X %s", 13, 10, 0

glStrings strings<offset s1, offset s2>
glStrings2 strings<>


.code


print_strings proc c, ptr_strings:ptr strings

	mov eax,[ptr_strings]
	assume eax:ptr strings

	invoke crt_printf, addr s1, [eax].str1	;[eax]
	mov eax,[ptr_strings]
	invoke crt_printf, addr s2, [eax].str2	; [eax + 4]
	mov ebx,[ptr_strings]
	invoke crt_printf, addr s3, [ebx].strings.str3	;[ebx + 8]

    ret
    
print_strings endp



; пример приведения типов
TestFunProto typedef proto stdcall :dword, :dword
;typedef void (__stdcall *TestFunProto) (dword, dword);


test_fun proc stdcall arg1:dword, arg2:dword

	invoke crt_printf, addr hello, arg1, arg2
	
	ret

test_fun endp


typecast proc ptr_strings:ptr strings, fun_ptr: TestFunProto

	local fun_ptr2: ptr byte
	
	mov eax, [ptr_strings]
	assume eax:ptr strings
	mov [eax].str1, 0
	
	assume eax:nothing
	;mov [eax].str1, 0
	mov (strings ptr[eax]).str1, 0
	
	mov eax, offset test_fun

	invoke (TestFunProto ptr eax), 10, addr typecast_str
	
	invoke [fun_ptr], 11, addr typecast_str
	
	mov eax, [fun_ptr]
	mov [fun_ptr2], eax
	;invoke [fun_ptr2], 12, addr typecast_str
	invoke (TestFunProto ptr [fun_ptr2]), 12, addr typecast_str
	
	ret

typecast endp



main proc c uses ebx argc:DWORD, argv:DWORD, envp:DWORD

	local s:strings
	local buf_strings[10]:strings
	local str1[10]:byte
	
	mov ebx, [argv]
	
	add ebx, 4
	mov eax, [ebx]
	mov s.str1, eax
	; s + offset str1 = [ebp-12] + 0 = [ebp-12]
	
	
	add ebx, 4
	mov eax, [ebx]
	mov s.str2, eax
	; s + offset str2 = [ebp-12] + 4 = [ebp-8]
	
	add ebx, 4
	mov eax, [ebx]
	mov s.str3, eax
	
	;mov eax, offset s
	invoke crt_printf, addr format, sizeof(strings)
	invoke print_strings, addr s
	
	invoke typecast, addr s, addr test_fun
	
	
	mov eax, 0
	ret

main endp

end


