;
; Файл bmp.h
;
; Заголовочный файл модуля bmp.asm
;
; Маткин Илья Александрович     12.11.2013
;

DrawBitmap proto hdc:HDC, hBitmap:HBITMAP, xStart:DWORD, yStart:DWORD

LoadBmpFile proto parentWindow:HWND, hIns:HINSTANCE

CreateBMPFile proto pszFile:LPTSTR, hBitmap:HBITMAP, MainWindow:HWND

SaveBMPFile proto hBitmap:HBITMAP, MainWindow:HWND

InvertBitmap proto srcBitmap:HBITMAP

GetGraystyleBitmap proto srcBitmap:HBITMAP

GetMoreBrightBitmap proto srcBitmap:HBITMAP

GetLessBrightBitmap proto srcBitmap:HBITMAP

GetBlackAndWhiteBitmap proto srcBitmap:HBITMAP

GetReflectVerticalBitmap proto srcBitmap:HBITMAP

GetReflectHorizontalBitmap proto srcBitmap:HBITMAP

GetTurnedLeftBitmap proto srcBitmap:HBITMAP

GetTurnedRightBitmap proto srcBitmap:HBITMAP

GetGluedBitmap proto fstHBitmap:HBITMAP, hwnd:HWND, hIns:HINSTANCE