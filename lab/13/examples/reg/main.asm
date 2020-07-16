;
; ������ main.asm.
;
; ������ ������ � ���������� x64.
;
; ������ ���� �������������     27.11.2013
;

option casemap:none

printf proto c :vararg

.data

.data?

qvar dq ?
dvar dd ?

.const

.code


main proc

	local a:qword
	
	mov rax, a
	mov a, rax
	
	mov rcx, [rdx]
	call printf

    push rbp
    mov ebp, esp
    mov rbp, rsp
    sub rsp, 40h
    sub esp, 40h
    
    mov eax, [dvar]
	
	; lea rax, [dvar]	(&dvar = 0x00406138)
	db 48h, 8Dh, 04h, 25h, 38h, 61h, 40h, 00h
	lea rax, [dvar]
	
	lea rax, [rax + 4 * rcx + 11223344h]
	lea rax, [0]
	lea rax, [11223344h]

	; ������������� � ���� � �� �� ����������
	mov eax, offset M
	mov eax, [M]
	mov eax, M

	; ��� ��������� � ������ ���� ������� dword ptr
	mov eax, dword ptr [M]
    
    lea eax, [M]
    ;mov eax, [rip + 10]

	lea rax, [M]
M:
	lea rax, [0]
	lea rax, [rdi + rsi + qvar]
	mov rax, [rdi + rsi + qvar]    
    lea rax, [qvar]
    mov rax, offset qvar
    
    ; ������ ����� ������������ ����� ����� 64-� ���������� ����������
    mov rax, 1122334455667788h
    mov rax, qword ptr 0    ; ��������� (64-� ������) ����������� � rax
    mov rax, 1122334455667788h
    mov rax, dword ptr 0	; ��������� (32-� ������) ����������� � rax
    mov rax, 0              ; = mov rax, dword ptr 0
    mov rbx, rax
    mov rcx, rax
    mov rdx, rax
    mov rsi, rax
    mov rdi, rax
    mov r8, rdi
    mov r8, 1122334455667788h
    mov r9, r8
    mov r10, r8
    mov r11, r8
    mov r12, r8
    mov r13, r8
    mov r14, r8
    mov r15, r8
    mov rax, r15
    
    mov eax, 1
    mov r8d, eax
    mov ebx, eax
    
    mov ax, 2
    mov r9w, ax
    mov bx, ax
    
    mov ah, 2
    mov al, 3
    mov bl, ah
    mov bl, al
    mov r10b, al
    mov sil, al
    mov dil, al
    mov cl, bpl
    mov bpl, cl
    mov al, spl
    mov spl, al
    ; ���������������� ����������
    ;mov r8b, ah
	
	mov rax, 1122334455667788h
	; ��� ��� ������ ����������, �� ���� ���� � ��� �� ���������
	; � rax ��������� �������� 0000000077777777h
    mov eax, 77777777h
    mov rax, 77777777h
    
    mov rax, 1122334455667788h
    mov ebx, 0AAAAAAAAh
    ; � rax ��������� �������� 00000000AAAAAAAAh
    mov eax, ebx
    
    ; ��������� ����� 4 ��������
    mov rax, 11223344h
    ; ��������� ����� 8 ��������
    mov rax, qword ptr 11223344h
    ; ��������� ����� 8 �������� (��� ��� � 4 ���� ����� ������������� ����� �� ������������)
    db 48h, 0C7h, 0C0h, 88h, 88h, 88h, 88h
    mov rax, dword ptr 88888888h
    ; ��������� ����� 8 ��������
    mov rax, qword ptr 88888888h
    
    ; ��������� ����� 4 �������� (����� ����� 0FFFFFFFFh)
    mov rax, dword ptr -1
    ; ��������� ����� 8 �������� (����� ����� 0FFFFFFFFFFFFFFFFh)
    mov rax, qword ptr -1
    
    ; ��� ������ ���������� ���������� (��������� ����� 4-� ��������)
    mov rax, 55h
    mov rax, dword ptr 55h
    mov rax, word ptr 55h
    mov rax, byte ptr 55h
    
    ; ��� ������ ���������� ���������� (��������� ����� 4-� ��������)
    mov eax, 11h
    mov eax, dword ptr 11h
    mov eax, word ptr 11h
    mov eax, byte ptr 11h
    
    ; ������ �������� � ������ ���������������� 64-� ������� ��������
    mov rax, 1122334455667788h
    mov [qvar], rax
    mov eax, dword ptr [qvar]
    mov rax, qword ptr [qvar]
    
    ; ��� ������� ����������
    ;mov [qvar], qword ptr 1122334455667788h
    ; ����� ������ ����� �������
    mov rax, 1122334455667788h
    mov [qvar], rax
    ; � qvar ����� �������� 4 �������� �����
    mov dword ptr [qvar], dword ptr 0AAAAAAAAh
    ; � qvar ����� �������� 8 �������� �����, ������� ���������� � 4 ����
    mov qword ptr [qvar], dword ptr 0AAAAAAAAh
    mov qword ptr [qvar], word ptr 0AAAAh
    
    ; ����� ���������� ���
    ;push eax
    ;push ah
    ;push al
    ;push sil
    push ax
    push rax
    ; ����� ���������� ���
    ;push qword ptr 0AAh
    ; � ���� ����� �������� 8 �������� �����, ������� ����������� � 4 ����
    push dword ptr 0AAAAAAAAh
    ; � ���� ����� �������� 2 �����
    push word ptr 0AAAAh
    ; � ���� ����� �������� 8 �������� �����, ������� ����������� � 1 �����
    push byte ptr 0AAh
    
    ; ����� ���������� ���
    ;push offset var
    ; ���������� ������������ ������� ���
    lea rax, [qvar]
    ; ��� ���
    mov rax, offset qvar
    push rax
    
    ; � rax ����� ���������� �� ����� M1
    mov rax, $+12
    call rax
    call M1
    ; ����� ���������� ���
    ;call eax
    
M1:
    ; � rax ����� ���������� �� ����� M2
    mov rax, $ + (M2-M1)
    mov [qvar], rax
    lea rax, [qvar]
    call qword ptr [rax]
    call qword ptr [qvar]
    call qword ptr [eax]
    jmp rax
    ; ����� ���������� ���
    ;jmp eax
    jmp qword ptr [qvar]
    jmp qword ptr [rax]
    jmp M2
    jmp near ptr M2
    je short M2
    je near ptr M2
M2:

    ; eax ������� ���������� �� 64-� ��� � ������� -1 + 1 = 0
    mov rax, 0FFFFFFFFFFFFFFFh
    add eax, 1
    mov rax, 0FFFFFFFFh
    add eax, 1
    mov eax, 0FFFFFFFFh
    mov ebx, 1
    add eax, ebx
    
    mov rdx, 1122334455667788h
    add rax, rax
    sub rax, rbx
    mul rbx
    cdq		; eax -> edx:eax
    cdqe    ; eax -> rax
    cqo     ; rax -> rdx:rax
    mov rdx, 0
    imul rbx	; -> rdx:rax
    mov rdx, 0
    imul rax, rbx	; -> rax
    and rax, rbx
    
    mov rax, 0FFFFFFFFh
    add ax, 1       ; rax = 0FFFF0000h
    
    mov rax, 0FFFFFFFFh
    add ah, 1       ; rax = 0FFFF00FFh
    
    mov rax, 0FFFFFFFFh
    and eax, 0FFFFFFFFh
    
    mov ax, 0FFFFh
    xor ax, 0FFh
    
    mov al, 0FFh
    xor ax, 0F0h
    
    mov rax, 11223344h
    shl eax, 16
    shl rax, 32

    ; ������� ������������ ��������
    finit
    fldz
    fld1
    fstsw ax
    
    mov rsp, rbp
    pop rbp
    ret

main endp




end
