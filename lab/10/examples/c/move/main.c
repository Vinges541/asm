/****************************************************************************

    Модуль main.c

    Демонстрирует технику прорисовки движущихся объектов.

    Маткин Илья Александрович       23.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <stdio.h>

#include "block.h"

//----------------------------------------
// глобальные переменные и константы

#define AppWindowName "Application"

// идентификатор таймера
#define TIMER_1             200

// размер логического блока
#define LBLOCKSIZE          30

// размер игрового поля
#define SIZE_GAMEFIELD      300

// количество логических блоков в строке и столбце игрового поля
#define NUMOBJ              (SIZE_GAMEFIELD/LBLOCKSIZE)

HINSTANCE hIns;             // описатель приложения

HWND    HwndMainWindow;     // описатель главного окна
HWND    HwndBlock;          // описатель окна движущегося блока

// прямоугольник первого игрового поля
RECT glRectField1 = {50,50,50+SIZE_GAMEFIELD,50+SIZE_GAMEFIELD};

// прямоугольник второго игрового поля
RECT glRectField2 = {450,50,450+SIZE_GAMEFIELD,50+SIZE_GAMEFIELD};

unsigned char *objects[NUMOBJ]; // массив объектов в первом игровом поле

//----------------------------------------
// объявление функций

ATOM RegisterClassMainWindow();

HWND CreateMainWindow();

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// описание функций

//
// Основная функция оконных приложений
//
int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,PSTR szCmdLine,int iCmdShow){

MSG msg;
    
    hIns = hInstance;

    HwndMainWindow = CreateMainWindow();

    // устанавливаем таймер для перерисовки объектов в первом игровом поле
    SetTimer(HwndMainWindow,TIMER_1,100,NULL);

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
ATOM RegisterClassMainWindow(){

WNDCLASSEX WndClass;    // структура класса

    // сначала заполняются поля структуры
    WndClass.cbSize         = sizeof (WndClass);
    WndClass.style          = CS_DBLCLKS;
    WndClass.lpfnWndProc    = WndProcMain;
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = 0;
    WndClass.hInstance      = hIns;
    WndClass.hIcon          = LoadIcon (hIns, "MainIcon");
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (WHITE_BRUSH);
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = AppWindowName;
    WndClass.hIconSm        = LoadIcon (hIns, "MainIcon");
    
    // регистрация класса
    return RegisterClassEx (&WndClass);
}

//--------------------

//
// Создание основного окна приложения
//
HWND CreateMainWindow(){

HWND hwnd;  // описатель окна

    // регистрация класса основного окна
    RegisterClassMainWindow();

    // создание окна зарегестрированного класса
    hwnd = CreateWindowEx(
                          WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,    // расширенный стиль окна
                          AppWindowName,            // имя зарегестрированного класса окна
                          "Перемещения",          // заголовок окна
                          WS_OVERLAPPEDWINDOW,      // стиль окна
                          10,                       // X-координата левого верхнего угла
                          10,                       // Y-координата левого верхнего угла
                          800,                      // ширина окна
                          450,                      // высота окна
                          NULL,                     // описатель родительского окна
                          NULL,                     // описатель главного меню (для главного окна)
                                                    // идентификатор окна (для дочернего окна)
                          hIns,                     // идентификатор приложения
                          NULL
                          );

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
// Функция обработки сообщений главного окна приложения.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

HDC	hdc;
RECT rect;              // структура задающая прямоугольник
                        // содержит координаты левой верхней и правой нижней точек
PAINTSTRUCT ps;
unsigned int i,j;
unsigned char *tmp;
BlockWinNotifyStruct *bwn;

    switch (iMsg){
        case WM_CREATE:
            // создание движущегося блока для второго игрового поля
            HwndBlock = CreateBlockWindow (hIns, hwnd, RGB(100, 150, 100), 500, 200);

            // выделение памяти для хранения объетов первого игрового поля
            for (i = 0; i < NUMOBJ; ++i) {
                objects[i] = (unsigned char*) calloc (sizeof(unsigned char), NUMOBJ);
                }
            return 0 ;

        case WM_DESTROY:
            PostQuitMessage (0);
            return 0;

        case WM_PAINT:
            hdc = BeginPaint (hwnd, &ps);

            // рисуем игровые поля
            FrameRect (hdc, &glRectField1, GetStockObject(BLACK_BRUSH));
            FrameRect (hdc, &glRectField2 ,GetStockObject(BLACK_BRUSH));

            // рисуем объекты первого игрового поля
            for (i = 0; i < NUMOBJ; ++i){
                for (j = 0; j < NUMOBJ; ++j){
                    if (objects[i][j]) {
                        rect.left = glRectField1.left + j*LBLOCKSIZE;
                        rect.top = glRectField1.top + i*LBLOCKSIZE;
                        rect.right = rect.left + LBLOCKSIZE;
                        rect.bottom = rect.top + LBLOCKSIZE;
                        FillRect (hdc, &rect, GetStockObject (GRAY_BRUSH));
                        }
                    }
                }

            EndPaint (hwnd, &ps);
            return 0;

        // уведомление от дочерних окон
        case WM_NOTIFY:
            // обрабатываем сообщения от блока второго поля
            if( ((NMHDR*)lParam)->hwndFrom == HwndBlock ){
                int ret = 1;
                bwn = (BlockWinNotifyStruct*) lParam;

                // обрабатываем сообщение, посылаемое при перемещении блока
                // проверяем, чтобы блок не выходил за пределы второго поля
                if(bwn->nmh.code == IS_VALID_MOVE){
                    if( bwn->x < glRectField2.left ){
                        bwn->x = glRectField2.left;
                        ret = 0;
                        }
                    if( bwn->x > glRectField2.right ){
                        bwn->x = glRectField2.right;
                        ret = 0;
                        }
                    if( bwn->y < glRectField2.top ){
                        bwn->y = glRectField2.top;
                        ret = 0;
                        }
                    if( bwn->y > glRectField2.bottom ){
                        bwn->y = glRectField2.bottom;
                        ret = 0;
                        }
                        return ret;
                    }
                }
            return 0;

        // сообщение посылается при нажатии клавиши
        case WM_KEYDOWN:
            // обрабатываем нажатие клавиш управления курсором
            // соответственно, перемещаем блок влево, вправо, вверх и вниз
            switch (wParam) {
                case VK_LEFT:
                    MoveBlockWindow (HwndBlock, -LBLOCKSIZE, 0);
                    break;
                case VK_RIGHT:
                    MoveBlockWindow (HwndBlock, LBLOCKSIZE, 0);
                    break;
                case VK_UP:
                    MoveBlockWindow (HwndBlock, 0, -LBLOCKSIZE);
                    break;
                case VK_DOWN:
                    MoveBlockWindow(HwndBlock,0,LBLOCKSIZE);
                    break;
                }
            return 0;

        case WM_TIMER:

            // сдвигаем все линии первого игрового поля
            // на одну вниз
            tmp = objects[NUMOBJ-1];
            for (i = NUMOBJ-1; i > 0; --i)
                objects[i] = objects[i-1];
            objects[0] = tmp;

            // инициализируем первую линию новыми случайными значениями
            for (j = 0; j < NUMOBJ; ++j) {
                objects[0][j] = rand()%2;
                if (objects[0][j])
                    objects[0][j] = rand()%2;
                if (objects[0][j])
                    objects[0][j] = rand()%2;
                }

            // делаем недействительным первое игровое поле,
            // что вызовет генерацию сообщения WM_PAINT
            InvalidateRect (hwnd, &glRectField1, TRUE);

            return 0;

        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

//--------------------
