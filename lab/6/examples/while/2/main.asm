;
; Модуль main.asm.
;
; Пример реализации цикла while встроенными средствами.
;
; Маткин Илья Александрович 25.09.2013
;

.686
.model flat, stdcall
option casemap:none

include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc

include Strings.mac

.data


.data?

.const
new_line db 13,10,0
format db "%s",13,10,0
s1 db "11111111111",0
s2 db "22222222222",0
s3 db "33333333333",0
offsets dd offset s1, offset s2, offset s3, offset s2, offset s1, 0

.code


print_array proc c uses ebx, arr:DWORD

    local strPointer:DWORD
    local i:DWORD

	mov [i], 0
	
	mov ebx, [arr]
	mov ebx, [ebx]
	mov [strPointer], ebx

    ; возможные условия:
    ; op1 ==(!=, <, >, <=, >=) op2
    ; op1 & op2     test op1, op2
    ; !op1
    ; op1 && op2
    ; op1 || op2
    ; CARRY?
    ; OVERFLOW?
    ; PARITY?
    ; SIGN?
    ; ZERO?

    .while dword ptr[ebx] == 1
    .endw
    
    .while [strPointer]
    ;.while CARRY?
        ;mov ecx, [i]
        ;mov ebx, [arr]
        ;invoke crt_printf, addr format, dword ptr[ecx + ebx]
        invoke crt_printf, addr format, [strPointer]
        
        add [i], 4
        mov ecx, [i]
        mov ebx, [arr]
        mov ebx, [ecx + ebx]
        mov [strPointer], ebx
    .endw

    ret
    
print_array endp


print_array2 proc c uses ebx, arr:DWORD

    local i:DWORD

	mov [i], 0
	
	mov ebx, [arr]
	mov ebx, [ebx]

    .while 1
        mov ecx, [i]
        mov ebx, [arr]
        
        add [i], 4
        ;.continue .if [i] == 4
        .if [i] == 4
			.continue
        .endif
        
        invoke crt_printf, addr format, dword ptr[ecx + ebx]
        
        mov ecx, [i]
        mov ebx, [arr]
        .break .if !dword ptr [ecx + ebx]
        ;.break
    .endw

    ret
    
print_array2 endp


main proc c argc:DWORD, argv:DWORD, envp:DWORD

	;invoke print_array, [argv]
	;invoke print_array, [envp]
	invoke print_array, offset offsets
	invoke crt_printf, addr new_line
	invoke print_array2, offset offsets
	invoke print_array, [envp]
	
	invoke crt_malloc, 10*4
	
	mov eax, 0
	ret

main endp

end
