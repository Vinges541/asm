/****************************************************************************

    ������ main.c

    ������������� ������ ������ � ������������ ���������� (����������).

    ������ ���� �������������       10.06.2010

****************************************************************************/

#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

//----------------------------------------
// ���������� ���������� � ���������

#define AppWindowName "Application"

#define ED_1        201     // ������������� �������� ���������� ����
#define ED_2        202     // ������������� ������� ���������� ����
#define ST_1        203     // ������������� ������������ ����
#define BT_1        204     // ������������� ������

HINSTANCE hIns;             // ��������� ����������

ULONG   glWindowMainWidth;  // ������ �������� ����
ULONG   glWindowMainHeight; // ������ �������� ����

HWND    HwndMainWindow;     // ��������� �������� ����
HWND    HwndEdit1;          // ��������� �������� ���������� ����
HWND    HwndEdit2;          // ��������� ������� ���������� ����
HWND    HwndButton1;        // ��������� ������
HWND    HwndStatic1;        // ��������� ������������ ���� (�������)

//----------------------------------------
// ���������� �������

ATOM RegisterClassMainWindow();

HWND CreateMainWindow();

void CreateControlWindowsMain(HWND hwnd);

LRESULT ProcessingSizeEvent(HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

void ProcessingButton1(void);

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
    WndClass.style          = 0;
    WndClass.lpfnWndProc    = WndProcMain;
    WndClass.cbClsExtra     = 0;
    WndClass.cbWndExtra     = 0;
    WndClass.hInstance      = hIns;
    WndClass.hIcon          = LoadIcon (hIns, "MainIcon");
    WndClass.hCursor        = LoadCursor (NULL, IDC_ARROW);
    WndClass.hbrBackground  = (HBRUSH) GetStockObject (BLACK_BRUSH);
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
                          "Application",            // ��������� ����
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
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_1, hIns, NULL);

    HwndEdit2 = CreateWindow("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_NUMBER | ES_READONLY,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_2, hIns, NULL);

    HwndStatic1 = CreateWindow("static", NULL,
                            WS_CHILD | WS_VISIBLE | WS_BORDER | ES_NUMBER,
                            10, 10,
                            80, 40,
                            hwnd, (HMENU)ST_1, hIns, NULL);
    SetWindowText(HwndStatic1,"static1");

    HwndButton1=CreateWindow("button", "button1",
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
LRESULT ProcessingSizeEvent(HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam){

    // ������� ����� ��������� lParam �������� ����� ������ ����
    glWindowMainWidth = LOWORD(lParam);
    // ������� - ������
    glWindowMainHeight = HIWORD(lParam);

    // �������� ������ ���������� ���� ��������������� �������� �������� ����
    MoveWindow(
               HwndEdit1,   // ��������� ������������� ����
               10,          // �-���������� ������ �������� ����
               100,         // �-���������� ������ �������� ����
               glWindowMainWidth-20,    // ������
               (glWindowMainHeight-120)/2,  // ������
               TRUE         // ���� ������������� �����������
               );

    MoveWindow(
               HwndEdit2,
               10,
               110 + (glWindowMainHeight-120)/2,
               glWindowMainWidth-20,
               (glWindowMainHeight-120)/2,
               TRUE
               );

	return 0;
}

//--------------------

//
// ������� ��������� ������� ������� ������.
// ��������� ����� �� �������� ���������� ����
// � ������.
//
void ProcessingButton1(void){                                                                                                                                                                                                      

unsigned int offset;
char *buf;
unsigned int size;

    // �������� ����� ������ � ������� ����
    size = GetWindowTextLength(HwndEdit1);
    if(size == 0)
        return;

    // �������� ����������� ������
    buf = (char*) malloc(size+1);
    if(buf == 0)
        return;

    // �������� ������ �� ���� � �����
    if(GetWindowText(HwndEdit1,buf,size+1) != size){
        free(buf);
        return;
        }

    // �������� � ������� ��������� ���� ������� ������
    // �.�. ������� ����
    SetWindowText(HwndEdit1,NULL);

    // �������� ����� ������ � ������ ����
    offset = GetWindowTextLength(HwndEdit2);

    // ���������� ������ � ����� ������
    SendMessage(HwndEdit2,EM_SETSEL,offset,offset);

    // �������� ������, ������������ �� �������� ���� � ������
    SendMessage(HwndEdit2,EM_REPLACESEL,0,(ULONG)buf);

    free(buf);

    return;
}

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
LRESULT CALLBACK WndProcMain(HWND hwnd,UINT iMsg,WPARAM wParam,LPARAM lParam){

HDC	hdc;
HPEN pen;
PAINTSTRUCT ps;

    switch (iMsg){
        case WM_CREATE:
            // ������ ����������� �������� �������� ����
            CreateControlWindowsMain(hwnd);
            return 0 ;

        // ��������� ���������� ��� ��������� �������� ����
        case WM_SIZE:
            // �������� ������� ��������� ����� ���������
            return ProcessingSizeEvent(hwnd,iMsg,wParam,lParam);

        // ��������� ���������� ���������� ���������� ������������� ����
        // ��������, ��������� ���������� ��� ������� ������, ������������� � ������ ����
        case WM_COMMAND:

            // ������� ����� ��������� wParam ����� �������������� �������� ����������,
            // ������������ �������� ��������� ���������.
            switch(LOWORD (wParam)){

                // ���� ������������� ������
                case BT_1:
                    //�������� ������� ��������� ������� ������
                    ProcessingButton1();
                    break;

                default:
                    break;			
                }

			return 0;

        // ��������� ���������� ����� ����������� ����
        case WM_DESTROY:
            // �������� �������, ���������� ��������� ���������� ��������
            PostQuitMessage(0);
            return 0;

        // ��������� ���������� ��� ����������� ����
        case WM_PAINT:
            //InvalidateRect(hwnd,NULL,TRUE);
            // ����� ������������ ���� �������� ����������� �������,
            // ������� �������������� ���� � ��������� �
            // ���������� ��������� ��������� ���������� ��� ������� ����.
            // ��������� �������������� �� ��������� ���������� ����.
            hdc = BeginPaint(HwndMainWindow,&ps);
            // ������ ������ "����" ��� ��������� �����
            pen = CreatePen(
                            PS_SOLID,       // ����� ��� ����� (��������)
                            3,              // ������� �����
                            RGB(255,150,30) // ���� ����� � ������� �������
                            );
            // ����������� ��������� ����� � ���������� ����������
            SelectObject(hdc,pen);

            // ���������� ������� �������, � ������� ���������� ���������
            MoveToEx(
                     hdc,           // ��������� ��������� ����������
                     0,             // X-����������
                     75,            // Y-����������
                     NULL);

            // ������ ����� ��������� ������ �� ������� ������� �� ��������� �����
            LineTo(
                   hdc,             // ��������� ��������� ����������
                   glWindowMainWidth,   // X-���������� �������� �����
                   75               // Y-���������� �������� �����
                   );
            // ������� ��������� "����"
            DeleteObject(pen);

            // ��������� ������� ����������� ���� ������� ��������������� �������
            EndPaint(hwnd,&ps);
            return 0;

        // ������� ���������� ��� ����������� �������� ��������� ���������� ����
        // ���� "static"
        // wParam �������� ��������� ��������� ����������
        // lParam �������� ��������� ��������� ����
        case WM_CTLCOLORSTATIC:

            // �������� ���� ������ � ���� ���� ������
            if((HWND)lParam == HwndEdit2){
                // ���� ��� ������ ��������� ����,
                // �� ���������� ������� ����� �� ����� ����
                SetTextColor((HDC)wParam,RGB(255,0,0));
                SetBkColor((HDC) wParam,RGB(200,200,200));
                // ���������� �����, ������� ����� ������������� ���
                return (LRESULT)GetStockObject(DKGRAY_BRUSH);
                }
            else{
                // ��� ���� ��������� ��������� ����� �� ������ ����
                SetTextColor((HDC)wParam,RGB(255,128,0));
                SetBkColor((HDC) wParam,RGB(100,100,0));
                return (LRESULT)GetStockObject(BLACK_BRUSH);
                }
        }

    return DefWindowProc(hwnd,iMsg,wParam,lParam);
}

//--------------------

//--------------------
