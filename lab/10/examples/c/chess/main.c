/****************************************************************************

    ������ main.c

    ������������� ������ ����������� ����� �� ��������� �����.

    ������ ���� �������������       21.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <stdio.h>

#include "chess.h"


//----------------------------------------


typedef struct _FigureStruct{

    FIGTYPE type;
    COLORREF color;

} FigureStruct;

//----------------------------------------
// ���������� ���������� � ���������

#define AppWindowName "Application"

HINSTANCE hIns;             // ��������� ����������

HWND    HwndMainWindow;     // ��������� �������� ����

FigureStruct figures[8][8];

//----------------------------------------
// ���������� �������

ATOM RegisterClassMainWindow();

HWND CreateMainWindow();

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

static void InstallFigures(HINSTANCE ins,HWND hwnd);

static void ShowFigures(HWND hwnd);

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
    hwnd = CreateWindowEx (
                          WS_EX_CONTROLPARENT | WS_EX_APPWINDOW,    // ����������� ����� ����
                          AppWindowName,            // ��� ������������������� ������ ����
                          "Simple Chess",          // ��������� ����
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

    if (hwnd == NULL) {
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
RECT rect;              // ��������� �������� �������������
                        // �������� ���������� ����� ������� � ������ ������ �����
PAINTSTRUCT ps;
HBRUSH white_brush;     // ����� �����
HBRUSH black_brush;     // ������ �����
HPEN border_pen;        // ���� ��� ���������� �����
COLORREF color_brush;
unsigned int i,j;

    switch (iMsg) {
        case WM_CREATE:
            RegisterClassChessWindow(hIns);
            //CreateChessWindow(hIns,hwnd,RGB(100,100,100),200,200,FIG_PAWN);
            //CreateChessWindow(hIns,hwnd,RGB(200,200,200),300,300,FIG_CASTLE);
            InstallFigures(hIns,hwnd);
            return 0;

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

            // ������ ���� ��� ��������� �����
            border_pen = CreatePen(
                                   PS_SOLID,    // ����� �����
                                   4,           // ������� �����
                                   RGB(100,200,200) // ���� �����
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
            FrameRect(hdc,&rect,GetStockObject(BLACK_BRUSH));

            // ������� ��������� �������
            DeleteObject(black_brush);
            DeleteObject(white_brush);
            DeleteObject(border_pen);

            EndPaint(hwnd,&ps);
            return 0;

        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------
//--------------------


static void ShowFigures(HWND hwnd){

unsigned int i,j;

    for(i=0;i<8;i++){
        for(j=0;j<8;j++){
            CreateChessWindow(hIns,hwnd,figures[i][j].color,100+j*50+25,100+i*50+25,figures[i][j].type);
            }
        }

    return;
}

//--------------------

static void InstallFigures(HINSTANCE ins,HWND hwnd){

unsigned int i;

    figures[0][0].color = COLOR_BLACK;
    figures[0][0].type  = FIG_CASTLE;
    figures[0][1].color = COLOR_BLACK;
    figures[0][1].type  = FIG_KNIGHT;
    figures[0][2].color = COLOR_BLACK;
    figures[0][2].type  = FIG_BISHOP;
    figures[0][3].color = COLOR_BLACK;
    figures[0][3].type  = FIG_QUEEN;
    figures[0][4].color = COLOR_BLACK;
    figures[0][4].type  = FIG_KING;
    figures[0][5].color = COLOR_BLACK;
    figures[0][5].type  = FIG_BISHOP;
    figures[0][6].color = COLOR_BLACK;
    figures[0][6].type  = FIG_KNIGHT;
    figures[0][7].color = COLOR_BLACK;
    figures[0][7].type  = FIG_CASTLE;

    for(i=0;i<8;i++){
        figures[1][i].color = COLOR_BLACK;
        figures[1][i].type = FIG_PAWN;
        }

    figures[7][0].color = COLOR_WHITE;
    figures[7][0].type  = FIG_CASTLE;
    figures[7][1].color = COLOR_WHITE;
    figures[7][1].type  = FIG_KNIGHT;
    figures[7][2].color = COLOR_WHITE;
    figures[7][2].type  = FIG_BISHOP;
    figures[7][3].color = COLOR_WHITE;
    figures[7][3].type  = FIG_QUEEN;
    figures[7][4].color = COLOR_WHITE;
    figures[7][4].type  = FIG_KING;
    figures[7][5].color = COLOR_WHITE;
    figures[7][5].type  = FIG_BISHOP;
    figures[7][6].color = COLOR_WHITE;
    figures[7][6].type  = FIG_KNIGHT;
    figures[7][7].color = COLOR_WHITE;
    figures[7][7].type  = FIG_CASTLE;

    for(i=0;i<8;i++){
        figures[6][i].color = COLOR_WHITE;
        figures[6][i].type = FIG_PAWN;
        }

    ShowFigures(hwnd);

    return;
}


//--------------------
