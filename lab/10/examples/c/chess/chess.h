/****************************************************************************

    Файл chess.h

    Заголовочный файл модуля chess.c

    Маткин Илья Александрович       05.07.2010

****************************************************************************/

#ifndef _CHESS_H_
#define _CHESS_H_

#include <windows.h>

//----------------------------------------

#define COLOR_WHITE     RGB(200,200,200)
#define COLOR_BLACK     RGB(100,100,100)


#define FIG_NULL        0
#define FIG_PAWN        1
#define FIG_CASTLE      2
#define FIG_BISHOP      3
#define FIG_KNIGHT      4
#define FIG_QUEEN       5
#define FIG_KING        6
#define FIG_MAX         6

typedef unsigned int FIGTYPE;

//--------------------

//----------------------------------------

extern ATOM RegisterClassChessWindow(HINSTANCE ins);


/*
Функция создания фигуры.

Аргументы:
ins     описатель приложения
parent  описатель родительского окна для фигуры
color   цвет фигуры
x       Х-координата центра фигуры
y       У-координата центра фигуры
type    тип фигуры

Возвращаемое значение:
описатель созданного окна фигуры
*/
extern HWND CreateChessWindow(HINSTANCE ins,HWND parent,COLORREF color,unsigned int x,unsigned int y,FIGTYPE type);

//----------------------------------------

#endif  // _CHESS_H_
