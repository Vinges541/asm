/****************************************************************************

    ������ main.c

    ������ ������ � ���������� ������.

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

#define ED_1        201     // ������������� �������� ���������� ����
#define ED_2        202     // ������������� ������� ���������� ����
#define BT_1        203     // ������������� ������ �����������
#define BT_2        204     // ������������� ������ ����������


HINSTANCE hIns;             // ��������� ����������

HWND hEdit1;
HWND hEdit2;
HWND hButton1;
HWND hButton2;

//----------------------------------------
// ���������� �������

void InsertStringTailEdit (HWND hwnd, char *str);

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
ATOM RegisterClassMainWindow (void){

WNDCLASSEX WndClass;

    WndClass.cbSize         = sizeof (WndClass);        // ������ ��������� ������
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;              // ����� ������� ��������� ������
    WndClass.cbClsExtra     = 0;                        // ������ �������������� ������ ������
    WndClass.cbWndExtra     = 0;                        // ������ �������������� ������ ����
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
void CreateControlWindowsMain (HWND hwnd){


    hEdit1 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_RIGHT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_1, hIns, NULL);

    hEdit2 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_READONLY,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_2, hIns, NULL);


    hButton1 = CreateWindow ("button", "�����������",
							WS_CHILD | WS_VISIBLE,
							10, 10,
							100, 30,
							hwnd, (HMENU)BT_1, hIns, NULL);

    hButton2 = CreateWindow ("button", "��������",
							WS_CHILD | WS_VISIBLE,
							200, 10,
							100, 30,
							hwnd, (HMENU)BT_2, hIns, NULL);

    return;
}

//--------------------

//
// ������� ��������� ������� ��������� �������� ����
//
LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

unsigned int width;
unsigned int height;

    width = LOWORD(lParam);
    height = HIWORD(lParam);

    // ������������ ��������� ����
    MoveWindow(hEdit1,
               10,
               100,
               width-20,
               (height-120)/2,
               TRUE
               );

    MoveWindow(hEdit2,
               10,
               110 + (height-120)/2,
               width-20,
               (height-120)/2,
               TRUE
               );

	return 0;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

DWORD textLength;
DWORD offset;
char *buf;

    switch (iMsg){

        case WM_CREATE:

            CreateControlWindowsMain(hwnd);
            return 0 ;

        case WM_DESTROY:

            PostQuitMessage(0);
            return 0;

        case WM_SIZE:
            return ProcessingSizeEvent (hwnd, iMsg ,wParam, lParam);

        case WM_COMMAND:

            switch(LOWORD (wParam)){

                case BT_1:
                    // �������� ����� ������ � ������ ��������� ����
                    textLength = GetWindowTextLength (hEdit1);

                    // �������� ������
                    buf = (char*) malloc (textLength + 1);

                    // ��������� ������ �� ������� ���������� ����
                    GetWindowText (hEdit1, buf, textLength + 1);

                    // ������������� ������ �� ������ ��������� ����
                    SetWindowText (hEdit2, buf);

                    free (buf);
                    break;

                case BT_2:
                    // �������� ����� ������ � ������ ��������� ����
                    textLength = GetWindowTextLength (hEdit1);

                    // �������� ������
                    buf = (char*) malloc (textLength + 1);

                    // ��������� ������ �� ������� ���������� ����
                    GetWindowText (hEdit1, buf, textLength + 1);

                    // �������� ����� ������ �� ������ ��������� ����
                    offset = GetWindowTextLength (hEdit2);

                    // ���������� ������ � ����� ������
                    SendMessage (hEdit2, EM_SETSEL, offset, offset);

                    // �������� ������
                    SendMessage (hEdit2, EM_REPLACESEL, 0, (LPARAM)buf);

                    free (buf);
                    break;

                default:
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
