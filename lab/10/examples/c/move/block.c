/****************************************************************************

    Модуль block.c

    Модуль описывает класс окон, представляющих перемещаемые блоки.
    Начальное положение блока и цвет блока задаётся при его создании.

    Маткин Илья Александрович       22.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>

#include "block.h"

//----------------------------------------
// глобальные переменные и константы

#define BlockWindowName "BlockWindow"

#define BLOCK_WIDTH   45
#define BLOCK_HEIGHT  BLOCK_WIDTH
#define BLOCK_CENTER  (BLOCK_WIDTH/2)

//----------------------------------------

// структура, которая храниться для каждого окна
typedef struct _BlockWindowStruct{

    BOOL capture;           // флаг захвата окна
    COLORREF color;         // цвет фона окна
    unsigned int x_capture; // Х-координата мыши при захвате окна
    unsigned int y_capture; // У-координата мыши при захвате окна

} BlockWindowStruct;

//----------------------------------------
// объявление функций

static ATOM RegisterClassBlockWindow(HINSTANCE ins,COLORREF color);

static BOOL MoveBlockByCenter(HWND hwnd,unsigned int x,unsigned int y);

static void GetBlockCenter(HWND hwnd,unsigned int *x,unsigned int *y);

static LRESULT CALLBACK WndProcBlock (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// описание функций

//
// Регистрация класса основного окна приложения
//
static ATOM RegisterClassBlockWindow(HINSTANCE ins,COLORREF color){

WNDCLASSEX WndClass;    // структура класса
HBRUSH brush;

    brush = CreateSolidBrush(color);

    // сначала заполняются поля структуры
    WndClass.cbSize         = sizeof (WndClass);
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcBlock;
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = sizeof(void*);    // размер дополнительных данных для каждого окна
    WndClass.hInstance      = ins;
    WndClass.hIcon          = NULL;
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = brush;
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = BlockWindowName;
    WndClass.hIconSm        = NULL;
    
    // регистрация класса
    return RegisterClassEx (&WndClass);
}

//--------------------

//
// Создание основного окна приложения
//
HWND CreateBlockWindow(HINSTANCE ins,HWND parent,COLORREF color,unsigned int x,unsigned int y){

HWND hwnd;  // описатель окна

    // регистрация класса основного окна
    RegisterClassBlockWindow(ins,color);

    // создание окна зарегестрированного класса
    hwnd = CreateWindow(
                          BlockWindowName,            // имя зарегестрированного класса окна
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
                          (LPVOID)color             // передаем цвет в качестве параметра
                                                    // доступ к параметрам возможен при обработке сообщения WM_CREATE
                          );

    if(hwnd == NULL){
        return NULL;
        }

    MoveBlockByCenter(hwnd,x,y);

    // отображение окна
    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    return hwnd;
}

//--------------------

//
// Перемещение блока в соответствии с указанными координами центра.
//
static BOOL MoveBlockByCenter(HWND hwnd,unsigned int x,unsigned int y){

    return MoveWindow(hwnd,x-BLOCK_CENTER,y-BLOCK_CENTER,BLOCK_WIDTH,BLOCK_HEIGHT,TRUE);
}

//--------------------

//
// Получение координат центра блока относительно родительского окна
//
static void GetBlockCenter(HWND hwnd,unsigned int *x,unsigned int *y){

RECT rect;
HWND parent;
POINT point;

    // получение расположения блока на экране
    GetWindowRect(hwnd,&rect);

    // вычисляем координаты центра
    point.x = rect.left + BLOCK_WIDTH/2;
    point.y = rect.top + BLOCK_HEIGHT/2;

    // получаем описатель родительского окна
    parent = GetParent(hwnd);
    // переводим координаты на экране в координаты относительно родительского окна
    ScreenToClient(parent,&point);

    // возвращаем координаты центра
    *x = point.x;
    *y = point.y;

    return;
}

//--------------------


static BOOL IsValidMove (HWND hwnd, unsigned int *x, unsigned int *y) {

HWND parent;
BlockWinNotifyStruct bwn;

    parent = GetParent(hwnd);
    bwn.nmh.hwndFrom = hwnd;
    bwn.nmh.code = IS_VALID_MOVE;

    bwn.x = *x - BLOCK_CENTER;
    bwn.y = *y - BLOCK_CENTER;

    if (!SendMessage (parent, WM_NOTIFY, 0, (LPARAM)&bwn)) {
        *x = bwn.x + BLOCK_CENTER;
        *y = bwn.y + BLOCK_CENTER;
        return FALSE;
        }

    bwn.x = *x + BLOCK_CENTER;
    bwn.y = *y + BLOCK_CENTER;

    if (!SendMessage (parent, WM_NOTIFY, 0, (LPARAM)&bwn)) {
        *x = bwn.x - BLOCK_CENTER;
        *y = bwn.y - BLOCK_CENTER;
        return FALSE;
        }

    return TRUE;
}

//--------------------


void MoveBlockWindow (HWND hwnd, int dx, int dy) {

int x,y;

    GetBlockCenter (hwnd, &x, &y);

    x += dx;
    y += dy;

    IsValidMove (hwnd, &x, &y);
    MoveBlockByCenter (hwnd, x, y);

    return;
}

//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
static LRESULT CALLBACK WndProcBlock (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
HBRUSH brush;
PAINTSTRUCT ps;
BlockWindowStruct *cws;
RECT rect;
unsigned int x,y;
unsigned int cx,cy;

    cws = (BlockWindowStruct*) GetWindowLong (hwnd, 0);

    switch (iMsg){

        case WM_CREATE:

            // выделяем память для новой структуры окна
            cws = (BlockWindowStruct*) malloc (sizeof (BlockWindowStruct));
            if (cws == NULL)
                return -1;
            // запоминаем указатель на структуру в первом двойном слове дополнительной памяти окна
            SetWindowLong (hwnd, 0, (LONG)cws);

            // запоминаем цвет, переданный при создании окна
            cws->color = (COLORREF)((CREATESTRUCT*)lParam)->lpCreateParams;

            return 0 ;

        case WM_DESTROY:
            //PostQuitMessage (0);
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
            rect.right = BLOCK_WIDTH;
            rect.bottom = BLOCK_HEIGHT;
            FillRect (hdc, &rect, brush);
            return 0;

        case WM_KEYDOWN:
            SendMessage (GetParent (hwnd), iMsg, wParam, lParam);
            return 0;

        case WM_LBUTTONDOWN:

            cws->x_capture = GET_X_LPARAM (lParam);
            cws->y_capture = GET_Y_LPARAM (lParam);
            cws->capture = TRUE;
            // захват мыши текущим окном
            SetCapture(hwnd);
            // делаем недействительным всю рабочую поверхность окна,
            // чтобы вызвать перерисовку окна
            InvalidateRect (hwnd, NULL, TRUE);
            return 0;

        case WM_LBUTTONUP:
            cws->capture = FALSE;
            // освобождение захвата мыши
            ReleaseCapture();
            return 0;

        case WM_MOUSEMOVE:
            //if(wParam & MK_LBUTTON){
            if (cws->capture == TRUE) {
                // получаем координаты текущего положения мыши
                // относительно блока
                x = GET_X_LPARAM (lParam);
                y = GET_Y_LPARAM (lParam);
                // получаем координаты центра блока относительно
                // родительского окна
                GetBlockCenter (hwnd, &cx, &cy);
                cx += x - cws->x_capture;
                cy += y - cws->y_capture;
                
                // проверка возможности перемещения
                if (IsValidMove (hwnd, &cx, &cy)) {
                    //перемещаем блок на величину смещения мыши относительно точки захвата
                    MoveBlockByCenter (hwnd, cx, cy);
                    }
                else{
                    // иначе перемещаем блок обратно
                    POINT point;
                    MoveBlockByCenter (hwnd, cx, cy);

                    // пемещаем курсор мыши обратно
                    point.x = cws->x_capture;
                    point.y = cws->y_capture;

                    // переводим координаты относительно блока
                    // в координаты экрана
                    ClientToScreen (hwnd, &point);

                    SetCursorPos (point.x, point.y);
                    }
                }
            return 0;

        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
