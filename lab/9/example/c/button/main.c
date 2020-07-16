/****************************************************************************

    Модуль main.c

    Пример работы с кнопками.

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

// идентификаторы кнопок
#define BT_1        201
#define BT_2        202
#define BT_3        203
#define BT_4        204
#define BT_5        205
#define BT_6        206
#define BT_7        207

HINSTANCE hIns;             // описатель приложения

HWND hButton1;
HWND hButton2;
HWND hButton3;
HWND hButton4;
HWND hButton5;
HWND hButton6;
HWND hButton7;

//----------------------------------------
// объявление функций

ATOM RegisterClassMainWindow (void);

HWND CreateMainWindow (void);

void CreateControlWindowsMain (HWND hwnd);

LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// описание функций

//
// Основная функция оконных приложений
//
int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,PSTR szCmdLine,int iCmdShow){

MSG msg;
    
    hIns = hInstance;

    if (CreateMainWindow() == NULL)
        return 0;

    // Основной цикл обработки сообщений
    while ( GetMessage(&msg, NULL, 0, 0) ) {
        TranslateMessage (&msg);
        DispatchMessage (&msg);
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
    WndClass.lpszMenuName   = NULL;
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

    hwnd = CreateWindowEx(WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,
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
    ShowWindow (hwnd,SW_SHOWNORMAL);
    UpdateWindow (hwnd);

    return hwnd;
}

//--------------------

//
// Создание управляющих элементов (контролов) главного окна
//
void CreateControlWindowsMain (HWND hwnd){

    hButton1 = CreateWindow("button", "button1",
                            WS_CHILD | WS_VISIBLE,
                            10, 0,
                            100, 30,
                            hwnd, (HMENU)BT_1, hIns, NULL);

    hButton2 = CreateWindow("button", "button2",
                            WS_CHILD | WS_VISIBLE | BS_3STATE,
                            10, 50,
                            100, 30,
                            hwnd, (HMENU)BT_2, hIns, NULL);

    hButton3 = CreateWindow("button", "button3",
                            WS_CHILD | WS_VISIBLE | BS_AUTO3STATE ,
                            10, 100,
                            100, 30,
                            hwnd, (HMENU)BT_3, hIns, NULL);

    hButton4 = CreateWindow("button", "button4",
                            WS_CHILD | WS_VISIBLE | BS_AUTOCHECKBOX,
                            10, 150,
                            100, 30,
                            hwnd, (HMENU)BT_4, hIns, NULL);

    hButton5 = CreateWindow("button", "button5",
                            WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON ,
                            10, 200,
                            100, 30,
                            hwnd, (HMENU)BT_5, hIns, NULL);

    hButton6 = CreateWindow("button", "button6",
                            WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON ,
                            10, 250,
                            100, 30,
                            hwnd, (HMENU)BT_6, hIns, NULL);

    hButton7 = CreateWindow("button", "button7",
                            WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON ,
                            10, 300,
                            100, 30,
                            hwnd, (HMENU)BT_7, hIns, NULL);

    return;
}

//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

DWORD state;

    switch (iMsg){

        case WM_CREATE:

            CreateControlWindowsMain(hwnd);
            return 0 ;

        case WM_DESTROY:

            PostQuitMessage(0);
            return 0;

        // сообщение посылается при нажатии кнопок
        case WM_COMMAND:

            // в параметре wParam идентификатор нажатой кнопки
            switch(LOWORD (wParam)){

                case BT_1:
                    MessageBox(hwnd,"Button1 down",NULL,MB_OK);
                    break;

                case BT_2:
                    // получаем состояние кнопки
                    state = SendMessage (hButton2, BM_GETCHECK, 0, 0);
                    if (state == BST_UNCHECKED) {
                        MessageBox(hwnd,"Button2 unchecked",NULL,MB_OK);
                        SetWindowText (hButton2, "checked");
                        }
                    else if (state == BST_CHECKED) {
                        MessageBox(hwnd,"Button2 checked",NULL,MB_OK);
                        SetWindowText (hButton2, "indeterminate");
                        }
                    else if (state == BST_INDETERMINATE) {
                        MessageBox(hwnd,"Button2 indeterminate",NULL,MB_OK);
                        SetWindowText (hButton2, "unchecked");
                        }
                    // изменяем состояние на следующее
                    SendMessage (hButton2, BM_SETCHECK, (state+1)%3, 0);
                    break;

                case BT_3:
                    state = SendMessage (hButton3, BM_GETCHECK, 0, 0);
                    if (state == BST_UNCHECKED) {
                        MessageBox(hwnd,"Button3 unchecked",NULL,MB_OK);
                        }
                    else if (state == BST_CHECKED) {
                        MessageBox(hwnd,"Button3 checked",NULL,MB_OK);
                        }
                    else if (state == BST_INDETERMINATE) {
                        MessageBox(hwnd,"Button3 indeterminate",NULL,MB_OK);
                        }
                    break;

                case BT_4:
                    state = SendMessage (hButton4, BM_GETCHECK, 0, 0);
                    if (state == BST_UNCHECKED) {
                        MessageBox(hwnd,"Button4 unchecked",NULL,MB_OK);
                        ShowWindow (hButton3, SW_HIDE);
                        }
                    else if (state == BST_CHECKED) {
                        MessageBox(hwnd,"Button4 checked",NULL,MB_OK);
                        ShowWindow (hButton3, SW_SHOWNORMAL);
                        }
                    break;

                case BT_5:
                    state = SendMessage (hButton5, BM_GETCHECK, 0, 0);
                    if (state == BST_UNCHECKED) {
                        MessageBox(hwnd,"Button5 unchecked",NULL,MB_OK);
                        }
                    else if (state == BST_CHECKED) {
                        MessageBox(hwnd,"Button5 checked",NULL,MB_OK);
                        }
                    break;

                case BT_6:
                    MessageBox(hwnd,"Button6 checked",NULL,MB_OK);
                    break;

                case BT_7:
                    MessageBox(hwnd,"Button7 checked",NULL,MB_OK);
                    break;

                default:
                    break;			
                }

			return 0;

        case WM_LBUTTONDOWN:
            break;
        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
