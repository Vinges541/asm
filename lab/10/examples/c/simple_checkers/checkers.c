/****************************************************************************

    ������ checkers.c

    ������ ��������� ����� ����, �������������� �����.
    ����� ����� ������������ �����.
    ��������� ��������� ����� � ���� ����� ������� ��� �� ��������.

    ������ ���� �������������       22.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>

#include "checkers.h"

//----------------------------------------
// ���������� ���������� � ���������

#define CheckerWindowName "CheckerWindow"

#define CHECKER_WIDTH   40
#define CHECKER_HEIGHT  CHECKER_WIDTH
#define CHECKER_CENTER  (CHECKER_WIDTH/2)

//----------------------------------------

// ���������, ������� ��������� ��� ������� ����
typedef struct _CheckerWindowStruct{

    COLORREF color;

} CheckerWindowStruct;

//----------------------------------------
// ���������� �������

static ATOM RegisterClassCheckerWindow(HINSTANCE ins,COLORREF color);

static BOOL MoveCheckerByCenter(HWND hwnd,unsigned int x,unsigned int y);

static void GetCheckerCenter(HWND hwnd,unsigned int *x,unsigned int *y);

static LRESULT CALLBACK WndProcChecker (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// �������� �������

//
// ����������� ������ ��������� ���� ����������
//
static ATOM RegisterClassCheckerWindow(HINSTANCE ins,COLORREF color){

WNDCLASSEX WndClass;    // ��������� ������
HBRUSH brush;

    brush = CreateSolidBrush(color);

    // ������� ����������� ���� ���������
    WndClass.cbSize         = sizeof (WndClass);
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcChecker;
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = sizeof(void*);    // ������ �������������� ������ ��� ������� ����
    WndClass.hInstance      = ins;
    WndClass.hIcon          = NULL;
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = brush;
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = CheckerWindowName;
    WndClass.hIconSm        = NULL;
    
    // ����������� ������
    return RegisterClassEx (&WndClass);
}

//--------------------

//
// �������� ��������� ���� ����������
//
HWND CreateCheckerWindow (
    HINSTANCE ins,          // ��������� ����������
    HWND parent,            // ��������� ������������� ����
    COLORREF color,         // ���� ����
    unsigned int x,         // x-���������� ������
    unsigned int y){        // y-���������� ������

HWND hwnd;  // ��������� ����
HRGN rgn;

    // ����������� ������ ��������� ����
    RegisterClassCheckerWindow(ins,color);

    // �������� ���� ������������������� ������
    hwnd = CreateWindow(
                          CheckerWindowName,            // ��� ������������������� ������ ����
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
                          (LPARAM)color             // �������� ���� � �������� ���������
                                                    // ������ � ���������� �������� ��� ��������� ��������� WM_CREATE
                          );

    if(hwnd == NULL){
        return NULL;
        }

    MoveCheckerByCenter (hwnd, x, y);

    // ������� ������ ����
    rgn = CreateEllipticRgn (0, 0, CHECKER_WIDTH, CHECKER_HEIGHT);
    SetWindowRgn (hwnd, rgn, FALSE);

    // ����������� ����
    ShowWindow (hwnd, SW_SHOWNORMAL);
    UpdateWindow (hwnd);

    return hwnd;
}

//--------------------

//
// ����������� ����� � ������������ � ���������� ���������� ������.
//
static BOOL MoveCheckerByCenter(HWND hwnd,unsigned int x,unsigned int y){

    return MoveWindow (hwnd, x-CHECKER_CENTER, y-CHECKER_CENTER, CHECKER_WIDTH, CHECKER_HEIGHT, TRUE);
}

//--------------------

//
// ��������� ��������� ������ ����� ������������ ������������� ����
//
static void GetCheckerCenter (HWND hwnd, unsigned int *x, unsigned int *y) {

RECT rect;
HWND parent;
POINT point;

    // ��������� ������������ ����� �� ������
    GetWindowRect (hwnd, &rect);

    // ��������� ���������� ������
    point.x = rect.left + CHECKER_WIDTH/2;
    point.y = rect.top + CHECKER_HEIGHT/2;

    // �������� ��������� ������������� ����
    parent = GetParent (hwnd);
    // ��������� ���������� �� ������ � ���������� ������������ ������������� ����
    ScreenToClient (parent, &point);

    // ���������� ���������� ������
    *x = point.x;
    *y = point.y;

    return;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
static LRESULT CALLBACK WndProcChecker (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
HBRUSH brush;
PAINTSTRUCT ps;
CheckerWindowStruct *cws;
RECT rect;
unsigned int x,y;
unsigned int cx,cy;

    cws = (CheckerWindowStruct*) GetWindowLong(hwnd, 0);

    switch (iMsg){

        case WM_CREATE:

            // �������� ������ ��� ����� ��������� ����
            cws = (CheckerWindowStruct*) malloc (sizeof (CheckerWindowStruct));
            if (cws == NULL)
                return -1;
            // ���������� ��������� �� ��������� � ������ ������� ����� �������������� ������ ����
            SetWindowLong (hwnd, 0, (LONG)cws);

            // ���������� ����, ���������� ��� �������� ����
            cws->color = ((CREATESTRUCT*)lParam)->lpCreateParams;

            return 0 ;

        case WM_DESTROY:
            //PostQuitMessage(0);
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
            rect.right = CHECKER_WIDTH;
            rect.bottom = CHECKER_HEIGHT;
            FillRect (hdc, &rect, brush);
            DeleteObject (brush);
            return 0;

        case WM_LBUTTONDOWN:

            // ������ ���� ������� �����
            SetCapture (hwnd);
            // ������ ���������������� ��� ������� ����������� ����,
            // ����� ������� ����������� ����
            InvalidateRect (hwnd, NULL, TRUE);
            return 0;

        case WM_LBUTTONUP:
            // ������������ ������� ����
            ReleaseCapture();
            return 0;

        case WM_MOUSEMOVE:
            if (wParam & MK_LBUTTON) {
                // �������� ���������� �������� ��������� ����
                x = GET_X_LPARAM (lParam);
                y = GET_Y_LPARAM (lParam);
                // �������� ���������� ����� �����
                GetCheckerCenter (hwnd,&cx,&cy);
                //���������� ����� �� �������� �������� ���� ������������ ������
                MoveCheckerByCenter (hwnd, cx+(x-CHECKER_CENTER), cy+(y-CHECKER_CENTER));
                }
            return 0;

        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

//--------------------
