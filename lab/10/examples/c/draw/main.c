/****************************************************************************

    Модуль main.c

    Демонстрирует пример рисования в окне простых графических примитивов.

    Маткин Илья Александрович       21.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <stdio.h>

//----------------------------------------
// глобальные переменные и константы

#define AppWindowName "Application"

HINSTANCE hIns;             // описатель приложения

HWND    HwndMainWindow;     // описатель главного окна

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
                          "Draw example",           // заголовок окна
                          WS_OVERLAPPEDWINDOW,      // стиль окна
                          10,                       // X-координата левого верхнего угла
                          10,                       // Y-координата левого верхнего угла
                          600,                      // ширина окна
                          600,                      // высота окна
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
    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

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
HBRUSH white_brush;     // белая кисть
HBRUSH black_brush;     // чёрная кисть
HBRUSH yellow_brush;    // жёлтая кисть
HPEN border_pen;        // перо для прорисовки линий
COLORREF color_brush;
unsigned int i,j;

    switch (iMsg){
        case WM_CREATE:
            return 0 ;

        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;

        case WM_PAINT:
            hdc = BeginPaint(hwnd,&ps);

            // создаём кисть нужного цвета
            color_brush = RGB(0,0,0);
            black_brush = CreateSolidBrush(color_brush);
            color_brush = RGB(255,255,255);
            white_brush = CreateSolidBrush(color_brush);
            color_brush = RGB(255,255,0);
            yellow_brush = CreateSolidBrush(color_brush);

            // назначаем контексту устройсва по умолчанию жёлтую кисть
            SelectObject(hdc,yellow_brush);
            // рисуем эллипс, который задаётся с помощью ограничивающего прямоугольника
            // эллипс закрашивается кистью, установленной для контекста устройства
            Ellipse(
                    hdc,    // контекст устройства
                    0,      // Х-координата левой верхней точки
                    0,      // У-координата левой верхней точки
                    20,     // Х-координата правой нижней точки
                    20      // У-координата правой нижней точки
                    );

            // создаём перо для рисования линий
            border_pen = CreatePen(
                                   PS_SOLID,    // стиль линии
                                   4,           // толщина линии
                                   RGB(100,200,120) // цвет линии
                                   );
            // устанавливаем созданное перо по умолчанию для контекста устройства
            SelectObject(hdc,border_pen);
            // устанавливаем белую кисть по умолчанию для контекста устройства
            SelectObject(hdc,white_brush);
            // рисуем прямоугольник
            // края прямоугольника рисуются пером по умолчанию
            // закрашивается прямоугольник кистью по умолчанию
            Rectangle(hdc,80,80,520,520);

            // рисуем черно-белое клеточное поле в прямоугольнике с углами (100,100),(500,500)
            // 64 клетки размером 50х50 рисуются построчно
            for(i=0;i<8;i++){
                for(j=0;j<8;j++){
                    // заполняем поля структуры текущего прямоугольника
                    rect.left = 100 + i*50;
                    rect.top = 100 + j*50;
                    rect.right = 150 + i*50;
                    rect.bottom = 150 + j*50;

                    // рисуем закрашенный прямоугольник нужного цвета
                    if( (i+j)%2 == 0 )
                        FillRect(hdc,&rect,white_brush);
                    else
                        FillRect(hdc,&rect,black_brush);
                    }
                }
            
            // рисуем рамку
            rect.left = 100;
            rect.top = 100;
            rect.right = 500;
            rect.bottom = 500;
            FrameRect(hdc,&rect,black_brush);

            // удаляем созданный объекты
            DeleteObject(black_brush);
            DeleteObject(white_brush);
            DeleteObject(yellow_brush);
            DeleteObject(border_pen);

            EndPaint(hwnd,&ps);
            return 0;

        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
