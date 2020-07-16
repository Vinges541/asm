/****************************************************************************

    Модуль main.c

    Демонстрирует пример работы с мышью.

    Маткин Илья Александрович       18.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

//----------------------------------------
// глобальные переменные и константы

#define AppWindowName "Application"

#define ED_1        201     // идентификатор верхнего текстового поля
#define ST_1        202     // идентификатор статического окна

HINSTANCE hIns;             // описатель приложения

ULONG   glWindowMainWidth;  // ширина главного окна
ULONG   glWindowMainHeight; // высота главного окна

HWND    HwndMainWindow;     // описатель главного окна
HWND    HwndEdit1;          // описатель верхнего текстового поля
HWND    HwndStatic1;        // описатель статического окна (надписи)

//----------------------------------------
// объявление функций

ATOM RegisterClassMainWindow();

HWND CreateMainWindow();

void CreateControlWindowsMain(HWND hwnd);

LRESULT ProcessingSizeEvent(HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

void InsertStringTailEdit(char *str);

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

    // создание окна зарегистрированного класса
    hwnd = CreateWindowEx(
                          WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,    // расширенный стиль окна
                          AppWindowName,            // имя зарегистрированного класса окна
                          "Mouse example",          // заголовок окна
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
// Создание управляющих элементов (контролов) главного окна
//
void CreateControlWindowsMain(HWND hwnd){


    HwndEdit1 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_READONLY,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_1, hIns, NULL);

    HwndStatic1 = CreateWindow("static", NULL,
                            WS_CHILD | WS_VISIBLE | WS_BORDER | ES_NUMBER,
                            10, 10,
                            80, 40,
                            hwnd, (HMENU)ST_1, hIns, NULL);
    SetWindowText(HwndStatic1,"static1");

    return;
}

//--------------------

//
// Функция обработки события изменения главного окна
//
LRESULT ProcessingSizeEvent(HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam){

    // младшее слово параметра lParam содержит новую ширину окна
    glWindowMainWidth = LOWORD(lParam);
    // старшее - высоту
    glWindowMainHeight = HIWORD(lParam);

    // изменяем размер текстового поля пропорционально размерам главного окна
    MoveWindow(HwndEdit1,   // описатель перемещаемого окна
               10,                                  // Х-координата левого верхнего угла
               110 + (glWindowMainHeight-120)/2,    // У-координата левого верхнего угла
               glWindowMainWidth-20,                // ширина
               (glWindowMainHeight-120)/2,          // высота
               TRUE         // флаг необходимости перерисовки
               );

	return 0;
}

//--------------------

//
// Функция добавляет строку в конец текстового поля.
//
void InsertStringTailEdit(char *str){

unsigned int offset;

    // получаем длину текста в нижнем окне
    offset = GetWindowTextLength(HwndEdit1);

    // перемещаем курсор в конец текста
    SendMessage(HwndEdit1,EM_SETSEL,offset,offset);

    // посылаем строку
    SendMessage(HwndEdit1,EM_REPLACESEL,0,(ULONG)str);

    return;
}

//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

HDC	hdc;
PAINTSTRUCT ps;
char buf[100];
unsigned int x,y;

    switch (iMsg){
        case WM_CREATE:
            // создаём управляющие элементы главного окна
            CreateControlWindowsMain(hwnd);
            return 0 ;

        // сообщение посылается при изменение размеров окна
        case WM_SIZE:
            return ProcessingSizeEvent(hwnd,iMsg,wParam,lParam);

        // сообщение посылается после уничтожения окна
        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;

        // сообщение посылается при перемещение мыши по окну
        case WM_MOUSEMOVE:
            // младшее слово содержит Х-координату
            x = GET_X_LPARAM(lParam);
            // старшее слово содержит У-координату
            y = GET_Y_LPARAM(lParam);

            sprintf(buf,"x = %d\ny = %d",x,y);

            // помещаем текст в статическое окно
            SetWindowText(HwndStatic1,buf);
            return 0;

        // сообщение посылается при нажатии левой кнопки мыши в окне
        case WM_LBUTTONDOWN:
            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            sprintf(buf,"Нажата левая кнопка мыши в точке (%d,%d)\r\n",x,y);
            InsertStringTailEdit(buf);
            return 0;

        // сообщение посылается при отпусании левой кнопки мыши
        case WM_LBUTTONUP:
            InsertStringTailEdit("Отпущена левая кнопка мыши\r\n");
            return 0;

        // сообщение посылается при двойном клике левой кнопкой мыши
        case WM_LBUTTONDBLCLK:
            InsertStringTailEdit("Дважды нажата левая кнопка мыши\r\n");
            return 0;

        // сообщение посылается при нажатии правой кнопки мыши
        case WM_RBUTTONDOWN:
            InsertStringTailEdit("Нажата правая кнопка мыши\r\n");
            return 0;

        // сообщение посылается при отпускании правой кнопки мыши
        case WM_RBUTTONUP:
            InsertStringTailEdit("Отпущена правая кнопка мыши\r\n");
            return 0;

        // сообщение посылается при двойном клике правой кнопки мыши
        case WM_RBUTTONDBLCLK:
            InsertStringTailEdit("Дважды нажата правая кнопка мыши\r\n");
            return 0;

        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
