/****************************************************************************

    Файл block.h

    Заголовочный файл модуля block.c

    Маткин Илья Александрович       22.06.2010

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
Функция создания шашки.

Аргументы:
ins     описатель приложения
parent  описатель родительского окна для шашки
color   цвет шашки
x       Х-координата центра шашки
y       У-координата центра шашки

Возвращаемое значение:
описатель созданного окна шашки

//*/

extern HWND CreateBlockWindow(HINSTANCE ins,HWND parent,COLORREF color,unsigned int x,unsigned int y);

extern void MoveBlockWindow(HWND hwnd,int dx,int dy);

//----------------------------------------

#endif  // _CHECKERS_H_
