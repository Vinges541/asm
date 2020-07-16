/****************************************************************************

    Модуль main.c

    Демонстрирует пример работы с управляющими элементами (контролами).

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

#define ED_1        201     // идентификатор верхнего текстового поля
#define ED_2        202     // идентификатор нижнего текстового поля
#define ST_1        203     // идентификатор статического окна
#define BT_1        204     // идентификатор кнопки

HINSTANCE hIns;             // описатель приложения

ULONG   glWindowMainWidth;  // ширина главного окна
ULONG   glWindowMainHeight; // высота главного окна

HWND    HwndMainWindow;     // описатель главного окна
HWND    HwndEdit1;          // описатель верхнего текстового поля
HWND    HwndEdit2;          // описатель нижнего текстового поля
HWND    HwndButton1;        // описатель кнопки
HWND    HwndStatic1;        // описатель статического окна (надписи)

//----------------------------------------
// объявление функций

ATOM RegisterClassMainWindow();

HWND CreateMainWindow();

void CreateControlWindowsMain(HWND hwnd);

LRESULT ProcessingSizeEvent(HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

void ProcessingButton1(void);

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
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = 0;
    WndClass.hInstance      = hIns;
    WndClass.hIcon          = LoadIcon (hIns, "MainIcon");
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (BLACK_BRUSH);
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
// Создание управляющих элементов (контролов) главного окна
//
void CreateControlWindowsMain(HWND hwnd){


    HwndEdit1 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_1, hIns, NULL);

    HwndEdit2 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_NUMBER | ES_READONLY,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_2, hIns, NULL);

    HwndStatic1 = CreateWindow("static", NULL,
                            WS_CHILD | WS_VISIBLE | WS_BORDER | ES_NUMBER,
                            10, 10,
                            80, 40,
                            hwnd, (HMENU)ST_1, hIns, NULL);
    SetWindowText(HwndStatic1,"static1");

    HwndButton1=CreateWindow("button", "button1",
							WS_CHILD | WS_VISIBLE,
							100, 10,
							55, 30,
							hwnd, (HMENU)BT_1, hIns, NULL);

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
    MoveWindow(
               HwndEdit1,   // описатель перемещаемого окна
               10,          // Х-координата левого верхнего угла
               100,         // У-координата левого верхнего угла
               glWindowMainWidth-20,    // ширина
               (glWindowMainHeight-120)/2,  // высота
               TRUE         // флаг необходимости перерисовки
               );

    MoveWindow(
               HwndEdit2,
               10,
               110 + (glWindowMainHeight-120)/2,
               glWindowMainWidth-20,
               (glWindowMainHeight-120)/2,
               TRUE
               );

	return 0;
}

//--------------------

//
// Функция обработки события нажатия кнопки.
// Добавляет текст из верхнего текстового поля
// в нижнее.
//
void ProcessingButton1(void){                                                                                                                                                                                                      

unsigned int offset;
char *buf;
unsigned int size;

    // получаем длину текста в верхнем окне
    size = GetWindowTextLength(HwndEdit1);
    if(size == 0)
        return;

    // выделяем необходимую память
    buf = (char*) malloc(size+1);
    if(buf == 0)
        return;

    // получаем данные из окна в буфер
    if(GetWindowText(HwndEdit1,buf,size+1) != size){
        free(buf);
        return;
        }

    // помещаем в верхнее текстовое поле нулевую строку
    // т.е. очищаем окно
    SetWindowText(HwndEdit1,NULL);

    // получаем длину текста в нижнем окне
    offset = GetWindowTextLength(HwndEdit2);

    // перемещаем курсор в конец текста
    SendMessage(HwndEdit2,EM_SETSEL,offset,offset);

    // посылаем строку, скопированую из верхнего окна в нижнее
    SendMessage(HwndEdit2,EM_REPLACESEL,0,(ULONG)buf);

    free(buf);

    return;
}

//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

HDC	hdc;
HPEN pen;
PAINTSTRUCT ps;

    switch (iMsg){
        case WM_CREATE:
            // создаём управляющие элементы главного окна
            CreateControlWindowsMain(hwnd);
            return 0 ;

        // сообщение посылается при изменение размеров окна
        case WM_SIZE:
            // вызываем функцию обработки этого сообщения
            return ProcessingSizeEvent(hwnd,iMsg,wParam,lParam);

        // сообщение посылается элементами управления родительскому окну
        // например, сообщение посылается при нажатии кнопки, расположенной в данном окне
        case WM_COMMAND:

            // младшее слово аргумента wParam равно идентификатору элемента управления,
            // послужившего причиной генерации сообщения.
            switch(LOWORD (wParam)){

                // если идентификатор кнопки
                case BT_1:
                    //вызываем функцию обработки нажатий кнопки
                    ProcessingButton1();
                    break;

                default:
                    break;			
                }

			return 0;

        // сообщение посылается после уничтожения окна
        case WM_DESTROY:
            // вызываем функцию, посылающую сообщение завершения процесса
            PostQuitMessage(0);
            return 0;

        // сообщение посылается при перерисовке окна
        case WM_PAINT:
            //InvalidateRect(hwnd,NULL,TRUE);
            // Перед перерисовкой окна вызываем специальную функцию,
            // которая подготавливает окно к рисованию и
            // возвращает описатель контекста устройства для данного окна.
            // Рисование осуществляется на контексте устройства окна.
            hdc = BeginPaint(HwndMainWindow,&ps);
            // создаём объект "перо" для рисования линий
            pen = CreatePen(
                            PS_SOLID,       // задаём тип линии (сплошная)
                            3,              // толщина линии
                            RGB(255,150,30) // цвет линии с помощью макроса
                            );
            // ассоциируем созданную кисть с контекстом устройства
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
                   glWindowMainWidth,   // X-координата конечной точки
                   75               // Y-координата конечной точки
                   );
            // удаляем созданное "перо"
            DeleteObject(pen);

            // завершаем процесс перерисовки окна вызовом соответствующей функции
            EndPaint(hwnd,&ps);
            return 0;

        // событие посылается при перерисовки дочерних элементов управления окна
        // типа "static"
        // wParam содержит описатель контекста устройства
        // lParam содержит описатель дочернего окна
        case WM_CTLCOLORSTATIC:

            // изменяем цвет текста и цвет фона текста
            if((HWND)lParam == HwndEdit2){
                // если это нижнее текстовое поле,
                // то выставляем красные текст на сером фоне
                SetTextColor((HDC)wParam,RGB(255,0,0));
                SetBkColor((HDC) wParam,RGB(200,200,200));
                // возвращаем кисть, которой будет закрашиваться фон
                return (LRESULT)GetStockObject(DKGRAY_BRUSH);
                }
            else{
                // для всех остальных оранжевый текст на зелёном фоне
                SetTextColor((HDC)wParam,RGB(255,128,0));
                SetBkColor((HDC) wParam,RGB(100,100,0));
                return (LRESULT)GetStockObject(BLACK_BRUSH);
                }
        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
