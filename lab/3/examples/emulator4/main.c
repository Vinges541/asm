/****************************************************************************

    ������ main.c

    ����������� ��������� ���������.

    ������ ���� �������������       04.12.2013

****************************************************************************/

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <FCNTL.H>
#include <io.h>
#include <malloc.h>

#include "main.h"
#include "vm.h"

//----------------------------------------

// ���������, ��������� � ������� �����
typedef struct _RWinStruct{

    HWND hwnd;              // ��������� ����
    unsigned int width;     // ������ ����
    unsigned int height;    // ������ ����
    HWND disasWindow;
    HWND memoryWindow;
    HWND loadButton;
    HWND runButton;
    HWND nextButton;
    vm_struct *vm;
    HWND regValue[VM_REG_COUNT];
    HWND regLabel[VM_REG_COUNT];

} RWinStruct;

//----------------------------------------
// ���������� ���������� � ���������

#define AppWindowName "Application"

#define ED_1        201     // ������������� �������� ���������� ����
#define ED_2        202     // ������������� ������� ���������� ����
#define BT_LOAD     203     // ������������� ������ �������� ����
#define BT_RUN      204     // ������������� ������ ������� ����
#define BT_NEXT     205     // ������������� ������ ���������� ����� ����������
#define DW_START    210
#define MW_START    250
//#define ST_1        203     // ������������� ������������ ����
//#define BT_1        204     // ������������� ������

HINSTANCE hIns;             // ��������� ����������

//----------------------------------------
// ���������� �������

BOOL CreateExtraConsole (void);

ATOM RegisterClassMainWindow (void);

HWND CreateMainWindow (void);

void CreateControlWindowsMain (HWND hwnd);

LRESULT ProcessingSizeEvent (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam);

void InsertStringTailEdit (HWND hwnd, char *str);

void LoadCode (HWND hwnd);
void RunCode (HWND hwnd);
void StepOver (HWND hwnd);
void LoadVmReg (HWND hwnd);
void DisasVmIns (HWND hwnd);

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

    CreateExtraConsole();

    if(CreateMainWindow() == NULL)
        return 0;

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
                          hIns, NULL);

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
unsigned int i;

    rws = (RWinStruct*) GetWindowLong (hwnd, 0);

    rws->disasWindow = CreateWindow ("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_READONLY,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_1, hIns, NULL);

    rws->memoryWindow = CreateWindow ("edit", NULL,
                            WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | WS_BORDER |
                            ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_READONLY,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)ED_2, hIns, NULL);

    for (i = 0; i < VM_REG_COUNT; ++i) {
        char num[4];
        rws->regValue[i] = CreateWindow ("edit", NULL,
                            WS_CHILD | WS_VISIBLE | ES_LEFT | ES_MULTILINE,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)DW_START + i, hIns, NULL);
        SendMessage (rws->regValue[i], EM_LIMITTEXT, 8, 0);
        rws->regLabel[i] = CreateWindow ("static", NULL,
                            WS_CHILD | WS_VISIBLE | WS_BORDER | ES_NUMBER,
                            0, 0,
                            0, 0,
                            hwnd, (HMENU)MW_START + i, hIns, NULL);
        sprintf (num, "%d", i);
        SetWindowText (rws->regLabel[i], num);
        }

    rws->loadButton = CreateWindow ("button", "load",
							WS_CHILD | WS_VISIBLE,
							20, 20,
							55, 30,
							hwnd, (HMENU)BT_LOAD, hIns, NULL);

    rws->runButton = CreateWindow ("button", "run",
							WS_CHILD | WS_VISIBLE,
							100, 20,
							55, 30,
							hwnd, (HMENU)BT_RUN, hIns, NULL);

    rws->nextButton = CreateWindow ("button", "next",
							WS_CHILD | WS_VISIBLE,
							180, 20,
							55, 30,
							hwnd, (HMENU)BT_NEXT, hIns, NULL);

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
unsigned int i;
unsigned int regWidthOffset;
unsigned int regHeightOffset = 100;
unsigned int regWidth = 200;

    rws = (RWinStruct*) GetWindowLong (hwnd, 0);

    width = rws->width = LOWORD(lParam);
    height = rws->height = HIWORD(lParam);

    regWidthOffset = width - regWidth;

    // ������������ ��������� ����
    MoveWindow (rws->disasWindow,
               10,
               100,
               width - 20 - regWidth,
               (height-120)/2,
               TRUE
               );

    MoveWindow (rws->memoryWindow,
               10,
               110 + (height-120)/2,
               width - 20 - regWidth,
               (height-120)/2,
               TRUE
               );

    // ���������� ��������� ���������
    for (i = 0; i < VM_REG_COUNT; ++i) {
        MoveWindow (rws->regLabel[i],
                    regWidthOffset + (i % 2) * 100,
                    regHeightOffset + 20 * (i / 2) ,
                    20,
                    18,
                    TRUE);
        MoveWindow (rws->regValue[i], 
                    regWidthOffset + 20 + (i % 2) * 100,
                    regHeightOffset + 20 * (i / 2),
                    80,
                    18,
                    TRUE);
        }

	return 0;
}

//--------------------

void InsertStringTailEdit (HWND hwnd, char *str){

unsigned int offset;

    // �������� ����� ������ � ������ ����
    offset = GetWindowTextLength (hwnd);

    // ���������� ������ � ����� ������
    SendMessage (hwnd, EM_SETSEL, offset, offset);

    // �������� ������
    SendMessage (hwnd, EM_REPLACESEL, 0, (ULONG)str);

    return;
}

//--------------------

HANDLE OpenCodeFile (HWND mainWindow, HINSTANCE ins) {

OPENFILENAMEA ofn;
char szFile[MAX_PATH] = "";
HANDLE fd = NULL;

	ZeroMemory (&ofn, sizeof(ofn));
	ofn.lStructSize = sizeof(ofn);
	ofn.hwndOwner = mainWindow;
	ofn.lpstrFile = szFile;
	ofn.nMaxFile = sizeof(szFile);
	ofn.lpstrFilter = "bin-�����\0*.bin\0��� �����\0*.*\0";
	ofn.nFilterIndex = 0;
	ofn.lpstrFileTitle = NULL;
	ofn.nMaxFileTitle = 0;
	ofn.lpstrInitialDir = NULL;
	ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;
	if (GetOpenFileNameA (&ofn)){
		fd = CreateFile (szFile, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
		}

	return fd;
}

//--------------------

void LoadCode (HWND hwnd) {

RWinStruct *rws;
HANDLE fd;
BYTE *code;
DWORD fileSize;
DWORD numBytes;

    if (!(rws = (RWinStruct*) GetWindowLong (hwnd, 0))) {
        return;
        }

    if (!(fd = OpenCodeFile (hwnd, hIns))) {
        return;
        }

    fileSize = GetFileSize (fd, NULL);
    if (code = (BYTE*) malloc (fileSize)) {
        ReadFile (fd, code, fileSize, &numBytes, NULL);
        vm_load_code (rws->vm, code, fileSize);
        LoadVmReg (hwnd);
        DisasVmIns (hwnd);
        free (code);
        }

    CloseHandle (fd);

    return;
}

//--------------------

void RunCode (HWND hwnd) {

RWinStruct *rws;

    if (!(rws = (RWinStruct*) GetWindowLong (hwnd, 0))) {
        return;
        }

    vm_run (rws->vm);

    LoadVmReg (hwnd);
    DisasVmIns (hwnd);

    return;
}

//--------------------

void StepOver (HWND hwnd) {

RWinStruct *rws;

    if (!(rws = (RWinStruct*) GetWindowLong (hwnd, 0))) {
        return;
        }

        vm_run_current_instruction (rws->vm);
    //vm_trace (rws->vm);

    LoadVmReg (hwnd);
    DisasVmIns (hwnd);

    return;
}

//--------------------


void LoadVmReg (HWND hwnd) {

unsigned int i;
char buf[10];
RWinStruct *rws;
vmopvalue_t regValue;

    if (!(rws = (RWinStruct*) GetWindowLong (hwnd, 0))) {
        return;
        }

    for (i = 0; i < VM_REG_COUNT; ++i) {
        regValue = vm_get_reg_full (rws->vm, i);
        sprintf (buf, "%08X", regValue);
        SetWindowText (rws->regValue[i], buf);
        }

}

//--------------------

void DisasVmIns (HWND hwnd) {

unsigned int ip;
char buf[100];
RWinStruct *rws;
unsigned int i;
unsigned int bufSize;

    buf[1] = ' ';

    if (!(rws = (RWinStruct*) GetWindowLong (hwnd, 0))) {
        return;
        }

    ip = (unsigned int) vm_get_current_instruction (rws->vm);
    ip -= 5 * VM_INSTRUCTION_SIZE;

    SetWindowText (rws->disasWindow, "");
    for (i = 0; i < 11; ++i) {
        if (i == 5) {
            buf[0] = '>';
            }
        else {
            buf[0] = ' ';
            }
        bufSize = vm_get_disas_ins (rws->vm, (vm_instruction*) (ip + i * VM_INSTRUCTION_SIZE), buf + 2) + 2;
        buf[bufSize] = '\r';
        buf[bufSize + 1] = '\n';
        buf[bufSize + 2] = 0;
        InsertStringTailEdit (rws->disasWindow, buf);
        }

    return;
}

//--------------------

//--------------------

//--------------------

//
// ������� ��������� ��������� �������� ���� ����������.
//
LRESULT CALLBACK WndProcMain (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam) {

HDC	hdc;
HPEN pen;
PAINTSTRUCT ps;
RWinStruct *rws;

    // �������� ��������� � ����� ������� �����
    rws = (RWinStruct*) GetWindowLong (hwnd, 0);

    switch (iMsg){

        case WM_CREATE:
            // �������� ��������� ��� ����
            rws = (RWinStruct*) malloc (sizeof(RWinStruct));
            if(rws == NULL)
                return -1;
            rws->hwnd = hwnd;

            rws->vm = create_vm();

            // ��������� ��������� �� ��������� � �����
            SetWindowLong (hwnd, 0, (LONG)rws);

            CreateControlWindowsMain (hwnd);
            return 0 ;

        case WM_DESTROY:
            free(rws);
            PostQuitMessage(0);
            return 0;

        case WM_SIZE:
            return ProcessingSizeEvent (hwnd, iMsg, wParam, lParam);

        case WM_SETFOCUS:
            break;

        case WM_PAINT:
            
            //InvalidateRect(hwnd,NULL,TRUE);
            hdc = BeginPaint (hwnd, &ps);

            pen = CreatePen (PS_SOLID, 3, RGB (255,150,30));
            SelectObject (hdc, pen);

            MoveToEx (hdc, 0, 75, NULL);
            LineTo (hdc, rws->width, 75);

            DeleteObject (pen);
            EndPaint (hwnd, &ps);
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
                //printf ("Shift down\n");
                }
            return 0;

        case WM_COMMAND:

            switch(LOWORD (wParam)){

                case BT_LOAD:
                    LoadCode (hwnd);
                    break;

                case BT_RUN:
                    RunCode (hwnd);
                    break;

                case BT_NEXT:
                    StepOver (hwnd);
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

            SetTextColor ((HDC)wParam, RGB (255, 255, 255));
            SetBkColor ((HDC) wParam, RGB (0, 0, 0));
            return (LRESULT)GetStockObject (BLACK_BRUSH);

        case WM_LBUTTONDOWN:
            SetFocus (hwnd);
            break;
        }

    return DefWindowProc (hwnd, iMsg, wParam, lParam);
}

//--------------------

//--------------------
