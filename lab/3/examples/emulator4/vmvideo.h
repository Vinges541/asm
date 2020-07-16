/****************************************

Файл vmvideo.h

Заголовочный файл модуля vmvideo.c

Маткин Илья Александрович   12.12.2013

****************************************/

#ifndef _VMVIDEO_H_
#define _VMVIDEO_H_


//----------------------------------------

typedef struct _vmvideo_struct vmvideo_struct;

//----------------------------------------

vmvideo_struct * create_vmvideo (unsigned int width, unsigned int height);

void vmvideo_write_videomem (
    vmvideo_struct *vmvideo,
    unsigned int addr,
    unsigned int count,
    unsigned char *srcBuf);

//----------------------------------------

#endif  // _VMVIDEO_H_
