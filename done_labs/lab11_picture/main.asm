;
; ������ main.asm.
;
; ������ ����������� ��������
;
; ������ ���� �������������     12.11.2013
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
include bmp.inc

;----------------------------------------

; ��������� ��������� � ������ ����
AppWindowName equ <"Application">

IDM_OPEN        equ 201
IDM_OPEN2       equ 202
IDM_SAVE        equ 203
IDM_INVERT      equ 204
IDM_GRAYSTYLE   equ 205

IDM_INCBRIGHTNESS equ 206
IDM_DECBRIGHTNESS equ 207
IDM_BLACKANDWHITE equ 208
IDM_REFLECTVERTICAL equ 209
IDM_REFLECTHORIZONTAL equ 210
IDM_TURNLEFT equ 211
IDM_TURNRIGHT equ 212
IDM_GLUE equ 213

;----------------------------------------


.data

glChar dd 0

.data?

hIns HINSTANCE ?

glCurrentBitmap HBITMAP ?   ; ��������� ��������

HwndMainWindow HWND ?

.const

.code

;----------------------------------------

RegisterClassMainWindow proto

CreateMainWindow proto

WndProcMain proto hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

;----------------------------------------

WinMain proc stdcall hInstance:HINSTANCE, hPrevInstance:HINSTANCE, szCmdLine:PSTR, iCmdShow:DWORD

    local msg: MSG
    local hAccel:HACCEL

    mov eax, [hInstance]
    mov [hIns], eax

    invoke CreateMainWindow
    mov [HwndMainWindow], eax
    .if [HwndMainWindow] == 0
        ret
    .endif
    
    invoke LoadAccelerators, [hIns], $CTA0("Accel")
    mov [hAccel], eax
	
    .while TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
            .break .if eax == 0

        invoke TranslateAccelerator, [HwndMainWindow], [hAccel], addr msg
        .if !eax
            invoke TranslateMessage, addr msg
            invoke DispatchMessage, addr msg
        .endif

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
    mov WndClass.lpszMenuName, $CTA0("MainMenu")        ; ��� ������� �������� ����
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
; ������� ��������� ������� ��������
;
UpdateCurrentBitmap proc newBitmap:HBITMAP, hwnd:HWND

    .if [newBitmap]
    
        .if [glCurrentBitmap]
            invoke DeleteObject, glCurrentBitmap
        .endif
        
        mov eax, [newBitmap]
        mov [glCurrentBitmap], eax
        
        invoke InvalidateRect, [hwnd], NULL, TRUE
        
    .endif
    
    ret

UpdateCurrentBitmap endp

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
    local ps:PAINTSTRUCT
    local newBitmap:HBITMAP

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
        
        .if [glCurrentBitmap]
            invoke DrawBitmap, hdc, glCurrentBitmap, 0, 0
        .endif
        
        ; ���������� �����������
        invoke EndPaint, [hwnd], addr ps
        
        xor eax, eax
        ret
        
    .elseif [iMsg] == WM_COMMAND
        ; ������� ����������� ���������
        
        .if word ptr [wParam] == IDM_OPEN
            invoke LoadBmpFile, [hwnd], [hIns]
            mov [newBitmap], eax
            invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            
        .elseif word ptr [wParam] == IDM_OPEN2
            invoke LoadImage, [hIns], $CTA0("Bitmap1"), IMAGE_BITMAP, 0, 0, 0
            mov [newBitmap], eax
            invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
        
        .elseif word ptr [wParam] == IDM_SAVE
            .if [glCurrentBitmap]
                invoke SaveBMPFile, [glCurrentBitmap], [hwnd]
            .endif
            
        .elseif word ptr [wParam] == IDM_INVERT
            .if [glCurrentBitmap]
                invoke InvertBitmap, [glCurrentBitmap]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif
            
        .elseif word ptr [wParam] == IDM_GRAYSTYLE
            .if [glCurrentBitmap]
                invoke GetGraystyleBitmap, [glCurrentBitmap]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif

        .elseif word ptr [wParam] == IDM_INCBRIGHTNESS
            .if [glCurrentBitmap]
                invoke GetMoreBrightBitmap, [glCurrentBitmap]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif
        
        .elseif word ptr [wParam] == IDM_DECBRIGHTNESS
            .if [glCurrentBitmap]
                invoke GetLessBrightBitmap, [glCurrentBitmap]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif

        .elseif word ptr [wParam] == IDM_BLACKANDWHITE
            .if [glCurrentBitmap]
                invoke GetBlackAndWhiteBitmap, [glCurrentBitmap]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif

        .elseif word ptr [wParam] == IDM_REFLECTVERTICAL
            .if [glCurrentBitmap]
                invoke GetReflectVerticalBitmap, [glCurrentBitmap]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif

        .elseif word ptr [wParam] == IDM_REFLECTHORIZONTAL
            .if [glCurrentBitmap]
                invoke GetReflectHorizontalBitmap, [glCurrentBitmap]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif

        .elseif word ptr [wParam] == IDM_TURNLEFT
            .if [glCurrentBitmap]
                invoke GetTurnedLeftBitmap, [glCurrentBitmap]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif

        .elseif word ptr [wParam] == IDM_TURNRIGHT
            .if [glCurrentBitmap]
                invoke GetTurnedRightBitmap, [glCurrentBitmap]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif

         .elseif word ptr [wParam] == IDM_GLUE
            .if [glCurrentBitmap]
                invoke GetGluedBitmap, [glCurrentBitmap], [hwnd], [hIns]
                mov newBitmap, eax
                invoke UpdateCurrentBitmap, [newBitmap], [hwnd]
            .endif

        .endif
        
    .endif
    
    ; �������������� ��������� ������������ � �������
    ; ��������� �� ���������.
    invoke DefWindowProc, hwnd, iMsg, wParam, lParam
    ret

WndProcMain endp

;--------------------

;--------------------


end
