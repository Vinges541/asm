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

FieldState struct 
	xStart			dword ?		;������ ��������� �� ����
	yStart			dword ?		;������ ��������� �� ������
	
	OrdPart			dword ?		;����� ������������
	OrdPart1		dword ?		;	
	AbsPart			dword ?		;����� ������������
	AbsPart1		dword ?		;

	function		dword ?		;������������� �������
	function_ptr	qword ?

	count			dword ?		;���������� �����
	for_ordinate	dword ?		;���� ��� ����������� ����������� ��������� ������������� ����� (������������ ������ � ������������ ���������)
	
	x0_cord			dword ?		;�������� ��� �������� � ��������
	x1_cord			dword ?

FieldState ends

; ��������� ��������� � ������ ����
AppWindowName equ <"Graphics">



ED_1 equ 201     ; ������������� �������� ���������� ����
ED_2 equ 202     ; ������������� ������� ���������� ����
ST_1 equ 203     ; ������������� ������������ ����
BT_1 equ 204     ; ������������� ������
BT_2 equ 205     ; ������������� ������
BT_3 equ 206     ; ������������� ������
BT_4 equ 207     ; ������������� ������
BT_5 equ 208     ; ������������� ������
BT_6 equ 209     ; ������������� ������
BT_7 equ 210     ; ������������� ������
BT_8 equ 211     ; ������������� ������
BT_9 equ 212     ; ������������� ������
BT_10 equ 213     ; ������������� ������
;BT_11 equ 214     ; ������������� ������
BT_12 equ 215     ; ������������� ������

LINE_ID		equ 100
SQX_ID		equ 101
CUBE_ID		equ	102
HYP_ID		equ 103
SIN_ID		equ 104
COS_ID		equ 105
TAN_ID		equ 106
CTAN_ID		equ 107
LN_ID		equ 108
LG_ID		equ 109
LOG2_ID		equ 110
DEG_ID		equ 111
POLY_ID		equ 112
EMPTY_ID	equ 113

FO1 equ 114	;��������� ��� for_ordinate
FO2 equ 115

ED_5	equ 240     ; ������������� ���������� ���� ����� �������
ED_6	equ 241
;ED_7	equ 242
ED_8	equ 243

;----------------------------------------
; ���������� �������

RegisterClassMainWindow proto

CreateMainWindow proto

DrawLine proto hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword

DrawAbscissa proto hdc:HDC, field_ptr:ptr FieldState

DrawOrdinate proto hdc:HDC, field_ptr:ptr FieldState

DrawFunctionXdegree proto hdc:HDC, field_ptr:ptr FieldState

DrawFunctionByPixel proto hdc:HDC, field_ptr:ptr FieldState

ZoomFunc proto a:dword, b:dword;, field_ptr:ptr FieldState

GetInterval proto field_ptr:ptr FieldState

GetPolynom proto field_ptr:ptr FieldState

ReturnPolynom proto c x:qword

GetIntSum proto field_ptr:ptr FieldState

WndProcMain proto hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

CreateControlWindowsMain proto hwnd:HWND

InitFieldState proto ptr_field:ptr FieldState

func typedef proto c:qword

sqx proto c x:qword

degree proto c x:qword;, y:qword

degreey proto x:qword, y:qword

cube proto c x:qword

hyperb proto c x:qword

sin_proc proto c x:qword

cos_proc proto c x:qword

log2_proc proto c x:qword

lg_proc proto c x:qword

ln_proc proto c x:qword

tan_proc proto c x:qword

ctan_proc proto c x:qword

IntSum proto c a:qword, b:qword, function:qword

;----------------------------------------
; �������� ������

.data
mas dq 100 dup (0)
oneth dq 0.001
thousand dq 1000.0

Field FieldState <0,0,0,0,0,0>

.data?
hButton1 HWND  ?
hButton2 HWND  ?
hButton3 HWND  ?
hButton4 HWND  ?
hButton5 HWND  ?
hButton6 HWND  ?
hButton7 HWND  ?
hButton8 HWND  ?
hButton9 HWND  ?
hButton10 HWND  ?
hButton11 HWND  ?
hButton12 HWND  ?

x3 dq ?

for_degree dq ?

globalf dq ?

;��� ����������
degs	dq ?	;�������
coofs	dq ?	;������������
signs	dq ?	;����� (1 -, 0 +)

glChar dq ?

hIns HINSTANCE ?

HwndMainWindow HWND ?
hEdit1			HWND ?	;handle ��������� ����(���� ����� ���������)
hEdit2			HWND ?
hEdit3			HWND ?  ;handle ��� ���� ����� �������
hEdit4			HWND ?

.const

;----------------------------------------
; �������� �������

.code

;
; �������� ������� ������� ����������
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
	
	; �������� ���� ��������� ���������
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
; ����������� ������ ��������� ���� ����������
;
RegisterClassMainWindow proc frame

    local WndClass:WNDCLASSEX	; ��������� ������

    ; ��������� ���� ���������
    mov WndClass.cbSize, sizeof (WNDCLASSEX)    ; ������ ��������� ������
    mov WndClass.style, 0
    mov rax, offset WndProcMain
    mov WndClass.lpfnWndProc,  rax              ; ����� ������� ��������� ������
    mov WndClass.cbClsExtra, 0
    mov WndClass.cbWndExtra, 0                  ; ������ �������������� ������ ����
    mov rax, [hIns]
    mov WndClass.hInstance, rax	                ; ��������� ����������
    invoke LoadIcon, hIns, $CTA0("MainIcon")    ; ������ ����������
    mov WndClass.hIcon, rax
    invoke LoadCursor, NULL, IDC_ARROW
    mov WndClass.hCursor, rax
    invoke GetStockObject, BLACK_BRUSH          ; ����� ��� ����
    mov WndClass.hbrBackground, rax
    mov WndClass.lpszMenuName, NULL
    mov rax, $CTA0(AppWindowName)
    mov WndClass.lpszClassName, rax             ; ��� ������
    invoke LoadIcon, hIns, $CTA0("MainIcon")
    mov WndClass.hIconSm, rax

    invoke RegisterClassEx, addr WndClass
    ret
RegisterClassMainWindow endp

;--------------------
; �������� ��������� ���� ����������
;
CreateMainWindow proc frame

    local hwnd:HWND

    ; ����������� ������ ��������� ����
    invoke RegisterClassMainWindow

    ; �������� ���� ������������������� ������
    invoke CreateWindowEx, 
        WS_EX_CONTROLPARENT or WS_EX_APPWINDOW, ; ����������� ����� ����
        $CTA0(AppWindowName),	; ��� ������������������� ������ ����
        $CTA0("Application"),	; ��������� ����
        WS_SYSMENU,	; ����� ����
        10,	    ; X-���������� ������ �������� ����
        10,	    ; Y-���������� ������ �������� ����
        960,    ; ������ ����
        700,    ; ������ ����
        NULL,   ; ��������� ������������� ����
        NULL,   ; ��������� �������� ���� (��� �������� ����)
        [hIns], ; ������������� ����������
        NULL
    mov [hwnd], rax
    
    .if [hwnd] == 0
        invoke MessageBox, NULL, $CTA0("������ �������� ��������� ���� ����������"), NULL, MB_OK
        xor rax, rax
        ret
    .endif
        
    invoke ShowWindow, [hwnd], SW_SHOWNORMAL
    invoke UpdateWindow, [hwnd]
    
    mov rax, [hwnd]
    ret
CreateMainWindow endp

;--------------------
;�������� ����������� ��������� (���������) �������� ����
CreateControlWindowsMain proc  hwnd:HWND
	
	invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = x^2"), WS_CHILD or WS_VISIBLE , 680, 90, 100, 26, hwnd, BT_1, hIns, NULL
    mov [hButton1], rax 
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = x^3"), WS_CHILD or WS_VISIBLE , 800, 90, 100, 26, hwnd, BT_2, hIns, NULL
    mov [hButton2], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = 1/x"), WS_CHILD or WS_VISIBLE , 680, 130, 100, 26, hwnd, BT_3, hIns, NULL
    mov [hButton3], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = sin x"), WS_CHILD or WS_VISIBLE , 800, 130, 100, 26, hwnd, BT_4, hIns, NULL
    mov [hButton4], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = cos x"), WS_CHILD or WS_VISIBLE , 680, 170, 100, 26, hwnd, BT_5, hIns, NULL
    mov [hButton5], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = tg x"), WS_CHILD or WS_VISIBLE , 800, 170, 100, 26, hwnd, BT_6, hIns, NULL
    mov [hButton6], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y =ctg x "), WS_CHILD or WS_VISIBLE , 680, 210, 100, 26, hwnd, BT_7, hIns, NULL
    mov [hButton7], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = ln x"), WS_CHILD or WS_VISIBLE , 800, 210, 100, 26, hwnd, BT_8, hIns, NULL
    mov [hButton8], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = lg x"), WS_CHILD or WS_VISIBLE , 680, 250, 100, 26, hwnd, BT_9, hIns, NULL
    mov [hButton9], rax
    
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("y = log2x"), WS_CHILD or WS_VISIBLE , 800, 250, 100, 26, hwnd, BT_10, hIns, NULL
    mov [hButton10], rax
    
    COMMENT @
    invoke CreateWindowEx, 0, $CTA0("button"), $CTA0("����������"), WS_CHILD or WS_VISIBLE , 800, 365, 100, 27, hwnd, BT_11, hIns, NULL
    mov [hButton11], rax
	@
    
    ;���� ���������
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("edit"), NULL, WS_CHILD or WS_VISIBLE or ES_RIGHT, 720, 40, 60, 20, hwnd, ED_5 , hIns, NULL
	mov hEdit1, rax
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("edit"), NULL, WS_CHILD or WS_VISIBLE or ES_RIGHT, 840, 40, 60, 20, hwnd, ED_6 , hIns, NULL
	mov hEdit2, rax
	
	COMMENT @
	;���� ����� �������-��������
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("edit"), NULL, WS_CHILD or WS_VISIBLE or ES_RIGHT, 680, 320, 220, 30, hwnd, ED_7 , hIns, NULL
	mov hEdit3, rax
	@

	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("edit"), NULL, WS_CHILD or WS_VISIBLE or ES_LEFT or ES_READONLY, 680, 610, 220, 30, hwnd, ED_8 , hIns, NULL
	mov hEdit4, rax
           
	ret
CreateControlWindowsMain endp
; ������ ������� �� ��������� ���������� � ���������� ������������.
;
DrawLine proc frame hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword

    local pen:HPEN
    
    ; ������ ������ "����" ��� ��������� �����
    invoke CreatePen, 
        PS_SOLID,       ; ����� ��� ����� (��������)
        1,              ; ������� �����
        0 + 0 shl 8 + 0 shl 16 ; ���� �����
    mov [pen], rax
    
    ; ����������� ��������� ����� � ���������� ����������
    invoke SelectObject, [hdc], [pen]
    
    ; ���������� ������� �������, � ������� ���������� ���������
    invoke MoveToEx,
        [hdc],          ; ��������� ��������� ����������
        startX,         ; X-����������
        startY,         ; Y-����������
        NULL
        
    ; ������ ����� ��������� ������ �� ������� ������� �� ��������� �����
    invoke LineTo,
        [hdc],          ; ��������� ��������� ����������
        endX,           ; X-���������� �������� �����
        endY            ; Y-���������� �������� �����

    ; ������� ��������� "����"
    invoke DeleteObject, pen

    ret
DrawLine endp
;--------------------
; ������ ��� �������.
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
	fld [rsi].AbsPart1 ;�������������� �������
	fsubp st(1), st
	fistp [startX]
	
	fld [rsi].xStart
	fld [rsi].AbsPart ;������������� �������
	faddp st(1), st
	fistp [endX]
	
	

  invoke DrawLine, [hdc], [startX], [startY], [endX], [startY]
    ret
DrawAbscissa endp
; ������ ��� �������.
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
	fld [rsi].OrdPart1 ;������������� �������
	fsubp st(1), st
	fistp [startY]
	
	fld [rsi].yStart
	fld [rsi].OrdPart ;������������� �������
	faddp st(1), st
	fistp [endY]

  invoke DrawLine, [hdc], [startX], [startY], [startX], [endY]
    ret
DrawOrdinate endp

;--------------------
;	��������� �������
DrawFunctionXdegree proc hdc:HDC, field_ptr:ptr FieldState
	local i:qword

	local _arg:qword
	local resfun:qword
	local startX:dword
	local startY:dword
	
	local temp:dword
	local temp1:dword
	local count:dword

	mov rsi, field_ptr
	assume rsi:ptr FieldState
	
	
	;����������� ���������� �� ��������� � �������: ������ ���������,����� �����
	mov r10d, [rsi].xStart		
	mov [startX], r10d
	mov r10d, [rsi].yStart
	mov [startY], r10d
	mov r10d, [rsi].count
	mov [count], r10d	

	mov [i] , 0.	
	cycle:
	
		finit		
		fld i			;��������� i
		fld oneth
		fmul st, st(1) 
		
		fst [_arg]		;��������� ���������� �������� � ��������
		
		;lea eax, function	;��������� ��������� �� �������,��������� � ����������
		;assume eax:nothing
		
		
		lea rax, [rsi].function_ptr
		assume rax:nothing

		invoke (func ptr[rax]), [_arg]		;������� �������
		;invoke sqx, [_arg]
		fst [resfun]			;��������� ��������� ������� �� ����� � ��������� ����������		
	
		fld [_arg]
		fld [startX]
		fadd st, st(1)
		fistp [temp]			;��������� �������� �������� � �������� �������� � ������� ����������
		
		fld [startY]
		fld [resfun]
		fsubp st(1),st			; ��������� st(i) = st(i) - st(0)
		fistp [temp1]			;��������� ��������� �� �������� �������� �������� � ������� ����������1
		
		fld [startX]			;��������� ��������
		fistp [startX]			;���������� � ��������� � ����� �������
		
		fld [startY]			;��������� ��������
		fistp [startY]			;���������� � ��������� � ����� �������		
		
		invoke DrawLine, [hdc], [startX], [startY], [temp], [temp1]
		
		fild [temp]				;��������� temp ��� �����
		fstp [temp]				;��������� ��� ������������
		
		mov r9d, [temp]
		mov [startX], r9d
		
		fild [temp1]			;��������� temp1 ��� �����
		fstp [temp1]			;��������� ��� ������������
		
		mov r9d, [temp1]
		mov [startY], r9d		
		
		fld i				;��������� i
		fld1				;��������� �������
		fadd st,st(1)		;����������������
		fst i				;��������� i
		
		fld [count]
		fcom				;��������� st(0) c st(1)
		fstsw ax			;������������ ���������� �������� ��������� ������������ � AX 
		sahf				;���������� �������� AH ������������ � ������� ������
		jnc cycle				; ����  i ������ result, �� ��������� ����
		
	mov rsi, field_ptr
	assume rsi:ptr FieldState
		
	;							����������� ���������� �� ��������� � �������: ������ ���������,����� �����
	mov r10d, [rsi].xStart		
	mov [startX], r10d
	mov r10d, [rsi].yStart
	mov [startY], r10d
	mov r10d, [rsi].count
	mov [count], r10d	

	mov [i] , 0.	
	cycle1:
	
		finit		
		fld i			;��������� i
		fld oneth
		fmul st, st(1) 
		
		fst [_arg]		;��������� ���������� �������� � ��������
		
		lea rax, [rsi].function_ptr
		assume rax:nothing

		invoke (func ptr[rax]), [_arg]		;������� �������
		;invoke sqx, [_arg]
		fst [resfun]			;��������� ��������� ������� �� ����� � ��������� ����������		
		
		fld [startX]
		fld [_arg]
		
		fsubp st(1), st
		fistp [temp]			;��������� �������� �������� � �������� �������� � ������� ����������
		
		.if Field.for_ordinate == FO1
			fld [startY]
			fld [resfun]
			fsubp st(1),st			; ��������� st(i) = st(i) - st(0)
			fistp [temp1]			;��������� ��������� �� �������� �������� �������� � ������� ����������1
		.elseif Field.for_ordinate == FO2
			fld [startY]
			fld [resfun]
			faddp st(1),st			
			fistp [temp1]			;��������� ��������� �� �������� �������� �������� � ������� ����������1
		.endif
		
		fld [startX]			;��������� ��������
		fistp [startX]			;���������� � ��������� � ����� �������
		
		fld [startY]			;��������� ��������
		fistp [startY]			;���������� � ��������� � ����� �������		
		
		invoke DrawLine, [hdc], [startX], [startY], [temp], [temp1]
		
		fild [temp]				;��������� temp ��� �����
		fst [temp]				;��������� ��� ������������
		
		mov r9d, [temp]
		mov [startX], r9d
		
		fild [temp1]			;��������� temp1 ��� �����
		fst [temp1]				;��������� ��� ������������
		
		mov r9d, [temp1]
		mov [startY], r9d		
		
		fld i				;��������� i
		fld1				;��������� �������
		fadd st,st(1)		;����������������
		fst i				;��������� i
		
		fld [count]
		fcom				;��������� st(0) c st(1)
		fstsw ax			;������������ ���������� �������� ��������� ������������ � AX 
		sahf				;���������� �������� AH ������������ � ������� ������
		jnc cycle1				; ����  i ������ result, �� ��������� ����
		
	
	
	ret
DrawFunctionXdegree endp


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
	
	mov [count], 600.	;������ ������� � ��������
	mov [six], 630.		;� ���������� ������� �������
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
	
	;����������� �� ��������� ���������� ��������� ��� ������� �������
	xor r10, r10
	mov r10d, [rsi].x0_cord
	mov [x0], r10d
	xor r10, r10
	mov r10d, [rsi].x1_cord
	mov [x1], r10d
	
	;mov [x0], -2
	;mov [x1], 2
	
	.if [rsi].function == LOG2_ID || [rsi].function == LG_ID || [rsi].function == LN_ID	
		finit
		fild [x0]
		fldz
		fcom 
		fstsw ax			;������������ ���������� �������� ��������� ������������ � AX 
		sahf				;���������� �������� AH ������������ � ������� ������
		jnc oper				; ����  x0 ������ 0
		jmp exit1
		oper:
		fldz 
		fistp [x0]	
		exit1:
	.endif
	
	mov globalf, 0			; ����
	
	finit
	invoke ZoomFunc, [x0], [x1]
	fstp [offsetx]
		
	fild [x0]
	fstp [a]
	fild [x1]
	fstp [b]
	
	;.if [rsi].function == SQX_ID || [rsi].function == CUBE_ID || [rsi].function == SIN_ID || [rsi].function == COS_ID || [rsi].function == TAN_ID || [rsi].function == CTAN_ID	|| [rsi].function == HYP_ID	|| [rsi].function == DEG_ID	|| [rsi].function == POLY_ID
	; ������ � ����������
	finit
	fld [a]
	fld [b]
	fsub st,st(1)		;�������� ����� ���������� ���������
	fld [count]
	fdiv st, st(1)		;�������� ����� ���������� �������
	fstp [onepartx]
	
	fld [a]
	fchs
	fst [halfint]		;����� ������������� [a,0]
	fld [onepartx]
	fmulp st(1), st
	fld [one]
	faddp st(1), st
	fstp [rsi].AbsPart1
	
	fld [b]
	fst [halfint1]		;����� ������������� [0,b]
	fld [onepartx]
	fmulp st(1), st
	fld [one]
	faddp st(1), st
	fstp [rsi].AbsPart
	
	fld [halfint]
	fld [onepartx]
	fmulp st(1),st		;�������� ����� �������������� ������������� �� ��������� �������, �������� ���������� ������ ���� ��������� �� ����
	fld [three]
	faddp st(1),st
	fstp [rsi].xStart
	;�����	
	;.elseif [rsi].function == LOG2_ID || [rsi].function == LG_ID || [rsi].function == LN_ID	
	;	mov [rsi].xStart, 30.
	;	mov [rsi].AbsPart, 610.
	;	mov [rsi].AbsPart1, 10.
	;.endif
	
	
	.if [rsi].function == LOG2_ID || [rsi].function == LG_ID || [rsi].function == LN_ID	
			
		finit	
		fld [a]
		fldz
		fcom				;��������� st(0) c st(1)
		fstsw ax			;������������ ���������� �������� ��������� ������������ � AX 
		sahf				;���������� �������� AH ������������ � ������� ������
		jz l				; ����  a ������ 0, ��
		jmp exit2 
		
		l:	
		fld [a]
		fld [offsetx]
		faddp st(1), st
		fst [a]
		exit2:
	.endif
	
	
	
	;finit
	mov rsi, field_ptr
	assume rsi:ptr FieldState	
	lea rax, [rsi].function_ptr
	assume rax:nothing
	;��� �^2-������ ������� �������� ������� � �������� ���������
	invoke (func ptr[rax]), [a]		;������� �������
	fstp [fx0]			;��������� ��������� ������� �� ����� � ��������� ����������
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState	
	lea rax, [rsi].function_ptr
	assume rax:nothing
	invoke (func ptr[rax]), [b]		;������� �������
	fstp [fx1]			;��������� ��������� ������� �� ����� � ��������� ����������
		
	fld [fx0]		;fx0 - ��������
	fstp [_max]
		
	fld [fx0]
	fld [fx1]
	fcom
	xor rax,rax
	fstsw ax			;������������ ���������� �������� ��������� ������������ � AX 
	sahf				;���������� �������� AH ������������ � ������� ������
	jnc dem				; ����  fx0 ������ fx1
	jmp demend
	
	dem:
	fld [fx1]			; ����  fx0 ������ fx1, �� fx1 -��������
	fstp [_max]			;�������� - ���������� ������������ �������� ������� �� ��������� ������� (�� ����������!)
	
	demend:
	.if [rsi].function == POLY_ID
	
		;fld a
		mov rsi, field_ptr
		assume rsi:ptr FieldState
		lea rax, [rsi].function_ptr
		assume rax:nothing
		invoke (func ptr[rax]), [a]
		fst [_min]
		fst [_max]
		
		;���� ��������
		mov [i], 0
		start1:
			finit
			fld [i]
			fld [offsetx]
			fmulp st(1), st		;i*offset_x
			fild [rsi].x0_cord
			faddp st(1), st		;x0+i*offset_x
			fstp [_arg]		;�������� �������� ��� ������ �������
			mov rsi, field_ptr
			assume rsi:ptr FieldState
			lea rax, [rsi].function_ptr
			assume rax:nothing
			invoke (func ptr[rax]), [_arg]	
			;��������� ������� �� ������� �����
			
			;�������� �� ��������
			fstp [temp]
			
			fld [_max]
			fld [temp]
			fcom
			fstsw ax
			sahf
			
			jnc metka2
			jmp enddeg2
	metka2:
			mov eax, [temp]
			mov [_max], eax
	enddeg2:
			
			fld [i]				;��������� i
			fld1				;��������� �������
			fadd st,st(1)		;����������������
			fst [i]				;��������� i

			fld [count]
			fcom				;��������� st(0) c st(1)
			fstsw ax			;������������ ���������� �������� ��������� ������������ � AX 
			sahf				;���������� �������� AH ������������ � ������� ������
			jnc start1			;���� i ������ wid, �� ��������� ����
			
		;�������
		mov [i], 0
	st12:
		finit
		fld [i]
		fld [offsetx]
		fmulp st(1), st		;i*offset_x
		fild [rsi].x0_cord
		faddp st(1), st		;x0+i*offset_x
		fstp [_arg]		;�������� �������� ��� ������ �������
		mov rsi, field_ptr
		assume rsi:ptr FieldState
		lea rax, [rsi].function_ptr
		assume rax:nothing
		invoke (func ptr[rax]), [_arg]	
		;��������� ������� �� ������� �����
		
		;�������� �� ��������
		fstp [temp]
		
		fld [_min]
		fld [temp]
		fcom
		fstsw ax
		sahf
		
		jc metka3
		jmp enddeg3
metka3:
		mov eax, [temp]
		mov [_min], eax
enddeg3:
		
		fld [i]				;��������� i
		fld1				;��������� �������
		fadd st,st(1)		;����������������
		fst [i]				;��������� i

		fld [count]
		fcom				;��������� st(0) c st(1)
		fstsw ax			;������������ ���������� �������� ��������� ������������ � AX 
		sahf				;���������� �������� AH ������������ � ������� ������
		jnc st12			;���� i ������ wid, �� ��������� ����		
		
	
	
	.elseif [rsi].function == DEG_ID
		mov rax, [for_degree]
		xor rdx,rdx
		mov rdi, 2
		div rdi
		.if rdx == 0
			finit 
			fldz
			fstp [_min]		
		.elseif rdx == 1
			finit
			fld [fx0]
			fstp [_min]
		.endif	
	
	.elseif [rsi].function == SQX_ID 	
		fldz
		fstp [_min] ;��� ������ � ������ �������� �� ���� �� ���������!
	.elseif [rsi].function == CUBE_ID		;��� ���������� ��������
		fld [fx0]
		fstp [_min]
	.elseif [rsi].function == SIN_ID || [rsi].function == COS_ID		;��� ������ � ��������
		fld [ed]
		fstp [_max]
		fld [ed1]
		fstp [_min]
	.elseif [rsi].function == TAN_ID ||	[rsi].function == CTAN_ID || [rsi].function == HYP_ID		;��� ��������, ���������� � ���������
		fld [hun]
		fstp [_max]
		fld [hun1]
		fstp [_min]
	.elseif [rsi].function == LOG2_ID || [rsi].function == LG_ID || [rsi].function == LN_ID	;��� ���������
		fld [fx0]
		fstp [_min]
		;mov globalf, 1			; ���������,����� ��������� ��������
	.endif
	mov globalf, 1	
	invoke ZoomFunc, [_min], [_max]
	fstp [offsety]
	
	;������ � ���� �
	
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
	fstp [rsi].OrdPart1	;�������������� �������
	
	fld [_min]
	fchs
	fld [oneparty]
	fmulp st(1), st
	fld [one]	
	faddp st(1), st
	fstp [rsi].OrdPart ;������������� �������
	
	;�����
	
	
	fild [x0]
	fstp [x0v]
	
	.if [rsi].function == LOG2_ID || [rsi].function == LG_ID || [rsi].function == LN_ID	
	
		fld [x0v]
		fld [offsetx]
		faddp st(1), st
		fstp [x0v]
		
	.endif
		
	
	fld [x0v]
	fld [offsetx]				;������� �=(�/offset_x)+330
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
	;.if [rsi].function == LOG2_ID || [rsi].function == LG_ID || [rsi].function == LN_ID 
	;		fld1
	;		fstp [i]
	;.endif
	
	cycle:
		finit
		fld i
		fld [offsetx]
		fmulp st(1), st   ;i*offset_x
		fld [x0v]
		faddp st(1), st ; x0+i*offset_x
		fstp [_arg]			;�������� �������� ��� ������ �������
		lea rax, [rsi].function_ptr
		assume rax:nothing
		invoke (func ptr[rax]), [_arg]		;������� �������
		fst [resfun]			;��������� ��������� ������� �� ����� � ��������� ����������
		
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
		
		fld i				;��������� i
		fld1				;��������� �������
		fadd st,st(1)		;����������������
		fst i				;��������� i
		
		fld [count]
		fcom				;��������� st(0) c st(1)
		fstsw ax			;������������ ���������� �������� ��������� ������������ � AX 
		sahf				;���������� �������� AH ������������ � ������� ������
		jnc cycle				; ����  i ������ result, �� ��������� ����

	ret
DrawFunctionByPixel endp
;---------------------------------------------
;�������������� ������� �������������� ����������
;---------------------------------------------
;������� ���������� �������� �����
sqx proc c x:qword
			
	finit					;������������� ������������
	fld x					;�������� ������������� ����� �� ������ ������ x1 � st(0)
	;fincstp
	;fincstp
	fld x
	
	fmul st,st(1)			;��������� � ������� ���������� � st(0)
	
	fst x3					;������ ���������� � ���������� ������ x3
	;invoke crt_printf, addr format, x3
	
	ret
sqx endp 
;������� ���������� ���� �����
cube proc c x:qword
			
	finit					;������������� ������������
	fld x					;�������� ������������� ����� �� ������ ������ x1 � st(0)
	fld x	
	fmul st,st(1)			;��������� � ������� ���������� � st(0)	
	fld x
	fmul st,st(1)			;��������� � ������� ���������� � st(0)	

	ret
cube endp 
;������� ���������� � �������
degree proc c x:qword;, y:qword
	local temp1:qword
	local temp2:qword
	local temp3:qword
	local res1:qword
	local res2:qword
	local res:qword
	local flag:dword
	local y:qword
	
	local tempx:qword
	local sflag:dword
	
	;������� �����: 0 � ����� ������� = 0
	.if x == 0
		fldz
		ret
	.endif
	
	;�������� ������ � �>0. � ����������� �� ��������
	;������� ���������� ���� ����������.
	finit	
	mov rax, for_degree
	xor rdx,rdx
	mov rdi, 2
	div rdi
	.if rdx == 0
		
		fld x
		ftst
		fstsw ax
		sahf
		jnc M1	;���� � >= 0 �� ������ ��� ����

		fld x
		fchs
		fstp x
M1:		
		mov sflag, 0 ;�� ������ ���� ����������
	.elseif rdx == 1
		fld x
		ftst
		fstsw ax
		sahf
		jnc M2	;���� � >= 0 �� ������ ��� ����

		fld x
		fchs
		fstp x
		mov sflag, 1	;�������� ���� ����������
		jmp M3
M2:		
		mov sflag, 0		;�� ������ ���� ����������
		
M3:
	.endif

	mov rax, for_degree
	mov y, rax
	fild y
	fstp y
	mov flag, 0
	
	finit 
	fld y				;��������� ���������� �
	fld x				;��������� ���������� x
		
	fyl2x				;st(1) = st(1)*log2(st(0)), pop	
	fstp temp1			;�������� � ������ temp1
	
	fld temp1 
	frndint				;��������� �� ������
	fstp temp2			;��������� ����� � ������ temp2

	fld temp2
	fld1				;��������� �������,������ ��� 1*2^(st(1))!!!!!!!
	fscale				;��������� 2*n ��� ����� �����
	fstp res1
	 
	fld temp1			;������������ ������
	fld temp2			;�����
	fsub st,st(1)		;�������� �� ������� �����
	fst temp3
	;st(0) = {}
	
	fldz				;��������� ����
	fcom				;���������� ������� � �����
	fstsw ax			;��������� ����� ������������ �� ����� ���������� (������� ��������� � ��)
	sahf				;
	jnc A				;���� �=0 �������� �� ����� �
	jmp E				;����� ������������� ����� � ����� �� � � ���������� ��������
A:						;���� ������� ������� ������ ����
	fld temp3			;��������� ���
	fchs				;������ ����
	fst temp3			;�������� ������� �������
	mov flag, 1			;������������� ���� � �������
E:	
	fld temp3			;�����-��������� �������
	f2xm1				;�������� � �������
	fld1				
	fadd st,st(1)		;���������� ������� (2^st-1)+1
	fst res2			;��������� ������ ����� ����������
	
	fld res1			;��������� ������
	.if flag == 1		;���� ���� �������� �����
		fmul st,st(1)	;��������
	.else
		fdiv st,st(1)	;�����-�����
	.endif
		
	.if sflag == 1
		fst res1
		fchs
	.endif
	
	;��� ��������� ��������? ��, ������������� ���������
		fst res	
		finit
		fld  res	
	;endtest

	ret 
degree endp

;������� x^y (��� �� ����)
degreey proc uses rax x:qword, y:qword
	local temp1:qword
	local temp2:qword
	local temp3:qword
	local res1:qword
	local res2:qword
	local res:dword
	local flag:dword
	local num:qword
	local deg1:qword

	local tempx:qword
	local sflag:dword
	
	;������� �����: 0 � ����� ������� = 0
	.if x == 0
		fldz
		ret
	.endif

	;�������� ������ � �>0. � ����������� �� ���������
	;������� ���������� ���� ����������.
	finit
	fld y
	fistp deg1
	mov rax, deg1
	xor rdx, rdx
	mov rdi, 2
	div rdi
	.if rdx == 0
		
		fld x
		ftst
		fstsw ax
		sahf
		jnc M1	;���� � >= 0 �� ������ ��� ����

		fld x
		fchs
		fstp x
M1:		
		mov sflag, 0 ;�� ������ ���� ����������
	.elseif rdx == 1
		fld x
		ftst
		fstsw ax
		sahf
		jnc M2	;���� � >= 0 �� ������ ��� ����

		fld x
		fchs
		fstp x
		mov sflag, 1	;�������� ���� ����������
		jmp M3
M2:		
		mov sflag, 0		;�� ������ ���� ����������
		
M3:
	.endif

	mov flag, 0
	
	finit 
	fld y				;��������� ���������� �
	fld x				;��������� ���������� x
		
	fyl2x				;st(1) = st(1)*log2(st(0)), pop	
	fstp temp1			;�������� � ������ temp1
	
	fld temp1 
	frndint				;��������� �� ������
	fstp temp2			;��������� ����� � ������ temp2

	fld temp2
	fld1				;��������� �������,������ ��� 1*2^(st(1))!!!!!!!
	fscale				;��������� 2*n ��� ����� �����
	fstp res1
	 
	fld temp1			;������������ ������
	fld temp2			;�����
	fsub st,st(1)		;�������� �� ������� �����
	fst temp3
	;st(0) = {}
	
	fldz				;��������� ����
	fcom				;���������� ������� � �����
	fstsw ax			;��������� ����� ������������ �� ����� ���������� (������� ��������� � ��)
	sahf				;
	jnc A				;���� �=0 �������� �� ����� �
	jmp E				;����� ������������� ����� � ����� �� � � ���������� ��������
A:						;���� ������� ������� ������ ����
	fld temp3			;��������� ���
	fchs				;������ ����
	fst temp3			;�������� ������� �������
	mov flag, 1			;������������� ���� � �������
E:	
	fld temp3			;�����-��������� �������
	f2xm1				;�������� � �������
	fld1				
	fadd st,st(1)		;���������� ������� (2^st-1)+1
	fst res2			;��������� ������ ����� ����������
	
	fld res1			;��������� ������
	.if flag == 1		;���� ���� �������� �����
		fmul st,st(1)	;��������
	.else
		fdiv st,st(1)	;�����-�����
	.endif

	.if sflag == 1
		fst res1
		fchs
	.endif

	;��� ��������� ��������? ��, ������������� ���������
		fst num
		finit
		fld num
	;endtest

	ret 
degreey endp

;������� ���������� ������� ���������������� �����������
hyperb proc c x:qword
	finit
	fld1
	fld x
	
	fdiv

	ret
hyperb endp
;������� ���������� ������
sin_proc proc c x:qword

	finit
	fld x

	fsin

	ret
sin_proc endp
;������� ���������� ��������
cos_proc proc c x:qword
	
	finit
	fld x

	fcos

	ret
cos_proc endp
;������� ���������� ��������� �� ��������� 2
log2_proc proc c x:qword
;�������� ����������� ������ ��� �>=0!!!!!!!!!!!!!!
	finit 
		
	fld1
	fld x
	fyl2x

	ret
log2_proc endp
lg_proc proc c x:qword
	local temp:qword
	finit
	invoke log2_proc, x
	fst [temp]
	
	fldl2t
	fdivp st(1), st	
	
	ret
lg_proc endp
ln_proc proc c x:qword
	finit
	invoke log2_proc, x

	fldln2
	fmul st, st(1)
	
	ret
ln_proc endp

;������� ���������� ��������
tan_proc proc c x:qword
	local temp:qword
	
	finit 
	fld x
	fptan
	fstp [temp] ; ����� �������� �� fincstp	
	ret
tan_proc endp
;������� ���������� ����������
ctan_proc proc c x:qword
	local res:qword
	
	finit
	;fld x
	invoke tan_proc, x
	fstp [res]

	fld [res]
	fld1
	fdiv st, st(1)
	fst [res]

	ret
ctan_proc endp

ReturnPolynom proc c uses rsi x:qword
	local i:qword
	local currentdeg:qword
	local currentcoof:dword
	local currentsign:byte
	local sum:qword
	local res:qword
	
	
	.if x == 0
		fldz
		ret
	.endif
	
	mov sum, 0.
	
	finit
	mov i, 0
	.while i < 10
		finit
		mov rsi, i
		imul rsi, 8
		add rsi, degs				;���������
		mov rsi, qword ptr [rsi]	;�������
		mov currentdeg, rsi
		.if currentdeg == 0
			.break
		.endif
		
		mov rsi, i
		imul rsi, 4
		add rsi, coofs
		mov esi, dword ptr [rsi]
		mov currentcoof, esi
		
		mov rsi, i
		add rsi, signs
		mov al, byte ptr [rsi]
		mov currentsign, al
		
		fild currentdeg
		fstp currentdeg
		invoke degreey, x, currentdeg
		fstp res
		
		fild currentcoof
		fld res
		fmul st, st(1)
		fstp res
		
		.if currentsign == -1
			fld res
			fchs
			fstp res
		.endif
		
		fld res
		fld sum
		fadd st, st(1)
		fstp sum
		
		inc i
	.endw

	fld sum
	
	ret
ReturnPolynom endp

IntSum proc c a:qword, b:qword, function:qword
	local i:qword
	local sum:qword
	
	local result:qword
	local result1:qword
	local fun:qword
	
	
	finit					;������������� 
	fld [b]
	fld [a]
	
	fsub st(1),st			; ��������� st(i) = st(i) - st(0)
	
	fld thousand
	fmul st,st(2)
	fst result				;��������� ���������� - ��������

	fldz					;����
	fst i					;������������� i �����
	fst sum					;������������� sum �����
	finit
	Cy:						;����
		finit
		fld i
		fld oneth
		fmul st,st(1)
		fld a
		fadd st,st(1)
		fst fun				;��������� �������� ���������� ������� fun(a+i*0.001)
		
		lea rax, function	;��������� ��������� �� �������,��������� � ����������
		assume rax:nothing
		
		invoke (func ptr[rax]), fun		;������� �������

		fld oneth
		fmul st,st(1)		;��������� ������� ���������
		
		fld sum				;��������� ������������ �����
		fadd st, st(1)		;���������
		fst sum				;�������� ������������ �����
		
		finit
		
		fld i				;��������� i
		fld1				;��������� �������
		fadd st,st(1)		;����������������
		fst i				;��������� i
		
		fld result 
		fcom				;��������� st(0) c st(1)
		fstsw ax			;������������ ���������� �������� ��������� ������������ � AX 
		sahf				;���������� �������� AH ������������ � ������� ������
		jnc Cy				; ����  i ������ result, �� ��������� ����
		
		fld sum
		
	ret
IntSum endp

;--------------------
;������� ��������������� �� ���
ZoomFunc proc a:dword, b:dword;, field_ptr:ptr FieldState
	local _a:qword
	local _b:qword
	local wid:qword
	local temp:qword
	local temp1:qword

	;��������� � ������� ��������� �����, ������� ��������� ���������� � ������������� �������������
	
		;.if Field.function == LOG2_ID
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
		;.else 
		;	fild [a]
		;	fstp [_a]
		;.endif
	
	

	mov [wid], 600;����� ������� ��� ��������� �������
	finit 
	fld [_a]
	fld [_b]
	fsub st,st(1)
	fstp [temp];�������� ����� ���������� �������


	fild [wid]
	fld [temp]
	fdiv st, st(1)
	fst [temp1];�������� ���� ������ ������� � ����� ����� �������

	ret
ZoomFunc endp

InitFieldState proc frame ptr_field:ptr FieldState
	mov rsi, ptr_field
	assume rsi:ptr FieldState
	
	;mov for_degree, 5
	mov Field.function, EMPTY_ID
	;mov Field.function, LOG2_ID
	mov Field.x0_cord, 0
	mov Field.x1_cord, 0
			
	mov Field.xStart, 330.
	mov Field.yStart, 330.
	
	mov Field.OrdPart, 310.
	mov Field.OrdPart1, 310.
	mov Field.AbsPart, 310.
	mov Field.AbsPart1, 310.
	
	lea rax, log2_proc
	mov Field.function_ptr, rax
	
	
	ret
InitFieldState endp

GetInterval proc field_ptr:ptr FieldState
	local string:qword
	local stringlen:dword
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState 
	
	xor rax, rax
	invoke GetWindowTextLength, hEdit1		;�������� ����� ��������� ������
	mov [stringlen], eax					;��������� �� � ������� ��� �����
	inc [stringlen]							;��������� ������
	invoke malloc, [stringlen]
	mov [string], rax
	invoke GetWindowText, hEdit1, [string], [stringlen]	;�������� ������
	
	invoke atoi, string
	mov [rsi].x0_cord, eax
	
	invoke free, string
	
	xor rax, rax
	invoke GetWindowTextLength, hEdit2		;�������� ����� ��������� ������
	mov [stringlen], eax					;��������� �� � ������� ��� �����
	inc [stringlen]							;��������� ������
	invoke malloc, [stringlen]
	mov [string], rax
	invoke GetWindowText, hEdit2, [string], [stringlen]	;�������� ������
	
	invoke atoi, string
	mov [rsi].x1_cord, eax
	
	invoke free, string	
	
	ret
GetInterval endp


COMMENT @
GetPolynom proc field_ptr:ptr FieldState
	local string:qword
	local stringlen:dword
	local i:qword
	local x:qword
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState 
	
	xor rax, rax
	invoke GetWindowTextLength, hEdit3		;�������� ����� ��������� ������
	mov [stringlen], eax					;��������� �� � ������� ��� �����
	inc [stringlen]							;��������� ������
	invoke malloc, [stringlen]
	mov [string], rax
	invoke GetWindowText, hEdit3, [string], [stringlen]	;�������� ������
	
	mov rax, string
	xor rbx, rbx
	mov bl, byte ptr [rax]
	inc rax
	mov bh, byte ptr [rax]
	.if bl == 'x' && bh == '^'
		inc rax
		invoke atoi, rax
		mov [for_degree], rax
		
		mov rax, [string]
		add rax, 3
		xor rbx, rbx
		mov bh, byte ptr [rax]
		.if bh != '+' && bh != '-'		
			.if [for_degree] !=0 
				mov rax, [for_degree]
				xor rdx, rdx
				mov rdi, 2
				div rdi
				.if rdx == 0
					mov [rsi].xStart, 330.
					mov [rsi].yStart, 630.
					mov [rsi].AbsPart, 300.
					mov [rsi].AbsPart, 300.
					mov [rsi].OrdPart, 10.
					mov [rsi].OrdPart1, 300.
				.elseif rdx == 1
					invoke InitFieldState, rsi
				.endif

				lea rax, degree
				mov [rsi].function_ptr, rax
				mov [rsi].function, DEG_ID
				
				invoke free, string	
				ret
			.endif
		.endif
	.endif
	
	;���������
	invoke malloc, 80		;8*10  10 qword
	mov [degs], rax
	invoke malloc, 10		;10 ����
	mov [signs], rax
	invoke malloc, 40		;10*4 10 dword
	mov [coofs], rax
	
	;���������������� ��������� �����, ��������� ������������, ������ �������
	mov i, 0
	.while i < 10
		mov rsi, i
		add rsi, signs
		mov byte ptr [rsi], 1
		
		mov rsi, i
		imul rsi, 4
		add rsi, coofs
		mov dword ptr [rsi], 1
		
		mov rsi, i
		imul rsi, 8
		add rsi, degs
		mov qword ptr [rsi], 0
	
		inc i
	.endw
	
	mov rsi, field_ptr
	assume rsi:ptr FieldState 
	
	mov rdi, string
	xor rbx, rbx
	xor rcx, rcx
	.if byte ptr [rdi] == '-'
		mov rsi, signs
		mov byte ptr [rsi], -1
		
		inc rdi
	.endif
	invoke atoi, rdi
	mov rsi, coofs
	mov dword ptr [rsi], eax	;�����
	inc rdi
	mov bl, byte ptr [rdi]
	inc rdi
	mov bh, byte ptr [rdi]
	
	.if bl == 'x' && bh == '^'
		inc rdi
		invoke atoi, rdi
		mov rsi, degs
		mov qword ptr [rsi], rax
		
		mov rdx, field_ptr
		assume rdx:ptr FieldState 
		mov [rdx].function, POLY_ID
		lea rsi, ReturnPolynom
		mov [rdx].function_ptr, rsi
		
		mov [rdx].xStart, 330.
		mov [rdx].yStart, 630.
		mov [rdx].AbsPart, 300.
		mov [rdx].AbsPart, 300.
		mov [rdx].OrdPart, 300.
		mov [rdx].OrdPart1, 300.
		
		inc rdi
		mov i, 0
		.while i < 10
			xor rbx, rbx
			xor rcx, rcx
			mov bl, byte ptr [rdi]	;����
			
			inc rdi
			invoke atoi, rdi
			mov rsi, i
			inc rsi
			imul rsi, 4
			add rsi, coofs
			mov dword ptr [rsi], eax	;�����
			
			inc rdi
			mov bh, byte ptr [rdi]	;������ �
			
			inc rdi
			mov cl, byte ptr [rdi]  ;������ �������
			.if bh == 'x' && cl == '^'
				.if bl == '-'
					mov rsi, i
					inc rsi
					add rsi, signs
					mov byte ptr [rsi], -1
				.elseif bl == '+'
					mov rsi, i
					inc rsi
					add rsi, signs
					mov byte ptr [rsi], 1
				.endif
				
				inc rdi
				invoke atoi, rdi
				mov rsi, i
				inc rsi
				imul rsi, 8
				add rsi, degs
				mov qword ptr [rsi], rax	;�������
			
			.endif
			
			inc rdi
			.if  byte ptr [rdi] != '-' && byte ptr [rdi] != '+'
				;.break
				ret
			.endif
			
			inc i
		.endw
	.endif
	
	;���� ������� polynom
	mov x, 2
	fild x
	fstp x
	invoke ReturnPolynom, x
	fistp x
	
	invoke InitFieldState, rsi
	invoke free, string	
	ret
GetPolynom endp
@

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
		
		invoke SetWindowText, hEdit4, string
		
		invoke free, string
	.else
		invoke SetWindowText, hEdit4, $CTA0("NONE")
		
	.endif

	ret
GetIntSum endp

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
WndProcMain proc frame hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

    local hdc:HDC
    local ps:PAINTSTRUCT
    local white_brush:HBRUSH
   
    local color_brush:COLORREF
    
    local state:dword
	local state1:dword
	local smth:dword
	
	mov [smth], 0

    ;and esp, 0FFFFFFF0h

    .if [iMsg] == WM_CREATE
        ; �������� ����
        invoke CreateControlWindowsMain, hwnd
		invoke InitFieldState, addr Field
		;invoke GetIntSum, addr Field
		
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_DESTROY
        ; ����������� ����
        
        invoke PostQuitMessage, 0
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_SIZE
        ; ��������� �������
        
    .elseif [iMsg] == WM_SETFOCUS
        ; ��������� ������
        
    .elseif [iMsg] == WM_CLOSE
        ; �������� ����
        
    .elseif [iMsg] == WM_QUIT
        ; ���������� ����������
        
    .elseif [iMsg] == WM_KEYDOWN
        ;������� �������
        
        .if wParam == VK_SHIFT
        .endif
        
    .elseif [iMsg] == WM_CHAR
        ; ���� � ����������
        
    .elseif [iMsg] == WM_COMMAND

        movzx eax, word ptr [wParam]
        .if eax == BT_1
			invoke GetInterval, addr Field
			mov Field.function, SQX_ID
			lea rax, sqx
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE
		.elseif eax == BT_2	
			invoke GetInterval, addr Field
			mov Field.function, CUBE_ID
			lea rax, cube
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE		
		.elseif eax == BT_3	
			invoke GetInterval, addr Field
			mov Field.function, HYP_ID
			lea rax, hyperb
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE
		.elseif eax == BT_4	
			invoke GetInterval, addr Field
			mov Field.function, SIN_ID
			lea rax, sin_proc
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE
		.elseif eax == BT_5	
			invoke GetInterval, addr Field
			mov Field.function, COS_ID
			lea rax, cos_proc
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE
		.elseif eax == BT_6	
			invoke GetInterval, addr Field
			mov Field.function, TAN_ID
			lea rax, tan_proc
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE
		.elseif eax == BT_7	
			invoke GetInterval, addr Field
			mov Field.function, CTAN_ID
			lea rax, ctan_proc
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE 
		.elseif eax == BT_8	
			invoke GetInterval, addr Field
			mov Field.function, LN_ID
			lea rax, ln_proc
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE  
		.elseif eax == BT_9	
			invoke GetInterval, addr Field
			mov Field.function, LG_ID
			lea rax, lg_proc
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE
		.elseif eax == BT_10	
			invoke GetInterval, addr Field
			mov Field.function, LOG2_ID
			lea rax, log2_proc
			mov Field.function_ptr, rax
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE
		COMMENT @
		.elseif eax == BT_11	
			invoke GetInterval, addr Field
			invoke GetPolynom, addr Field
			invoke GetIntSum, addr Field
			invoke InvalidateRect, hwnd, NULL, TRUE
		@
		.endif
        ret
        
    .elseif [iMsg] == WM_PAINT
        ; ����������� ����
        
        ; �������� �������� ����������
        invoke BeginPaint, HwndMainWindow, addr ps
        mov [hdc], rax
        
        ; ���������� ���� ������
        invoke SetTextColor, [hdc], 255 + (255 shl 8) + (255 shl 16)
        
       
        
        ; ���������� ���� ���� ������
        invoke SetBkColor, [hdc], 0 + (0 shl 8) + (0 shl 16)
        
       
        
        ;������� ����� ������� �����
		mov [color_brush], 255 + 255 shl 8 + 255 shl 16
        invoke CreateSolidBrush, [color_brush]
        mov [white_brush], rax
        
        ;������������� ����� ����� �� ���������
        invoke SelectObject, [hdc], white_brush           
        
        invoke Rectangle, [hdc], 20, 20, 640, 640  
        
         ; ����� ������ �� �������� ����������
        invoke TextOut, [hdc], 680, 20, $CTA0("������� ��������:"), 17
        invoke TextOut, [hdc], 680, 45, $CTA0("A:"), 2
		invoke TextOut, [hdc], 800, 45, $CTA0("B:"), 2
		invoke TextOut, [hdc], 680, 65, $CTA0("�������� �������...:"), 20
		; invoke TextOut, [hdc], 680, 300, $CTA0("��� ������� ���������:"), 25
		invoke TextOut, [hdc], 680, 580, $CTA0("�������� ���������:"), 19
        ;lea rax, Field
		invoke DrawFunctionByPixel, [hdc], addr Field
        
        .if Field.function == EMPTY_ID || Field.function == CUBE_ID || Field.function == SIN_ID || Field.function == COS_ID || Field.function == TAN_ID || Field.function == CTAN_ID || Field.function == HYP_ID || Field.function == DEG_ID || Field.function == POLY_ID; || LOG2_ID || Field.function == LG_ID || Field.function == LN_ID || Field.function == SQX_ID
			invoke DrawAbscissa, [hdc], addr Field ;20, 330, 640
			invoke DrawOrdinate, [hdc], addr Field ;330, 640, 20
		.elseif Field.function == SQX_ID
			invoke DrawAbscissa, [hdc], addr Field ;20, 630, 640
			invoke DrawOrdinate, [hdc], addr Field ;330, 640, 20
		.elseif Field.function == LOG2_ID || 	Field.function == LG_ID || Field.function == LN_ID
			invoke DrawAbscissa, [hdc], addr Field ;20, 330, 640
			invoke DrawOrdinate, [hdc], addr Field  ;30, 640, 20
        .endif
                
        ; ���������� �����������
        invoke EndPaint, [hwnd], addr ps
        
        xor rax, rax
        ret
        
    
        
    .endif
    
    ; �������������� ��������� ������������ � �������
    ; ��������� �� ���������.
    invoke DefWindowProc, hwnd, iMsg, wParam, lParam
    ret
WndProcMain endp

;--------------------
;--------------------


end
