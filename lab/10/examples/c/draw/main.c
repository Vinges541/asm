/****************************************************************************

    ������ main.c

    ������������� ������ ��������� � ���� ������� ����������� ����������.

    ������ ���� �������������       21.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <stdio.h>

//----------------------------------------
// ���������� ���������� � ���������

#define AppWindowName "Application"

HINSTANCE hIns;             // ��������� ����������

HWND    HwndMainWindow;     // ��������� �������� ����

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
                          "Draw example",           // ��������� ����
                          WS_OVERLAPPEDWINDOW,      // ����� ����
                          10,                       // X-���������� ������ �������� ����
                          10,                       // Y-���������� ������ �������� ����
                          600,                      // ������ ����
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
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

HDC	hdc;
RECT rect;              // ��������� �������� �������������
                        // �������� ���������� ����� ������� � ������ ������ �����
PAINTSTRUCT ps;
HBRUSH white_brush;     // ����� �����
HBRUSH black_brush;     // ������ �����
HBRUSH yellow_brush;    // ����� �����
HPEN border_pen;        // ���� ��� ���������� �����
COLORREF color_brush;
unsigned int i,j;

    switch (iMsg){
        case WM_CREATE:
            return 0 ;

        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;

        case WM_PAINT:
            hdc = BeginPaint(hwnd,&ps);

            // ������ ����� ������� �����
            color_brush = RGB(0,0,0);
            black_brush = CreateSolidBrush(color_brush);
            color_brush = RGB(255,255,255);
            white_brush = CreateSolidBrush(color_brush);
            color_brush = RGB(255,255,0);
            yellow_brush = CreateSolidBrush(color_brush);

            // ��������� ��������� ��������� �� ��������� ����� �����
            SelectObject(hdc,yellow_brush);
            // ������ ������, ������� ������� � ������� ��������������� ��������������
            // ������ ������������� ������, ������������� ��� ��������� ����������
            Ellipse(
                    hdc,    // �������� ����������
                    0,      // �-���������� ����� ������� �����
                    0,      // �-���������� ����� ������� �����
                    20,     // �-���������� ������ ������ �����
                    20      // �-���������� ������ ������ �����
                    );

            // ������ ���� ��� ��������� �����
            border_pen = CreatePen(
                                   PS_SOLID,    // ����� �����
                                   4,           // ������� �����
                                   RGB(100,200,120) // ���� �����
                                   );
            // ������������� ��������� ���� �� ��������� ��� ��������� ����������
            SelectObject(hdc,border_pen);
            // ������������� ����� ����� �� ��������� ��� ��������� ����������
            SelectObject(hdc,white_brush);
            // ������ �������������
            // ���� �������������� �������� ����� �� ���������
            // ������������� ������������� ������ �� ���������
            Rectangle(hdc,80,80,520,520);

            // ������ �����-����� ��������� ���� � �������������� � ������ (100,100),(500,500)
            // 64 ������ �������� 50�50 �������� ���������
            for(i=0;i<8;i++){
                for(j=0;j<8;j++){
                    // ��������� ���� ��������� �������� ��������������
                    rect.left = 100 + i*50;
                    rect.top = 100 + j*50;
                    rect.right = 150 + i*50;
                    rect.bottom = 150 + j*50;

                    // ������ ����������� ������������� ������� �����
                    if( (i+j)%2 == 0 )
                        FillRect(hdc,&rect,white_brush);
                    else
                        FillRect(hdc,&rect,black_brush);
                    }
                }
            
            // ������ �����
            rect.left = 100;
            rect.top = 100;
            rect.right = 500;
            rect.bottom = 500;
            FrameRect(hdc,&rect,black_brush);

            // ������� ��������� �������
            DeleteObject(black_brush);
            DeleteObject(white_brush);
            DeleteObject(yellow_brush);
            DeleteObject(border_pen);

            EndPaint(hwnd,&ps);
            return 0;

        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
