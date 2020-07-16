/****************************************************************************

    Файл bmp.h
    
    Заголовочный файл модуля bmp.c

    Маткин Илья Александрович       06.11.2013

****************************************************************************/

#ifndef _BMP_H_
#define _BMP_H_


#include <windows.h>

//----------------------------------------

//----------------------------------------


void DrawBitmap (HDC hdc, HBITMAP hBitmap, int xStart, int yStart);

HBITMAP LoadBmpFile (HWND MainWindow, HINSTANCE ins);

void CreateBMPFile (LPTSTR pszFile, HBITMAP hbitmap, HWND MainWindow);

void SaveBMPFile (HBITMAP hbitmap, HWND MainWindow);

HBITMAP InvertBitmap (HBITMAP srcBitmap);

HBITMAP GetGraystyleBitmap (HBITMAP srcBitmap);


#endif  // _BMP_H_
