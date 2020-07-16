/****************************************************************************

    Модуль main.c

    Демонстрирует пример работы с таймером.

    Маткин Илья Александрович       18.06.2010

****************************************************************************/

#include <windows.h>
//#include <windowsx.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

//----------------------------------------
// глобальные переменные и константы

#define AppWindowName "Application"

#define TIMER_1     200     // идентификатор таймера

HINSTANCE hIns;             // описатель приложения

ULONG   glWindowMainWidth;  // ширина главного окна
ULONG   glWindowMainHeight; // высота главного окна

HWND    HwndMainWindow;     // описатель главного окна

//----------------------------------------
// объявление функций

ATOM RegisterClassMainWindow();

HWND CreateMainWindow();

LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// описание функций

//
// Основная функция оконных приложений
//
int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow) {

MSG msg;
    
    hIns = hInstance;

    HwndMainWindow = CreateMainWindow();

    // инициализация таймера
    SetTimer(
             HwndMainWindow,    // описатель окна, которому будут
                                // посылаться сообщения таймера
             TIMER_1,           // идентификатор таймера
             1000,              // время в миллисекундах срабатывания таймера
             NULL               // адрес процедуры таймера
             );

    // Основной цикл обработки сообщений
    while ( GetMessage (&msg, NULL, 0, 0) ) {
        TranslateMessage (&msg);
        DispatchMessage (&msg);
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
    hwnd = CreateWindowEx (
                          WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,    // расширенный стиль окна
                          AppWindowName,            // имя зарегестрированного класса окна
                          "Timer example",          // заголовок окна
                          WS_OVERLAPPEDWINDOW,      // стиль окна
                          10,                       // X-координата левого верхнего угла
                          10,                       // Y-координата левого верхнего угла
                          400,                      // ширина окна
                          400,                      // высота окна
                          NULL,                     // описатель родительского окна
                          NULL,                     // описатель главного меню (для главного окна)
                                                    // идентификатор окна (для дочернего окна)
                          hIns,                     // идентификатор приложения
                          NULL
                          );

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
static count_timer_message = 0; // счётчик символов в строке
static count_timer_init = 0;    // счётчик строк
static div = 1;                 // делитель времени таймера

    switch (iMsg) {
        case WM_CREATE:
            return 0 ;

        // сообщение посылается после уничтожения окна
        case WM_DESTROY:
            PostQuitMessage (0);
            return 0;

        // сообщение посылается при истечении времени ожидания таймера
        // lParam - функция таймера (4 параметр функции SetTimer)
        // wParam - идентификатор таймера
        case WM_TIMER:

            // получаем контекст устройства окна
            hdc = GetDC (hwnd);

            // выводим текст на контекст устройства
            TextOut(
                    hdc,            // контекст устройства
                    100 + count_timer_message*10, // Х-координата
                    50 + count_timer_init*20,     // У-координата
                    "#",            // указатель на выводимую строку
                    1               // размер выводимой строки
                    );

            // освобождаем контекст устройства
            ReleaseDC (hwnd, hdc);

            // увеличиваем счётчик выведенных символов
            ++count_timer_message;

            // если вывели 10 символов в одной строке,
            // то переинициализируем таймер
            if (count_timer_message == 10) {
                count_timer_message = 0;
                ++count_timer_init;

                // увеличиваем делитель в 2 раза,
                // т.е. таймер будет срабатывать в 2 раза чаще
                div *= 2;

                // заново устанавливаем таймер
                // т.к. таймер с таким идентификатором уже установлен
                // для данного окна, то новый таймер не создаётся,
                // а происходит модификация существующего
                SetTimer ( hwnd,
                          TIMER_1,
                          1024/div,
                          NULL);
                }

            // если уже нарисовали 10 линий, то уничтожаем таймер
            if (count_timer_init == 10) {
                KillTimer (hwnd, TIMER_1);
                }

            return 0;

        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

//--------------------
