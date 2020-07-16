/****************************************************************************

    Модуль main.c

    Пример работы со статическими окнами

    Маткин Илья Александрович       23.10.2013

****************************************************************************/

#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

#include "main.h"

//----------------------------------------

//----------------------------------------
// глобальные переменные и константы

#define AppWindowName "Application"

// идентификаторы контролов
#define ST_1        201
#define ST_2        202
#define BT_1        203


HINSTANCE hIns;             // описатель приложения

HWND hStatic1;
HWND hStatic2;
HWND hButton1;

//----------------------------------------
// объявление функций

ATOM RegisterClassMainWindow (void);

HWND CreateMainWindow (void);

void CreateControlWindowsMain (HWND hwnd);

LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// описание функций

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
    
    hIns = hInstance;

    if(CreateMainWindow() == NULL)
        return 0;

    // Основной цикл обработки сообщений
    while( GetMessage(&msg, NULL, 0, 0) ){
        TranslateMessage(&msg);
        DispatchMessage(&msg);
        }

    return msg.wParam;
}

//--------------------

//
// Регистрация класса основного окна приложения
//
ATOM RegisterClassMainWindow (void) {

WNDCLASSEX WndClass;

    WndClass.cbSize         = sizeof (WndClass);        // размер структуры класса
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;              // адрес оконной процедуры класса
    WndClass.cbClsExtra     = 0;                        // размер дополнительной памяти класса
    WndClass.cbWndExtra     = 0;                        // размер дополнительной памяти окна
    WndClass.hInstance      = hIns;                     // описатель приложения
    WndClass.hIcon          = LoadIcon (hIns, "MainIcon");
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW); // курсор окна
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (GRAY_BRUSH);
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = AppWindowName;            // имя класса
    WndClass.hIconSm        = LoadIcon (hIns, "MainIcon");

    return RegisterClassEx (&WndClass);
}

//--------------------

//
// Создание основного окна приложения
//
HWND CreateMainWindow (void) {

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
                          hIns,NULL);

    if(hwnd == NULL){
        MessageBox(NULL,"Ошибка создания основного окна приложения","",MB_OK);
        return NULL;
        }

    // отображение окна
    ShowWindow (hwnd, SW_SHOWNORMAL);
    UpdateWindow (hwnd);

    return hwnd;
}

//--------------------

//
// Создание управляющих элементов (контролов) главного окна
//
void CreateControlWindowsMain (HWND hwnd) {

    hStatic1 = CreateWindow("static", NULL,
                            WS_CHILD | WS_VISIBLE,
                            10, 10,
                            100, 40,
                            hwnd, (HMENU)ST_1, hIns, NULL);
    SetWindowText(hStatic1,"static1");

    hStatic2 = CreateWindow("static", NULL,
                            WS_CHILD | WS_VISIBLE | WS_BORDER,
                            10, 60,
                            100, 40,
                            hwnd, (HMENU)ST_2, hIns, NULL);
    SetWindowText(hStatic2,"static2");

    hButton1=CreateWindow("button", "button1",
							WS_CHILD | WS_VISIBLE,
							10, 110,
							100, 40,
							hwnd, (HMENU)BT_1, hIns, NULL);
    SetWindowText(hButton1,"Hello");

    return;
}

//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

char buf1[100];
char buf2[100];

    switch (iMsg){

        case WM_CREATE:

            CreateControlWindowsMain(hwnd);
            return 0 ;

        case WM_DESTROY:

            PostQuitMessage(0);
            return 0;

        // событие посылается при перерисовки дочерних элементов управления окна
        // типа "static"
        // wParam содержит описатель контекста устройства
        // lParam содержит описатель дочернего окна
        case WM_CTLCOLORSTATIC:

            if ((HWND)lParam == hStatic1) {
                SetTextColor ((HDC)wParam, RGB (255,128,0));
                SetBkColor ((HDC)wParam, RGB (100,100,100));
                return (LRESULT)GetStockObject (WHITE_BRUSH);
                }
            break;

        // сообщение посылается при нажатии кнопки
        case WM_COMMAND:

            // в параметре wParam идентификатор нажатой кнопки
            switch(LOWORD (wParam)){

                case BT_1:
                    GetWindowText (hStatic1, buf1, 100);
                    GetWindowText (hStatic2, buf2, 100);
                    SetWindowText (hStatic2, buf1);
                    SetWindowText (hStatic1, buf2);
                    break;
                }

			return 0;

        case WM_LBUTTONDOWN:
            MessageBox(hwnd,"Left button down",NULL,MB_OK);
            break;
        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
