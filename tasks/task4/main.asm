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

FieldState struct 
	xStart			dword ?		;начало координат по иксу
	yStart			dword ?		;начало координат по игреку
	
	OrdPart			dword ?		;длина полуординаты
	OrdPart1		dword ?		;	
	AbsPart			dword ?		;длина полуабсциссы
	AbsPart1		dword ?		;

	function		dword ?		;идентификатор функции
	function_ptr	qword ?

	count			dword ?		;количество точек
	for_ordinate	dword ?		;поле для определения направления отрисовки отрицательной ветви (используется только в НЕпикслеьном рисовании)
	
	x0_cord			dword ?		;интервал для действий с функцией
	x1_cord			dword ?

FieldState ends

; строковая константа с именем окна
AppWindowName equ <"Graphics">

BT_SQ		equ 204
BT_CUBE		equ 205
BT_HYP		equ 206
BT_SIN		equ 207
BT_COS		equ 208
BT_TG		equ 209
BT_CTG		equ 210
BT_LN		equ 211
BT_LG		equ 212
BT_LOG2		equ 213     

SQX_ID		equ 101
CUBE_ID		equ	102
HYP_ID		equ 103
SIN_ID		equ 104
COS_ID		equ 105
TG_ID		equ 106
CTG_ID		equ 107
LN_ID		equ 108
LG_ID		equ 109
LOG2_ID		equ 110
EMPTY_ID	equ 113

ED_INT_A	equ 240     ; идентификатор текстового поля ввода функции
ED_INT_B	equ 241
ED_INT_SUM	equ 243

;----------------------------------------
; объявление функций

RegisterClassMainWindow proto

CreateMainWindow proto

DrawLine proto hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword

DrawAbscissa proto hdc:HDC, field_ptr:ptr FieldState

DrawOrdinate proto hdc:HDC, field_ptr:ptr FieldState

DrawFunctionByPixel proto hdc:HDC, field_ptr:ptr FieldState

ZoomFunc proto a:dword, b:dword

GetInterval proto field_ptr:ptr FieldState

GetIntSum proto field_ptr:ptr FieldState

WndProcMain proto hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

CreateControlWindowsMain proto hwnd:HWND

InitFieldState proto ptr_field:ptr FieldState

func typedef proto c:qword

sq_func proto c x:qword

cube_func proto c x:qword

hyp_func proto c x:qword

sin_func proto c x:qword

cos_func proto c x:qword

log2_func proto c x:qword

lg_func proto c x:qword

ln_func proto c x:qword

tg_func proto c x:qword

ctg_func proto c x:qword

IntSum proto c a:qword, b:qword, function:qword

;----------------------------------------
; описание данных

.data
mas dq 100 dup (0)
oneth dq 0.001
thousand dq 1000.0

Field FieldState <0,0,0,0,0,0>

.data?
hButtonSQ HWND  ?
hButtonCUBEX HWND  ?
hButtonHYP HWND  ?
hButtonSIN HWND  ?
hButtonCOS HWND  ?
hButtonTG HWND  ?
hButtonCTG HWND  ?
hButtonLN HWND  ?
hButtonLG HWND  ?
hButtonLOG2 HWND  ?

globalf dq ?

glChar dq ?

hIns HINSTANCE ?

HwndMainWindow HWND ?
hEditIntA			HWND ?
hEditIntB			HWND ?
hEditIntSum			HWND ?

.const

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
        WS_SYSMENU,	; стиль окна
        10,	    ; X-координата левого верхнего угла
        10,	    ; Y-координата левого верхнего угла
        960,    ; ширина окна
        700,    ; высота окна
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
;Создание управляющих элементов (контролов) главного окна
CreateControlWindowsMain proc  hwnd:HWND
	
	invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = x^2"), WS_CHILD or WS_VISIBLE , 680, 90, 100, 26, hwnd, BT_SQ, hIns, NULL
    mov [hButtonSQ], rax 
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = x^3"), WS_CHILD or WS_VISIBLE , 800, 90, 100, 26, hwnd, BT_CUBE, hIns, NULL
    mov [hButtonCUBEX], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = 1/x"), WS_CHILD or WS_VISIBLE , 680, 130, 100, 26, hwnd, BT_HYP, hIns, NULL
    mov [hButtonHYP], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = sin(x)"), WS_CHILD or WS_VISIBLE , 800, 130, 100, 26, hwnd, BT_SIN, hIns, NULL
    mov [hButtonSIN], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = cos(x)"), WS_CHILD or WS_VISIBLE , 680, 170, 100, 26, hwnd, BT_COS, hIns, NULL
    mov [hButtonCOS], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = tg(x)"), WS_CHILD or WS_VISIBLE , 800, 170, 100, 26, hwnd, BT_TG, hIns, NULL
    mov [hButtonTG], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = ctg(x)"), WS_CHILD or WS_VISIBLE , 680, 210, 100, 26, hwnd, BT_CTG, hIns, NULL
    mov [hButtonCTG], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = ln(x)"), WS_CHILD or WS_VISIBLE , 800, 210, 100, 26, hwnd, BT_LN, hIns, NULL
    mov [hButtonLN], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = lg(x)"), WS_CHILD or WS_VISIBLE , 680, 250, 100, 26, hwnd, BT_LG, hIns, NULL
    mov [hButtonLG], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = log_2(x)"), WS_CHILD or WS_VISIBLE , 800, 250, 100, 26, hwnd, BT_LOG2, hIns, NULL
    mov [hButtonLOG2], rax
    
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("edit"), NULL, WS_CHILD or WS_VISIBLE or ES_RIGHT, 720, 40, 60, 20, hwnd, ED_INT_A , hIns, NULL
	mov hEditIntA, rax

	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("edit"), NULL, WS_CHILD or WS_VISIBLE or ES_RIGHT, 840, 40, 60, 20, hwnd, ED_INT_B , hIns, NULL
	mov hEditIntB, rax

	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("edit"), NULL, WS_CHILD or WS_VISIBLE or ES_LEFT or ES_READONLY, 680, 610, 220, 30, hwnd, ED_INT_SUM , hIns, NULL
	mov hEditIntSum, rax
           
	ret
CreateControlWindowsMain endp
; Рисует отрезок на контексте устройства с указанными координатами.
;
DrawLine proc frame hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword

    local pen:HPEN
    
    ; создаём объект "перо" для рисования линий
    invoke CreatePen, 
        PS_SOLID,       ; задаём тип линии (сплошная)
        1,              ; толщина линии
        0 + 0 shl 8 + 0 shl 16 ; цвет линии
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
; Рисует ось абсцисс.
DrawAbscissa proc frame hdc:HDC, field_ptr:ptr FieldState

	local startX:dword
	local startY:dword
	local endX:dword
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState 
	
	finit
	fld [rsi].yStart
	fistp [startY]
	
	fld [rsi].xStart
	fld [rsi].AbsPart1 ;отрицательная полуось
	fsubp st(1), st
	fistp [startX]
	
	fld [rsi].xStart
	fld [rsi].AbsPart ;положительная полуось
	faddp st(1), st
	fistp [endX]
	
	

	invoke DrawLine, [hdc], [startX], [startY], [endX], [startY]
    ret
DrawAbscissa endp

; Рисует ось ординат.
DrawOrdinate proc frame hdc:HDC, field_ptr:ptr FieldState
    local startY:dword
    local startX:dword	
	local endY:dword
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState 
	
	finit
	fld [rsi].xStart
	fistp [startX]
	
	fld [rsi].yStart
	fld [rsi].OrdPart1 ;положительная полуось
	fsubp st(1), st
	fistp [startY]
	
	fld [rsi].yStart
	fld [rsi].OrdPart ;отрицательная полуось
	faddp st(1), st
	fistp [endY]

	invoke DrawLine, [hdc], [startX], [startY], [startX], [endY]
    ret
DrawOrdinate endp

DrawFunctionByPixel proc hdc:HDC, field_ptr:ptr FieldState
	local i:qword
	local _arg:qword
	local resfun:qword
	local resfun1:dword
	local x0:dword
	local x0v:qword
	local x1:dword
	local x1v:dword
	local fx1:qword
	local fx0:qword
	local _max:dword
	local _min:dword
	local offsetx:qword
	local offsety:qword
	local a:qword
	local b:qword
	
	local count:dword
	local temp:dword
	local onepartx:qword
	local oneparty:qword
	local halfint:dword
	local halfint1:dword
	
	local startx:dword
	local starty:dword
	local endx:dword
	local endy:dword
	local three:dword
	local one:dword
	
	local ed:dword
	local ed1:dword
	local hun:dword
	local hun1:dword
	local fif:dword
	local six:dword
	
	mov [count], 600.	;ширина области в пикселях
	mov [six], 630.		;х координата границы области
	mov [three], 30.	
	mov [one], 10.		
	mov [ed], 1.
	mov [ed1], -1.
	mov [hun], 10.
	mov [hun1], -10.
	mov [fif], -5.
	
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState
	
	.if [rsi].function == EMPTY_ID
		ret
	.endif
	
	;перегружаем из структуры координаты интервала для задания функции
	xor r10, r10
	mov r10d, [rsi].x0_cord
	mov [x0], r10d
	xor r10, r10
	mov r10d, [rsi].x1_cord
	mov [x1], r10d
	
	
	.if [rsi].function == LOG2_ID || [rsi].function == LG_ID || [rsi].function == LN_ID	
		finit
		fild [x0]
		fldz
		fcom 
		fstsw ax			;переписываем содержимое регистра состояния сопроцессора в AX 
		sahf				;содержимое регистра AH переписываем в регистр флагов
		jnc oper			; если  x0 меньше 0
		jmp exit1
		oper:
		fldz 
		fistp [x0]	
		exit1:
	.endif
	
	mov globalf, 0			; надо
	
	finit
	invoke ZoomFunc, [x0], [x1]
	fstp [offsetx]
		
	fild [x0]
	fstp [a]
	fild [x1]
	fstp [b]
	
	; РАБОТА С ИНТЕРВАЛОМ
	finit
	fld [a]
	fld [b]
	fsub st,st(1)		;получили длину введенного интервала
	fld [count]
	fdiv st, st(1)		;получили длину единичного отрезка
	fstp [onepartx]
	
	fld [a]
	fchs
	fst [halfint]		;длина полуинтервала [a,0]
	fld [onepartx]
	fmulp st(1), st
	fld [one]
	faddp st(1), st
	fstp [rsi].AbsPart1
	
	fld [b]
	fst [halfint1]		;длина полуинтервала [0,b]
	fld [onepartx]
	fmulp st(1), st
	fld [one]
	faddp st(1), st
	fstp [rsi].AbsPart
	
	fld [halfint]
	fld [onepartx]
	fmulp st(1),st		;умножаем длину отрицательного полуинтервала на единичный отрезок, получаем координату центра осей координат по иксу
	fld [three]
	faddp st(1),st
	fstp [rsi].xStart
	
	
	.if [rsi].function == LOG2_ID || [rsi].function == LG_ID || [rsi].function == LN_ID	
			
		finit	
		fld [a]
		fldz
		fcom				;сравнение st(0) c st(1)
		fstsw ax			;переписываем содержимое регистра состояния сопроцессора в AX 
		sahf				;содержимое регистра AH переписываем в регистр флагов
		jz l				; если  a меньше 0, то
		jmp exit2 
		
		l:	
		fld [a]
		fld [offsetx]
		faddp st(1), st
		fst [a]
		exit2:
	.endif
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState	
	lea rax, [rsi].function_ptr
	assume rax:nothing
	;для х^2-просто считаем значение функции в границах интервала
	invoke (func ptr[rax]), [a]		;вызвали функцию
	fstp [fx0]			;выгрузили результат функции из стека в локальную переменную
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState	
	lea rax, [rsi].function_ptr
	assume rax:nothing
	invoke (func ptr[rax]), [b]		;вызвали функцию
	fstp [fx1]			;выгрузили результат функции из стека в локальную переменную
		
	fld [fx0]		;fx0 - максимум
	fstp [_max]
		
	fld [fx0]
	fld [fx1]
	fcom
	xor rax,rax
	fstsw ax			;переписываем содержимое регистра состояния сопроцессора в AX 
	sahf				;содержимое регистра AH переписываем в регистр флагов
	jnc dem				; если  fx0 меньше fx1
	jmp demend
	
	dem:
	fld [fx1]			; если  fx0 меньше fx1, то fx1 -максимум
	fstp [_max]			;максимум - наибольшее координатное значение функции на указанном отрезке (НЕ ПИКСЕЛЬНОЕ!)
	
	demend:
	.if [rsi].function == SQX_ID 	
		fldz
		fstp [_min] ;это только в случае параболы от нуля до максимума!
	.elseif [rsi].function == CUBE_ID || [rsi].function == LOG2_ID \
	|| [rsi].function == LG_ID || [rsi].function == LN_ID
		fld [fx0]
		fstp [_min]
	.elseif [rsi].function == SIN_ID || [rsi].function == COS_ID
		fld [ed]
		fstp [_max]
		fld [ed1]
		fstp [_min]
	.elseif [rsi].function == TG_ID ||	[rsi].function == CTG_ID || [rsi].function == HYP_ID
		fld [hun]
		fstp [_max]
		fld [hun1]
		fstp [_min]
	.endif
	mov globalf, 1	; костылище,чтобы заработал логарифм
	invoke ZoomFunc, [_min], [_max]
	fstp [offsety]
	
	;РАБОТА С ОСЬЮ У
	
	fld [_max]
	fld [_min]
	fsubp st(1), st
	fld [count]
	fdiv st, st(1)
	fstp [oneparty]
	
	
	fld [_max]
	fstp [halfint1]
	
	fld [halfint1]
	fld [oneparty]
	fmulp st(1), st
	fld [three]
	faddp st(1), st
	fstp [rsi].yStart
	
	fld [halfint1]
	fld [oneparty]
	fmulp st(1), st
	fld [one]	
	faddp st(1), st
	fstp [rsi].OrdPart1	;положительная полуось
	
	fld [_min]
	fchs
	fld [oneparty]
	fmulp st(1), st
	fld [one]	
	faddp st(1), st
	fstp [rsi].OrdPart ;отрицательная полуось
	
	fild [x0]
	fstp [x0v]
	
	.if [rsi].function == LOG2_ID || [rsi].function == LG_ID || [rsi].function == LN_ID	
	
		fld [x0v]
		fld [offsetx]
		faddp st(1), st
		fstp [x0v]
		
	.endif
		
	
	fld [x0v]
	fld [offsetx]				;текущее х=(х/offset_x)+330
	fdivp st(1), st
	fld [rsi].xStart
	faddp st(1), st	
	fstp [startx]
	
		
	fld [fx0] 
	fld [_min]	
	fsubp st(1), st
	fld [offsety]
	fdivp st(1),st
	fld [six]
	fsub st, st(1)
	fstp [starty]
	
	mov [i], 0
	
	cycle:
		finit
		fld i
		fld [offsetx]
		fmulp st(1), st	;i*offset_x
		fld [x0v]
		faddp st(1), st ; x0+i*offset_x
		fstp [_arg]		;получили аргумент для вызова функции
		lea rax, [rsi].function_ptr
		assume rax:nothing
		invoke (func ptr[rax]), [_arg]		;вызвали функцию
		fst [resfun]			;выгрузили результат функции из стека в локальную переменную
		
		fld [resfun]
		fld [_min]
		fsubp st(1), st
		fst [temp]
		fld [offsety]
		fdivp st(1),st
		fst [resfun1]
		fld [six]
		fsub st, st(1)
		fstp [resfun1]
		
		fld [_arg]
		fld [offsetx]
		fdivp st(1), st
		fld [rsi].xStart
		faddp st(1), st
		fistp [endx]
	
		fld [startx]
		fistp [startx]
		fld [starty]
		fistp [starty]

		fld [resfun1]
		fistp [endy]
		
		invoke DrawLine, [hdc], [startx], [starty], [endx], [endy]
		
		fild [endx]
		fstp [endx]
		mov r9d, [endx]
		mov [startx], r9d
		
		fild [endy]
		fstp [endy]
		mov r9d, [endy]
		mov [starty], r9d
		
		fld i				;загрузили i
		fld1				;загрузили единицу
		fadd st,st(1)		;инкрементировали
		fst i				;выгрузили i
		
		fld [count]
		fcom				;сравнение st(0) c st(1)
		fstsw ax			;переписываем содержимое регистра состояния сопроцессора в AX 
		sahf				;содержимое регистра AH переписываем в регистр флагов
		jnc cycle			; если  i меньше result, то повторяем цикл

	ret
DrawFunctionByPixel endp
;---------------------------------------------
;Сопроцессорные функции арифметических вычислений
;---------------------------------------------
;Функция вычисления квадрата числа
sq_func proc c x:qword
			
	finit					;инициализация сопроцессора
	fld x					;загрузка вещественного числа из ячейки памяти x1 в st(0)
	fld x

	fmul st,st(1)			;умножение с записью результата в st(0)
	
	ret
sq_func endp 

;Функция вычисления куба числа
cube_func proc c x:qword
			
	finit					;инициализация сопроцессора
	fld x					;загрузка вещественного числа из ячейки памяти x1 в st(0)
	fld x
	fmul st,st(1)			;умножение с записью результата в st(0)	
	fld x
	fmul st,st(1)			;умножение с записью результата в st(0)	

	ret
cube_func endp

;функция вычисления обратно пропорциональной зависимости
hyp_func proc c x:qword
	finit
	fld1
	fld x
	
	fdiv

	ret
hyp_func endp

;функция вычисления синуса
sin_func proc c x:qword

	finit
	fld x

	fsin

	ret
sin_func endp

;функция вычисления косинуса
cos_func proc c x:qword
	
	finit
	fld x

	fcos

	ret
cos_func endp

;функция вычисления логарифма по основанию 2
log2_func proc c x:qword
;логарифм вычисляется только для х>=0
	finit 
		
	fld1
	fld x
	fyl2x

	ret
log2_func endp

lg_func proc c x:qword
	finit
	invoke log2_func, x
	
	fldl2t

	;log_10(x) = log_2(x)/log_2(10)
	fdivp st(1), st	
	
	ret
lg_func endp

ln_func proc c x:qword
	finit
	invoke log2_func, x

	fldln2

	;log_2(x) * log_e(x) = log_e(x) * log_2(2) = log_e(x)
	fmul st, st(1) 
	
	ret
ln_func endp

;функция вычисления тангенса
tg_func proc c x:qword
	local temp:qword
	
	finit 
	fld x
	fptan
	fstp [temp] ; можно заменить на fincstp	
	ret
tg_func endp

;функция вычисления котангенса
ctg_func proc c x:qword
	local res:qword
	
	finit
	invoke tg_func, x
	fstp [res]

	fld [res]
	fld1
	fdiv st, st(1)
	fst [res]

	ret
ctg_func endp

IntSum proc c a:qword, b:qword, function:qword
	local i:qword
	local sum:qword
	
	local result:qword
	local fun:qword
	
	
	finit					;инициализация 
	fld [b]
	fld [a]
	
	fsub st(1),st			; вычитание st(i) = st(i) - st(0)
	
	fld thousand
	fmul st,st(2)
	fst result				;Получение результата - счетчика

	fldz					;нуль
	fst i					;инициализация i нулем
	fst sum					;инициализация sum нулем
	finit
	Cy:						;цикл
		finit
		fld i
		fld oneth
		fmul st,st(1)
		fld a
		fadd st,st(1)
		fst fun				;посчитали аргумент вызываемой функции fun(a+i*0.001)
		
		lea rax, function	;загрузили указатель на функцию,указанную в аргументах
		assume rax:nothing
		
		invoke (func ptr[rax]), fun		;вызвали функцию

		fld oneth
		fmul st,st(1)		;посчитали площадь фрагмента
		
		fld sum				;загрузили интегральную сумму
		fadd st, st(1)		;прибавили
		fst sum				;записали интегральную сумму
		
		finit
		
		fld i				;загрузили i
		fld1				;загрузили единицу
		fadd st,st(1)		;инкрементировали
		fst i				;выгрузили i
		
		fld result 
		fcom				;сравнение st(0) c st(1)
		fstsw ax			;переписываем содержимое регистра состояния сопроцессора в AX 
		sahf				;содержимое регистра AH переписываем в регистр флагов
		jnc Cy				; если  i меньше result, то повторяем цикл
		
		fld sum
		
	ret
IntSum endp

;--------------------
;ФУНКЦИЯ масштабирования по оси
ZoomFunc proc a:dword, b:dword
	local _a:qword
	local _b:qword
	local wid:qword
	local temp:qword
	local temp1:qword

	;аргументы в функцию поступили целые, поэтому выполняем приведение к вещественному представлению
	
	.if globalf == 1
		fld [a]
		fstp [_a]
		fld [b]
		fstp [_b]
	.elseif globalf == 0
		fild [a]
		fstp [_a]
		fild [b]
		fstp [_b]
	.endif
	
	

	mov [wid], 600;длина области для рисования графика
	finit 
	fld [_a]
	fld [_b]
	fsub st,st(1)
	fstp [temp];получили длину введенного отрезка


	fild [wid]
	fld [temp]
	fdiv st, st(1)
	fst [temp1];получили долю одного пикселя в общей длине отрезка

	ret
ZoomFunc endp

InitFieldState proc frame ptr_field:ptr FieldState
	mov rsi, ptr_field
	assume rsi:ptr FieldState
	
	mov Field.function, EMPTY_ID
	mov Field.x0_cord, 0
	mov Field.x1_cord, 0
			
	mov Field.xStart, 330.
	mov Field.yStart, 330.
	
	mov Field.OrdPart, 310.
	mov Field.OrdPart1, 310.
	mov Field.AbsPart, 310.
	mov Field.AbsPart1, 310.
	
	lea rax, log2_func
	mov Field.function_ptr, rax
	
	
	ret
InitFieldState endp

GetInterval proc field_ptr:ptr FieldState
	local string:qword
	local stringlen:dword
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState 
	
	xor rax, rax
	invoke GetWindowTextLength, hEditIntA	
	mov [stringlen], eax					
	inc [stringlen]							
	invoke malloc, [stringlen]
	mov [string], rax
	invoke GetWindowText, hEditIntA, [string], [stringlen]
	
	invoke atoi, string
	mov [rsi].x0_cord, eax
	
	invoke free, string
	
	xor rax, rax
	invoke GetWindowTextLength, hEditIntB	
	mov [stringlen], eax					
	inc [stringlen]							
	invoke malloc, [stringlen]
	mov [string], rax
	invoke GetWindowText, hEditIntB, [string], [stringlen]
	
	invoke atoi, string
	mov [rsi].x1_cord, eax
	
	invoke free, string	
	
	ret
GetInterval endp

GetIntSum proc frame field_ptr:ptr FieldState
	local string:qword
	local sum:qword
	local a:qword
	local b:qword
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState
	
	.if [rsi].function_ptr != NULL
		finit
		
		fild [rsi].x0_cord
		fstp [a]
		fild [rsi].x1_cord
		fstp [b]
		
		invoke IntSum, [a], [b], [rsi].function_ptr
		fstp [sum]		
		invoke malloc, 50
		mov string, rax

		invoke sprintf, string, $CTA0("%f"), [sum]
		
		invoke SetWindowText, hEditIntSum, string
		
		invoke free, string
	.else
		invoke SetWindowText, hEditIntSum, $CTA0("NONE")
		
	.endif

	ret
GetIntSum endp

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
    local white_brush:HBRUSH
    local color_brush:COLORREF

    .if [iMsg] == WM_CREATE
        ; создание окна
        invoke CreateControlWindowsMain, hwnd
		invoke InitFieldState, addr Field
		
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
        
    .elseif [iMsg] == WM_COMMAND

        movzx eax, word ptr [wParam]

		push rax
		.if  eax == BT_SQ || eax == BT_CUBE || eax == BT_HYP \
		|| eax == BT_SIN || eax == BT_COS || eax == BT_TG \
		|| eax == BT_CTG || eax == BT_LN || eax == BT_LG \
		|| eax == BT_LOG2
			invoke GetInterval, addr Field
		.endif
		pop rbx
        .if ebx == BT_SQ
			mov Field.function, SQX_ID
			lea rax, sq_func
		.elseif ebx == BT_CUBE	
			mov Field.function, CUBE_ID
			lea rax, cube_func	
		.elseif ebx == BT_HYP	
			mov Field.function, HYP_ID
			lea rax, hyp_func
		.elseif ebx == BT_SIN	
			mov Field.function, SIN_ID
			lea rax, sin_func
		.elseif ebx == BT_COS	
			mov Field.function, COS_ID
			lea rax, cos_func
		.elseif ebx == BT_TG
			mov Field.function, TG_ID
			lea rax, tg_func
		.elseif ebx == BT_CTG	
			mov Field.function, CTG_ID
			lea rax, ctg_func
		.elseif ebx == BT_LN	
			mov Field.function, LN_ID
			lea rax, ln_func 
		.elseif ebx == BT_LG
			mov Field.function, LG_ID
			lea rax, lg_func
		.elseif ebx == BT_LOG2	
			mov Field.function, LOG2_ID
			lea rax, log2_func
		.endif

		.if  ebx == BT_SQ || ebx == BT_CUBE || ebx == BT_HYP \
		|| ebx == BT_SIN || ebx == BT_COS || ebx == BT_TG \
		|| ebx == BT_CTG || ebx == BT_LN || ebx == BT_LG \
		|| ebx == BT_LOG2
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE
		.endif

        ret
        
    .elseif [iMsg] == WM_PAINT
        ; перерисовка окна
        
        ; получаем контекст устройства
        invoke BeginPaint, HwndMainWindow, addr ps
        mov [hdc], rax
        
        ; установить цвет текста
        invoke SetTextColor, [hdc], 255 + (255 shl 8) + (255 shl 16)
        
        ; установить цвет фона текста
        invoke SetBkColor, [hdc], 0 + (0 shl 8) + (0 shl 16)
        
        ;создаем кисти нужного цвета
		mov [color_brush], 255 + 255 shl 8 + 255 shl 16
        invoke CreateSolidBrush, [color_brush]
        mov [white_brush], rax
        
        ;устанавливаем белую кисть по умолчанию
        invoke SelectObject, [hdc], white_brush           
        
        invoke Rectangle, [hdc], 20, 20, 640, 640  
        
         ; вывод текста на контекст устройства
        invoke TextOut, [hdc], 680, 20, $CTA0("Введите интервал:"), 17
        invoke TextOut, [hdc], 680, 45, $CTA0("A:"), 2
		invoke TextOut, [hdc], 800, 45, $CTA0("B:"), 2
		invoke TextOut, [hdc], 680, 65, $CTA0("Выберите функцию...:"), 20
		invoke TextOut, [hdc], 680, 580, $CTA0("Значение интеграла:"), 19

		invoke DrawFunctionByPixel, [hdc], addr Field
        
        .if Field.function == EMPTY_ID || Field.function == CUBE_ID || Field.function == SIN_ID \
		|| Field.function == COS_ID || Field.function == TG_ID || Field.function == CTG_ID \
		|| Field.function == HYP_ID || Field.function == SQX_ID || Field.function == LOG2_ID \
		|| Field.function == LG_ID || Field.function == LN_ID
			invoke DrawAbscissa, [hdc], addr Field
			invoke DrawOrdinate, [hdc], addr Field
        .endif
                
        ; завершение перерисовки
        invoke EndPaint, [hwnd], addr ps
        
        xor rax, rax
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
