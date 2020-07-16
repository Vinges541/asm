/****************************************************************************

    ������ main.c

    ������ �������� �������� ����������.

    ������ ���� �������������       10.06.2010

****************************************************************************/

#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

//----------------------------------------
// ���������� ���������� � ���������

#define AppWindowName "Application"

HINSTANCE hIns;             // ��������� ����������

HWND HwndMainWindow;        // ��������� �������� ����

//----------------------------------------
// ���������� �������

ATOM RegisterClassMainWindow();

HWND CreateMainWindow();

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// �������� �������

//
// �������� ������� ������� ����������
//
int WINAPI WinMain(
 HINSTANCE hInstance,       // ��������� �������� ����������
 HINSTANCE hPrevInstance,   // ������ NULL
 PSTR szCmdLine, 
 int iCmdShow
){

MSG msg;
    
    hIns = hInstance;

    HwndMainWindow = CreateMainWindow();
    if (HwndMainWindow == NULL) {
        return 0;
        }

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
ATOM RegisterClassMainWindow(){

WNDCLASSEX WndClass;    // ��������� ������

    // ������� ����������� ���� ���������
    WndClass.cbSize         = sizeof (WndClass);    // ������ ��������� ������
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;          // ����� ������� ��������� ������
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = 0;
    WndClass.hInstance      = hIns;                 // ��������� ����������
    WndClass.hIcon          = LoadIcon (hIns, "MainIcon");  // ������ ����������
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (GRAY_BRUSH);    // ����� ��� ����
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = AppWindowName;        // ��� ������
    WndClass.hIconSm        = LoadIcon (hIns, "MainIcon");
    
    // ����������� ������
    return RegisterClassEx (&WndClass);
}

//--------------------

//
// �������� ��������� ���� ����������
//
HWND CreateMainWindow(){

HWND hwnd;  // ��������� ����

    // ����������� ������ ��������� ����
    RegisterClassMainWindow();

    // �������� ���� ������������������� ������
    hwnd = CreateWindowEx(
                          WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,    // ����������� ����� ����
                          AppWindowName,            // ��� ������������������� ������ ����
                          "Application",            // ��������� ����
                          WS_OVERLAPPEDWINDOW,      // ����� ����
                          10,                       // X-���������� ������ �������� ����
                          10,                       // Y-���������� ������ �������� ����
                          650,                      // ������ ����
                          600,                      // ������ ����
                          NULL,                     // ��������� ������������� ����
                          NULL,                     // ��������� �������� ���� (��� �������� ����)
                                                    // ������������� ���� (��� ��������� ����)
                          hIns,                     // ������������� ����������
                          NULL
                          );

    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    hwnd = CreateWindowEx(
                          /*WS_EX_CONTROLPARENT | WS_EX_APPWINDOW*/0,    // ����������� ����� ����
                          AppWindowName,            // ��� ������������������� ������ ����
                          "Application",            // ��������� ����
                          WS_OVERLAPPEDWINDOW,      // ����� ����
                          10,                       // X-���������� ������ �������� ����
                          10,                       // Y-���������� ������ �������� ����
                          650,                      // ������ ����
                          600,                      // ������ ����
                          NULL,                     // ��������� ������������� ����
                          NULL,                     // ��������� �������� ���� (��� �������� ����)
                                                    // ������������� ���� (��� ��������� ����)
                          hIns,                     // ������������� ����������
                          NULL
                          );

    if(hwnd == NULL){
        MessageBox(NULL,"������ �������� ��������� ���� ����������","",MB_OK);
        return NULL;
        }

    // ����������� ����
    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    return hwnd;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
// ���������� �������� ��� ����������� ��������� ��� �������� ����
// � ���������������� �����������.
//
LRESULT CALLBACK WndProcMain(
HWND hwnd,      // ��������� ����, ����������� ���������
UINT iMsg,      // ������������� (�����) ���������
WPARAM wParam,  // �������� ���������
LPARAM lParam   // �������� ���������
){

HDC	hdc;
HPEN pen;
PAINTSTRUCT ps;

    switch (iMsg){
        // ��������� ���������� ����� ����� �������� ����, �� ��� �����������
        case WM_CREATE:
            return 0;

        // ��������� ���������� ����� ����������� ����
        case WM_DESTROY:
            // �������� �������, ���������� ��������� ���������� ��������,
            // ���� ����������� ������� ����
            if (hwnd == HwndMainWindow)
                PostQuitMessage(0);
            return 0;

        // ��������� ���������� ��� ����������� ����
        case WM_PAINT:

            // ����� ������������ ���� �������� ����������� �������,
            // ������� �������������� ���� � ��������� �
            // ���������� ��������� ��������� ���������� ��� ������� ����.
            // ��������� �������������� �� ��������� ���������� ����.
            hdc = BeginPaint(hwnd,&ps);
            // ������ ������ "����" ��� ��������� �����
            pen = CreatePen(
                            PS_DASHDOT,       // ����� ��� ����� (��������)
                            2,              // ������� �����
                            RGB(255,150,30) // ���� ����� � ������� �������
                            );
            // ����������� ��������� ���� � ���������� ����������
            SelectObject(hdc,pen);

            // ���������� ������� �������, � ������� ���������� ���������
            MoveToEx(
                     hdc,           // ��������� ��������� ����������
                     0,             // X-����������
                     75,            // Y-����������
                     NULL);

            // ������ ����� ��������� ������ �� ������� ������� �� ��������� �����
            LineTo(
                   hdc,             // ��������� ��������� ����������
                   1500,   // X-���������� �������� �����
                   75               // Y-���������� �������� �����
                   );
            // ������� ��������� "����"
            DeleteObject(pen);

            // ��������� ������� ����������� ���� ������� ��������������� �������
            EndPaint(hwnd,&ps);
            return 0;

        }

    // �������������� ��������� ������������ � �������
    // ��������� �� ���������.
    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
