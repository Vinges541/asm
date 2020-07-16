/****************************************************************************

    ������ main.c

    ������������� ������� ���������� ���������� ��������.

    ������ ���� �������������       23.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <stdio.h>

#include "block.h"

//----------------------------------------
// ���������� ���������� � ���������

#define AppWindowName "Application"

// ������������� �������
#define TIMER_1             200

// ������ ����������� �����
#define LBLOCKSIZE          30

// ������ �������� ����
#define SIZE_GAMEFIELD      300

// ���������� ���������� ������ � ������ � ������� �������� ����
#define NUMOBJ              (SIZE_GAMEFIELD/LBLOCKSIZE)

HINSTANCE hIns;             // ��������� ����������

HWND    HwndMainWindow;     // ��������� �������� ����
HWND    HwndBlock;          // ��������� ���� ����������� �����

// ������������� ������� �������� ����
RECT glRectField1 = {50,50,50+SIZE_GAMEFIELD,50+SIZE_GAMEFIELD};

// ������������� ������� �������� ����
RECT glRectField2 = {450,50,450+SIZE_GAMEFIELD,50+SIZE_GAMEFIELD};

unsigned char *objects[NUMOBJ]; // ������ �������� � ������ ������� ����

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
int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,PSTR szCmdLine,int iCmdShow){

MSG msg;
    
    hIns = hInstance;

    HwndMainWindow = CreateMainWindow();

    // ������������� ������ ��� ����������� �������� � ������ ������� ����
    SetTimer(HwndMainWindow,TIMER_1,100,NULL);

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
                          "�����������",          // ��������� ����
                          WS_OVERLAPPEDWINDOW,      // ����� ����
                          10,                       // X-���������� ������ �������� ����
                          10,                       // Y-���������� ������ �������� ����
                          800,                      // ������ ����
                          450,                      // ������ ����
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
    ShowWindow (hwnd, SW_SHOWNORMAL);
    UpdateWindow (hwnd);

    return hwnd;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

HDC	hdc;
RECT rect;              // ��������� �������� �������������
                        // �������� ���������� ����� ������� � ������ ������ �����
PAINTSTRUCT ps;
unsigned int i,j;
unsigned char *tmp;
BlockWinNotifyStruct *bwn;

    switch (iMsg){
        case WM_CREATE:
            // �������� ����������� ����� ��� ������� �������� ����
            HwndBlock = CreateBlockWindow (hIns, hwnd, RGB(100, 150, 100), 500, 200);

            // ��������� ������ ��� �������� ������� ������� �������� ����
            for (i = 0; i < NUMOBJ; ++i) {
                objects[i] = (unsigned char*) calloc (sizeof(unsigned char), NUMOBJ);
                }
            return 0 ;

        case WM_DESTROY:
            PostQuitMessage (0);
            return 0;

        case WM_PAINT:
            hdc = BeginPaint (hwnd, &ps);

            // ������ ������� ����
            FrameRect (hdc, &glRectField1, GetStockObject(BLACK_BRUSH));
            FrameRect (hdc, &glRectField2 ,GetStockObject(BLACK_BRUSH));

            // ������ ������� ������� �������� ����
            for (i = 0; i < NUMOBJ; ++i){
                for (j = 0; j < NUMOBJ; ++j){
                    if (objects[i][j]) {
                        rect.left = glRectField1.left + j*LBLOCKSIZE;
                        rect.top = glRectField1.top + i*LBLOCKSIZE;
                        rect.right = rect.left + LBLOCKSIZE;
                        rect.bottom = rect.top + LBLOCKSIZE;
                        FillRect (hdc, &rect, GetStockObject (GRAY_BRUSH));
                        }
                    }
                }

            EndPaint (hwnd, &ps);
            return 0;

        // ����������� �� �������� ����
        case WM_NOTIFY:
            // ������������ ��������� �� ����� ������� ����
            if( ((NMHDR*)lParam)->hwndFrom == HwndBlock ){
                int ret = 1;
                bwn = (BlockWinNotifyStruct*) lParam;

                // ������������ ���������, ���������� ��� ����������� �����
                // ���������, ����� ���� �� ������� �� ������� ������� ����
                if(bwn->nmh.code == IS_VALID_MOVE){
                    if( bwn->x < glRectField2.left ){
                        bwn->x = glRectField2.left;
                        ret = 0;
                        }
                    if( bwn->x > glRectField2.right ){
                        bwn->x = glRectField2.right;
                        ret = 0;
                        }
                    if( bwn->y < glRectField2.top ){
                        bwn->y = glRectField2.top;
                        ret = 0;
                        }
                    if( bwn->y > glRectField2.bottom ){
                        bwn->y = glRectField2.bottom;
                        ret = 0;
                        }
                        return ret;
                    }
                }
            return 0;

        // ��������� ���������� ��� ������� �������
        case WM_KEYDOWN:
            // ������������ ������� ������ ���������� ��������
            // ��������������, ���������� ���� �����, ������, ����� � ����
            switch (wParam) {
                case VK_LEFT:
                    MoveBlockWindow (HwndBlock, -LBLOCKSIZE, 0);
                    break;
                case VK_RIGHT:
                    MoveBlockWindow (HwndBlock, LBLOCKSIZE, 0);
                    break;
                case VK_UP:
                    MoveBlockWindow (HwndBlock, 0, -LBLOCKSIZE);
                    break;
                case VK_DOWN:
                    MoveBlockWindow(HwndBlock,0,LBLOCKSIZE);
                    break;
                }
            return 0;

        case WM_TIMER:

            // �������� ��� ����� ������� �������� ����
            // �� ���� ����
            tmp = objects[NUMOBJ-1];
            for (i = NUMOBJ-1; i > 0; --i)
                objects[i] = objects[i-1];
            objects[0] = tmp;

            // �������������� ������ ����� ������ ���������� ����������
            for (j = 0; j < NUMOBJ; ++j) {
                objects[0][j] = rand()%2;
                if (objects[0][j])
                    objects[0][j] = rand()%2;
                if (objects[0][j])
                    objects[0][j] = rand()%2;
                }

            // ������ ���������������� ������ ������� ����,
            // ��� ������� ��������� ��������� WM_PAINT
            InvalidateRect (hwnd, &glRectField1, TRUE);

            return 0;

        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

//--------------------
