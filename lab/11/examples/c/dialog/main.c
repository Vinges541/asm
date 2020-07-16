/****************************************************************************

    Модуль main.c

    Пример работы с диалоговыми окнами.

    Маткин Илья Александрович       06.11.2013

****************************************************************************/

#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

#include "resource.h"


//----------------------------------------

//----------------------------------------
// глобальные переменные и константы

#define AppWindowName "Application"

HINSTANCE hIns;             // описатель приложения

HWND hDialog;

//----------------------------------------
// объявление функций

BOOL CreateExtraConsole (void);

ATOM RegisterClassMainWindow (void);

HWND CreateMainWindow (void);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

BOOL CALLBACK DlgProc1 (HWND hDlg, UINT iMsg, WPARAM wParam, LPARAM lParam);

BOOL CALLBACK DlgProc2 (HWND hDlg, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// описание функций

//
// Функция создания консоли
//
BOOL CreateExtraConsole (void) {

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
ATOM RegisterClassMainWindow (void){

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
HWND CreateMainWindow (void){

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

    if(hwnd == NULL){
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
// Функция обработки сообщений главного окна приложения.
//
LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
HPEN pen;
PAINTSTRUCT ps;

    switch (iMsg){

        case WM_CREATE:
            return 0 ;

        case WM_DESTROY:
            PostQuitMessage (0);
            return 0;

        case WM_PAINT:
            
            //InvalidateRect(hwnd,NULL,TRUE);
            hdc = BeginPaint (hwnd,&ps);

            pen = CreatePen (PS_SOLID, 3, RGB (255,150,30));
            SelectObject (hdc, pen);

            MoveToEx (hdc, 0, 75, NULL);
            LineTo (hdc, 1000, 75);

            DeleteObject (pen);
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

        case WM_COMMAND:

            switch (LOWORD (wParam)) {
                case IDM_1:
                    DialogBox (hIns, "DlgBox1", hwnd, DlgProc1);
                    break;

                case IDM_2:
                    hDialog = CreateDialog (hIns, "DlgBox2", hwnd, DlgProc2);
                    ShowWindow (hDialog, SW_SHOWNORMAL);
                    UpdateWindow (hDialog);
                    break;

                case IDM_3:
                    MessageBox (hwnd, "Ё", "", MB_OK);
                    break;

                default:
                    break;			
                }

			return 0;
        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------


BOOL CALLBACK DlgProc1 (HWND hDlg, UINT iMsg, WPARAM wParam, LPARAM lParam) {


    switch (iMsg){
        case WM_INITDIALOG:
            
            PlaySound (MAKEINTRESOURCE(IDS_1), hIns, SND_RESOURCE | SND_ASYNC | SND_LOOP);

			return TRUE;

        case WM_DESTROY:
            PlaySound (NULL, NULL, 0);
            return TRUE;

        case WM_PAINT:
            break;

        case WM_COMMAND:
            switch (LOWORD (wParam)) {
                case IDB_OK:
                    EndDialog (hDlg, 0);
                    return TRUE;
                case IDOK:
                    EndDialog (hDlg, 0);
                    return TRUE;
                case IDCANCEL:
                    EndDialog (hDlg, 0);
                    return TRUE;
                }
            break;

        case WM_KEYDOWN:
            if (wParam == VK_ESCAPE)
                EndDialog (hDlg ,0);
            return TRUE;
		}

    return FALSE;
}

//--------------------

BOOL CALLBACK DlgProc2 (HWND hDlg, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC hdc;
PAINTSTRUCT	ps;
RECT rect;
HBRUSH brush;

    switch (iMsg){
        case WM_INITDIALOG:
			return TRUE;

        case WM_DESTROY:
            return TRUE;

        case WM_PAINT:
            hdc = BeginPaint (hDlg, &ps);
            
            GetClientRect (hDlg, &rect);
            brush = CreateSolidBrush (RGB (50, 50, 50));
            SelectObject(hdc, brush);

            Rectangle (hdc, 0, 0, rect.right-30, rect.bottom-30);

            DeleteObject (brush);
            EndPaint (hDlg, &ps);
            break;

        case WM_COMMAND:
            switch (LOWORD (wParam)) {
                case IDB_OK:
                    EndDialog (hDlg, 0);
                    return TRUE;
                case IDOK:
                    EndDialog (hDlg, 0);
                    return TRUE;
                case IDCANCEL:
                    EndDialog (hDlg, 0);
                    return TRUE;
                }
            break;

        case WM_KEYDOWN:
            if (wParam == VK_ESCAPE)
                EndDialog (hDlg, 0);
            return TRUE;
		}

    return FALSE;
}

//--------------------

//--------------------
