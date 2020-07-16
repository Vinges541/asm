;
; ������ main.asm.
;
; ������ �������� ����������
;
; ������ ���� ������������� 16.10.2013
;

;----------------------------------------

.686
.model flat, stdcall
option casemap:none

;----------------------------------------

include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\gdi32.inc
include c:\masm32\include\windows.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\msvcrt.inc

include Strings.mac

;RGB macro r, g, b
    ;(r) or ((g) shr 8) or ((b) shr 16)
;RGB endm

;----------------------------------------

; ��������� ��������� � ������ ����
AppWindowName equ <"Application">

;----------------------------------------


.data

glChar dd 0

.data?

hIns HINSTANCE ?

HwndMainWindow HWND ?

.const

.code

;----------------------------------------

RegisterClassMainWindow proto;

CreateMainWindow proto;

WndProcMain proto hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

;----------------------------------------

WinMain proc stdcall hInstance:HINSTANCE, hPrevInstance:HINSTANCE, szCmdLine:PSTR, iCmdShow:DWORD

    local msg: MSG

    mov eax, [hInstance]
    mov [hIns], eax

    invoke CreateMainWindow
    mov [HwndMainWindow], eax
    .if [HwndMainWindow] == 0
        xor eax, eax
        ret
    .endif
	
    .while TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
            .break .if eax == 0

        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg

    .endw

    mov eax, [msg].wParam
    ret

WinMain endp

;--------------------

;
; ����������� ������ ��������� ���� ����������
;
RegisterClassMainWindow proc

    local WndClass:WNDCLASSEX	; ��������� ������

    ; ��������� ���� ���������
    mov WndClass.cbSize, sizeof (WNDCLASSEX)	; ������ ��������� ������
    mov WndClass.style, 0
    mov WndClass.lpfnWndProc, WndProcMain		; ����� ������� ��������� ������
    mov WndClass.cbClsExtra, 0
    mov WndClass.cbWndExtra, 0
    mov eax, [hIns]
    mov WndClass.hInstance, eax					; ��������� ����������
    invoke LoadIcon, hIns, $CTA0("MainIcon")	; ������ ����������
    mov WndClass.hIcon, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov WndClass.hCursor, eax
    invoke GetStockObject, BLACK_BRUSH			; ����� ��� ����
    mov WndClass.hbrBackground, eax
    mov WndClass.lpszMenuName, NULL
    mov WndClass.lpszClassName, $CTA0(AppWindowName)	; ��� ������
    invoke LoadIcon, hIns, $CTA0("MainIcon")
    mov WndClass.hIconSm, eax

    invoke RegisterClassEx, addr WndClass
    ret

RegisterClassMainWindow endp

;--------------------

;
; �������� ��������� ���� ����������
;
CreateMainWindow proc

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
    mov [hwnd], eax
    
    .if [hwnd] == 0
        invoke MessageBox, NULL, $CTA0("������ �������� ��������� ���� ����������"), NULL, MB_OK
        xor eax, eax
        ret
    .endif
        
    invoke ShowWindow, hwnd, SW_SHOWNORMAL
    invoke UpdateWindow, hwnd
    
    mov eax, [hwnd]
    ret

CreateMainWindow endp

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
WndProcMain proc hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

    local hdc:HDC
    local pen:HPEN
    local ps:PAINTSTRUCT

    .if [iMsg] == WM_CREATE
        ; �������� ����
        
        xor eax, eax
        ret
    .elseif [iMsg] == WM_DESTROY
        ; �������� ����
        
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .elseif [iMsg] == WM_CHAR
        ; ���� � ����������
        
        mov eax, [wParam]
        mov [glChar], eax
        xor eax, eax
        invoke InvalidateRect, hwnd, NULL, TRUE
        ret
    .elseif [iMsg] == WM_PAINT
        ; ����������� ����
        
        ; �������� �������� ����������
        invoke BeginPaint, HwndMainWindow, addr ps
        mov [hdc], eax
        
        ; ���������� ���� ������
        invoke SetTextColor, [hdc], 255
        
        ; ���������� ���� ���� ������
        invoke SetBkColor, [hdc], 100 + (100 shl 8) + (100 shl 16)
        
        ; ����� ������ �� �������� ����������
        invoke TextOut, [hdc], 10, 10, $CTA0("Hello, World"), 12
        
        ; ����� ���������� ���������� �������
        invoke TextOut, [hdc], 10, 50, addr glChar, 1
        invoke TextOut, [hdc], 20, 50, addr glChar, 1
        
        ; ������ ������ "����" ��� ��������� �����
        invoke CreatePen, 
            PS_SOLID,       ; ����� ��� ����� (��������)
            3,              ; ������� �����
            (30 shl 16) + (150 shl 8) + 255 ; ���� �����
        mov [pen],eax
        
        ; ����������� ��������� ����� � ���������� ����������
        invoke SelectObject, [hdc], [pen]
        
        ; ���������� ������� �������, � ������� ���������� ���������
        invoke MoveToEx,
            [hdc],          ; ��������� ��������� ����������
            0,              ; X-����������
            75,             ; Y-����������
            NULL
            
        ; ������ ����� ��������� ������ �� ������� ������� �� ��������� �����
        invoke LineTo,
            [hdc],          ; ��������� ��������� ����������
            1500,           ; X-���������� �������� �����
            75              ; Y-���������� �������� �����

        ; ������� ��������� "����"
        invoke DeleteObject, pen
        
        ; ���������� �����������
        invoke EndPaint, [hwnd], addr ps
        
        xor eax, eax
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
