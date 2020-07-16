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

HFONT	hButtonFont;

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
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (WHITE_BRUSH);
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
                            WS_CHILD | WS_VISIBLE | BS_OWNERDRAW,
                            100, 100,
                            100, 100,
                            hwnd, (HMENU)BT_1, hIns, NULL);

    return;
}

//--------------------

//
// ������� ����������� ������ �� ������������� ����
//
void ButtonRedrawParent (LPDRAWITEMSTRUCT pdis, HWND parent) {

HBRUSH  brush;
char*   WindowText;
DWORD   SizeText;
HWND    HwndChild;
SIZE    LengthText;
RECT    rect;

    brush = CreateSolidBrush(RGB(55,55,55));
    FillRect (pdis->hDC, &pdis->rcItem, brush);
    DeleteObject(brush);

    HwndChild = GetDlgItem (parent, pdis->CtlID);

    if (pdis->itemState & ODS_SELECTED) {
        brush = CreateSolidBrush (RGB (0,0,0));
        FrameRect (pdis->hDC, &pdis->rcItem, brush);
        CopyRect (&rect, &pdis->rcItem);
        rect.top -= 1;
        rect.left -= 1;
        rect.bottom -= 1;
        rect.right -= 1;
        FrameRect (pdis->hDC, &rect, brush);
        DeleteObject (brush);
        //SetTextColor (pdis->hDC, RGB (200,50,50));
        SetTextColor (pdis->hDC, RGB (170,50,50));
        }
    else{
        brush = CreateSolidBrush (RGB(50,50,50));
        FrameRect (pdis->hDC, &pdis->rcItem, brush);
        DeleteObject (brush);
        if (pdis->itemState & ODS_DISABLED)
            SetTextColor (pdis->hDC, RGB (150,150,150));
        else{
            if (pdis->itemState & ODS_FOCUS)
                //SetTextColor (pdis->hDC, RGB(150,50,50));
                SetTextColor (pdis->hDC, RGB(200,50,50));
            else							
                SetTextColor (pdis->hDC, RGB(255,255,255));
            }
        }

    SetBkColor (pdis->hDC, RGB (55,55,55));
    SizeText = GetWindowTextLength (HwndChild);
    WindowText = (char*) malloc (SizeText+1);
    GetWindowText (HwndChild, WindowText, SizeText+1);

    GetTextExtentPoint32 (pdis->hDC, WindowText, SizeText, &LengthText);
    TextOut (pdis->hDC, (pdis->rcItem.right-LengthText.cx)/2,
            pdis->rcItem.bottom/2-LengthText.cy/2, WindowText,SizeText);
    free (WindowText);

    return;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

LOGFONT	lf;
LPDRAWITEMSTRUCT pdis;

    switch (iMsg){

        case WM_CREATE:

            CreateControlWindowsMain(hwnd);

            // �������� ������
            lf.lfHeight			= 20;
            lf.lfWidth			= 12;
            lf.lfEscapement		= 0;
            lf.lfOrientation	= 0;
            lf.lfWeight			= FW_MEDIUM;
            lf.lfItalic			= 1;
            lf.lfUnderline		= 0;
            lf.lfStrikeOut		= 0;
            lf.lfCharSet		= ANSI_CHARSET;
            lf.lfOutPrecision	= 0;
            lf.lfClipPrecision	= 0;
            lf.lfQuality		= 0;
            lf.lfPitchAndFamily	= 0;
            hButtonFont = CreateFontIndirect (&lf);

            return 0 ;

        case WM_DESTROY:

            PostQuitMessage(0);
            return 0;

        case WM_DRAWITEM:
            pdis = (LPDRAWITEMSTRUCT)lParam;
            switch(pdis->CtlID){
                case BT_1:
                    SelectObject (pdis->hDC, hButtonFont);
                    ButtonRedrawParent (pdis, hwnd);
                    break;
                default:
                    break;
                }
            return 0;

        // ��������� ���������� ��� ������� ������
        case WM_COMMAND:

            // � ��������� wParam ������������� ������� ������
            switch(LOWORD (wParam)){

                case BT_1:
                    MessageBox(hwnd,"Button1 down",NULL,MB_OK);
                    break;

                default:
                    break;			
                }

			return 0;

        case WM_LBUTTONDOWN:
            SetFocus (hwnd);
            break;
        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
