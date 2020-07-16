/****************************************************************************

    ������ chess.c

    ������ ��������� ����� ����, �������������� ������.
    ���� ����� ������������ �����.
    ��������� ��������� � ���� ������ ������� ��� �� ��������.

    ������ ���� �������������       21.06.2010

****************************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <commctrl.h>

#include "chess.h"

//----------------------------------------
// ���������� ���������� � ���������

#define ChessWindowName "ChessWindow"

#define CHESS_WIDTH   40
#define CHESS_HEIGHT  CHESS_WIDTH
#define CHESS_CENTER  (CHESS_WIDTH/2)


HRGN glPawnRgn;
HRGN glCastleRgn;
HRGN glBishopRgn;
HRGN glKnightRgn;
HRGN glQueenRgn;
HRGN glKingRgn;

HIMAGELIST glImages;
HIMAGELIST glImages2;

//----------------------------------------

// ���������, ������� ��������� ��� ������� ����
typedef struct _ChessWindowStruct {

    COLORREF color;     // ���� ������
    FIGTYPE  type;      // ��� ������
    BOOL isCapture;

} ChessWindowStruct;

//----------------------------------------
// ���������� �������

static BOOL CreateChessRgn (HINSTANCE ins);

static BOOL MoveChessByCenter (HWND hwnd, unsigned int x, unsigned int y);

static void GetChessCenter (HWND hwnd,unsigned int *x, unsigned int *y);

static LRESULT CALLBACK WndProcChess (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// �������� �������

//
// ����������� ������ ������
//
ATOM RegisterClassChessWindow (HINSTANCE ins) {

WNDCLASSEX WndClass;    // ��������� ������

    CreateChessRgn (ins);

    // ������� ����������� ���� ���������
    WndClass.cbSize         = sizeof (WndClass);
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcChess;
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = sizeof (void*);    // ������ �������������� ������ ��� ������� ����
    WndClass.hInstance      = ins;
    WndClass.hIcon          = NULL;
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = NULL;
    WndClass.lpszMenuName   = NULL;
    WndClass.lpszClassName  = ChessWindowName;
    WndClass.hIconSm        = NULL;
    
    // ����������� ������
    return RegisterClassEx (&WndClass);
}

//--------------------

//
// �������� �������� �����
//
static BOOL CreateChessRgn (HINSTANCE ins) {

HBITMAP hb;
HRGN DstRgn;
HRGN TempRgn;
BITMAP bitmap;
BITMAPINFOHEADER bmih;
unsigned int i,j;
unsigned int *bits;
unsigned int left,right;
unsigned int pattern;
unsigned int width;
HDC hdc;
//static char *names[] = {"Pawn", "Castle", "Bishop", "Knight", "Queen", "King"};
static HRGN *rgns[] = {&glPawnRgn, &glCastleRgn, &glBishopRgn, &glKnightRgn, &glQueenRgn, &glKingRgn};
unsigned int fig;

#define INVALID_OFFSET  0
#define SIZE_FIG        40

    // ������� ������
    bits = (unsigned int*) malloc(4 * 480 * 40);

    // ��������� �������� �� ��������
    hb = LoadBitmap (ins, "Fig");
    // �������� ���������� � �������� � ���������
    GetObject (hb, sizeof(bitmap), &bitmap);

    // �������� �������� ����������
    hdc = GetDC (NULL);

    // ��������� ���� ��������� ��� ��������� ��������� �������
    bmih.biSize = sizeof (BITMAPINFOHEADER); 
    bmih.biWidth = bitmap.bmWidth;
    bmih.biHeight = bitmap.bmHeight;
    bmih.biPlanes = bitmap.bmPlanes;
    bmih.biBitCount = bitmap.bmBitsPixel;
    bmih.biClrUsed = 0;
    bmih.biCompression = BI_RGB; 
    bmih.biSizeImage = 0;
    bmih.biClrImportant = 0;
    // �������� �������� � ���� ������� ����
    if (!GetDIBits (hdc, hb, 0, bitmap.bmHeight, bits, (LPBITMAPINFO)&bmih, DIB_RGB_COLORS)) {
        int err = GetLastError();
        return FALSE;
        }
    ReleaseDC(NULL,hdc);

    // ����� ������� ���� ���������� � �������� �������
    // ��� ����������� �������, ������� ����� �����������
    pattern = bits[0];

    width = bitmap.bmWidth;

    for (fig = 0; fig < 6; ++fig) {

        // ������ ��������� ������ ������
        DstRgn = CreateRectRgn (0, 0, 0, 0);

        for (i = 0; i < bitmap.bmHeight; ++i){

            left = right = INVALID_OFFSET;

            for (j = SIZE_FIG*fig; j < SIZE_FIG*(fig+1); ++j) {

                if(bits[i*bitmap.bmWidth+j] == pattern){
                    if(left == INVALID_OFFSET)
                        continue;
                    else{
                        if(right == INVALID_OFFSET){
                            right = j - 1 - SIZE_FIG*fig;
                            }
                        else{
                            // ���� ����� ����� � ������ ����������

                            // ������ ������ ������� � 1 ������
                            TempRgn = CreateRectRgn (left, SIZE_FIG - 1 - i, right, SIZE_FIG - i);

                            // ����������� � ��� ������������� ���������
                            CombineRgn (DstRgn, DstRgn, TempRgn, RGN_OR);
                            left = right = INVALID_OFFSET;
                            DeleteObject(TempRgn);
                            }
                        }
                    }
                else{
                    if(left == INVALID_OFFSET)
                        left = j - SIZE_FIG * fig;
                    }
                }

            // ��������� � ������ ������ ��������� �����
            TempRgn = CreateRectRgn (left, SIZE_FIG - i - 1, right, SIZE_FIG - i);
            CombineRgn (DstRgn, DstRgn, TempRgn, RGN_OR);
            DeleteObject(TempRgn);
            }

        // ��������� ����������� ������
        *rgns[fig] = DstRgn;
        }

    return TRUE;
}


//--------------------

//
// �������� ���� ������
//
HWND CreateChessWindow (
    HINSTANCE ins,          // ��������� ����������
    HWND parent,            // ��������� ������������� ����
    COLORREF color,         // ���� ������
    unsigned int x,
    unsigned int y,
    FIGTYPE type){          // ��� ������

HWND hwnd;  // ��������� ����
HRGN rgn;   // ��������� �������
ChessWindowStruct *cws;

    if(type > FIG_MAX || type == FIG_NULL)
        return NULL;

    // ����������� ������ ���� �����
    RegisterClassChessWindow (ins);

    // �������� ���� ������������������� ������
    hwnd = CreateWindow(
                          ChessWindowName,            // ��� ������������������� ������ ����
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
                          NULL
                          );

    if(hwnd == NULL){
        return NULL;
        }

    // �������� ��������� ����
    cws = (ChessWindowStruct*) GetWindowLong(hwnd,0);
    cws->type = type;
    cws->color = color;
    cws->isCapture = FALSE;

    // ���������� ������
    MoveChessByCenter(hwnd,x,y);

    // �������� ������ � ����������� �� ���� ������
    if(type == FIG_PAWN)
        rgn = glPawnRgn;
    if(type == FIG_CASTLE)
        rgn = glCastleRgn;
    if(type == FIG_BISHOP)
        rgn = glBishopRgn;
    if(type == FIG_KNIGHT)
        rgn = glKnightRgn;
    if(type == FIG_QUEEN)
        rgn = glQueenRgn;
    if(type == FIG_KING)
        rgn = glKingRgn;

    // ������������� ������ ��� ����
    SetWindowRgn(hwnd,rgn,FALSE);

    // ����������� ����
    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    return hwnd;
}

//--------------------

//
// ����������� ������ � ������������ � ���������� ���������� ������.
//
static BOOL MoveChessByCenter (HWND hwnd, unsigned int x, unsigned int y) {

    return MoveWindow (hwnd, x-CHESS_CENTER, y-CHESS_CENTER, CHESS_WIDTH, CHESS_HEIGHT, TRUE);
}

//--------------------

//
// ��������� ��������� ������ ������ ������������ ������������� ����
//
static void GetChessCenter (HWND hwnd, unsigned int *x, unsigned int *y) {

RECT rect;
HWND parent;
POINT point;

    // ��������� ������������ ������ �� ������
    GetWindowRect (hwnd, &rect);

    // ��������� ���������� ������
    point.x = rect.left + CHESS_WIDTH/2;
    point.y = rect.top + CHESS_HEIGHT/2;

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
static LRESULT CALLBACK WndProcChess (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
PAINTSTRUCT ps;
HIMAGELIST list;
HBRUSH brush;
ChessWindowStruct *cws;
RECT rect;
unsigned int x,y;
unsigned int cx,cy;

    // �������� ���������, ��������� � �����
    cws = (ChessWindowStruct*) GetWindowLong (hwnd, 0);

    switch (iMsg){

        case WM_CREATE:

            // �������� ������ ��� ����� ��������� ����
            cws = (ChessWindowStruct*) malloc (sizeof (ChessWindowStruct));
            if (cws == NULL)
                return -1;
            // ���������� ��������� �� ��������� � ������ ������� ����� �������������� ������ ����
            SetWindowLong (hwnd, 0, (LONG)cws);

            return 0 ;

        case WM_DESTROY:
            //PostQuitMessage(0);
            return 0;

        case WM_PAINT:
            hdc = BeginPaint(hwnd,&ps);
            if(cws->color == COLOR_WHITE)
                list = glImages2;
            else
                list = glImages;
            EndPaint(hwnd,&ps);
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
            rect.right = CHESS_WIDTH;
            rect.bottom = CHESS_HEIGHT;
            FillRect (hdc, &rect, brush);
            return 0;

        case WM_LBUTTONDOWN:

            // ������ ���� ������� �����
            SetCapture(hwnd);
            cws->isCapture = TRUE;
            // ������ ���������������� ��� ������� ����������� ����,
            // ����� ������� ����������� ����
            InvalidateRect(hwnd,NULL,TRUE);
            return 0;

        case WM_LBUTTONUP:
            // ������������ ������� ����
            ReleaseCapture();
            cws->isCapture = FALSE;
            return 0;

        case WM_MOUSEMOVE:
            if (wParam & MK_LBUTTON && cws->isCapture) {
                // �������� ���������� �������� ��������� ����
                // ������������ ���� ������
                x = GET_X_LPARAM (lParam);
                y = GET_Y_LPARAM (lParam);
                // �������� ���������� ������ ������
                // ������������ ������������� ����
                GetChessCenter (hwnd, &cx, &cy);
                //���������� ������ �� �������� �������� ���� ������������ ������
                MoveChessByCenter (hwnd, cx + (x-CHESS_CENTER), cy + (y-CHESS_CENTER));
                }
            return 0;

        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

//--------------------
