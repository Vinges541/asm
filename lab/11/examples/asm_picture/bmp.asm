;
; Модуль bmp.asm
;
; Модуль содержит описание функций, необходимых 
; для работы с bmp-файлами и bmp-изображениями.
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
include c:\masm32\include\comdlg32.inc

include Strings.mac

;----------------------------------------
.code

;
; Функция отображения картинки на контексте устройства
;
DrawBitmap proc hdc:HDC, hBitmap:HBITMAP, xStart:DWORD, yStart:DWORD

    local bm:BITMAP
    local hdcMem:HDC
    local ptSize:POINT
    local ptOrg:POINT
    
    ; создаем контест памяти (контекст устройства, существующий только в памяти),
    ; совместимый с существующим контестом устройства hdc
    ; после создания содержит только 1 монохромный пиксель
    invoke CreateCompatibleDC, [hdc]
    mov [hdcMem], eax
    
    ; выбираем картинку в контекст устройства
    ; после этого размер поверхности контекста памяти
    ; будет равен размеру картинки
    invoke SelectObject, [hdcMem], [hBitmap]

    ; копируем режим отображения
    invoke GetMapMode, [hdc]
	invoke SetMapMode, [hdcMem], eax
	
	; заполняем структуру информацией картинки
	invoke GetObject, hBitmap, sizeof(BITMAP), addr bm
	
	; преобразуем координаты устройства в логические
	mov eax, [bm].bmWidth
	mov [ptSize].x, eax
	mov eax, [bm].bmHeight
	mov [ptSize].y, eax
	invoke DPtoLP, [hdc], addr ptSize, 1
	mov [ptOrg].x, 0
	mov [ptOrg].y, 0
	invoke DPtoLP, [hdcMem], addr ptOrg, 1
	
	; перенос битов картинки из контекста памяти на контекст устройства
	invoke BitBlt, [hdc], [xStart], [yStart], [ptSize].x, [ptSize].y, [hdcMem], [ptOrg].x, [ptOrg].y, SRCCOPY
	
	; удаление контекста памяти
	invoke DeleteDC, [hdcMem]
	
	ret

DrawBitmap endp

;--------------------

;
; Загружает картинку из файла в память
;
LoadBmpFile proc parentWindow:HWND, hIns:HINSTANCE

    local ofn:OPENFILENAMEA
    local szFile[MAX_PATH]:byte
    local bm:HBITMAP
    
    mov [bm], 0
    mov byte ptr [szFile], 0
    
    invoke RtlZeroMemory, addr ofn, sizeof(OPENFILENAMEA)
    
    mov [ofn].lStructSize, sizeof(OPENFILENAMEA)
    mov eax, [parentWindow]
	mov [ofn].hwndOwner, eax
	lea eax, [szFile]
	mov [ofn].lpstrFile, eax
	mov [ofn].nMaxFile, MAX_PATH
	mov [ofn].lpstrFilter, $CTA0("bmp-файлы\0*.bmp\0Все файлы\0*.*\0")
	mov [ofn].nFilterIndex, 0
	mov [ofn].lpstrFileTitle, NULL
	mov [ofn].nMaxFileTitle, 0
	mov [ofn].lpstrInitialDir, NULL
	mov [ofn].Flags, OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST
	
	invoke GetOpenFileNameA, addr ofn
	
	.if eax
	    invoke LoadImage, [hIns], addr szFile, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	    mov [bm], eax
	.endif
	
	mov eax, [bm]
	ret

LoadBmpFile endp

;--------------------

;
; Создаёт bmp-файл с переданной картинкой
;
CreateBMPFile proc pszFile:LPTSTR, hBitmap:HBITMAP, parentWindow:HWND

    local bitmap:BITMAP
    local hf:HANDLE         ; описатель файла
    local hdr:BITMAPFILEHEADER      ; указатель на файловый заголовок файла 
    local bmih:BITMAPINFOHEADER     ; указатель на заголовок битмапа
    local bits:ptr byte
    local size_bitmap:DWORD
    local tmp:LPDWORD
    local hdc:HDC
    
    invoke GetObject, [hBitmap], sizeof(BITMAP), addr bitmap
    .if eax == 0
        ret
    .endif
    
    .if bitmap.bmBitsPixel != 32
        ret
    .endif
    
    mov [bmih].biSize, sizeof(BITMAPINFOHEADER)
    mov eax, [bitmap].bmWidth
	mov [bmih].biWidth, eax
	mov eax, [bitmap].bmHeight
	mov [bmih].biHeight, eax
	mov ax, [bitmap].bmPlanes
	mov [bmih].biPlanes, ax
	mov ax, [bitmap].bmBitsPixel
	mov [bmih].biBitCount, ax
	mov [bmih].biClrUsed, 0
	mov [bmih].biCompression, BI_RGB
	mov [bmih].biSizeImage, 0
	mov [bmih].biClrImportant, 0
	
	mov eax, 4
	imul eax, [bitmap].bmHeight
	imul eax, [bitmap].bmWidth
	invoke crt_malloc, size_bitmap
	mov [bits], eax
	.if !eax
	    ret
	.endif
	
	invoke GetDC, [parentWindow]
	mov [hdc], eax
	
	invoke GetDIBits, [hdc], [hBitmap], 0, [bmih].biHeight, [bits], addr bmih, DIB_RGB_COLORS
	.if !eax
	    ret
	.endif
	
	invoke CreateFile, pszFile, GENERIC_READ or GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
	mov [hf], eax
	.if [hf] == INVALID_HANDLE_VALUE
	    ret
	.endif
	
	mov [hdr].bfType, 4d42h     ;0x42 = "B" 0x4d = "M" 
	mov eax, sizeof(BITMAPFILEHEADER)
	add eax, [bmih].biSize
	add eax, [size_bitmap]
	add [hdr].bfSize, eax
	mov [hdr].bfReserved1, 0
	mov [hdr].bfReserved2, 0
	
	mov eax, sizeof(BITMAPFILEHEADER)
	add eax, [bmih].biSize
	mov [hdr].bfOffBits, eax
	
	invoke WriteFile, [hf], addr hdr, sizeof(BITMAPFILEHEADER), addr tmp, NULL
	.if eax
	    invoke WriteFile, [hf], addr bmih, sizeof(BITMAPINFOHEADER), addr tmp, NULL
	    .if eax
	        invoke WriteFile, [hf], [bits], [size_bitmap], addr tmp, NULL
	    .endif
	.endif
	
    invoke CloseHandle, [hf]

    invoke crt_free, [bits]

	ret

CreateBMPFile endp

;--------------------

;
; Сохраняет картинку в файл
;
SaveBMPFile proc hBitmap:HBITMAP, parentWindow:HWND

    local ofn:OPENFILENAMEA
    local szFile[MAX_PATH]:byte
    
    mov byte ptr[szFile], 0
    
    invoke RtlZeroMemory, addr ofn, sizeof(OPENFILENAMEA)
    
	mov [ofn].lStructSize, sizeof(OPENFILENAMEA)
	mov eax, [parentWindow]
	mov [ofn].hwndOwner, eax
	lea eax, [szFile]
	mov [ofn].lpstrFile, eax
	mov [ofn].nMaxFile, MAX_PATH
	mov [ofn].lpstrFilter, $CTA0("bmp-файлы\0*.bmp\0Все файлы\0*.*\0")
	mov [ofn].nFilterIndex, 0
	mov [ofn].lpstrFileTitle, NULL
	mov [ofn].nMaxFileTitle, 0
	mov [ofn].lpstrInitialDir, NULL
	mov [ofn].Flags, OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST
	
	invoke GetSaveFileNameA, addr ofn
	.if eax
	    invoke CreateBMPFile, addr szFile, [hBitmap], [parentWindow]
	.endif
	
	ret

SaveBMPFile endp

;--------------------

;
; Функция обрабатывает картинку попиксельно.
; Каждый пиксель изменяется вызовом функции updater.
;
ProcessingBitmap proc srcBitmap:HBITMAP, updater:DWORD

    local bitmap:BITMAP
    local dstBitmap:HBITMAP
    local bits:ptr byte
    local pBits:ptr byte
    local pixelCount:DWORD
    local i:DWORD
    local j:DWORD
    local pixel:DWORD
    local bytesPixel:DWORD
    
    invoke GetObject, [srcBitmap], sizeof(BITMAP), addr bitmap
    .if !eax
		ret
    .endif
    
    xor eax, eax
    .if bitmap.bmBitsPixel != 24
        .if bitmap.bmBitsPixel != 32
            ret
        .endif
    .endif

    mov eax, [bitmap].bmHeight
    imul eax, [bitmap].bmWidth
    mov [pixelCount], eax
    
    movzx eax, [bitmap].bmBitsPixel 
    shr eax, 3
    mov [bytesPixel], eax
    imul eax, [pixelCount]
    
    invoke crt_malloc, eax
    mov [bits], eax
    .if !eax
        ret
    .endif
    
    movzx eax, bitmap.bmBitsPixel
    imul eax, [pixelCount]
    invoke GetBitmapBits, [srcBitmap],  eax, [bits]
    
    mov eax, [bits]
    mov pBits, eax
    
    mov [i], 0
    mov ecx, [i]
    
    .while ecx < [bitmap].bmHeight
    
        mov [j], 0
        mov ecx, [j]
        .while ecx < [bitmap.bmWidth]
        
            mov [pixel], 0

            invoke crt_memcpy, addr pixel, [pBits], [bytesPixel]
            
            push [pixel]
            call [updater]
            mov [pixel], eax
            
            invoke crt_memcpy, [pBits], addr pixel, [bytesPixel]

            mov eax, [bytesPixel]
            add [pBits], eax            

            inc [j]
            mov ecx, [j]
        .endw
        
        inc [i]
        mov ecx, [i]
    .endw
    
    invoke  CreateBitmap, [bitmap].bmWidth, [bitmap].bmHeight, 1, [bitmap].bmBitsPixel, [bits]
    mov [dstBitmap], eax
    
    invoke crt_free, [bits]
    
    mov eax, [dstBitmap]
    ret

ProcessingBitmap endp

;--------------------


InvertUpdater proc pixel:DWORD

    mov eax, [pixel]
    xor eax, 00FFFFFFh
    and eax, 00FFFFFFh

    ret

InvertUpdater endp

;
; Возвращает картинку с цветами, инвертированными
; относительно исходного
;
InvertBitmap proc srcBitmap:HBITMAP

    invoke ProcessingBitmap, srcBitmap, InvertUpdater
    
    ret

InvertBitmap endp

;--------------------


GraystyleUpdater proc pixel:DWORD

    local r:DWORD
    local g:DWORD
    local b:DWORD

    mov eax, [pixel]
    mov [r], eax
    and [r], 0FFh
    mov [g], eax
    shr [g], 8
    and [g], 0FFh
    mov [b], eax
    shr [b], 16
    and [b], 0FFh
    
    mov eax, [r]
    add eax, [g]
    add eax, [b]
    mov ecx, 3
    cdq
    idiv ecx
    
    mov ecx, 00010101h
    imul eax, ecx
    
    ret

GraystyleUpdater endp

;
; Возвращает исходную картинку в оттенках серого
;
GetGraystyleBitmap proc srcBitmap:HBITMAP

    invoke ProcessingBitmap, srcBitmap, GraystyleUpdater
    
    ret

GetGraystyleBitmap endp

;--------------------

;--------------------

end
