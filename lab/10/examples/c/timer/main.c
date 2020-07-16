/****************************************************************************

    ������ main.c

    ������������� ������ ������ � ��������.

    ������ ���� �������������       18.06.2010

****************************************************************************/

#include <windows.h>
//#include <windowsx.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

//----------------------------------------
// ���������� ���������� � ���������

#define AppWindowName "Application"

#define TIMER_1     200     // ������������� �������

HINSTANCE hIns;             // ��������� ����������

ULONG   glWindowMainWidth;  // ������ �������� ����
ULONG   glWindowMainHeight; // ������ �������� ����

HWND    HwndMainWindow;     // ��������� �������� ����

//----------------------------------------
// ���������� �������

ATOM RegisterClassMainWindow();

HWND CreateMainWindow();

LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// �������� �������

//
// �������� ������� ������� ����������
//
int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow) {

MSG msg;
    
    hIns = hInstance;

    HwndMainWindow = CreateMainWindow();

    // ������������� �������
    SetTimer(
             HwndMainWindow,    // ��������� ����, �������� �����
                                // ���������� ��������� �������
             TIMER_1,           // ������������� �������
             1000,              // ����� � ������������� ������������ �������
             NULL               // ����� ��������� �������
             );

    // �������� ���� ��������� ���������
    while ( GetMessage (&msg, NULL, 0, 0) ) {
        TranslateMessage (&msg);
        DispatchMessage (&msg);
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
    hwnd = CreateWindowEx (
                          WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,    // ����������� ����� ����
                          AppWindowName,            // ��� ������������������� ������ ����
                          "Timer example",          // ��������� ����
                          WS_OVERLAPPEDWINDOW,      // ����� ����
                          10,                       // X-���������� ������ �������� ����
                          10,                       // Y-���������� ������ �������� ����
                          400,                      // ������ ����
                          400,                      // ������ ����
                          NULL,                     // ��������� ������������� ����
                          NULL,                     // ��������� �������� ���� (��� �������� ����)
                                                    // ������������� ���� (��� ��������� ����)
                          hIns,                     // ������������� ����������
                          NULL
                          );

    if(hwnd == NULL){
        MessageBox (NULL, "������ �������� ��������� ���� ����������", "", MB_OK);
        return NULL;
        }

    // ����������� ����
    ShowWindow (hwnd, SW_SHOWNORMAL);
    UpdateWindow (hwnd);

    return hwnd;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
static count_timer_message = 0; // ������� �������� � ������
static count_timer_init = 0;    // ������� �����
static div = 1;                 // �������� ������� �������

    switch (iMsg) {
        case WM_CREATE:
            return 0 ;

        // ��������� ���������� ����� ����������� ����
        case WM_DESTROY:
            PostQuitMessage (0);
            return 0;

        // ��������� ���������� ��� ��������� ������� �������� �������
        // lParam - ������� ������� (4 �������� ������� SetTimer)
        // wParam - ������������� �������
        case WM_TIMER:

            // �������� �������� ���������� ����
            hdc = GetDC (hwnd);

            // ������� ����� �� �������� ����������
            TextOut(
                    hdc,            // �������� ����������
                    100 + count_timer_message*10, // �-����������
                    50 + count_timer_init*20,     // �-����������
                    "#",            // ��������� �� ��������� ������
                    1               // ������ ��������� ������
                    );

            // ����������� �������� ����������
            ReleaseDC (hwnd, hdc);

            // ����������� ������� ���������� ��������
            ++count_timer_message;

            // ���� ������ 10 �������� � ����� ������,
            // �� ������������������ ������
            if (count_timer_message == 10) {
                count_timer_message = 0;
                ++count_timer_init;

                // ����������� �������� � 2 ����,
                // �.�. ������ ����� ����������� � 2 ���� ����
                div *= 2;

                // ������ ������������� ������
                // �.�. ������ � ����� ��������������� ��� ����������
                // ��� ������� ����, �� ����� ������ �� ��������,
                // � ���������� ����������� �������������
                SetTimer ( hwnd,
                          TIMER_1,
                          1024/div,
                          NULL);
                }

            // ���� ��� ���������� 10 �����, �� ���������� ������
            if (count_timer_init == 10) {
                KillTimer (hwnd, TIMER_1);
                }

            return 0;

        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

//--------------------
