;
; Модуль main.asm.
;
; Пример рисования пустого графика под Win64.
;
; Маткин Илья Александрович     04.12.2013
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

; строковая константа с именем окна
AppWindowName equ <"Application">

ED_1 equ 201     ; идентификатор верхнего текстового поля
ED_2 equ 202     ; идентификатор нижнего текстового поля
ST_1 equ 203     ; идентификатор статического окна
BT_1 equ 204     ; идентификатор кнопки

;----------------------------------------
; объявление функций

RegisterClassMainWindow proto

CreateMainWindow proto

DrawLine proto hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword

DrawAbscissa proto hdc:HDC, startX:dword, startY:dword, endX:dword

DrawOrdinate proto hdc:HDC, startX:dword, startY:dword, endY:dword

WndProcMain proto hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

;----------------------------------------
; описание данных

.data


.data?

glChar dq ?

hIns HINSTANCE ?

HwndMainWindow HWND ?

.const
text db "Hello, World!",0
caption db "Info",0


;----------------------------------------
; описание функций

.code

;
; Основная функция оконных приложений
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
	
	; Основной цикл обработки сообщений
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
; Регистрация класса основного окна приложения
;
RegisterClassMainWindow proc frame

    local WndClass:WNDCLASSEX	; структура класса

    ; заполняем поля структуры
    mov WndClass.cbSize, sizeof (WNDCLASSEX)    ; размер структуры класса
    mov WndClass.style, 0
    mov rax, offset WndProcMain
    mov WndClass.lpfnWndProc,  rax              ; адрес оконной процедуры класса
    mov WndClass.cbClsExtra, 0
    mov WndClass.cbWndExtra, 0                  ; размер дополнительной памяти окна
    mov rax, [hIns]
    mov WndClass.hInstance, rax	                ; описатель приложения
    invoke LoadIcon, hIns, $CTA0("MainIcon")    ; иконка приложения
    mov WndClass.hIcon, rax
    invoke LoadCursor, NULL, IDC_ARROW
    mov WndClass.hCursor, rax
    invoke GetStockObject, BLACK_BRUSH          ; кисть для фона
    mov WndClass.hbrBackground, rax
    mov WndClass.lpszMenuName, NULL
    mov rax, $CTA0(AppWindowName)
    mov WndClass.lpszClassName, rax             ; имя класса
    invoke LoadIcon, hIns, $CTA0("MainIcon")
    mov WndClass.hIconSm, rax

    invoke RegisterClassEx, addr WndClass
    ret

RegisterClassMainWindow endp

;--------------------

;
; Создание основного окна приложения
;
CreateMainWindow proc frame

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
    mov [hwnd], rax
    
    .if [hwnd] == 0
        invoke MessageBox, NULL, $CTA0("Ошибка создания основного окна приложения"), NULL, MB_OK
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
; Рисует отрезок на контексте устройства с указанными координатами.
;
DrawLine proc frame hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword

    local pen:HPEN
    
    ; создаём объект "перо" для рисования линий
    invoke CreatePen, 
        PS_SOLID,       ; задаём тип линии (сплошная)
        2,              ; толщина линии
        (30 shl 16) + (150 shl 8) + 255 ; цвет линии
    mov [pen], rax
    
    ; ассоциируем созданную кисть с контекстом устройства
    invoke SelectObject, [hdc], [pen]
    
    ; перемещаем текущую позицию, с которой начинается рисование
    invoke MoveToEx,
        [hdc],          ; описатель контекста устройства
        startX,         ; X-координата
        startY,         ; Y-координата
        NULL
        
    ; рисуем линию выбранной кистью от текущей позиции до указанной точки
    invoke LineTo,
        [hdc],          ; описатель контекста устройства
        endX,           ; X-координата конечной точки
        endY            ; Y-координата конечной точки

    ; удаляем созданное "перо"
    invoke DeleteObject, pen

    ret

DrawLine endp


;--------------------

;
; Рисует ось абсцисс.
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
; Рисует ось ординат.
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
WndProcMain proc frame hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

    local hdc:HDC
    local ps:PAINTSTRUCT

    ;and esp, 0FFFFFFF0h

    .if [iMsg] == WM_CREATE
        ; создание окна
        
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_DESTROY
        ; уничтожение окна
        
        invoke PostQuitMessage, 0
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_SIZE
        ; изменение размера
        
    .elseif [iMsg] == WM_SETFOCUS
        ; получение фокуса
        
    .elseif [iMsg] == WM_CLOSE
        ; закрытие окна
        
    .elseif [iMsg] == WM_QUIT
        ; завершение приложения
        
    .elseif [iMsg] == WM_KEYDOWN
        ;нажание клавиши
        
        .if wParam == VK_SHIFT
        .endif
        
    .elseif [iMsg] == WM_CHAR
        ; ввод с клавиатуры
        
    .elseif [iMsg] == WM_PAINT
        ; перерисовка окна
        
        ; получаем контекст устройства
        invoke BeginPaint, HwndMainWindow, addr ps
        mov [hdc], rax
        
        ; установить цвет текста
        invoke SetTextColor, [hdc], 255
        
        ; установить цвет фона текста
        invoke SetBkColor, [hdc], 100 + (100 shl 8) + (100 shl 16)
        
        ; вывод текста на контекст устройства
        invoke TextOut, [hdc], 200, 10, $CTA0("Пустой график"), 13
        
        ;invoke DrawLine, [hdc], 0, 75, 1500, 75
        
        invoke DrawAbscissa, [hdc], 10, 500, 600
        invoke DrawOrdinate, [hdc], 10, 500, 100
        
        ; завершение перерисовки
        invoke EndPaint, [hwnd], addr ps
        
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_COMMAND

        movzx eax, word ptr [wParam]
        .if eax == BT_1
        .endif
        ret
        
    .endif
    
    ; Необработанные сообщения направляются в функцию
    ; обработки по умолчанию.
    invoke DefWindowProc, hwnd, iMsg, wParam, lParam
    ret

WndProcMain endp

;--------------------
;--------------------


end
