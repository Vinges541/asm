;
; Модуль main.asm.
;
; Демонстрирует пример перемещения фигур на шахматной доске.
;
; Маткин Илья Александрович 01.12.2013
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

; строковая константа с именем окна
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
; Функция создания консоли
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
; Регистрация класса основного окна приложения
;
RegisterClassMainWindow proc

    local WndClass:WNDCLASSEX	; структура класса

    ; заполняем поля структуры
    mov WndClass.cbSize, sizeof (WNDCLASSEX)	; размер структуры класса
    mov WndClass.style, 0
    mov WndClass.lpfnWndProc, WndProcMain		; адрес оконной процедуры класса
    mov WndClass.cbClsExtra, 0
    mov WndClass.cbWndExtra, 0
    mov eax, [hIns]
    mov WndClass.hInstance, eax					; описатель приложения
    invoke LoadIcon, hIns, $CTA0("MainIcon")	; иконка приложения
    mov WndClass.hIcon, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov WndClass.hCursor, eax
    invoke GetStockObject, BLACK_BRUSH			; кисть для фона
    mov WndClass.hbrBackground, eax
    mov WndClass.lpszMenuName, NULL
    mov WndClass.lpszClassName, $CTA0(AppWindowName)	; имя класса
    invoke LoadIcon, hIns, $CTA0("MainIcon")
    mov WndClass.hIconSm, eax

    invoke RegisterClassEx, addr WndClass
    ret

RegisterClassMainWindow endp

;--------------------

;
; Создание основного окна приложения
;
CreateMainWindow proc

    local hwnd:HWND

    ; регистрация класса основного окна
    invoke RegisterClassMainWindow

    ; создание окна зарегестрированного класса
    invoke CreateWindowEx, 
        WS_EX_CONTROLPARENT or WS_EX_APPWINDOW, ; расширенный стиль окна
        $CTA0(AppWindowName),	; имя зарегестрированного класса окна
        $CTA0("Application"),	; заголовок окна
        WS_OVERLAPPEDWINDOW,	; стиль окна
        10,	    ; X-координата левого верхнего угла
        10,	    ; Y-координата левого верхнего угла
        650,    ; ширина окна
        650,    ; высота окна
        NULL,   ; описатель родительского окна
        NULL,   ; описатель главного меню (для главного окна)
        [hIns], ; идентификатор приложения
        NULL
    mov [hwnd], eax
    
    .if [hwnd] == 0
        invoke MessageBox, NULL, $CTA0("Ошибка создания основного окна приложения"), NULL, MB_OK
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
; Функция обработки сообщений главного окна приложения.
; Вызывается системой при поступлении сообщения для главного окна
; с соответствующими параметрами.
;
; Агрументы:
;
; hwnd      описатель окна, получившего сообщение
; iMsg      идентификатор (номер) сообщения
; wParam    параметр сообщения
; lParam    параметр сообщения
;
WndProcMain proc hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

    local hdc:HDC
    local pen:HPEN
    local ps:PAINTSTRUCT

    .if [iMsg] == WM_CREATE
        ; создание окна
        
        ;invoke RegisterClassChessWindow, [hIns]
        invoke InstallFigures, [hwnd]
        
        xor eax, eax
        ret
    .elseif [iMsg] == WM_DESTROY
        ; закрытие окна
        
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .elseif [iMsg] == WM_PAINT
        ; перерисовка окна
        
        ; получаем контекст устройства
        invoke BeginPaint, HwndMainWindow, addr ps
        mov [hdc], eax
        
        ; установить цвет текста
        invoke SetTextColor, [hdc], 255
        
        ; установить цвет фона текста
        invoke SetBkColor, [hdc], 100 + (100 shl 8) + (100 shl 16)
        
        ; создаём объект "перо" для рисования линий
        invoke CreatePen, 
            PS_SOLID,       ; задаём тип линии (сплошная)
            3,              ; толщина линии
            (30 shr 16) + (150 shr 8) + 255 ; цвет линии
        mov [pen],eax
        
        ; ассоциируем созданную кисть с контекстом устройства
        invoke SelectObject, [hdc], [pen]
        
        ; перемещаем текущую позицию, с которой начинается рисование
        invoke MoveToEx,
            [hdc],          ; описатель контекста устройства
            0,              ; X-координата
            75,             ; Y-координата
            NULL
            
        ; рисуем линию выбранной кистью от текущей позиции до указанной точки
        invoke LineTo,
            [hdc],          ; описатель контекста устройства
            1500,           ; X-координата конечной точки
            75              ; Y-координата конечной точки

        ; удаляем созданное "перо"
        invoke DeleteObject, pen
        
        ; завершение перерисовки
        invoke EndPaint, [hwnd], addr ps
        
        xor eax, eax
        ret
    .endif
    
    ; Необработанные сообщения направляются в функцию
    ; обработки по умолчанию.
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
