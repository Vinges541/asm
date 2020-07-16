/****************************************

Модуль vmvideo.c

Видеодисплей виртуальной машины.

Маткин Илья Александрович   12.12.2013

****************************************/

#include <windows.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>

#include "vmvideo.h"


//----------------------------------------

static ATOM RegisterClassVideoAdapterWindow (void);

static HWND CreateVideoAdapterWindow (DWORD width, DWORD height, vmvideo_struct *vmvideo);

static void DrawBitmap (HDC hdc, HBITMAP hBitmap, int xStart, int yStart);

static LRESULT CALLBACK WndProcVideoAdapter (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------

#define VideoAdapterWindow  "VMVideoAdapterWindow"

typedef struct _vmvideo_struct {

    HWND hwnd;
    unsigned int width;
    unsigned int height;
    unsigned int bytesPixel;
    unsigned char *mem;

} vmvideo_struct;

//----------------------------------------

//--------------------

vmvideo_struct * create_vmvideo (unsigned int width, unsigned int height) {

    vmvideo_struct *vmvideo;
    unsigned int i;

    vmvideo = (vmvideo_struct*) malloc (sizeof(vmvideo_struct));
    if (!vmvideo) {
        return NULL;
        }

    vmvideo->width = width;
    vmvideo->height = height;
    vmvideo->bytesPixel = 1;

    vmvideo->mem = (unsigned char*) malloc (width * height * 4);
    if (!vmvideo->mem) {
        free (vmvideo);
        return NULL;
        }

    for (i = 0; i < width * height; ++i) {
        vmvideo->mem[4*i] = vmvideo->mem[4*i+1] = vmvideo->mem[4*i+2] = 255;
        vmvideo->mem[4*i+3] = 0;
        }
    //memset (vmvideo->mem, 255, width * height * 4);

    vmvideo->hwnd = CreateVideoAdapterWindow (width, height, vmvideo);

    return vmvideo;
}

//--------------------


void vmvideo_write_videomem (
    vmvideo_struct *vmvideo,
    unsigned int addr,
    unsigned int count,
    unsigned char *srcBuf) {

    if (addr < vmvideo->width * vmvideo->height * vmvideo->bytesPixel - count) {
        unsigned int i;
        for (i = 0; i < count; ++i) {
            unsigned int pixel = addr + i;
            vmvideo->mem[4*pixel] = vmvideo->mem[4*pixel+1] = vmvideo->mem[4*pixel+2] = srcBuf[i];
            }
        InvalidateRect (vmvideo->hwnd, NULL, TRUE);
        }

    return;
}

//--------------------

//
// Регистрация класса 
//
static ATOM RegisterClassVideoAdapterWindow (void) {

WNDCLASSEX WndClass;

    WndClass.cbSize         = sizeof (WndClass);        // размер структуры класса
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcVideoAdapter;      // адрес оконной процедуры класса
    WndClass.cbClsExtra     = 0;                        // размер дополнительной памяти класса
    WndClass.cbWndExtra     = sizeof(void*);            // размер дополнительной памяти окна
    WndClass.hInstance      = NULL;                     // описатель приложения
    WndClass.hIcon          = NULL;
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW); // курсор окна
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (BLACK_BRUSH);
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = VideoAdapterWindow;            // имя класса
    WndClass.hIconSm        = NULL;

    return RegisterClassEx (&WndClass);
}

//--------------------

//
// Создание основного окна приложения
//
static HWND CreateVideoAdapterWindow (DWORD width, DWORD height, vmvideo_struct *vmvideo) {

HWND hwnd;

    RegisterClassVideoAdapterWindow();

    hwnd = CreateWindowEx (WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,
                          VideoAdapterWindow,
                          "VM display",
                          WS_OVERLAPPEDWINDOW,
                          10, 10,
                          width, height,
                          NULL,                 // описатель родительского окна
                          NULL,                 // описатель главного меню (для главного окна)
                          NULL, vmvideo);

    if (hwnd == NULL) {
        MessageBox (NULL, "Ошибка создания основного окна приложения", "", MB_OK);
        return NULL;
        }

    // отображение окна
    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    return hwnd;
}

//--------------------

//
// Функция отображения картинки на контексте устройства
//
static void DrawBitmap (HDC hdc, HBITMAP hBitmap, int xStart, int yStart) { 

BITMAP bm; 
HDC hdcMem; 
POINT ptSize;
POINT ptOrg;

    // создаем контест памяти (контекст устройства, существующий только в памяти),
    // совместимый с существующим контестом устройства hdc
    // после создания содержит только 1 монохромный пиксель
	hdcMem = CreateCompatibleDC (hdc);

    // выбираем картинку в контекст устройства
    // после этого размер поверхности контекста памяти
    // будет равен размеру картинки
	SelectObject (hdcMem, hBitmap);

    // копируем режим отображения
	SetMapMode(hdcMem, GetMapMode(hdc)); 

    // заполняем структуру информацией картинки
	GetObject (hBitmap, sizeof(BITMAP), (LPVOID) &bm); 

    // преобразуем координаты устройства в логические
	ptSize.x = bm.bmWidth; 
	ptSize.y = bm.bmHeight;
	DPtoLP (hdc, &ptSize, 1); 
	ptOrg.x = 0; 
	ptOrg.y = 0; 
	DPtoLP(hdcMem, &ptOrg, 1);

    // перенос битов картинки из контекста памяти на контекст устройства
	BitBlt (hdc, xStart, yStart, ptSize.x, ptSize.y, 
			hdcMem, ptOrg.x, ptOrg.y, SRCCOPY);

    // удаление контекста памяти
	DeleteDC (hdcMem);
	return;
} 

//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
static LRESULT CALLBACK WndProcVideoAdapter (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
PAINTSTRUCT ps;
vmvideo_struct *vmvideo;
HBITMAP bitmap;

    switch (iMsg){

        case WM_CREATE:
            vmvideo = ((CREATESTRUCT*)lParam)->lpCreateParams;
            SetWindowLongPtr (hwnd, 0, (LONG)vmvideo);
            return 0 ;

        case WM_DESTROY:
            return 0;

        case WM_SIZE:
            return -1;

        case WM_SETFOCUS:
            break;

        case WM_PAINT:
            
            vmvideo = (vmvideo_struct*) GetWindowLongPtr (hwnd, 0);
            //InvalidateRect(hwnd,NULL,TRUE);
            hdc = BeginPaint (hwnd, &ps);

            bitmap = CreateBitmap (vmvideo->width, vmvideo->height, 1, 32, vmvideo->mem);

            DrawBitmap (hdc, bitmap, 0, 0);
            DeleteObject (bitmap);

            EndPaint (hwnd, &ps);
            return 0;

        case WM_CLOSE:
            break;

        case WM_QUIT:
            break;

        case WM_DRAWITEM:
            break;

        case WM_NOTIFY:
            break;

        case WM_KEYDOWN:
            if (wParam == VK_SHIFT) {
                //printf ("Shift down\n");
                }
            return 0;

        case WM_COMMAND:
			return 0;

        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}


//--------------------

//--------------------
