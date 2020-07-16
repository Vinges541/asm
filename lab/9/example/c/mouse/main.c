/****************************************************************************

    ������ main.c

    ������������� ������ ������ � �����.

    ������ ���� �������������       18.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

//----------------------------------------
// ���������� ���������� � ���������

#define AppWindowName "Application"

#define ED_1        201     // ������������� �������� ���������� ����
#define ST_1        202     // ������������� ������������ ����

HINSTANCE hIns;             // ��������� ����������

ULONG   glWindowMainWidth;  // ������ �������� ����
ULONG   glWindowMainHeight; // ������ �������� ����

HWND    HwndMainWindow;     // ��������� �������� ����
HWND    HwndEdit1;          // ��������� �������� ���������� ����
HWND    HwndStatic1;        // ��������� ������������ ���� (�������)

//----------------------------------------
// ���������� �������

ATOM RegisterClassMainWindow();

HWND CreateMainWindow();

void CreateControlWindowsMain(HWND hwnd);

LRESULT ProcessingSizeEvent(HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

void InsertStringTailEdit(char *str);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// �������� �������

//
// �������� ������� ������� ����������
//
int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,PSTR szCmdLine,int iCmdShow){

MSG msg;
    
    hIns = hInstance;

    HwndMainWindow = CreateMainWindow();

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
    hwnd = CreateWindowEx(
                          WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,    // ����������� ����� ����
                          AppWindowName,            // ��� ������������������� ������ ����
                          "Mouse example",          // ��������� ����
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
// �������� ����������� ��������� (���������) �������� ����
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
// ������� ��������� ������� ��������� �������� ����
//
LRESULT ProcessingSizeEvent(HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam){

    // ������� ����� ��������� lParam �������� ����� ������ ����
    glWindowMainWidth = LOWORD(lParam);
    // ������� - ������
    glWindowMainHeight = HIWORD(lParam);

    // �������� ������ ���������� ���� ��������������� �������� �������� ����
    MoveWindow(HwndEdit1,   // ��������� ������������� ����
               10,                                  // �-���������� ������ �������� ����
               110 + (glWindowMainHeight-120)/2,    // �-���������� ������ �������� ����
               glWindowMainWidth-20,                // ������
               (glWindowMainHeight-120)/2,          // ������
               TRUE         // ���� ������������� �����������
               );

	return 0;
}

//--------------------

//
// ������� ��������� ������ � ����� ���������� ����.
//
void InsertStringTailEdit(char *str){

unsigned int offset;

    // �������� ����� ������ � ������ ����
    offset = GetWindowTextLength(HwndEdit1);

    // ���������� ������ � ����� ������
    SendMessage(HwndEdit1,EM_SETSEL,offset,offset);

    // �������� ������
    SendMessage(HwndEdit1,EM_REPLACESEL,0,(ULONG)str);

    return;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

HDC	hdc;
PAINTSTRUCT ps;
char buf[100];
unsigned int x,y;

    switch (iMsg){
        case WM_CREATE:
            // ������ ����������� �������� �������� ����
            CreateControlWindowsMain(hwnd);
            return 0 ;

        // ��������� ���������� ��� ��������� �������� ����
        case WM_SIZE:
            return ProcessingSizeEvent(hwnd,iMsg,wParam,lParam);

        // ��������� ���������� ����� ����������� ����
        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;

        // ��������� ���������� ��� ����������� ���� �� ����
        case WM_MOUSEMOVE:
            // ������� ����� �������� �-����������
            x = GET_X_LPARAM(lParam);
            // ������� ����� �������� �-����������
            y = GET_Y_LPARAM(lParam);

            sprintf(buf,"x = %d\ny = %d",x,y);

            // �������� ����� � ����������� ����
            SetWindowText(HwndStatic1,buf);
            return 0;

        // ��������� ���������� ��� ������� ����� ������ ���� � ����
        case WM_LBUTTONDOWN:
            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            sprintf(buf,"������ ����� ������ ���� � ����� (%d,%d)\r\n",x,y);
            InsertStringTailEdit(buf);
            return 0;

        // ��������� ���������� ��� ��������� ����� ������ ����
        case WM_LBUTTONUP:
            InsertStringTailEdit("�������� ����� ������ ����\r\n");
            return 0;

        // ��������� ���������� ��� ������� ����� ����� ������� ����
        case WM_LBUTTONDBLCLK:
            InsertStringTailEdit("������ ������ ����� ������ ����\r\n");
            return 0;

        // ��������� ���������� ��� ������� ������ ������ ����
        case WM_RBUTTONDOWN:
            InsertStringTailEdit("������ ������ ������ ����\r\n");
            return 0;

        // ��������� ���������� ��� ���������� ������ ������ ����
        case WM_RBUTTONUP:
            InsertStringTailEdit("�������� ������ ������ ����\r\n");
            return 0;

        // ��������� ���������� ��� ������� ����� ������ ������ ����
        case WM_RBUTTONDBLCLK:
            InsertStringTailEdit("������ ������ ������ ������ ����\r\n");
            return 0;

        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
