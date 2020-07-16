;
; ������ main.asm.
;
; ������������� ������ ����������� ����� �� ��������� �����.
;
; ������ ���� ������������� 01.12.2013
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
include chess.inc

;----------------------------------------

FILE struct
    _ptr    DWORD       ?
    _cnt    DWORD       ?
    _base   DWORD       ?
    _flag   DWORD       ?
    _file   DWORD       ?
    _charbuf DWORD      ?
    _bufsiz DWORD       ?
    _tmpfname DWORD     ?
FILE ends

__iob_func proto c

_O_TEXT equ 4000h

_IONBF  equ 0004h

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

ShowFigures proto hwnd:HWND

InstallFigures proto hwnd:HWND

;----------------------------------------

;
; ������� �������� �������
;
CreateExtraConsole proc stdcall

    local stdin:DWORD
    local stdout:DWORD
    local stderr:DWORD

    invoke AllocConsole
    .if eax == 0
        ret
    .endif

    invoke __iob_func
    mov [stdin], eax
    add eax, sizeof (FILE)
    mov [stdout], eax
    add eax, sizeof (FILE)
    mov [stderr], eax
    
    invoke SetConsoleTitle, $CTA0("Debug console")
    
    invoke GetStdHandle, STD_INPUT_HANDLE
    invoke crt__open_osfhandle, eax, _O_TEXT
    invoke crt__fdopen, eax, $CTA("r\0")
    invoke crt_memcpy, [stdin], eax, sizeof (FILE)
    
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    invoke crt__open_osfhandle, eax, _O_TEXT
    invoke crt__fdopen, eax, $CTA("w\0")
    invoke crt_memcpy, [stdout], eax, sizeof (FILE)
    
    invoke GetStdHandle, STD_ERROR_HANDLE
    invoke crt__open_osfhandle, eax, _O_TEXT
    invoke crt__fdopen, eax, $CTA("w\0")
    invoke crt_memcpy, [stderr], eax, sizeof (FILE)
    
    invoke crt_setvbuf, [stdout], NULL, _IONBF, 0
    .if eax
        xor eax, eax
        ret
    .endif
    
    invoke crt_setvbuf, [stderr], NULL, _IONBF, 0
    .if eax
        xor eax, eax
        ret
    .endif
    
    mov eax, 1
    ret

CreateExtraConsole endp

;--------------------

WinMain proc stdcall hInstance:HINSTANCE, hPrevInstance:HINSTANCE, szCmdLine:PSTR, iCmdShow:DWORD

    local msg: MSG

    mov eax, [hInstance]
    mov [hIns], eax

    invoke CreateExtraConsole
    invoke crt_printf, $CTA("Hello, World\n\0")

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
        
        ;invoke RegisterClassChessWindow, [hIns]
        invoke InstallFigures, [hwnd]
        
        xor eax, eax
        ret
    .elseif [iMsg] == WM_DESTROY
        ; �������� ����
        
        invoke PostQuitMessage, 0
        xor eax, eax
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
        
        ; ������ ������ "����" ��� ��������� �����
        invoke CreatePen, 
            PS_SOLID,       ; ����� ��� ����� (��������)
            3,              ; ������� �����
            (30 shr 16) + (150 shr 8) + 255 ; ���� �����
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

ShowFigures proc hwnd:HWND

    local i:dword
    local j:dword
    local cur_i:dword
    local cur_j:dword

    mov [i], 0
    .while [i] < 8
        mov [j], 0
        .while [j] <8
            mov eax, i
            imul eax, 50
            add eax, 100 + 25
            mov [cur_i], eax
            mov eax, j
            imul eax, 50
            add eax, 100 + 25
            mov [cur_j], eax
            invoke CreateChessWindow, [hIns], [hwnd], COLOR_WHITE, [cur_j], [cur_i], FIG_KING
            inc [j]
        .endw
        inc [i]
    .endw
    
    ;CreateChessWindow(hIns,hwnd,figures[i][j].color,100+j*50+25,100+i*50+25,figures[i][j].type);
    
    ret
    
ShowFigures endp

;--------------------

InstallFigures proc hwnd:HWND

    invoke ShowFigures, [hwnd]

    ret
    
InstallFigures endp

;--------------------
;--------------------
;--------------------

end
