;
; Модуль main.asm.
;
; Пример использования инструкций.
;
; Маткин Илья Александрович 18.09.2013
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
text db "Hello, World!",0
caption db "Info",0

.code

main proc c argc:DWORD, argv:DWORD, envp:DWORD

	jmp M

; префикс смены разрядности операнда
	mov ax, bx
	mov eax, ebx
	
	db 66h
	mov al, bl
	mov al, bl
	
	mov eax, 11111111h
	mov ebx, 22222222h
	
	;lock mov fs:[ax], bx
		
	;db 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 2eh, 2eh
	;db 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h
	;db 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h
	db 67h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h, 66h
	;db 66h, 66h, 66h, 2eh
	;db 66h
	mov eax, ebx
	;mov ax, bx

; префикс смены разрядности адреса операнда
	;mov eax, [0]
	;db  66h, 67h
	db 67h
	mov eax, [eax]
	;mov eax, [bx+si]

; префиксы смены сегментных регистров
	mov ebx, [argv]
	assume fs:nothing
	assume gs:nothing
	mov eax, [ebx]
	mov eax, cs:[ebx]
	mov eax, ds:[ebx]
	
	mov eax, [esp]
	mov eax, ds:[esp]
	;db 3Eh, 3Eh, 3Eh, 3Eh, 2Eh, 64h
	db 3Eh, 3Eh, 3Eh, 3Eh, 2Eh, 64h, 3Eh
	mov eax, [esp]
	
	mov eax, ss:[ebx]
	mov eax, es:[ebx]
	mov eax, fs:[ebx]
	mov eax, gs:[ebx]
	
	; 2E - cs
	; 3E - ds
	; 36 - ss
	; 26 - es
	; 64 - fs
	; 65 - gs


	mov eax, [esp]
	mov eax, ds:[esp]


	inc dword ptr [eax]
	lock inc dword ptr [eax]
	; F0h - lock

	M:
; пересылки (загрузки) данных
;mov m, r/imm
;mov r, r/m/imm
;mov r/cri, r/cri

	mov eax, [11223344h + eax + 1*ebx]
	mov eax, [11223344h + eax + 2*ebx]
	mov eax, [11223344h + eax + 4*ebx]
	mov eax, [11223344h + eax + 8*ebx]

	mov eax, ebx
;xchg r, r/m
;xchg m, r
	xchg eax, eax

; lea r/m, [...]
	lea eax, [ebx + eax * 8 + 1234]
	lea ebx, [eax][eax*4]	; ebx = 5 * eax

; стековые операции
; push r16,r32/m/imm
; pop r16,r32/m
; pusha	pushaw/pushad	сохраняют в стек все регистры общего назначения
; popa popaw/popad
; pushf pushfd			сохраняет в стек регистр флагов
; popf popfd

	pushaw
	pushad

	pushf
	pushfd
	popfd
	popf
	
	
; инструкции для работы с eflags
; sti/cli
; stc/clc
; std/cld
; lahf/sahf	пересылка младшего байта регистра eflags в ah

    
; инструкции расширения (знакового и беззнакового)
; al = 00000001 -> ax = 00000000 00000001
; al = 10101010 -> ax =	11111111 10101010
; cbw   al -> ax
; cwde  ax -> eax
; cwd   ax -> dx:ax
; cdq   eax -> edx:eax
; movsx r8/m8 -> r16, r8/r16/m8/m16 -> r32
; movzx r8/m8 -> r16, r8/r16/m8/m16 -> r32
M2:
	mov ax, 2214h
	cbw
	mov eax, 22338122h
	cwde
	

; арифметические инструкции
; add 
; sub
; mul r/m	
; div r/m
; imul r/m
; imul r, r/m/imm
; imul r, r/m, imm
; idiv r/m
; inc r/m
; dec r/m
; neg r/m


	imul eax
	imul dword ptr [eax]
	imul eax, ecx
	imul eax, 10
	imul eax, dword ptr [eax]
	imul eax, eax, 2
	imul eax, [eax], 1

	idiv eax
	idiv dword ptr [eax]

; логические операции
; and
; or
; xor
; not


; сдвиги
; 01010100 << 1 -> 10101000
; 01010100 >> 1 -> 00101010
; 11110001 << 1 -> 11100010, 11100001
; 11110001 >> 1 -> 11111000, 01111000
; 11110000 >> 1 -> 01111000, 
; shl/shr r/m, 1/imm/cl		логические сдвиги
; sal/sar r/m, 1/imm/cl		арифметические сдвиги
; rol/ror r/m, 1/imm/cl		циклический сдвиг
; rcl/rcr r/m, 1/imm/cl

	shl eax, 5
	shl eax, cl
	sal eax, 5
	sar eax, cl
	rol eax, 5
	ror eax, cl

; команды сравнения
; cmp r/m, r/m/imm			вычитание с установкой флагов
; test r/m/, r/m/imm		логическое И c установкой флагов


; команды передачи управления
; call r
; call M
; call dword ptr [m]
; call seg:offset
; jmp r
; jmp M
; short jmp M
; near jmp M
; j<cond>
; je = jz, jne = jnz, 
; jl = jnge, jg = jnle,...			знаковое сравнение
; jb = jnae, ja = jnbe,...			беззнаковое сравнение
; ret
; ret N
; retf
; int
; iret
; sysenter/sysexit

	call eax
	call M
	call dword ptr [eax]



	mov eax, 0
	ret

main endp


end
