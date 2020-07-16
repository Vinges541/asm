/****************************************************************************

    Модуль main.c

    Пример создания дочернего окна.

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
#define ChildWindowName "ChildAppWindow"

#define CHILD_1        201     // идентификатор дочернего окна


HINSTANCE hIns;             // описатель приложения

WNDPROC glWndProc;

//----------------------------------------
// объявление функций

BOOL CreateExtraConsole (void);

ATOM RegisterClassMainWindow (void);

ATOM RegisterClassChildWindow (void);

HWND CreateMainWindow (void);

void CreateControlWindowsMain (HWND hwnd);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

LRESULT CALLBACK WndProcChild (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// описание функций

//
// Функция создания консоли
//
BOOL CreateExtraConsole(void){

	if(!AllocConsole())
		return FALSE;

    //HANDLE file = CreateFile("C:\\out.txt",GENERIC_WRITE,(DWORD)0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,(HANDLE) NULL);
	SetConsoleTitle("Debug console");
	*stdout = *(_fdopen(_open_osfhandle((long)GetStdHandle(STD_OUTPUT_HANDLE),_O_TEXT),"w"));
    //*stdout = *(_fdopen(_open_osfhandle((long)file,_O_TEXT),"w"));
	*stderr = *(_fdopen(_open_osfhandle((long)GetStdHandle(STD_ERROR_HANDLE),_O_TEXT),"w"));
	*stdin = *(_fdopen(_open_osfhandle((long)GetStdHandle(STD_INPUT_HANDLE),_O_TEXT),"r"));
	if(setvbuf(stdout, NULL, _IONBF, 0))
		return FALSE;
	if(setvbuf(stderr, NULL, _IONBF, 0))
		return FALSE;

	return TRUE;
}

//--------------------

//
// Основная функция оконных приложений
//
int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,PSTR szCmdLine,int iCmdShow){

MSG msg;
    
    hIns = hInstance;

    if(CreateMainWindow() == NULL)
        return 0;

	CreateExtraConsole();
    printf ("Hello, World!\n");

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
ATOM RegisterClassMainWindow (void) {

WNDCLASSEX WndClass;

    WndClass.cbSize         = sizeof (WndClass);        // размер структуры класса
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;              // адрес оконной процедуры класса
    WndClass.cbClsExtra     = 0;                        // размер дополнительной памяти класса
    WndClass.cbWndExtra     = sizeof(void*);            // размер дополнительной памяти окна
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
// Создаёт класс на основе существующего
//
WNDPROC CreateNewClass (LPCSTR name, LPCSTR newname, WNDPROC newproc, HINSTANCE ins) {

WNDCLASS    wndclass;
WNDPROC     wndproc;

    GetClassInfo(NULL,name,&wndclass);
    wndclass.lpszClassName = newname;
    wndproc = wndclass.lpfnWndProc;
    wndclass.lpfnWndProc = newproc;
    wndclass.hInstance = ins;
    //wndclass.cbWndExtra = 0;
    if(RegisterClass(&wndclass) == 0)
        return NULL;

    return wndproc;
}

//--------------------

//
// Создание основного окна приложения
//
HWND CreateMainWindow (void){

HWND hwnd;

    RegisterClassMainWindow();

    hwnd = CreateWindowEx(WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,
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
    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    return hwnd;
}

//--------------------

//
// Создание управляющих элементов (контролов) главного окна
//
void CreateControlWindowsMain (HWND hwnd){

HWND hChild;


    glWndProc = CreateNewClass ("edit", "myedit", WndProcChild, hIns);

    hChild = CreateWindow("myedit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_BORDER | ES_MULTILINE,
                            100, 100,
                            200, 200,
                            hwnd, (HMENU)CHILD_1, hIns, NULL);
    
    return;
}

//--------------------

//
// Функция обработки сообщений главного окна приложения.
//
LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {


    switch (iMsg){

        case WM_CREATE:

            CreateControlWindowsMain(hwnd);
            return 0 ;

        case WM_DESTROY:

            PostQuitMessage(0);
            return 0;

        case WM_LBUTTONDOWN:
            MessageBox (hwnd, "Left button down\n", "", MB_OK);
            SetFocus (hwnd);
            break;
        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

char buf[100];
unsigned int count;
//
// Функция обработки сообщений дочернего окна.
//
LRESULT CALLBACK WndProcChild (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

    //*
    switch (iMsg){

        //case WM_KEYDOWN:
        //    break;
        case WM_CHAR:
            if ( (char)wParam == '\r') {
                printf ("\n");
                return glWndProc (hwnd, iMsg, wParam, lParam);
                }
            else {
                buf[count++] = (char) wParam;
                printf ("%c", (char) wParam);
                return glWndProc (hwnd, iMsg, rand() % 26 + 'A'/*'#'*/, lParam);
                }
        }
    //*/

    return glWndProc (hwnd, iMsg, wParam, lParam);
}

//--------------------
