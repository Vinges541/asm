;
; Модуль main.asm.
;
; Пример отображения картинок
;
; Маткин Илья Александрович     12.11.2013
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

; строковая константа с именем окна
AppWindowName equ <"Application">

IDM_OPEN        equ 201
IDM_OPEN2       equ 202
IDM_SAVE        equ 203
IDM_INVERT      equ 204
IDM_GRAYSTYLE   equ 205

;----------------------------------------


.data

glChar dd 0

.data?

hIns HINSTANCE ?

glCurrentBitmap HBITMAP ?   ; описатель картинки

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
    mov WndClass.lpszMenuName, $CTA0("MainMenu")        ; имя ресарса главного меню
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
; Функция обновляет текущую картинку
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
    local ps:PAINTSTRUCT
    local newBitmap:HBITMAP

    .if [iMsg] == WM_CREATE
        ; создание окна
        
        xor eax, eax
        ret
        
    .elseif [iMsg] == WM_DESTROY
        ; закрытие окна
        
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
        
    .elseif [iMsg] == WM_CHAR
        ; ввод с клавиатуры
        
        mov eax, [wParam]
        mov [glChar], eax
        xor eax, eax
        invoke InvalidateRect, hwnd, NULL, TRUE
        ret
        
    .elseif [iMsg] == WM_PAINT
        ; перерисовка окна
        
        ; получаем контекст устройства
        invoke BeginPaint, HwndMainWindow, addr ps
        mov [hdc], eax
        
        .if [glCurrentBitmap]
            invoke DrawBitmap, hdc, glCurrentBitmap, 0, 0
        .endif
        
        ; завершение перерисовки
        invoke EndPaint, [hwnd], addr ps
        
        xor eax, eax
        ret
        
    .elseif [iMsg] == WM_COMMAND
        ; команды управляющих элементов
        
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
        
        .endif
        
    .endif
    
    ; Необработанные сообщения направляются в функцию
    ; обработки по умолчанию.
    invoke DefWindowProc, hwnd, iMsg, wParam, lParam
    ret

WndProcMain endp

;--------------------

;--------------------


end
