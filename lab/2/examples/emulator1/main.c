/*

Модуль main.c

Маткин Илья Александрович   28.11.2013

*/

#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>

#include "vm.h"

//----------------------------------------

//----------------------------------------

//
// Трассирует код, загружаемый из файла
//
void TraceCodeFromFile (char *fileName) {

    unsigned char *buf;
    vm_struct *vm;
    int fd = _open (fileName, _O_RDONLY | _O_BINARY);
    int fileSize = _lseek (fd, 0, SEEK_END);
    _lseek (fd, 0, SEEK_SET);

    buf = (unsigned char*) malloc (fileSize);
    if (!buf) {
        return;
        }

    if (_read (fd, buf, fileSize) != fileSize) {
        printf ("error read file\n");
        return;
        }

    vm = create_vm();
    vm_load_code (vm, buf, fileSize);

    free (buf);

    vm_trace (vm);
    //vm_run (vm);

    destroy_vm (vm);

    return;
}

//--------------------

int main (unsigned int argc, char *argv[], char *envp[]) {

    if (argv[1]) {
        TraceCodeFromFile (argv[1]);
        }

    return 0;
}
