/****************************************************************************

    ������ main.c

    ������ ������ � ��������.

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

// �������������� ������
#define BT_1        201
#define BT_2        202
#define BT_3        203
#define BT_4        204
#define BT_5        205
#define BT_6        206
#define BT_7        207

HINSTANCE hIns;             // ��������� ����������

HWND hButton1;
HWND hButton2;
HWND hButton3;
HWND hButton4;
HWND hButton5;
HWND hButton6;
HWND hButton7;

//----------------------------------------
// ���������� �������

ATOM RegisterClassMainWindow (void);

HWND CreateMainWindow (void);

void CreateControlWindowsMain (HWND hwnd);

LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// �������� �������

//
// �������� ������� ������� ����������
//
int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,PSTR szCmdLine,int iCmdShow){

MSG msg;
    
    hIns = hInstance;

    if (CreateMainWindow() == NULL)
        return 0;

    // �������� ���� ��������� ���������
    while ( GetMessage(&msg, NULL, 0, 0) ) {
        TranslateMessage (&msg);
        DispatchMessage (&msg);
        }

    return msg.wParam;
}

//--------------------

//
// ����������� ������ ��������� ���� ����������
//
ATOM RegisterClassMainWindow (void){

WNDCLASSEX WndClass;

    WndClass.cbSize         = sizeof (WndClass);        // ������ ��������� ������
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;              // ����� ������� ��������� ������
    WndClass.cbClsExtra     = 0;                        // ������ �������������� ������ ������
    WndClass.cbWndExtra     = sizeof(void*);            // ������ �������������� ������ ����
    WndClass.hInstance      = hIns;                     // ��������� ����������
    WndClass.hIcon          = LoadIcon (hIns, "MainIcon");
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW); // ������ ����
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (BLACK_BRUSH);
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = AppWindowName;            // ��� ������
    WndClass.hIconSm        = LoadIcon (hIns, "MainIcon");

    return RegisterClassEx (&WndClass);
}

//--------------------

//
// �������� ��������� ���� ����������
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
                          NULL,                 // ��������� ������������� ����
                          NULL,                 // ��������� �������� ���� (��� �������� ����)
                          hIns,NULL);

    if(hwnd == NULL){
        MessageBox(NULL,"������ �������� ��������� ���� ����������","",MB_OK);
        return NULL;
        }

    // ����������� ����
    ShowWindow (hwnd,SW_SHOWNORMAL);
    UpdateWindow (hwnd);

    return hwnd;
}

//--------------------

//
// �������� ����������� ��������� (���������) �������� ����
//
void CreateControlWindowsMain (HWND hwnd){

    hButton1 = CreateWindow("button", "button1",
                            WS_CHILD | WS_VISIBLE,
                            10, 0,
                            100, 30,
                            hwnd, (HMENU)BT_1, hIns, NULL);

    hButton2 = CreateWindow("button", "button2",
                            WS_CHILD | WS_VISIBLE | BS_3STATE,
                            10, 50,
                            100, 30,
                            hwnd, (HMENU)BT_2, hIns, NULL);

    hButton3 = CreateWindow("button", "button3",
                            WS_CHILD | WS_VISIBLE | BS_AUTO3STATE ,
                            10, 100,
                            100, 30,
                            hwnd, (HMENU)BT_3, hIns, NULL);

    hButton4 = CreateWindow("button", "button4",
                            WS_CHILD | WS_VISIBLE | BS_AUTOCHECKBOX,
                            10, 150,
                            100, 30,
                            hwnd, (HMENU)BT_4, hIns, NULL);

    hButton5 = CreateWindow("button", "button5",
                            WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON ,
                            10, 200,
                            100, 30,
                            hwnd, (HMENU)BT_5, hIns, NULL);

    hButton6 = CreateWindow("button", "button6",
                            WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON ,
                            10, 250,
                            100, 30,
                            hwnd, (HMENU)BT_6, hIns, NULL);

    hButton7 = CreateWindow("button", "button7",
                            WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON ,
                            10, 300,
                            100, 30,
                            hwnd, (HMENU)BT_7, hIns, NULL);

    return;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

DWORD state;

    switch (iMsg){

        case WM_CREATE:

            CreateControlWindowsMain(hwnd);
            return 0 ;

        case WM_DESTROY:

            PostQuitMessage(0);
            return 0;

        // ��������� ���������� ��� ������� ������
        case WM_COMMAND:

            // � ��������� wParam ������������� ������� ������
            switch(LOWORD (wParam)){

                case BT_1:
                    MessageBox(hwnd,"Button1 down",NULL,MB_OK);
                    break;

                case BT_2:
                    // �������� ��������� ������
                    state = SendMessage (hButton2, BM_GETCHECK, 0, 0);
                    if (state == BST_UNCHECKED) {
                        MessageBox(hwnd,"Button2 unchecked",NULL,MB_OK);
                        SetWindowText (hButton2, "checked");
                        }
                    else if (state == BST_CHECKED) {
                        MessageBox(hwnd,"Button2 checked",NULL,MB_OK);
                        SetWindowText (hButton2, "indeterminate");
                        }
                    else if (state == BST_INDETERMINATE) {
                        MessageBox(hwnd,"Button2 indeterminate",NULL,MB_OK);
                        SetWindowText (hButton2, "unchecked");
                        }
                    // �������� ��������� �� ���������
                    SendMessage (hButton2, BM_SETCHECK, (state+1)%3, 0);
                    break;

                case BT_3:
                    state = SendMessage (hButton3, BM_GETCHECK, 0, 0);
                    if (state == BST_UNCHECKED) {
                        MessageBox(hwnd,"Button3 unchecked",NULL,MB_OK);
                        }
                    else if (state == BST_CHECKED) {
                        MessageBox(hwnd,"Button3 checked",NULL,MB_OK);
                        }
                    else if (state == BST_INDETERMINATE) {
                        MessageBox(hwnd,"Button3 indeterminate",NULL,MB_OK);
                        }
                    break;

                case BT_4:
                    state = SendMessage (hButton4, BM_GETCHECK, 0, 0);
                    if (state == BST_UNCHECKED) {
                        MessageBox(hwnd,"Button4 unchecked",NULL,MB_OK);
                        ShowWindow (hButton3, SW_HIDE);
                        }
                    else if (state == BST_CHECKED) {
                        MessageBox(hwnd,"Button4 checked",NULL,MB_OK);
                        ShowWindow (hButton3, SW_SHOWNORMAL);
                        }
                    break;

                case BT_5:
                    state = SendMessage (hButton5, BM_GETCHECK, 0, 0);
                    if (state == BST_UNCHECKED) {
                        MessageBox(hwnd,"Button5 unchecked",NULL,MB_OK);
                        }
                    else if (state == BST_CHECKED) {
                        MessageBox(hwnd,"Button5 checked",NULL,MB_OK);
                        }
                    break;

                case BT_6:
                    MessageBox(hwnd,"Button6 checked",NULL,MB_OK);
                    break;

                case BT_7:
                    MessageBox(hwnd,"Button7 checked",NULL,MB_OK);
                    break;

                default:
                    break;			
                }

			return 0;

        case WM_LBUTTONDOWN:
            break;
        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
