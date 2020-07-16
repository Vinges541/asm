#include <stdio.h>

int buf[10];

int main (unsigned int argc, char *argv[], char *envp[]) {

    int a = 0x11223344;

    buf[0] = 1;
    buf[5] = 7;

    printf ("Hello, World\n");
    
    if (argv[1])
        printf (argv[1]);

    fun (1, 2, 3, 4, 5);

    return 0;
}


void fun (int arg1, int arg2, int arg3, int arg4, int arg5) {

    return;
}

