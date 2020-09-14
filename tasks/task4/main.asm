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

field struct
	start_coord		dword ?
	end_coord		dword ?
	center_coord	dword ?

	a				dword ?
	b				dword ?
	function		dword ?
	function_ptr	qword ?

	y				real8 ?		;для x^y

field ends

AppWindowName	equ <"Graphics">

BT_EXP			equ 206
BT_SIN			equ 207
BT_COS			equ 208
BT_TG			equ 209
BT_CTG			equ 210
BT_LN			equ 211
BT_LG			equ 212
BT_LOG2			equ 213     

EXP_ID			equ 103
SIN_ID			equ 104
COS_ID			equ 105
TG_ID			equ 106
CTG_ID			equ 107
LN_ID			equ 108
LG_ID			equ 109
LOG2_ID			equ 110
EMPTY_ID		equ 113

ED_EXP			equ 239
ED_INT_A		equ 240
ED_INT_B		equ 241
ED_INT_SUM		equ 243

;----------------------------------------
; Прототипы функций

RegisterClassMainWindow proto

CreateMainWindow proto

DrawLine proto hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword

DrawAxis proto hdc:HDC, field_ptr:ptr field

DrawFunctionByPixel proto hdc:HDC, field_ptr:ptr field

ZoomFunc	proto a:dword, b:dword

GetInterval proto field_ptr:ptr field

GetIntSum	proto field_ptr:ptr field

WndProcMain proto hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

CreateControlWindowsMain proto hwnd:HWND

InitFieldState	proto ptr_field:ptr field

unary_function	typedef proto c:real8

binary_function typedef proto c:real8, :real8

exp				proto c x:real8, y:real8

sin				proto c x:real8

cos				proto c x:real8

log2			proto c x:real8

lg				proto c x:real8

ln				proto c x:real8

tg				proto c x:real8

ctg				proto c x:real8

IntSum proto c a:real8, b:real8, function:qword

;----------------------------------------

.data
thousandth		real8		0.001
thousand		real8		1000.0

.data?
Field			field		<>
hButtonEXP		HWND		?
hButtonSIN		HWND		?
hButtonCOS		HWND		?
hButtonTG		HWND		?
hButtonCTG		HWND		?
hButtonLN		HWND		?
hButtonLG		HWND		?
hButtonLOG2		HWND		?

hIns			HINSTANCE	?

HwndMainWindow	HWND		?
hEditExp		HWND		?
hEditIntA		HWND		?
hEditIntB		HWND		?
hEditIntSum		HWND		?

.const


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
	  
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("x^"), WS_CHILD or WS_VISIBLE, 680, 90, 20, 26, hwnd, BT_EXP, hIns, NULL
    mov hButtonEXP, rax

	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("edit"), NULL, WS_CHILD or WS_VISIBLE or ES_LEFT, 700, 90, 80, 26, hwnd, ED_EXP , hIns, NULL
	mov hEditExp, rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("sin(x)"), WS_CHILD or WS_VISIBLE , 800, 90, 100, 26, hwnd, BT_SIN, hIns, NULL
    mov hButtonSIN, rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("cos(x)"), WS_CHILD or WS_VISIBLE , 680, 130, 100, 26, hwnd, BT_COS, hIns, NULL
    mov hButtonCOS, rax
    
    ;invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("tg(x)"), WS_CHILD or WS_VISIBLE , 800, 130, 100, 26, hwnd, BT_TG, hIns, NULL
    ;mov hButtonTG, rax
    
    ;invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("ctg(x)"), WS_CHILD or WS_VISIBLE , 680, 170, 100, 26, hwnd, BT_CTG, hIns, NULL
    ;mov hButtonCTG, rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("ln(x)"), WS_CHILD or WS_VISIBLE , 800, 170, 100, 26, hwnd, BT_LN, hIns, NULL
    mov hButtonLN, rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("lg(x)"), WS_CHILD or WS_VISIBLE , 680, 210, 100, 26, hwnd, BT_LG, hIns, NULL
    mov hButtonLG, rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("log_2(x)"), WS_CHILD or WS_VISIBLE , 800, 210, 100, 26, hwnd, BT_LOG2, hIns, NULL
    mov hButtonLOG2, rax
    
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
; Рисует оси.
DrawAxis proc frame hdc:HDC, field_ptr:ptr field

	mov rsi, field_ptr
	assume rsi:ptr field 
	
	invoke DrawLine, [hdc], [rsi].start_coord, [rsi].center_coord, [rsi].end_coord, [rsi].center_coord
	invoke DrawLine, [hdc], [rsi].center_coord, [rsi].start_coord, [rsi].center_coord, [rsi].end_coord

    ret
DrawAxis endp

DrawFunctionByPixel proc hdc:HDC, field_ptr:ptr field
	
	local count:		dword
	local global_x:		dword
	local global_y:		dword

	local prev_local_x:	dword
	local prev_local_y:	dword
	local local_x:		dword
	local local_y:		dword
	local unit_interval:dword
	local arg:			real8
	local invalid_coord:dword

	mov rsi, field_ptr
	assume rsi:ptr field

	mov eax, [rsi].end_coord
	inc eax
	mov invalid_coord, eax

	mov unit_interval,	10
	mov prev_local_x,	0
	mov prev_local_y,	0

	
	.if [rsi].function == EMPTY_ID
		ret
	.endif

	mov eax, [rsi].end_coord
	sub eax, [rsi].start_coord
	xor edx, edx
	idiv unit_interval
	mov count, eax

	sar eax, 1
	neg eax
	mov global_x, eax

	finit
DrawFunctionByPixel_main_loop:
	
	mov ebx, global_x

	mov eax, ebx
	imul unit_interval
	cmp edx, 0
	add eax, [rsi].center_coord
	mov local_x, eax
	
	lea rax, [rsi].function_ptr
	mov arg, rbx
	fild dword ptr [arg]
	fstp arg
	.if Field.function != EXP_ID
		invoke (unary_function ptr[rax]), arg
	.else
		;cmp global_x, 0
		;je DrawFunctionByPixel_main_loop_iter
		invoke (binary_function ptr[rax]), arg, Field.y
	.endif
	fist global_y
	fild unit_interval
	fmul st, st(1)
	fist local_y
	neg local_y
	mov eax, local_y
	add eax, [rsi].center_coord
	cmp eax, [rsi].start_coord
	jl DrawFunctionByPixel_beyond_edge
	mov local_y, eax
	jmp DrawFunctionByPixel_main_loop_iter
	
DrawFunctionByPixel_beyond_edge:
	mov eax, invalid_coord
	mov local_y, eax
	
DrawFunctionByPixel_main_loop_iter:
	
	mov r8d, prev_local_x
	mov r9d, prev_local_y
	mov r10d, local_x
	mov r11d, local_y

	.if r11d != invalid_coord && r9d != 0 && r8d != 0
		invoke DrawLine, hdc, r8d, r9d, r10d, r11d
	.endif

	mov r10d, local_x
	mov r11d, local_y
	.if r11d != invalid_coord
		; invoke DrawLine, hdc, r10d, r11d, r10d, r11d
		mov prev_local_x, r10d
		mov prev_local_y, r11d
	.endif
	
	inc global_x
	dec count

	cmp count, 0
	jg DrawFunctionByPixel_main_loop

DrawFunctionByPixel_main_loop_exit:

	ret
DrawFunctionByPixel endp
;---------------------------------------------
;Сопроцессорные функции арифметических вычислений
;---------------------------------------------
sin		proc c x:real8
	finit
	fld x
	fsin
	ret
sin endp

cos		proc c x:real8
	finit
	fld x
	fcos
	ret
cos endp

log2	proc c x:real8
	;логарифм вычисляется только для х>=0
	finit 
	fld1
	fld x
	fyl2x
	ret
log2 endp

lg		proc c x:real8
	finit
	invoke log2, x
	fldl2t
	;log_10(x) = log_2(x)/log_2(10)
	fdivp st(1), st	
	ret
lg endp

ln		proc c x:real8
	finit
	invoke log2, x
	fldln2
	;log_2(x) * log_e(x) = log_e(x) * log_2(2) = log_e(x)
	fmul st, st(1) 
	ret
ln endp

tg		proc c x:real8
	finit 
	fld x
	fptan
	fstp st ;в st(1) находится истинное значение тангенса числа, находившегося в st(0)
	ret
tg endp

ctg		proc c x:real8
	finit
	invoke tg, x
	fld1
	fdiv st, st(1)
	ret
ctg endp

exp		proc c x:real8, y:real8
    local change_x_sign:dword
    local change_res_sign:dword

    mov eax, 1
    mov [change_x_sign], eax

    finit

	fldz
    fld y
    fcomi st, st(1)

	.if ZERO?
		fld1
		ret
    .endif

    fldz
    fld x
    fcomi st, st(1)

    .if CARRY?
        neg [change_x_sign] ;устанавливаем флаг -1, если x<0
	.elseif ZERO?
		fldz
		ret
    .endif

    fld y
    fist [change_res_sign]
    and [change_res_sign], 1
    .if [change_x_sign] == -1 && [change_res_sign] == 1
        neg [change_res_sign] ;если x<0 и степень нечётна, меняем в конце знак результата
    .endif
    fld x
    .if [change_x_sign] == -1
        fchs
    .endif
    fyl2x
    fld     st
    frndint
    fsub    st(1),st
    fxch    st(1)
    f2xm1
    fld1
    fadd
    fscale
    fstp    st(1)
    .if [change_res_sign] == -1
        fchs
    .endif
    ret     

exp endp

IntSum proc c a:real8, b:real8, function:qword
	local i:real8
	local sum:real8
	
	local result:real8
	local arg:real8
	
	
	finit
	fld [b]
	fld [a]
	
	fsub st(1),st
	
	fld thousand
	fmul st,st(2)
	fst result				;Получение результата - счетчика

	fldz					
	fst i
	fst sum
	finit
	.while !CARRY? ; i < result
		finit
		fld i
		fld thousandth
		fmul st,st(1)
		fld a
		fadd st,st(1)
		fst arg				;посчитали аргумент вызываемой функции arg(a+i*0.001)
		
		lea rax, function
		
		.if Field.function != EXP_ID
			invoke (unary_function ptr[rax]), arg
		.else
			invoke (binary_function ptr[rax]), arg, Field.y
		.endif

		fld thousandth
		fmul st,st(1)		;посчитали площадь фрагмента
		
		fld sum		
		fadd st, st(1)
		fst sum			
		
		finit
		
		fld i
		fld1
		fadd st,st(1)
		fst i
		
		fld result 
		fcomi st, st(1)
		
	.endw
	fld sum
		
	ret
IntSum endp

InitFieldState proc frame ptr_field:ptr field
	mov rsi, ptr_field
	assume rsi:ptr field
	
	mov [rsi].function, EMPTY_ID
	mov [rsi].start_coord, 20
	mov [rsi].end_coord, 640
	mov [rsi].center_coord, 330
	
	ret
InitFieldState endp

GetIntFromWindowText proc frame hEdit:HWND
	local string:qword
	local stringlen:dword

	xor rax, rax
	invoke GetWindowTextLength, hEdit	
	mov [stringlen], eax					
	inc [stringlen]							
	invoke malloc, [stringlen]
	mov [string], rax
	invoke GetWindowText, hEdit, [string], [stringlen]
	invoke atoi, string
	push rax
	invoke free, string
	pop rax
	ret

GetIntFromWindowText endp

GetInterval proc field_ptr:ptr field
	mov rsi, field_ptr
	assume rsi:ptr field 
	
	invoke GetIntFromWindowText, hEditIntA
	mov [rsi].a, eax

	invoke GetIntFromWindowText, hEditIntB
	mov [rsi].b, eax
	cmp eax, [rsi].a
	jge GetIntervalEnd
	mov eax, [rsi].a
	xchg [rsi].b, eax
	mov [rsi].a, eax
GetIntervalEnd:
	ret
GetInterval endp

GetIntSum proc frame field_ptr:ptr field
	local string:qword
	local sum:qword
	local a:qword
	local b:qword
	
	mov rsi, field_ptr
	assume rsi:ptr field
	
	.if [rsi].function_ptr != NULL
		finit
		
		fild [rsi].a
		fstp [a]
		fild [rsi].b
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
		.if  eax == BT_EXP || eax == BT_SIN || eax == BT_COS || eax == BT_TG \
		|| eax == BT_CTG || eax == BT_LN || eax == BT_LG || eax == BT_LOG2
			invoke GetInterval, addr Field
		.endif
		pop rbx
        .if ebx == BT_EXP
			mov Field.function, EXP_ID
			xor rax, rax
			invoke GetIntFromWindowText, hEditExp
			finit
			mov Field.y, rax
			fild Field.y
			fstp Field.y
			lea rax, exp
		.elseif ebx == BT_SIN	
			mov Field.function, SIN_ID
			lea rax, sin
		.elseif ebx == BT_COS	
			mov Field.function, COS_ID
			lea rax, cos
		.elseif ebx == BT_TG
			mov Field.function, TG_ID
			lea rax, tg
		.elseif ebx == BT_CTG	
			mov Field.function, CTG_ID
			lea rax, ctg
		.elseif ebx == BT_LN	
			mov Field.function, LN_ID
			lea rax, ln 
		.elseif ebx == BT_LG
			mov Field.function, LG_ID
			lea rax, lg
		.elseif ebx == BT_LOG2	
			mov Field.function, LOG2_ID
			lea rax, log2
		.endif

		.if  ebx == BT_EXP || ebx == BT_SIN || ebx == BT_COS || ebx == BT_TG \
		|| ebx == BT_CTG || ebx == BT_LN || ebx == BT_LG || ebx == BT_LOG2
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
        invoke TextOut, [hdc], 680, 20, $CTA0("Enter interval"), 17
        invoke TextOut, [hdc], 680, 45, $CTA0("A:"), 2
		invoke TextOut, [hdc], 800, 45, $CTA0("B:"), 2
		invoke TextOut, [hdc], 680, 65, $CTA0("Choose function:"), 20
		invoke TextOut, [hdc], 680, 580, $CTA0("Integral value:"), 19

		invoke DrawFunctionByPixel, [hdc], addr Field
		invoke DrawAxis, [hdc], addr Field
                
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
