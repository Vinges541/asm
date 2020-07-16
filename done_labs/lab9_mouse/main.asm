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

buf dd 100 dup(0)

.data?

hIns HINSTANCE ?

HwndMainWindow HWND ? ;; ��������� �������� ����
HwndEdit1 HWND ? ;          ; ��������� �������� ���������� ����
HwndStatic1 HWND ? ;        ; ��������� ������������ ���� (�������)

glWindowMainWidth ULONG ?;  ; ������ �������� ����
glWindowMainHeight ULONG ?; ; ������ �������� ����

.const

ED_1 dd 201     ; ������������� �������� ���������� ����
ST_1 dd 202     ; ������������� ������������ ����

.code

;----------------------------------------

sprintf proto C :dword, :VARARG

RegisterClassMainWindow proto;

CreateMainWindow proto;

CreateControlWindowsMain proto hwnd:HWND;

ProcessingSizeEvent proto hwnd:HWND, iMsg: UINT, wParam:WPARAM, lParam:LPARAM;

InsertStringTailEdit proto string:DWORD;

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
    mov WndClass.style, CS_DBLCLKS
    mov WndClass.lpfnWndProc, WndProcMain		; ����� ������� ��������� ������
    mov WndClass.cbClsExtra, 0
    mov WndClass.cbWndExtra, 0
    mov eax, [hIns]
    mov WndClass.hInstance, eax					; ��������� ����������
    invoke LoadIcon, hIns, $CTA0("MainIcon")	; ������ ����������
    mov WndClass.hIcon, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov WndClass.hCursor, eax
    invoke GetStockObject, WHITE_BRUSH			; ����� ��� ����
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
    invoke CreateWindowEx,\ 
        WS_EX_CONTROLPARENT or WS_EX_APPWINDOW,\
        $CTA0(AppWindowName),\
        $CTA0("Mouse example"),\
        WS_OVERLAPPEDWINDOW,\
        10,\
        10,\
        650,\
        650,\
        NULL,\
        NULL,\
        [hIns],\ 
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
; �������� ����������� ��������� (���������) �������� ����
;
CreateControlWindowsMain proc hwnd:HWND


    invoke CreateWindowEx, 0, $CTA0("edit"), NULL,
                            (((WS_CHILD or WS_VISIBLE) or (WS_VSCROLL or WS_HSCROLL)) or ((WS_BORDER or ES_LEFT) or (ES_MULTILINE or ES_AUTOVSCROLL))) or (ES_AUTOHSCROLL or ES_READONLY),
                            0, 0,
                            0, 0,
                            hwnd, ED_1, hIns, NULL;
    mov HwndEdit1, eax
    invoke CreateWindowEx, 0, $CTA0("static"), NULL,
                            (WS_CHILD or WS_VISIBLE) or (WS_BORDER or ES_NUMBER),
                            10, 10,
                            80, 40,
                            hwnd, ST_1, hIns, NULL;
    mov HwndStatic1, eax
    invoke SetWindowText, HwndStatic1, $CTA0("static1");

    ret;
CreateControlWindowsMain endp

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
	local x:DWORD
	local y:DWORD

    .if [iMsg] == WM_CREATE
        ; �������� ����
        invoke CreateControlWindowsMain, hwnd;
        xor eax, eax
        ret
	.elseif [iMsg] == WM_SIZE
        invoke ProcessingSizeEvent, hwnd, iMsg, wParam, lParam
        ret
    .elseif [iMsg] == WM_DESTROY
        ; �������� ����
        
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .elseif [iMsg] == WM_MOUSEMOVE
            ; ������� ����� �������� �-����������
			mov eax, lParam
			and eax, 0FFFFh
			mov x, eax
            ; ������� ����� �������� �-����������
			mov eax, lParam
			and eax, 0FFFF0000h
			mov y, eax
			shr y, 16

            invoke sprintf, offset buf, $CTA0("x = %d\ny = %d"), x, y;

            ; �������� ����� � ����������� ����
            invoke SetWindowText, HwndStatic1, offset buf;
			xor eax, eax
            ret;

        ; ��������� ���������� ��� ������� ����� ������ ���� � ����
       .elseif [iMsg] == WM_LBUTTONDOWN
            ; ������� ����� �������� �-����������
			mov eax, lParam
			and eax, 0FFFFh
			mov x, eax
            ; ������� ����� �������� �-����������
			mov eax, lParam
			and eax, 0FFFF0000h
			mov y, eax
			shr y, 16
            invoke sprintf, offset buf, $CTA0("������ ����� ������ ���� � ����� (%d,%d)\r\n"), x, y;
            invoke InsertStringTailEdit, offset buf;
			xor eax, eax
            ret;

        ; ��������� ���������� ��� ��������� ����� ������ ����
        .elseif [iMsg] == WM_LBUTTONUP
            invoke InsertStringTailEdit, $CTA0("�������� ����� ������ ����\r\n");
            xor eax, eax
            ret;

        ; ��������� ���������� ��� ������� ����� ����� ������� ����
        .elseif [iMsg] == WM_LBUTTONDBLCLK
            invoke InsertStringTailEdit, $CTA0("������ ������ ����� ������ ����\r\n");
           xor eax, eax
            ret;

        ; ��������� ���������� ��� ������� ������ ������ ����
        .elseif [iMsg] == WM_RBUTTONDOWN
            invoke InsertStringTailEdit, $CTA0("������ ������ ������ ����\r\n");
			xor eax, eax
            ret;

        ; ��������� ���������� ��� ���������� ������ ������ ����
       .elseif [iMsg] == WM_RBUTTONUP
            invoke InsertStringTailEdit, $CTA0("�������� ������ ������ ����\r\n");
            xor eax, eax
            ret;

        ; ��������� ���������� ��� ������� ����� ������ ������ ����
        .elseif [iMsg] == WM_RBUTTONDBLCLK
            invoke InsertStringTailEdit, $CTA0("������ ������ ������ ������ ����\r\n");
            xor eax, eax
            ret;
    .endif
    
    ; �������������� ��������� ������������ � �������
    ; ��������� �� ���������.
    invoke DefWindowProc, hwnd, iMsg, wParam, lParam
    ret

WndProcMain endp

;--------------------
; ������� ��������� ������� ��������� �������� ����
;
ProcessingSizeEvent proc hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM
	local nWidth:DWORD
	local nHeight:DWORD
	local Y:DWORD
	; ������� ����� ��������� lParam �������� ����� ������ ����
	mov eax, lParam
	and eax, 0FFFFh
    mov glWindowMainWidth, eax;
    ; ������� - ������
	mov eax, lParam
	and eax, 0FFFF0000h
    mov glWindowMainHeight, eax;

	mov eax, glWindowMainWidth
	mov nWidth, eax
	sub nWidth, 20

	mov eax, glWindowMainHeight
	mov nHeight, eax
	shr nHeight, 16
	sub nHeight, 120
	shr nHeight, 1

	mov eax, 110
	add eax, nHeight
	mov Y, eax
    ; �������� ������ ���������� ���� ��������������� �������� �������� ����
    invoke MoveWindow,
               HwndEdit1,   ; ��������� ������������� ����
               10,          ; �-���������� ������ �������� ����
               Y,         ; �-���������� ������ �������� ����
               nWidth,    ; ������
               nHeight,  ; ������
               TRUE         ; ���� ������������� �����������
    xor eax, eax
	ret;
ProcessingSizeEvent endp
;--------------------

; ������� ��������� ������ � ����� ���������� ����.
;
InsertStringTailEdit proc string:DWORD

    local offset_:DWORD;

    ; �������� ����� ������ � ������ ����
    invoke GetWindowTextLength, HwndEdit1;
    mov offset_, eax
    ; ���������� ������ � ����� ������
    invoke SendMessage, HwndEdit1, EM_SETSEL, offset_, offset_;

    ; �������� ������
    invoke SendMessage, HwndEdit1, EM_REPLACESEL, 0, string;

    ret;
InsertStringTailEdit endp

end
