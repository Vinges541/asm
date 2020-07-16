/****************************************************************************

    Модуль main.c

    Пример простого оконного приложения.

    Маткин Илья Александрович       10.06.2010

****************************************************************************/

#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

//----------------------------------------
// глобальные переменные и константы

#define AppWindowName "Application"

HINSTANCE hIns;             // описатель приложения

HWND HwndMainWindow;        // описатель главного окна

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
int WINAPI WinMain(
 HINSTANCE hInstance,       // описатель текущего приложения
 HINSTANCE hPrevInstance,   // всегда NULL
 PSTR szCmdLine, 
 int iCmdShow
){

MSG msg;
    
    hIns = hInstance;

    HwndMainWindow = CreateMainWindow();
    if (HwndMainWindow == NULL) {
        return 0;
        }

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
    WndClass.cbSize         = sizeof (WndClass);    // размер структуры класса
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;          // адрес оконной процедуры класса
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = 0;
    WndClass.hInstance      = hIns;                 // описатель приложения
    WndClass.hIcon          = LoadIcon (hIns, "MainIcon");  // иконка приложения
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (GRAY_BRUSH);    // кисть для фона
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = AppWindowName;        // имя класса
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

    // создание окна зарегистрированного класса
    hwnd = CreateWindowEx(
                          WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,    // расширенный стиль окна
                          AppWindowName,            // имя зарегистрированного класса окна
                          "Application",            // заголовок окна
                          WS_OVERLAPPEDWINDOW,      // стиль окна
                          10,                       // X-координата левого верхнего угла
                          10,                       // Y-координата левого верхнего угла
                          650,                      // ширина окна
                          600,                      // высота окна
                          NULL,                     // описатель родительского окна
                          NULL,                     // описатель главного меню (для главного окна)
                                                    // идентификатор окна (для дочернего окна)
                          hIns,                     // идентификатор приложения
                          NULL
                          );

    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    hwnd = CreateWindowEx(
                          /*WS_EX_CONTROLPARENT | WS_EX_APPWINDOW*/0,    // расширенный стиль окна
                          AppWindowName,            // имя зарегистрированного класса окна
                          "Application",            // заголовок окна
                          WS_OVERLAPPEDWINDOW,      // стиль окна
                          10,                       // X-координата левого верхнего угла
                          10,                       // Y-координата левого верхнего угла
                          650,                      // ширина окна
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
// Вызывается системой при поступлении сообщения для главного окна
// с соответствующими параметрами.
//
LRESULT CALLBACK WndProcMain(
HWND hwnd,      // описатель окна, получившего сообщение
UINT iMsg,      // идентификатор (номер) сообщения
WPARAM wParam,  // параметр сообщения
LPARAM lParam   // параметр сообщения
){

HDC	hdc;
HPEN pen;
PAINTSTRUCT ps;

    switch (iMsg){
        // сообщение посылается сразу после создания окна, до его отображения
        case WM_CREATE:
            return 0;

        // сообщение посылается после уничтожения окна
        case WM_DESTROY:
            // вызываем функцию, посылающую сообщение завершения процесса,
            // если закрывается главное окно
            if (hwnd == HwndMainWindow)
                PostQuitMessage(0);
            return 0;

        // сообщение посылается при перерисовке окна
        case WM_PAINT:

            // Перед перерисовкой окна вызываем специальную функцию,
            // которая подготавливает окно к рисованию и
            // возвращает описатель контекста устройства для данного окна.
            // Рисование осуществляется на контексте устройства окна.
            hdc = BeginPaint(hwnd,&ps);
            // создаём объект "перо" для рисования линий
            pen = CreatePen(
                            PS_DASHDOT,       // задаём тип линии (сплошная)
                            2,              // толщина линии
                            RGB(255,150,30) // цвет линии с помощью макроса
                            );
            // ассоциируем созданную перо с контекстом устройства
            SelectObject(hdc,pen);

            // перемещаем текущую позицию, с которой начинается рисование
            MoveToEx(
                     hdc,           // описатель контекста устройства
                     0,             // X-координата
                     75,            // Y-координата
                     NULL);

            // рисуем линию выбранной кистью от текущей позиции до указанной точки
            LineTo(
                   hdc,             // описатель контекста устройства
                   1500,   // X-координата конечной точки
                   75               // Y-координата конечной точки
                   );
            // удаляем созданное "перо"
            DeleteObject(pen);

            // завершаем процесс перерисовки окна вызовом соответствующей функции
            EndPaint(hwnd,&ps);
            return 0;

        }

    // Необработанные сообщения направляются в функцию
    // обработки по умолчанию.
    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
