;
; Модуль main.asm.
;
; Шаблон оконного приложения
;
; Маткин Илья Александрович 16.10.2013
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

; строковая константа с именем окна
AppWindowName equ <"Application">

;----------------------------------------


.data


.data?

hIns HINSTANCE ?

HwndMainWindow HWND ? ;; описатель главного окна
HwndEdit1 HWND ? ;          ; описатель верхнего текстового поля
HwndStatic1 HWND ? ;        ; описатель статического окна (надписи)

glWindowMainWidth ULONG ?;  ; ширина главного окна
glWindowMainHeight ULONG ?; ; высота главного окна

.const

ED_1 dd 201     ; идентификатор верхнего текстового поля
ST_1 dd 202     ; идентификатор статического окна

.code

;----------------------------------------

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
; Регистрация класса основного окна приложения
;
RegisterClassMainWindow proc

    local WndClass:WNDCLASSEX	; структура класса

    ; заполняем поля структуры
    mov WndClass.cbSize, sizeof (WNDCLASSEX)	; размер структуры класса
    mov WndClass.style, CS_DBLCLKS
    mov WndClass.lpfnWndProc, WndProcMain		; адрес оконной процедуры класса
    mov WndClass.cbClsExtra, 0
    mov WndClass.cbWndExtra, 0
    mov eax, [hIns]
    mov WndClass.hInstance, eax					; описатель приложения
    invoke LoadIcon, hIns, $CTA0("MainIcon")	; иконка приложения
    mov WndClass.hIcon, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov WndClass.hCursor, eax
    invoke GetStockObject, WHITE_BRUSH			; кисть для фона
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
        $CTA0("Mouse example"),	; заголовок окна
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
; Создание управляющих элементов (контролов) главного окна
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
        
        xor eax, eax
        ret
    .elseif [iMsg] == WM_DESTROY
        ; закрытие окна
        
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .elseif [iMsg] == WM_SIZE
        invoke ProcessingSizeEvent, hwnd, iMsg, wParam, lParam
        ret
    .endif
    
    ; Необработанные сообщения направляются в функцию
    ; обработки по умолчанию.
    invoke DefWindowProc, hwnd, iMsg, wParam, lParam
    ret

WndProcMain endp

;--------------------
; Функция обработки события изменения главного окна
;
ProcessingSizeEvent proc hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM
	local nWidth:DWORD
	local nHeight:DWORD
	; младшее слово параметра lParam содержит новую ширину окна
	mov eax, lParam
	and eax, 0FFFFh
    mov glWindowMainWidth, eax;
    ; старшее - высоту
	mov eax, lParam
	and eax, 0FFFF0000h
    mov glWindowMainHeight, eax;

	mov eax, glWindowMainWidth
	mov nWidth, eax
	sub nWidth, 20

	mov eax, glWindowMainHeight
	mov nHeight, eax
	sub nHeight, 120
	shr nHeight, 1
    ; изменяем размер текстового поля пропорционально размерам главного окна
    invoke MoveWindow,
               HwndEdit1,   ; описатель перемещаемого окна
               10,          ; Х-координата левого верхнего угла
               100,         ; У-координата левого верхнего угла
               nWidth,    ; ширина
               nHeight,  ; высота
               TRUE         ; флаг необходимости перерисовки
    xor eax, eax
	ret;
ProcessingSizeEvent endp
;--------------------

; Функция добавляет строку в конец текстового поля.
;
InsertStringTailEdit proc string:DWORD

    local offset_:DWORD;

    ; получаем длину текста в нижнем окне
    invoke GetWindowTextLength, HwndEdit1;
    mov offset_, eax
    ; перемещаем курсор в конец текста
    invoke SendMessage, HwndEdit1, EM_SETSEL, offset_, offset_;

    ; посылаем строку
    invoke SendMessage, HwndEdit1, EM_REPLACESEL, 0, string;

    ret;
InsertStringTailEdit endp

end
