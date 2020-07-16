/****************************************************************************

    ���� block.h

    ������������ ���� ������ block.c

    ������ ���� �������������       22.06.2010

****************************************************************************/

#ifndef _CHECKERS_H_
#define _CHECKERS_H_

#include <windows.h>

//----------------------------------------

#define IS_VALID_MOVE   100

typedef struct _BlockWinNotifyStruct{
    NMHDR nmh;
    LONG x;
    LONG y;
} BlockWinNotifyStruct;

//----------------------------------------

/*
������� �������� �����.

���������:
ins     ��������� ����������
parent  ��������� ������������� ���� ��� �����
color   ���� �����
x       �-���������� ������ �����
y       �-���������� ������ �����

������������ ��������:
��������� ���������� ���� �����

//*/

extern HWND CreateBlockWindow(HINSTANCE ins,HWND parent,COLORREF color,unsigned int x,unsigned int y);

extern void MoveBlockWindow(HWND hwnd,int dx,int dy);

//----------------------------------------

#endif  // _CHECKERS_H_
