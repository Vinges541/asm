/****************************************************************************

    ������ main.c

    ������ ������ �� ������������ ������

    ������ ���� �������������       23.10.2013

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
// ���������� ���������� � ���������

#define AppWindowName "Application"

// �������������� ���������
#define ST_1        201
#define ST_2        202
#define BT_1        203


HINSTANCE hIns;             // ��������� ����������

HWND hStatic1;
HWND hStatic2;
HWND hButton1;

//----------------------------------------
// ���������� �������

ATOM RegisterClassMainWindow (void);

HWND CreateMainWindow (void);

void CreateControlWindowsMain (HWND hwnd);

LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// �������� �������

//--------------------

//
// �������� ������� ������� ����������
//
int WINAPI WinMain (
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    PSTR szCmdLine,
    int iCmdShow) {

MSG msg;
    
    hIns = hInstance;

    if(CreateMainWindow() == NULL)
        return 0;

    // �������� ���� ��������� ���������
    while( GetMessage(&msg, NULL, 0, 0) ){
        TranslateMessage(&msg);
        DispatchMessage(&msg);
        }

    return msg.wParam;
}

//--------------------

//
// ����������� ������ ��������� ���� ����������
//
ATOM RegisterClassMainWindow (void) {

WNDCLASSEX WndClass;

    WndClass.cbSize         = sizeof (WndClass);        // ������ ��������� ������
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;              // ����� ������� ��������� ������
    WndClass.cbClsExtra     = 0;                        // ������ �������������� ������ ������
    WndClass.cbWndExtra     = 0;                        // ������ �������������� ������ ����
    WndClass.hInstance      = hIns;                     // ��������� ����������
    WndClass.hIcon          = LoadIcon (hIns, "MainIcon");
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW); // ������ ����
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (GRAY_BRUSH);
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = AppWindowName;            // ��� ������
    WndClass.hIconSm        = LoadIcon (hIns, "MainIcon");

    return RegisterClassEx (&WndClass);
}

//--------------------

//
// �������� ��������� ���� ����������
//
HWND CreateMainWindow (void) {

HWND hwnd;

    RegisterClassMainWindow();

    hwnd = CreateWindowEx (WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,
                          AppWindowName,
                          "Application",
                          WS_OVERLAPPEDWINDOW,
                          10, 10,
                          650, 600,
                          NULL,                 // ��������� ������������� ����
                          NULL,                 // ��������� �������� ���� (��� �������� ����)
                          hIns,NULL);

    if(hwnd == NULL){
        MessageBox(NULL,"������ �������� ��������� ���� ����������","",MB_OK);
        return NULL;
        }

    // ����������� ����
    ShowWindow (hwnd, SW_SHOWNORMAL);
    UpdateWindow (hwnd);

    return hwnd;
}

//--------------------

//
// �������� ����������� ��������� (���������) �������� ����
//
void CreateControlWindowsMain (HWND hwnd) {

    hStatic1 = CreateWindow("static", NULL,
                            WS_CHILD | WS_VISIBLE,
                            10, 10,
                            100, 40,
                            hwnd, (HMENU)ST_1, hIns, NULL);
    SetWindowText(hStatic1,"static1");

    hStatic2 = CreateWindow("static", NULL,
                            WS_CHILD | WS_VISIBLE | WS_BORDER,
                            10, 60,
                            100, 40,
                            hwnd, (HMENU)ST_2, hIns, NULL);
    SetWindowText(hStatic2,"static2");

    hButton1=CreateWindow("button", "button1",
							WS_CHILD | WS_VISIBLE,
							10, 110,
							100, 40,
							hwnd, (HMENU)BT_1, hIns, NULL);
    SetWindowText(hButton1,"Hello");

    return;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

char buf1[100];
char buf2[100];

    switch (iMsg){

        case WM_CREATE:

            CreateControlWindowsMain(hwnd);
            return 0 ;

        case WM_DESTROY:

            PostQuitMessage(0);
            return 0;

        // ������� ���������� ��� ����������� �������� ��������� ���������� ����
        // ���� "static"
        // wParam �������� ��������� ��������� ����������
        // lParam �������� ��������� ��������� ����
        case WM_CTLCOLORSTATIC:

            if ((HWND)lParam == hStatic1) {
                SetTextColor ((HDC)wParam, RGB (255,128,0));
                SetBkColor ((HDC)wParam, RGB (100,100,100));
                return (LRESULT)GetStockObject (WHITE_BRUSH);
                }
            break;

        // ��������� ���������� ��� ������� ������
        case WM_COMMAND:

            // � ��������� wParam ������������� ������� ������
            switch(LOWORD (wParam)){

                case BT_1:
                    GetWindowText (hStatic1, buf1, 100);
                    GetWindowText (hStatic2, buf2, 100);
                    SetWindowText (hStatic2, buf1);
                    SetWindowText (hStatic1, buf2);
                    break;
                }

			return 0;

        case WM_LBUTTONDOWN:
            MessageBox(hwnd,"Left button down",NULL,MB_OK);
            break;
        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
