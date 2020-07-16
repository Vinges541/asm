/****************************************

Файл vm.h

Заголовочный файл модуля vm.c

Маткин Илья Александрович   28.11.2013

****************************************/

#ifndef _VM_H_
#define _VM_H_

#include <stdio.h>
#include <string.h>

//----------------------------------------

#define VM_INSTRUCTION_SIZE 11

typedef struct _vm_struct vm_struct;

typedef int BOOL;
#ifndef TRUE
#define TRUE    1
#endif
#ifndef FALSE
#define FALSE   0
#endif

//----------------------------------------

extern BOOL vm_run_current_instruction (vm_struct *vm);

extern void vm_run (vm_struct *vm);

extern vm_struct * create_vm (void);

void destroy_vm (vm_struct *vm);

BOOL vm_load_code (vm_struct *vm, unsigned char *code, unsigned int code_size);

void vm_trace (vm_struct *vm);

void vm_print_error (vm_struct *vm);

//----------------------------------------

#endif  // _VM_H_

