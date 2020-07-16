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


.data?

hIns HINSTANCE ?

HwndMainWindow HWND ? ;; ��������� �������� ����
HwndEdit1 HWND ? ;          ; ��������� �������� ���������� ����
HwndEdit2 HWND ? ;          ; ��������� ������� ���������� ����
HwndButton1 HWND ? ;        ; ��������� ������
HwndStatic1 HWND ? ;        ; ��������� ������������ ���� (�������)

glWindowMainWidth ULONG ?;  ; ������ �������� ����
glWindowMainHeight ULONG ?; ; ������ �������� ����

.const

ED_1 dd 201     ; ������������� �������� ���������� ����
ED_2 dd 202     ; ������������� ������� ���������� ����
ST_1 dd 203     ; ������������� ������������ ����
BT_1 dd 204     ; ������������� ������

.code

;----------------------------------------

RegisterClassMainWindow proto;

CreateMainWindow proto;

WndProcMain proto hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

CreateControlWindowsMain proto hwnd:HWND;

ProcessingSizeEvent proto hwnd:HWND, iMsg: UINT, wParam:WPARAM, lParam:LPARAM;

ProcessingButton1 proto;

;----------------------------------------
; �������� ������� ������� ���������� (������)
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
; ����������� ������ ��������� ���� ���������� (������)
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
; �������� ��������� ���� ���������� (������)
;
CreateMainWindow proc

    local hwnd:HWND

    ; ����������� ������ ��������� ����
    invoke RegisterClassMainWindow

    ; �������� ���� ������������������� ������
    invoke CreateWindowEx,\ 
        WS_EX_CONTROLPARENT or WS_EX_APPWINDOW,\
        $CTA0(AppWindowName),\
        $CTA0("Application"),\
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

	local lowordParam:WPARAM

    .if [iMsg] == WM_CREATE
        ; �������� ����
        invoke CreateControlWindowsMain, [hwnd]
        xor eax, eax
        ret
    .elseif [iMsg] == WM_DESTROY
        ; �������� ����
        
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
	.elseif [iMsg] == WM_SIZE
        
        invoke ProcessingSizeEvent, hwnd,iMsg,wParam,lParam;
        ret
    .elseif [iMsg] == WM_COMMAND
		mov eax, wParam
		and eax, 0FFFFh
        .if eax == BT_1
            invoke ProcessingButton1;
        .endif
        ret
    .elseif [iMsg] == WM_PAINT
        ; ����������� ����
        
        ; �������� �������� ����������
        invoke BeginPaint, HwndMainWindow, addr ps
        mov [hdc], eax
        
        ; ������ ������ "����" ��� ��������� �����
        invoke CreatePen,\ 
            PS_SOLID,\
            3,\
            (30 shl 16) + (150 shl 8) + 255
        mov [pen],eax
        
        ; ����������� ��������� ����� � ���������� ����������
        invoke SelectObject, [hdc], [pen]
        
        ; ���������� ������� �������, � ������� ���������� ���������
        invoke MoveToEx,\
            [hdc],\
            0,\
            75,\
            NULL
            
        ; ������ ����� ��������� ������ �� ������� ������� �� ��������� �����
        invoke LineTo,
            [hdc],\
            [glWindowMainWidth],\
            75

        ; ������� ��������� "����"
        invoke DeleteObject, pen
        
        ; ���������� �����������
        invoke EndPaint, [hwnd], addr ps
        
        xor eax, eax
        ret

    .elseif [iMsg] == WM_CTLCOLORSTATIC
			
			mov eax, lParam
			mov ebx, HwndEdit2
            .if eax == ebx
                invoke SetTextColor, wParam, (0 shl 16) + (0 shl 8) + 255
                invoke SetBkColor, wParam, (200 shl 16) + (200 shl 8) + 200
                invoke GetStockObject, DKGRAY_BRUSH
                ret;
            .else
                invoke SetTextColor, wParam,(0 shl 16) + (128 shl 8) + 255;
                invoke SetBkColor, wParam,(0 shl 16) + (100 shl 8) + 100;
				invoke GetStockObject, BLACK_BRUSH
                ret;
			.endif

    .endif
    
    ; �������������� ��������� ������������ � �������
    ; ��������� �� ���������.
    invoke DefWindowProc, hwnd, iMsg, wParam, lParam
    ret

WndProcMain endp

;--------------------
;; �������� ����������� ��������� (���������) �������� ����
;;
CreateControlWindowsMain proc hwnd:HWND

	local dwStyle:DWORD
	mov dwStyle, 0
	or dwStyle, WS_CHILD
	or dwStyle, WS_VISIBLE
	or dwStyle, WS_VSCROLL
	or dwStyle, WS_HSCROLL
	or dwStyle, WS_BORDER 
    or dwStyle, ES_LEFT
	or dwStyle, ES_MULTILINE
	or dwStyle, ES_AUTOVSCROLL
	or dwStyle, ES_AUTOHSCROLL
    invoke CreateWindowEx,\ 
							NULL, $CTA0("edit"), NULL, dwStyle,\
                            0, 0,\
                            0, 0,\
                            hwnd, ED_1, hIns, NULL;
    mov HwndEdit1, eax
	or dwStyle, ES_NUMBER 
	or dwStyle, ES_READONLY
    invoke CreateWindowEx,\ 
							NULL, $CTA0("edit"), NULL, dwStyle,\
                            0, 0,\
                            0, 0,\
                            hwnd, ED_2, hIns, NULL;
    mov HwndEdit2, eax
	mov dwStyle, 0
	or dwStyle, WS_CHILD
	or dwStyle, WS_VISIBLE
	or dwStyle, WS_BORDER
	or dwStyle, ES_NUMBER
    invoke CreateWindowEx, NULL, $CTA0("static"), NULL,\
                            dwStyle,\
                            10, 10,\
                            80, 40,\
                            hwnd, ST_1, hIns, NULL;
    mov HwndStatic1, eax
    invoke SetWindowText, HwndStatic1, $CTA0("static1");

    invoke CreateWindowEx, NULL,$CTA0("button"), $CTA0("button1"),\
							WS_CHILD or WS_VISIBLE,\
							100, 10,\
							55, 30,\
							hwnd, BT_1, hIns, NULL;
    mov HwndButton1, eax
    ret
CreateControlWindowsMain endp
;--------------------
;
; ������� ��������� ������� ��������� �������� ����
;
ProcessingSizeEvent proc hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM
	local Y:DWORD
	local nWidth:DWORD
	local nHeight:DWORD
	; ������� ����� ��������� lParam �������� ����� ������ ����
	mov eax, lParam
	and eax, 0FFFFh
    mov [glWindowMainWidth], eax;
    ; ������� - ������
	mov eax, lParam
	and eax, 0FFFF0000h
    mov [glWindowMainHeight], eax;

	mov eax, [glWindowMainWidth]
	mov nWidth, eax
	sub nWidth, 20

	mov eax, [glWindowMainHeight]
	mov nHeight, eax
	shr nHeight, 16
	sub nHeight, 120;120
	shr nHeight, 1
    ; �������� ������ ���������� ���� ��������������� �������� �������� ����
    invoke MoveWindow,
               HwndEdit1,\
               10,\
               100,\
               nWidth,\
               nHeight,\
               TRUE         ; ���� ������������� �����������
	mov Y, 110
	mov eax, nHeight
	add Y, eax
    invoke MoveWindow,\
               HwndEdit2,\
               10,\
               Y,\
               nWidth,\
               nHeight,\
               TRUE
    xor eax, eax
	ret;
ProcessingSizeEvent endp

;--------------------

;
; ������� ��������� ������� ������� ������.
; ��������� ����� �� �������� ���������� ����
; � ������.
;(������)
ProcessingButton1 proc                                                                                                                                                                                                      

    local offset_:DWORD;
    local buf:DWORD;
    local size_:DWORD;

        ; �������� ����� ������ � ������� ����
        invoke GetWindowTextLength, HwndEdit1;
        mov size_, eax;
        .if size_ == 0
            ret;
        .endif
        ; �������� ����������� ������
        invoke crt_malloc, size_+1;
        mov buf, eax
        .if buf == 0
            ret;
        .endif
        ; �������� ������ �� ���� � �����
        invoke GetWindowText, HwndEdit1, buf, size_+1
        .if eax != size_
            invoke crt_free, buf;
            ret;
        .endif

        ; �������� � ������� ��������� ���� ������� ������
        ; �.�. ������� ����
        invoke SetWindowText, HwndEdit1, NULL;

        ; �������� ����� ������ � ������ ����
        invoke GetWindowTextLength, HwndEdit2;
        mov offset_, eax

        ; ���������� ������ � ����� ������
        invoke SendMessage, HwndEdit2, EM_SETSEL, offset_, offset_;

        ; �������� ������, ������������ �� �������� ���� � ������
        invoke SendMessage, HwndEdit2, EM_REPLACESEL, 0, buf;

        invoke crt_free, buf;

        ret;
ProcessingButton1 endp

;--------------------

end
