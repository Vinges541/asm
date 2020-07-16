/****************************************************************************

    ������ block.c

    ������ ��������� ����� ����, �������������� ������������ �����.
    ��������� ��������� ����� � ���� ����� ������� ��� ��� ��������.

    ������ ���� �������������       22.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>

#include "block.h"

//----------------------------------------
// ���������� ���������� � ���������

#define BlockWindowName "BlockWindow"

#define BLOCK_WIDTH   45
#define BLOCK_HEIGHT  BLOCK_WIDTH
#define BLOCK_CENTER  (BLOCK_WIDTH/2)

//----------------------------------------

// ���������, ������� ��������� ��� ������� ����
typedef struct _BlockWindowStruct{

    BOOL capture;           // ���� ������� ����
    COLORREF color;         // ���� ���� ����
    unsigned int x_capture; // �-���������� ���� ��� ������� ����
    unsigned int y_capture; // �-���������� ���� ��� ������� ����

} BlockWindowStruct;

//----------------------------------------
// ���������� �������

static ATOM RegisterClassBlockWindow(HINSTANCE ins,COLORREF color);

static BOOL MoveBlockByCenter(HWND hwnd,unsigned int x,unsigned int y);

static void GetBlockCenter(HWND hwnd,unsigned int *x,unsigned int *y);

static LRESULT CALLBACK WndProcBlock (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// �������� �������

//
// ����������� ������ ��������� ���� ����������
//
static ATOM RegisterClassBlockWindow(HINSTANCE ins,COLORREF color){

WNDCLASSEX WndClass;    // ��������� ������
HBRUSH brush;

    brush = CreateSolidBrush(color);

    // ������� ����������� ���� ���������
    WndClass.cbSize         = sizeof (WndClass);
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcBlock;
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = sizeof(void*);    // ������ �������������� ������ ��� ������� ����
    WndClass.hInstance      = ins;
    WndClass.hIcon          = NULL;
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = brush;
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = BlockWindowName;
    WndClass.hIconSm        = NULL;
    
    // ����������� ������
    return RegisterClassEx (&WndClass);
}

//--------------------

//
// �������� ��������� ���� ����������
//
HWND CreateBlockWindow(HINSTANCE ins,HWND parent,COLORREF color,unsigned int x,unsigned int y){

HWND hwnd;  // ��������� ����

    // ����������� ������ ��������� ����
    RegisterClassBlockWindow(ins,color);

    // �������� ���� ������������������� ������
    hwnd = CreateWindow(
                          BlockWindowName,            // ��� ������������������� ������ ����
                          NULL,          // ��������� ����
                          WS_OVERLAPPED | WS_CHILD,      // ����� ����
                          0,                       // X-���������� ������ �������� ����
                          0,                       // Y-���������� ������ �������� ����
                          0,                       // ������ ����
                          0,                       // ������ ����
                          parent,                   // ��������� ������������� ����
                          NULL,                     // ��������� �������� ���� (��� �������� ����)
                                                    // ������������� ���� (��� ��������� ����)
                          ins,                      // ������������� ����������
                          (LPVOID)color             // �������� ���� � �������� ���������
                                                    // ������ � ���������� �������� ��� ��������� ��������� WM_CREATE
                          );

    if(hwnd == NULL){
        return NULL;
        }

    MoveBlockByCenter(hwnd,x,y);

    // ����������� ����
    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    return hwnd;
}

//--------------------

//
// ����������� ����� � ������������ � ���������� ���������� ������.
//
static BOOL MoveBlockByCenter(HWND hwnd,unsigned int x,unsigned int y){

    return MoveWindow(hwnd,x-BLOCK_CENTER,y-BLOCK_CENTER,BLOCK_WIDTH,BLOCK_HEIGHT,TRUE);
}

//--------------------

//
// ��������� ��������� ������ ����� ������������ ������������� ����
//
static void GetBlockCenter(HWND hwnd,unsigned int *x,unsigned int *y){

RECT rect;
HWND parent;
POINT point;

    // ��������� ������������ ����� �� ������
    GetWindowRect(hwnd,&rect);

    // ��������� ���������� ������
    point.x = rect.left + BLOCK_WIDTH/2;
    point.y = rect.top + BLOCK_HEIGHT/2;

    // �������� ��������� ������������� ����
    parent = GetParent(hwnd);
    // ��������� ���������� �� ������ � ���������� ������������ ������������� ����
    ScreenToClient(parent,&point);

    // ���������� ���������� ������
    *x = point.x;
    *y = point.y;

    return;
}

//--------------------


static BOOL IsValidMove (HWND hwnd, unsigned int *x, unsigned int *y) {

HWND parent;
BlockWinNotifyStruct bwn;

    parent = GetParent(hwnd);
    bwn.nmh.hwndFrom = hwnd;
    bwn.nmh.code = IS_VALID_MOVE;

    bwn.x = *x - BLOCK_CENTER;
    bwn.y = *y - BLOCK_CENTER;

    if (!SendMessage (parent, WM_NOTIFY, 0, (LPARAM)&bwn)) {
        *x = bwn.x + BLOCK_CENTER;
        *y = bwn.y + BLOCK_CENTER;
        return FALSE;
        }

    bwn.x = *x + BLOCK_CENTER;
    bwn.y = *y + BLOCK_CENTER;

    if (!SendMessage (parent, WM_NOTIFY, 0, (LPARAM)&bwn)) {
        *x = bwn.x - BLOCK_CENTER;
        *y = bwn.y - BLOCK_CENTER;
        return FALSE;
        }

    return TRUE;
}

//--------------------


void MoveBlockWindow (HWND hwnd, int dx, int dy) {

int x,y;

    GetBlockCenter (hwnd, &x, &y);

    x += dx;
    y += dy;

    IsValidMove (hwnd, &x, &y);
    MoveBlockByCenter (hwnd, x, y);

    return;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
static LRESULT CALLBACK WndProcBlock (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
HBRUSH brush;
PAINTSTRUCT ps;
BlockWindowStruct *cws;
RECT rect;
unsigned int x,y;
unsigned int cx,cy;

    cws = (BlockWindowStruct*) GetWindowLong (hwnd, 0);

    switch (iMsg){

        case WM_CREATE:

            // �������� ������ ��� ����� ��������� ����
            cws = (BlockWindowStruct*) malloc (sizeof (BlockWindowStruct));
            if (cws == NULL)
                return -1;
            // ���������� ��������� �� ��������� � ������ ������� ����� �������������� ������ ����
            SetWindowLong (hwnd, 0, (LONG)cws);

            // ���������� ����, ���������� ��� �������� ����
            cws->color = (COLORREF)((CREATESTRUCT*)lParam)->lpCreateParams;

            return 0 ;

        case WM_DESTROY:
            //PostQuitMessage (0);
            return 0;

        // ��������� ���������� ��� ������������ ���� ����
        case WM_ERASEBKGND:
            // �������� ���������� ��������� ����� wParam
            hdc = (HDC)wParam;
            // ������ ����� ������� �����
            brush = CreateSolidBrush (cws->color);
            // ����������� ������������� ������� ����� � �������
            rect.left = 0;
            rect.top = 0;
            rect.right = BLOCK_WIDTH;
            rect.bottom = BLOCK_HEIGHT;
            FillRect (hdc, &rect, brush);
            return 0;

        case WM_KEYDOWN:
            SendMessage (GetParent (hwnd), iMsg, wParam, lParam);
            return 0;

        case WM_LBUTTONDOWN:

            cws->x_capture = GET_X_LPARAM (lParam);
            cws->y_capture = GET_Y_LPARAM (lParam);
            cws->capture = TRUE;
            // ������ ���� ������� �����
            SetCapture(hwnd);
            // ������ ���������������� ��� ������� ����������� ����,
            // ����� ������� ����������� ����
            InvalidateRect (hwnd, NULL, TRUE);
            return 0;

        case WM_LBUTTONUP:
            cws->capture = FALSE;
            // ������������ ������� ����
            ReleaseCapture();
            return 0;

        case WM_MOUSEMOVE:
            //if(wParam & MK_LBUTTON){
            if (cws->capture == TRUE) {
                // �������� ���������� �������� ��������� ����
                // ������������ �����
                x = GET_X_LPARAM (lParam);
                y = GET_Y_LPARAM (lParam);
                // �������� ���������� ������ ����� ������������
                // ������������� ����
                GetBlockCenter (hwnd, &cx, &cy);
                cx += x - cws->x_capture;
                cy += y - cws->y_capture;
                
                // �������� ����������� �����������
                if (IsValidMove (hwnd, &cx, &cy)) {
                    //���������� ���� �� �������� �������� ���� ������������ ����� �������
                    MoveBlockByCenter (hwnd, cx, cy);
                    }
                else{
                    // ����� ���������� ���� �������
                    POINT point;
                    MoveBlockByCenter (hwnd, cx, cy);

                    // �������� ������ ���� �������
                    point.x = cws->x_capture;
                    point.y = cws->y_capture;

                    // ��������� ���������� ������������ �����
                    // � ���������� ������
                    ClientToScreen (hwnd, &point);

                    SetCursorPos (point.x, point.y);
                    }
                }
            return 0;

        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
