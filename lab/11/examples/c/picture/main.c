/****************************************************************************

    Модуль main.c

    Пример отображения картинок.

    Маткин Илья Александрович       06.11.2013

****************************************************************************/

#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

#include "bmp.h"
#include "resource.h"


//----------------------------------------

//----------------------------------------
// глобальные переменные и константы

#define AppWindowName "Application"

HINSTANCE hIns;             // описатель приложения

HBITMAP glCurrentBitmap;    // описатель картинки

//----------------------------------------
// объявление функций

BOOL CreateExtraConsole (void);

ATOM RegisterClassMainWindow (void);

HWND CreateMainWindow (void);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

void UpdateCurrentBitmap (HBITMAP newBitmap, HWND hwnd);

//----------------------------------------
// описание функций

//
// Функция создания консоли
//
static BOOL CreateExtraConsole (void) {

	if (!AllocConsole())
		return FALSE;

    //HANDLE file = CreateFile("C:\\out.txt",GENERIC_WRITE,(DWORD)0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,(HANDLE) NULL);
	SetConsoleTitle ("Debug console");
	*stdout = *(_fdopen (_open_osfhandle ((long)GetStdHandle (STD_OUTPUT_HANDLE), _O_TEXT), "w"));
    //*stdout = *(_fdopen(_open_osfhandle((long)file,_O_TEXT),"w"));
	*stderr = *(_fdopen (_open_osfhandle ((long)GetStdHandle (STD_ERROR_HANDLE), _O_TEXT), "w"));
	*stdin = *(_fdopen (_open_osfhandle ((long)GetStdHandle (STD_INPUT_HANDLE), _O_TEXT), "r"));
	if (setvbuf (stdout, NULL, _IONBF, 0))
		return FALSE;
	if (setvbuf (stderr, NULL, _IONBF, 0))
		return FALSE;

	return TRUE;
}

//--------------------

//
// Основная функция оконных приложений
//
int WINAPI WinMain (
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    PSTR szCmdLine,
    int iCmdShow) {

MSG msg;
HACCEL  hAccel;
HWND HwndMainWindow;
    
    hIns = hInstance;

    HwndMainWindow = CreateMainWindow();
    if (HwndMainWindow == NULL)
        return 0;

	CreateExtraConsole();

    hAccel = LoadAccelerators (hIns, "Accel");

    // Основной цикл обработки сообщений
    while ( GetMessage(&msg, NULL, 0, 0) ) {
        if (!TranslateAccelerator (HwndMainWindow, hAccel, &msg)) {
            TranslateMessage (&msg);
            DispatchMessage (&msg);
            }
        }

    return msg.wParam;
}

//--------------------

//
// Регистрация класса основного окна приложения
//
static ATOM RegisterClassMainWindow (void){

WNDCLASSEX WndClass;

    WndClass.cbSize         = sizeof (WndClass);        // размер структуры класса
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;              // адрес оконной процедуры класса
    WndClass.cbClsExtra     = 0;                        // размер дополнительной памяти класса
    WndClass.cbWndExtra     = sizeof(void*);            // размер дополнительной памяти окна
    WndClass.hInstance      = hIns;                     // описатель приложения
    WndClass.hIcon          = LoadIcon (hIns, "MainIcon");
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW); // курсор окна
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (BLACK_BRUSH);
    WndClass.lpszMenuName   = "MainMenu";               // имя ресарса главного меню
    WndClass.lpszClassName  = AppWindowName;            // имя класса
    WndClass.hIconSm        = LoadIcon (hIns, "MainIcon");

    return RegisterClassEx (&WndClass);
}

//--------------------

//
// Создание основного окна приложения
//
static HWND CreateMainWindow (void){

HWND hwnd;

    RegisterClassMainWindow();

    hwnd = CreateWindowEx (WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,
                          AppWindowName,
                          "Application",
                          WS_OVERLAPPEDWINDOW,
                          10, 10,
                          650, 600,
                          NULL,                 // описатель родительского окна
                          NULL,                 // описатель главного меню (для главного окна)
                          hIns, NULL);

    if (hwnd == NULL) {
        MessageBox (NULL, "Ошибка создания основного окна приложения", "", MB_OK);
        return NULL;
        }

    // отображение окна
    ShowWindow (hwnd, SW_SHOWNORMAL);
    UpdateWindow (hwnd);

    return hwnd;
}

//--------------------

//
// Функция обновляет текущую картинку
//
static void UpdateCurrentBitmap (HBITMAP newBitmap, HWND hwnd) {

    if (newBitmap) {
        if (glCurrentBitmap) {
            DeleteObject (glCurrentBitmap);
            }
        glCurrentBitmap = newBitmap;
        InvalidateRect (hwnd, NULL, TRUE);
        }

    return;
}


//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
static LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
PAINTSTRUCT ps;
HBITMAP newBitmap;

    switch (iMsg){

        case WM_CREATE:
            return 0 ;

        case WM_DESTROY:
            PostQuitMessage (0);
            return 0;

        case WM_PAINT:
            
            hdc = BeginPaint (hwnd,&ps);

            if (glCurrentBitmap)
				DrawBitmap(hdc, glCurrentBitmap, 0, 0);

            EndPaint (hwnd, &ps);
            return 0;

        case WM_CLOSE:
            break;

        case WM_QUIT:
            break;

        case WM_COMMAND:

            switch (LOWORD (wParam)) {
                case IDM_OPEN:
                    newBitmap = LoadBmpFile (hwnd, hIns);
                    UpdateCurrentBitmap (newBitmap, hwnd);
                    break;

                case IDM_OPEN2:
                    // Загружаем картинку из ресурсов
                    newBitmap = LoadImage (hIns, "Bitmap1", IMAGE_BITMAP, 0, 0, 0);
                    UpdateCurrentBitmap (newBitmap, hwnd);
                    break;

                case IDM_SAVE:
                    if (glCurrentBitmap){
                        SaveBMPFile (glCurrentBitmap, hwnd);
                        }
                    break;

                case IDM_INVERT:
                    if (glCurrentBitmap){
                        newBitmap = InvertBitmap (glCurrentBitmap);
                        UpdateCurrentBitmap (newBitmap, hwnd);
                        }
                    break;

                case IDM_GRAYSTYLE:
                    if (glCurrentBitmap){
                        newBitmap = GetGraystyleBitmap (glCurrentBitmap);
                        UpdateCurrentBitmap (newBitmap, hwnd);
                        }
                    break;

                default:
                    break;			
                }

			return 0;
        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------


//--------------------
