;
; ������ main.asm.
;
; ������ ��������� ������� ������� ��� Win64.
;
; ������ ���� �������������     04.12.2013
;

.x64
option casemap:none
option frame:auto
option win64:1
;OPTION FIELDALIGN:16

include windows.inc
include stdio.inc
include string.inc
include stdlib.inc

include Strings.mac

;----------------------------------------

CStr macro y:req
local sym
	.const
sym db y,0
	.code
	exitm <offset sym>
endm

CStrn macro y:req
local sym
	.const
sym db y, 13, 10, 0
	.code
	exitm <offset sym>
endm

;----------------------------------------

; ��������� ��������� � ������ ����
AppWindowName equ <"Application">

ED_1 equ 201     ; ������������� �������� ���������� ����
ED_2 equ 202     ; ������������� ������� ���������� ����
ST_1 equ 203     ; ������������� ������������ ����
BT_1 equ 204     ; ������������� ������

;----------------------------------------
; ���������� �������

RegisterClassMainWindow proto

CreateMainWindow proto

DrawLine proto hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword

DrawAbscissa proto hdc:HDC, startX:dword, startY:dword, endX:dword

DrawOrdinate proto hdc:HDC, startX:dword, startY:dword, endY:dword

WndProcMain proto hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

;----------------------------------------
; �������� ������

.data


.data?

glChar dq ?

hIns HINSTANCE ?

HwndMainWindow HWND ?

.const
text db "Hello, World!",0
caption db "Info",0


;----------------------------------------
; �������� �������

.code

;
; �������� ������� ������� ����������
;
WinMain proc frame hInstance:HINSTANCE, hPrevInstance:HINSTANCE, szCmdLine:PSTR, iCmdShow:DWORD

    local msg: MSG

    mov rax, [hInstance]
    mov [hIns], rax

    invoke CreateMainWindow
    mov [HwndMainWindow], rax
    .if [HwndMainWindow] == 0
        xor rax, rax
        ret
    .endif
	
	; �������� ���� ��������� ���������
    .while TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
            .break .if rax == 0

        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg

    .endw

    mov rax, [msg].wParam
    ret

WinMain endp

;--------------------

;
; ����������� ������ ��������� ���� ����������
;
RegisterClassMainWindow proc frame

    local WndClass:WNDCLASSEX	; ��������� ������

    ; ��������� ���� ���������
    mov WndClass.cbSize, sizeof (WNDCLASSEX)    ; ������ ��������� ������
    mov WndClass.style, 0
    mov rax, offset WndProcMain
    mov WndClass.lpfnWndProc,  rax              ; ����� ������� ��������� ������
    mov WndClass.cbClsExtra, 0
    mov WndClass.cbWndExtra, 0                  ; ������ �������������� ������ ����
    mov rax, [hIns]
    mov WndClass.hInstance, rax	                ; ��������� ����������
    invoke LoadIcon, hIns, $CTA0("MainIcon")    ; ������ ����������
    mov WndClass.hIcon, rax
    invoke LoadCursor, NULL, IDC_ARROW
    mov WndClass.hCursor, rax
    invoke GetStockObject, BLACK_BRUSH          ; ����� ��� ����
    mov WndClass.hbrBackground, rax
    mov WndClass.lpszMenuName, NULL
    mov rax, $CTA0(AppWindowName)
    mov WndClass.lpszClassName, rax             ; ��� ������
    invoke LoadIcon, hIns, $CTA0("MainIcon")
    mov WndClass.hIconSm, rax

    invoke RegisterClassEx, addr WndClass
    ret

RegisterClassMainWindow endp

;--------------------

;
; �������� ��������� ���� ����������
;
CreateMainWindow proc frame

    local hwnd:HWND

    ; ����������� ������ ��������� ����
    invoke RegisterClassMainWindow

    ; �������� ���� ������������������� ������
    invoke CreateWindowEx, 
        WS_EX_CONTROLPARENT or WS_EX_APPWINDOW, ; ����������� ����� ����
        $CTA0(AppWindowName),	; ��� ������������������� ������ ����
        $CTA0("Application"),	; ��������� ����
        WS_OVERLAPPEDWINDOW,	; ����� ����
        10,	    ; X-���������� ������ �������� ����
        10,	    ; Y-���������� ������ �������� ����
        650,    ; ������ ����
        650,    ; ������ ����
        NULL,   ; ��������� ������������� ����
        NULL,   ; ��������� �������� ���� (��� �������� ����)
        [hIns], ; ������������� ����������
        NULL
    mov [hwnd], rax
    
    .if [hwnd] == 0
        invoke MessageBox, NULL, $CTA0("������ �������� ��������� ���� ����������"), NULL, MB_OK
        xor rax, rax
        ret
    .endif
        
    invoke ShowWindow, [hwnd], SW_SHOWNORMAL
    invoke UpdateWindow, [hwnd]
    
    mov rax, [hwnd]
    ret

CreateMainWindow endp

;--------------------

;
; ������ ������� �� ��������� ���������� � ���������� ������������.
;
DrawLine proc frame hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword

    local pen:HPEN
    
    ; ������ ������ "����" ��� ��������� �����
    invoke CreatePen, 
        PS_SOLID,       ; ����� ��� ����� (��������)
        2,              ; ������� �����
        (30 shl 16) + (150 shl 8) + 255 ; ���� �����
    mov [pen], rax
    
    ; ����������� ��������� ����� � ���������� ����������
    invoke SelectObject, [hdc], [pen]
    
    ; ���������� ������� �������, � ������� ���������� ���������
    invoke MoveToEx,
        [hdc],          ; ��������� ��������� ����������
        startX,         ; X-����������
        startY,         ; Y-����������
        NULL
        
    ; ������ ����� ��������� ������ �� ������� ������� �� ��������� �����
    invoke LineTo,
        [hdc],          ; ��������� ��������� ����������
        endX,           ; X-���������� �������� �����
        endY            ; Y-���������� �������� �����

    ; ������� ��������� "����"
    invoke DeleteObject, pen

    ret

DrawLine endp


;--------------------

;
; ������ ��� �������.
;
DrawAbscissa proc frame hdc:HDC, startX:dword, startY:dword, endX:dword

    invoke DrawLine, [hdc], [startX], [startY], [endX], [startY]
    
    mov r10d, [endX]
    sub r10d, 10
    mov r11d, [startY]
    sub r11d, 5
    invoke DrawLine, [hdc], r10d, r11d, [endX], [startY]
    
    mov r10d, [endX]
    sub r10d, 10
    mov r11d, [startY]
    add r11d, 5
    invoke DrawLine, [hdc], r10d, r11d, [endX], [startY]
    
    ret

DrawAbscissa endp

;--------------------

;
; ������ ��� �������.
;
DrawOrdinate proc frame hdc:HDC, startX:dword, startY:dword, endY:dword

    invoke DrawLine, [hdc], [startX], [startY], [startX], [endY]
    
    mov r10d, [endY]
    add r10d, 10
    mov r11d, [startX]
    sub r11d, 5
    invoke DrawLine, [hdc], r11d, r10d, [startX], [endY]
    
    mov r10d, [endY]
    add r10d, 10
    mov r11d, [startX]
    add r11d, 5
    invoke DrawLine, [hdc], r11d, r10d, [startX], [endY]
    
    ret

DrawOrdinate endp

;--------------------

;
; ������� ��������� ��������� �������� ���� ����������.
; ���������� �������� ��� ����������� ��������� ��� �������� ����
; � ���������������� �����������.
;
; ���������:
;
; hwnd      ��������� ����, ����������� ���������
; iMsg      ������������� (�����) ���������
; wParam    �������� ���������
; lParam    �������� ���������
;
WndProcMain proc frame hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

    local hdc:HDC
    local ps:PAINTSTRUCT

    ;and esp, 0FFFFFFF0h

    .if [iMsg] == WM_CREATE
        ; �������� ����
        
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_DESTROY
        ; ����������� ����
        
        invoke PostQuitMessage, 0
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_SIZE
        ; ��������� �������
        
    .elseif [iMsg] == WM_SETFOCUS
        ; ��������� ������
        
    .elseif [iMsg] == WM_CLOSE
        ; �������� ����
        
    .elseif [iMsg] == WM_QUIT
        ; ���������� ����������
        
    .elseif [iMsg] == WM_KEYDOWN
        ;������� �������
        
        .if wParam == VK_SHIFT
        .endif
        
    .elseif [iMsg] == WM_CHAR
        ; ���� � ����������
        
    .elseif [iMsg] == WM_PAINT
        ; ����������� ����
        
        ; �������� �������� ����������
        invoke BeginPaint, HwndMainWindow, addr ps
        mov [hdc], rax
        
        ; ���������� ���� ������
        invoke SetTextColor, [hdc], 255
        
        ; ���������� ���� ���� ������
        invoke SetBkColor, [hdc], 100 + (100 shl 8) + (100 shl 16)
        
        ; ����� ������ �� �������� ����������
        invoke TextOut, [hdc], 200, 10, $CTA0("������ ������"), 13
        
        ;invoke DrawLine, [hdc], 0, 75, 1500, 75
        
        invoke DrawAbscissa, [hdc], 10, 500, 600
        invoke DrawOrdinate, [hdc], 10, 500, 100
        
        ; ���������� �����������
        invoke EndPaint, [hwnd], addr ps
        
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_COMMAND

        movzx eax, word ptr [wParam]
        .if eax == BT_1
        .endif
        ret
        
    .endif
    
    ; �������������� ��������� ������������ � �������
    ; ��������� �� ���������.
    invoke DefWindowProc, hwnd, iMsg, wParam, lParam
    ret

WndProcMain endp

;--------------------
;--------------------


end
