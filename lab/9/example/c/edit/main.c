/****************************************************************************

    Модуль main.c

    Пример работы с текстовыми полями.

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

#define ED_1        201     // идентификатор верхнего текстового поля
#define ED_2        202     // идентификатор нижнего текстового поля
#define BT_1        203     // идентификатор кнопки копирования
#define BT_2        204     // идентификатор кнопки добавления


HINSTANCE hIns;             // описатель приложения

HWND hEdit1;
HWND hEdit2;
HWND hButton1;
HWND hButton2;

//----------------------------------------
// объявление функций

void InsertStringTailEdit (HWND hwnd, char *str);

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
ATOM RegisterClassMainWindow (void){

WNDCLASSEX WndClass;

    WndClass.cbSize         = sizeof (WndClass);        // размер структуры класса
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;              // адрес оконной процедуры класса
    WndClass.cbClsExtra     = 0;                        // размер дополнительной памяти класса
    WndClass.cbWndExtra     = 0;                        // размер дополнительной памяти окна
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
void CreateControlWindowsMain (HWND hwnd){


    hEdit1 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_RIGHT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_1, hIns, NULL);

    hEdit2 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_READONLY,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_2, hIns, NULL);


    hButton1 = CreateWindow ("button", "скопировать",
							WS_CHILD | WS_VISIBLE,
							10, 10,
							100, 30,
							hwnd, (HMENU)BT_1, hIns, NULL);

    hButton2 = CreateWindow ("button", "добавить",
							WS_CHILD | WS_VISIBLE,
							200, 10,
							100, 30,
							hwnd, (HMENU)BT_2, hIns, NULL);

    return;
}

//--------------------

//
// Функция обработки события изменения главного окна
//
LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

unsigned int width;
unsigned int height;

    width = LOWORD(lParam);
    height = HIWORD(lParam);

    // масштабируем текстовые поля
    MoveWindow(hEdit1,
               10,
               100,
               width-20,
               (height-120)/2,
               TRUE
               );

    MoveWindow(hEdit2,
               10,
               110 + (height-120)/2,
               width-20,
               (height-120)/2,
               TRUE
               );

	return 0;
}

//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

DWORD textLength;
DWORD offset;
char *buf;

    switch (iMsg){

        case WM_CREATE:

            CreateControlWindowsMain(hwnd);
            return 0 ;

        case WM_DESTROY:

            PostQuitMessage(0);
            return 0;

        case WM_SIZE:
            return ProcessingSizeEvent (hwnd, iMsg ,wParam, lParam);

        case WM_COMMAND:

            switch(LOWORD (wParam)){

                case BT_1:
                    // получаем длину строки в первом текстовом поле
                    textLength = GetWindowTextLength (hEdit1);

                    // выделяем память
                    buf = (char*) malloc (textLength + 1);

                    // считываем строку из первого текстового поля
                    GetWindowText (hEdit1, buf, textLength + 1);

                    // устанавливаем строку во второе текстовое поле
                    SetWindowText (hEdit2, buf);

                    free (buf);
                    break;

                case BT_2:
                    // получаем длину строки в первом текстовом поле
                    textLength = GetWindowTextLength (hEdit1);

                    // выделяем память
                    buf = (char*) malloc (textLength + 1);

                    // считываем строку из первого текстового поля
                    GetWindowText (hEdit1, buf, textLength + 1);

                    // получаем длину строки во втором текстовом поле
                    offset = GetWindowTextLength (hEdit2);

                    // перемещаем курсор в конец текста
                    SendMessage (hEdit2, EM_SETSEL, offset, offset);

                    // посылаем строку
                    SendMessage (hEdit2, EM_REPLACESEL, 0, (LPARAM)buf);

                    free (buf);
                    break;

                default:
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
