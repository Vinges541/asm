/****************************************************************************

    Модуль checkers.c

    Модуль описывает класс окон, представляющих шашки.
    Шашки могут перемещаться мышью.
    Начальное положение шашки и цвет шашки задаётся при ее создании.

    Маткин Илья Александрович       22.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>

#include "checkers.h"

//----------------------------------------
// глобальные переменные и константы

#define CheckerWindowName "CheckerWindow"

#define CHECKER_WIDTH   40
#define CHECKER_HEIGHT  CHECKER_WIDTH
#define CHECKER_CENTER  (CHECKER_WIDTH/2)

//----------------------------------------

// структура, которая храниться для каждого окна
typedef struct _CheckerWindowStruct{

    COLORREF color;

} CheckerWindowStruct;

//----------------------------------------
// объявление функций

static ATOM RegisterClassCheckerWindow(HINSTANCE ins,COLORREF color);

static BOOL MoveCheckerByCenter(HWND hwnd,unsigned int x,unsigned int y);

static void GetCheckerCenter(HWND hwnd,unsigned int *x,unsigned int *y);

static LRESULT CALLBACK WndProcChecker (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// описание функций

//
// Регистрация класса основного окна приложения
//
static ATOM RegisterClassCheckerWindow(HINSTANCE ins,COLORREF color){

WNDCLASSEX WndClass;    // структура класса
HBRUSH brush;

    brush = CreateSolidBrush(color);

    // сначала заполняются поля структуры
    WndClass.cbSize         = sizeof (WndClass);
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcChecker;
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = sizeof(void*);    // размер дополнительных данных для каждого окна
    WndClass.hInstance      = ins;
    WndClass.hIcon          = NULL;
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = brush;
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = CheckerWindowName;
    WndClass.hIconSm        = NULL;
    
    // регистрация класса
    return RegisterClassEx (&WndClass);
}

//--------------------

//
// Создание основного окна приложения
//
HWND CreateCheckerWindow (
    HINSTANCE ins,          // описатель приложения
    HWND parent,            // описатель родительского окна
    COLORREF color,         // цвет окна
    unsigned int x,         // x-координата центра
    unsigned int y){        // y-координата центра

HWND hwnd;  // описатель окна
HRGN rgn;

    // регистрация класса основного окна
    RegisterClassCheckerWindow(ins,color);

    // создание окна зарегестрированного класса
    hwnd = CreateWindow(
                          CheckerWindowName,            // имя зарегестрированного класса окна
                          NULL,          // заголовок окна
                          WS_OVERLAPPED | WS_CHILD,      // стиль окна
                          0,                       // X-координата левого верхнего угла
                          0,                       // Y-координата левого верхнего угла
                          0,                       // ширина окна
                          0,                       // высота окна
                          parent,                   // описатель родительского окна
                          NULL,                     // описатель главного меню (для главного окна)
                                                    // идентификатор окна (для дочернего окна)
                          ins,                      // идентификатор приложения
                          (LPARAM)color             // передаем цвет в качестве параметра
                                                    // доступ к параметрам возможен при обработке сообщения WM_CREATE
                          );

    if(hwnd == NULL){
        return NULL;
        }

    MoveCheckerByCenter (hwnd, x, y);

    // создаем регион окна
    rgn = CreateEllipticRgn (0, 0, CHECKER_WIDTH, CHECKER_HEIGHT);
    SetWindowRgn (hwnd, rgn, FALSE);

    // отображение окна
    ShowWindow (hwnd, SW_SHOWNORMAL);
    UpdateWindow (hwnd);

    return hwnd;
}

//--------------------

//
// Перемещение шашки в соответствии с указанными координами центра.
//
static BOOL MoveCheckerByCenter(HWND hwnd,unsigned int x,unsigned int y){

    return MoveWindow (hwnd, x-CHECKER_CENTER, y-CHECKER_CENTER, CHECKER_WIDTH, CHECKER_HEIGHT, TRUE);
}

//--------------------

//
// Получение координат центра шашки относительно родительского окна
//
static void GetCheckerCenter (HWND hwnd, unsigned int *x, unsigned int *y) {

RECT rect;
HWND parent;
POINT point;

    // получение расположения шашки на экране
    GetWindowRect (hwnd, &rect);

    // вычисляем координаты центра
    point.x = rect.left + CHECKER_WIDTH/2;
    point.y = rect.top + CHECKER_HEIGHT/2;

    // получаем описатель родительского окна
    parent = GetParent (hwnd);
    // переводим координаты на экране в координаты относительно родительского окна
    ScreenToClient (parent, &point);

    // возвращаем координаты центра
    *x = point.x;
    *y = point.y;

    return;
}

//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
static LRESULT CALLBACK WndProcChecker (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
HBRUSH brush;
PAINTSTRUCT ps;
CheckerWindowStruct *cws;
RECT rect;
unsigned int x,y;
unsigned int cx,cy;

    cws = (CheckerWindowStruct*) GetWindowLong(hwnd, 0);

    switch (iMsg){

        case WM_CREATE:

            // выделяем память для новой структуры окна
            cws = (CheckerWindowStruct*) malloc (sizeof (CheckerWindowStruct));
            if (cws == NULL)
                return -1;
            // запоминаем указатель на структуру в первом двойном слове дополнительной памяти окна
            SetWindowLong (hwnd, 0, (LONG)cws);

            // запоминаем цвет, переданный при создании окна
            cws->color = ((CREATESTRUCT*)lParam)->lpCreateParams;

            return 0 ;

        case WM_DESTROY:
            //PostQuitMessage(0);
            return 0;

        // сообщение посылается при закрашивании фона окна
        case WM_ERASEBKGND:
            // контекст устройства передаётся через wParam
            hdc = (HDC)wParam;
            // создаём кисть нужного цвета
            brush = CreateSolidBrush (cws->color);
            // закрашиваем прямоугольник нужного цвета и размера
            rect.left = 0;
            rect.top = 0;
            rect.right = CHECKER_WIDTH;
            rect.bottom = CHECKER_HEIGHT;
            FillRect (hdc, &rect, brush);
            DeleteObject (brush);
            return 0;

        case WM_LBUTTONDOWN:

            // захват мыши текущим окном
            SetCapture (hwnd);
            // делаем недействительным всю рабочую поверхность окна,
            // чтобы вызвать перерисовку окна
            InvalidateRect (hwnd, NULL, TRUE);
            return 0;

        case WM_LBUTTONUP:
            // освобождение захвата мыши
            ReleaseCapture();
            return 0;

        case WM_MOUSEMOVE:
            if (wParam & MK_LBUTTON) {
                // получаем координаты текущего положения мыши
                x = GET_X_LPARAM (lParam);
                y = GET_Y_LPARAM (lParam);
                // получаем коориданыт цента шашки
                GetCheckerCenter (hwnd,&cx,&cy);
                //перемещаем шашку на величину смещения мыши относительно центра
                MoveCheckerByCenter (hwnd, cx+(x-CHECKER_CENTER), cy+(y-CHECKER_CENTER));
                }
            return 0;

        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

//--------------------
