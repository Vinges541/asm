/****************************************************************************

    ������ main.c

    ������ �������� ����������.

    ������ ���� �������������       15.06.2010

****************************************************************************/

#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

#include "main.h"

//----------------------------------------

// ���������, ��������� � ������� �����
typedef struct _RWinStruct{

    HWND hwnd;              // ��������� ����
    unsigned int width;     // ������ ����
    unsigned int height;    // ������ ����
    HWND edit1;
    HWND edit2;
    HWND static1;
    HWND button1;

} RWinStruct;

//----------------------------------------
// ���������� ���������� � ���������

#define AppWindowName "Application"

#define ED_1        201     // ������������� �������� ���������� ����
#define ED_2        202     // ������������� ������� ���������� ����
#define ST_1        203     // ������������� ������������ ����
#define BT_1        204     // ������������� ������

HINSTANCE hIns;             // ��������� ����������

//----------------------------------------
// ���������� �������

BOOL CreateExtraConsole (void);

ATOM RegisterClassMainWindow (void);

HWND CreateMainWindow (void);

void CreateControlWindowsMain (HWND hwnd);

LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

//----------------------------------------
// �������� �������

//
// ������� �������� �������
//
BOOL CreateExtraConsole(void){

	if(!AllocConsole())
		return FALSE;

    //HANDLE file = CreateFile("C:\\out.txt",GENERIC_WRITE,(DWORD)0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,(HANDLE) NULL);
	SetConsoleTitle("Debug console");
	*stdout = *(_fdopen(_open_osfhandle((long)GetStdHandle(STD_OUTPUT_HANDLE),_O_TEXT),"w"));
    //*stdout = *(_fdopen(_open_osfhandle((long)file,_O_TEXT),"w"));
	*stderr = *(_fdopen(_open_osfhandle((long)GetStdHandle(STD_ERROR_HANDLE),_O_TEXT),"w"));
	*stdin = *(_fdopen(_open_osfhandle((long)GetStdHandle(STD_INPUT_HANDLE),_O_TEXT),"r"));
	if(setvbuf(stdout, NULL, _IONBF, 0))
		return FALSE;
	if(setvbuf(stderr, NULL, _IONBF, 0))
		return FALSE;

	return TRUE;
}

//--------------------

//
// �������� ������� ������� ����������
//
int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,PSTR szCmdLine,int iCmdShow){

MSG msg;
    
    hIns = hInstance;

    if(CreateMainWindow() == NULL)
        return 0;

	CreateExtraConsole();
    printf ("Hello, World!\n");

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
    ShowWindow(hwnd,SW_SHOWNORMAL);
    UpdateWindow(hwnd);

    return hwnd;
}

//--------------------

//
// �������� ����������� ��������� (���������) �������� ����
//
void CreateControlWindowsMain (HWND hwnd){

RWinStruct *rws;

    rws = (RWinStruct*) GetWindowLong(hwnd,0);

    rws->edit1 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_1, hIns, NULL);

    rws->edit2 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_NUMBER | ES_READONLY,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_2, hIns, NULL);

    rws->static1 = CreateWindow("static", NULL,
                            WS_CHILD | WS_VISIBLE | WS_BORDER | ES_NUMBER,
                            10, 10,
                            80, 40,
                            hwnd, (HMENU)ST_1, hIns, NULL);
    SetWindowText(rws->static1,"static1");

    rws->button1=CreateWindow("button", "button1",
							WS_CHILD | WS_VISIBLE,
							100, 10,
							55, 30,
							hwnd, (HMENU)BT_1, hIns, NULL);

    return;
}

//--------------------

//
// ������� ��������� ������� ��������� �������� ����
//
LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam){

RWinStruct *rws;
unsigned int width;
unsigned int height;

    rws = (RWinStruct*) GetWindowLong(hwnd,0);

    width = rws->width = LOWORD(lParam);
    height = rws->height = HIWORD(lParam);

    // ������������ ��������� ����
    MoveWindow(rws->edit1,
               10,
               100,
               width-20,
               (height-120)/2,
               TRUE
               );

    MoveWindow(rws->edit2,
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

HDC	hdc;
HPEN pen;
PAINTSTRUCT ps;
RWinStruct *rws;

    // �������� ��������� � ����� ������� �����
    rws = (RWinStruct*) GetWindowLong(hwnd,0);

    switch (iMsg){

        case WM_CREATE:
            // �������� ��������� ��� ����
            rws = (RWinStruct*) malloc(sizeof(RWinStruct));
            if(rws == NULL)
                return -1;
            rws->hwnd = hwnd;

            // ��������� ��������� �� ��������� � �����
            SetWindowLong(hwnd,0,(LONG)rws);

            CreateControlWindowsMain(hwnd);
            return 0 ;

        case WM_DESTROY:
            free(rws);
            PostQuitMessage(0);
            return 0;

        case WM_SIZE:
            return ProcessingSizeEvent(hwnd,iMsg,wParam,lParam);

        case WM_SETFOCUS:
            printf ("Set focus\n");
            break;

        case WM_PAINT:
            
            //InvalidateRect(hwnd,NULL,TRUE);
            hdc = BeginPaint (hwnd,&ps);

            pen = CreatePen(PS_SOLID,3,RGB(255,150,30));
            SelectObject(hdc,pen);

            MoveToEx(hdc,0,75,NULL);
            LineTo(hdc,rws->width,75);

            DeleteObject(pen);
            EndPaint(hwnd,&ps);
            return 0;

        case WM_CLOSE:
            break;

        case WM_QUIT:
            break;

        case WM_DRAWITEM:
            break;

        case WM_NOTIFY:
            break;

        case WM_KEYDOWN:
            if (wParam == VK_SHIFT) {
                printf ("Shift down\n");
                }
            return 0;

        case WM_COMMAND:

            switch(LOWORD (wParam)){

                case BT_1:
                    break;

                default:
                    break;			
                }

			return 0;

        // ������� ���������� ��� ����������� �������� ��������� ���������� ����
        // ���� "static" � readonly "edit".
        // wParam �������� ��������� ��������� ����������
        // lParam �������� ��������� ��������� ����
        case WM_CTLCOLORSTATIC:

            SetTextColor ((HDC)wParam, RGB(255,128,0));
            SetBkColor ((HDC) wParam, RGB(100,100,0));
            return (LRESULT)GetStockObject (BLACK_BRUSH);

        case WM_LBUTTONDOWN:
            printf ("Left button down\n");
            SetFocus (hwnd);
            break;
        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
