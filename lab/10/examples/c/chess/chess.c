/****************************************************************************

    Модуль chess.c

    Модуль описывает класс окон, представляющих фигуры.
    Окна могут перемещаться мышью.
    Начальное положение и цвет фигуры задаётся при ее создании.

    Маткин Илья Александрович       21.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <commctrl.h>

#include "chess.h"

//----------------------------------------
// глобальные переменные и константы

#define ChessWindowName "ChessWindow"

#define CHESS_WIDTH   40
#define CHESS_HEIGHT  CHESS_WIDTH
#define CHESS_CENTER  (CHESS_WIDTH/2)


HRGN glPawnRgn;
HRGN glCastleRgn;
HRGN glBishopRgn;
HRGN glKnightRgn;
HRGN glQueenRgn;
HRGN glKingRgn;

HIMAGELIST glImages;
HIMAGELIST glImages2;

//----------------------------------------

// структура, которая храниться для каждого окна
typedef struct _ChessWindowStruct {

    COLORREF color;     // цвет фигуры
    FIGTYPE  type;      // тип фигуры
    BOOL isCapture;

} ChessWindowStruct;

//----------------------------------------
// объявление функций

static BOOL CreateChessRgn (HINSTANCE ins);

static BOOL MoveChessByCenter (HWND hwnd, unsigned int x, unsigned int y);

static void GetChessCenter (HWND hwnd,unsigned int *x, unsigned int *y);

static LRESULT CALLBACK WndProcChess (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// описание функций

//
// Регистрация класса фигуры
//
ATOM RegisterClassChessWindow (HINSTANCE ins) {

WNDCLASSEX WndClass;    // структура класса

    CreateChessRgn (ins);

    // сначала заполняются поля структуры
    WndClass.cbSize         = sizeof (WndClass);
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcChess;
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = sizeof (void*);    // размер дополнительных данных для каждого окна
    WndClass.hInstance      = ins;
    WndClass.hIcon          = NULL;
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = NULL;
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = ChessWindowName;
    WndClass.hIconSm        = NULL;
    
    // регистрация класса
    return RegisterClassEx (&WndClass);
}

//--------------------

//
// Создание регионов фигур
//
static BOOL CreateChessRgn (HINSTANCE ins) {

HBITMAP hb;
HRGN DstRgn;
HRGN TempRgn;
BITMAP bitmap;
BITMAPINFOHEADER bmih;
unsigned int i,j;
unsigned int *bits;
unsigned int left,right;
unsigned int pattern;
unsigned int width;
HDC hdc;
//static char *names[] = {"Pawn", "Castle", "Bishop", "Knight", "Queen", "King"};
static HRGN *rgns[] = {&glPawnRgn, &glCastleRgn, &glBishopRgn, &glKnightRgn, &glQueenRgn, &glKingRgn};
unsigned int fig;

#define INVALID_OFFSET  0
#define SIZE_FIG        40

    // битовый массив
    bits = (unsigned int*) malloc(4 * 480 * 40);

    // загрузить картинку из ресурсов
    hb = LoadBitmap (ins, "Fig");
    // получить информацию о картинке в структуру
    GetObject (hb, sizeof(bitmap), &bitmap);

    // получить контекст устройства
    hdc = GetDC (NULL);

    // заполняем поля структуры для получения байтового массива
    bmih.biSize = sizeof (BITMAPINFOHEADER); 
    bmih.biWidth = bitmap.bmWidth;
    bmih.biHeight = bitmap.bmHeight;
    bmih.biPlanes = bitmap.bmPlanes;
    bmih.biBitCount = bitmap.bmBitsPixel;
    bmih.biClrUsed = 0;
    bmih.biCompression = BI_RGB; 
    bmih.biSizeImage = 0;
    bmih.biClrImportant = 0;
    // получаем картинку в виде массива байт
    if (!GetDIBits (hdc, hb, 0, bitmap.bmHeight, bits, (LPBITMAPINFO)&bmih, DIB_RGB_COLORS)) {
        int err = GetLastError();
        return FALSE;
        }
    ReleaseDC(NULL,hdc);

    // левый верхний угол используем в качестве эталона
    // для определения области, которую будем отбрасывать
    pattern = bits[0];

    width = bitmap.bmWidth;

    for (fig = 0; fig < 6; ++fig) {

        // создаём начальный пустой регион
        DstRgn = CreateRectRgn (0, 0, 0, 0);

        for (i = 0; i < bitmap.bmHeight; ++i){

            left = right = INVALID_OFFSET;

            for (j = SIZE_FIG*fig; j < SIZE_FIG*(fig+1); ++j) {

                if(bits[i*bitmap.bmWidth+j] == pattern){
                    if(left == INVALID_OFFSET)
                        continue;
                    else{
                        if(right == INVALID_OFFSET){
                            right = j - 1 - SIZE_FIG*fig;
                            }
                        else{
                            // если нашли левую и правую координату

                            // создаём регион высотой в 1 пиксел
                            TempRgn = CreateRectRgn (left, SIZE_FIG - 1 - i, right, SIZE_FIG - i);

                            // комбинируем с уже обнаруженными регионами
                            CombineRgn (DstRgn, DstRgn, TempRgn, RGN_OR);
                            left = right = INVALID_OFFSET;
                            DeleteObject(TempRgn);
                            }
                        }
                    }
                else{
                    if(left == INVALID_OFFSET)
                        left = j - SIZE_FIG * fig;
                    }
                }

            // добавляем в регион фигуры последнюю линию
            TempRgn = CreateRectRgn (left, SIZE_FIG - i - 1, right, SIZE_FIG - i);
            CombineRgn (DstRgn, DstRgn, TempRgn, RGN_OR);
            DeleteObject(TempRgn);
            }

        // сохраняем построенный регион
        *rgns[fig] = DstRgn;
        }

    return TRUE;
}


//--------------------

//
// Создание окна фигуры
//
HWND CreateChessWindow (
    HINSTANCE ins,          // описатель приложения
    HWND parent,            // описатель родительского окна
    COLORREF color,         // цвет фигуры
    unsigned int x,
    unsigned int y,
    FIGTYPE type){          // тип фигуры

HWND hwnd;  // описатель окна
HRGN rgn;   // описатель региона
ChessWindowStruct *cws;

    if(type > FIG_MAX || type == FIG_NULL)
        return NULL;

    // регистрация класса окна фигур
    RegisterClassChessWindow (ins);

    // создание окна зарегестрированного класса
    hwnd = CreateWindow(
                          ChessWindowName,            // имя зарегестрированного класса окна
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
                          NULL
                          );

    if(hwnd == NULL){
        return NULL;
        }

    // получаем структуру окна
    cws = (ChessWindowStruct*) GetWindowLong(hwnd,0);
    cws->type = type;
    cws->color = color;
    cws->isCapture = FALSE;

    // перемещаем фигуру
    MoveChessByCenter(hwnd,x,y);

    // выбираем регион в зависимости от типа фигуры
    if(type == FIG_PAWN)
        rgn = glPawnRgn;
    if(type == FIG_CASTLE)
        rgn = glCastleRgn;
    if(type == FIG_BISHOP)
        rgn = glBishopRgn;
    if(type == FIG_KNIGHT)
        rgn = glKnightRgn;
    if(type == FIG_QUEEN)
        rgn = glQueenRgn;
    if(type == FIG_KING)
        rgn = glKingRgn;

    // устанавливаем регион для окна
    SetWindowRgn(hwnd,rgn,FALSE);

    // отображение окна
    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    return hwnd;
}

//--------------------

//
// Перемещение фигуры в соответствии с указанными координами центра.
//
static BOOL MoveChessByCenter (HWND hwnd, unsigned int x, unsigned int y) {

    return MoveWindow (hwnd, x-CHESS_CENTER, y-CHESS_CENTER, CHESS_WIDTH, CHESS_HEIGHT, TRUE);
}

//--------------------

//
// Получение координат центра фигуры относительно родительского окна
//
static void GetChessCenter (HWND hwnd, unsigned int *x, unsigned int *y) {

RECT rect;
HWND parent;
POINT point;

    // получение расположения фигуры на экране
    GetWindowRect (hwnd, &rect);

    // вычисляем координаты центра
    point.x = rect.left + CHESS_WIDTH/2;
    point.y = rect.top + CHESS_HEIGHT/2;

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
static LRESULT CALLBACK WndProcChess (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
PAINTSTRUCT ps;
HIMAGELIST list;
HBRUSH brush;
ChessWindowStruct *cws;
RECT rect;
unsigned int x,y;
unsigned int cx,cy;

    // получаем структуру, связанную с окном
    cws = (ChessWindowStruct*) GetWindowLong (hwnd, 0);

    switch (iMsg){

        case WM_CREATE:

            // выделяем память для новой структуры окна
            cws = (ChessWindowStruct*) malloc (sizeof (ChessWindowStruct));
            if (cws == NULL)
                return -1;
            // запоминаем указатель на структуру в первом двойном слове дополнительной памяти окна
            SetWindowLong (hwnd, 0, (LONG)cws);

            return 0 ;

        case WM_DESTROY:
            //PostQuitMessage(0);
            return 0;

        case WM_PAINT:
            hdc = BeginPaint(hwnd,&ps);
            if(cws->color == COLOR_WHITE)
                list = glImages2;
            else
                list = glImages;
            EndPaint(hwnd,&ps);
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
            rect.right = CHESS_WIDTH;
            rect.bottom = CHESS_HEIGHT;
            FillRect (hdc, &rect, brush);
            return 0;

        case WM_LBUTTONDOWN:

            // захват мыши текущим окном
            SetCapture(hwnd);
            cws->isCapture = TRUE;
            // делаем недействительным всю рабочую поверхность окна,
            // чтобы вызвать перерисовку окна
            InvalidateRect(hwnd,NULL,TRUE);
            return 0;

        case WM_LBUTTONUP:
            // освобождение захвата мыши
            ReleaseCapture();
            cws->isCapture = FALSE;
            return 0;

        case WM_MOUSEMOVE:
            if (wParam & MK_LBUTTON && cws->isCapture) {
                // получаем координаты текущего положения мыши
                // относительно окна фигуры
                x = GET_X_LPARAM (lParam);
                y = GET_Y_LPARAM (lParam);
                // получаем координаты центра фигуры
                // относительно родительского окна
                GetChessCenter (hwnd, &cx, &cy);
                //перемещаем фигуру на величину смещения мыши относительно центра
                MoveChessByCenter (hwnd, cx + (x-CHESS_CENTER), cy + (y-CHESS_CENTER));
                }
            return 0;

        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

//--------------------
