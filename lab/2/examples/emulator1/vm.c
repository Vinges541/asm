/****************************************

Модуль vm.c

Виртуальная машина.

Маткин Илья Александрович   28.11.2013

****************************************/

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>

#include "vm.h"



//----------------------------------------

#define _VM_DEBUG

#ifdef _VM_DEBUG
#define VM_DEBUG(command)   command
#else
#define VM_DEBUG(command)
#endif

// инструкции чтения/записи
#define vm_read    _read
#define vm_write   _write

// количество регистров
#define VM_REG_COUNT    32

// размер адресного пространства
#define VM_MEM_SIZE     (4096*1024)

// стартовый адрес загрузки кода
#define VM_CODE_START   4096

//----------------------------------------

// тип значения регистров и операндов
typedef unsigned int vmopvalue_t;

// тип значения файлового дескриптора
typedef int vmfd_t;

// тип значения опкода
typedef unsigned char vmopcode_t;
// значения опкодов
#define     VM_NOP      0
#define     VM_IN       1
#define     VM_OUT      2
#define     VM_MOV      3
#define     VM_ADD      4
#define     VM_SUB      5
#define     VM_XOR      6
#define     VM_AND      7
#define     VM_OR       8
#define     VM_HLT      9
// количество инструкций
#define VM_COUNT_INST   (VM_HLT + 1)

static char *vm_mnem[] = {"nop", "in", "out", "mov", "add", "sub", "xor", "and", "or", "hlt"};

// тип обработчиков инструкций
typedef void (*vm_handler)(vm_struct *vm);

// тип значения типа операнда
typedef unsigned char vm_operand_type;
// значения типов операндов
#define     VM_OPTYPE_NONE          0
#define     VM_OPTYPE_REG_BYTE      1
#define     VM_OPTYPE_REG_WORD      2
#define     VM_OPTYPE_IMMEDIATE     3
#define     VM_OPTYPE_MEMORY_BYTE   4
#define     VM_OPTYPE_MEMORY_WORD   5
#define     VM_OPTYPE_MEMORY_REG_BYTE   6
#define     VM_OPTYPE_MEMORY_REG_WORD   7

// структура для кодирования операнда
#pragma pack(1)
typedef struct _vm_operand{
    vm_operand_type optype;     // тип операнда
    vmopvalue_t  value;         // значение операнда (в зависимости от типа)
} vm_operand;
#pragma pack()

// структура для кодирования инструкции
#pragma pack(1)
typedef struct _vm_instruction{
    vmopcode_t opcode;          // опкод
    vm_operand op1;             // первый операнд
    vm_operand op2;             // второй операнд
} vm_instruction;
#pragma pack()

// возможные состояния виртуальной машины
typedef enum _vm_state{
    VM_STATE_OK = 0,
    VM_STATE_UNKNOW_INSTRUCTION,
    VM_STATE_INVALID_OPERAND,
    VM_STATE_IO_ERROR,
    VM_STATE_GENERAL_ERROR,
    VM_STATE_UNKNOW_ERROR,
    VM_STATE_HALT
} vm_state;

// текстовые сообщения, соответствующие состояниям
static char *vm_state_message[] = {
    "VM_STATE_OK", "VM_STATE_UNKNOW_INSTRUCTION", "VM_STATE_INVALID_OPERAND",
    "VM_STATE_IO_ERROR", "VM_STATE_GENERAL_ERROR", "VM_STATE_UNKNOW_ERROR",
    "VM_STATE_HALT"};

// структура виртуальной машины
typedef struct _vm_struct{

    vm_state state;     // состояние
    vmfd_t fdin;        // дескриптор для чтения
    vmfd_t fdout;       // дескриптор для записи

    vm_instruction *ip; // указатель инструкций
    vmopvalue_t regs[VM_REG_COUNT];     // регистры

    unsigned char memory[VM_MEM_SIZE];  // память

} vm_struct;


#define vm_get_current_instruction(ip, vm)  ((vm_instruction*)((unsigned int)ip + (unsigned int)vm->memory))


//----------------------------------------
// declaration function

static unsigned int vm_get_word(vm_struct *vm);
static unsigned char vm_get_byte(vm_struct *vm);
static void vm_put_word(vm_struct *vm, unsigned int value);
static void vm_put_byte(vm_struct *vm, unsigned char value);
static unsigned int vm_get_opsize(vm_operand_type optype);

static vmopvalue_t vm_get_operand(vm_struct *vm, vm_operand *op);
static void vm_set_operand(vm_struct *vm, vm_operand *op, vmopvalue_t value);

static void vm_nop(vm_struct *vm);
static void vm_in(vm_struct *vm);
static void vm_out(vm_struct *vm);
static void vm_mov(vm_struct *vm);
static void vm_add(vm_struct *vm);
static void vm_sub(vm_struct *vm);
static void vm_xor(vm_struct *vm);
static void vm_and(vm_struct *vm);
static void vm_or(vm_struct *vm);
static void vm_hlt (vm_struct *vm);

static void vm_init (vm_struct *vm);

//----------------------------------------
// global variable

// таблица обработчиков инструкций (опкод инструкции является индексом ее обработчика)
vm_handler vm_handlers[VM_COUNT_INST] = {vm_nop, vm_in, vm_out, vm_mov, vm_add, vm_sub, vm_xor, vm_and, vm_or, vm_hlt};


//----------------------------------------
// definition function

//
// Читает слово из дескриптора
//
static unsigned int vm_get_word (vm_struct *vm) {

unsigned int tmp;

    if (vm_read (vm->fdin, &tmp, 4) == 4) {
        return tmp;
        }
    else {
        vm->state = VM_STATE_IO_ERROR;
        return 0;
        }
}

//--------------------

//
// Читает байт из дескриптора
//
static unsigned char vm_get_byte (vm_struct *vm) {
    
unsigned char tmp;

    if (vm_read (vm->fdin, &tmp, 1) == 1) {
        return tmp;
        }
    else {
        vm->state = VM_STATE_IO_ERROR;
        return 0;
        }
}

//--------------------

//
// Записывает слово в дескриптор
//
static void vm_put_word (vm_struct *vm, unsigned int value) {

    if (vm_write(vm->fdout, &value, 4) != 4 ) {
        vm->state = VM_STATE_IO_ERROR;
        }

    return;
}

//--------------------

//
// Записывает байт в дескриптор
//
static void vm_put_byte (vm_struct *vm, unsigned char value) {

    if (vm_write(vm->fdout, &value, 1) != 1 ) {
        vm->state = VM_STATE_IO_ERROR;
        }

    return;
}

//--------------------
//--------------------

//
// Возращает размер операнда в зависимости от типа
//
static unsigned int vm_get_opsize (vm_operand_type optype) {

    switch(optype){

        case VM_OPTYPE_NONE:
            return 0;

        case VM_OPTYPE_REG_BYTE:
        case VM_OPTYPE_MEMORY_BYTE:
            return 1;

        case VM_OPTYPE_REG_WORD:
        case VM_OPTYPE_IMMEDIATE:
        case VM_OPTYPE_MEMORY_WORD:
            return 4;
        }

    return 0;
} 

//--------------------
//--------------------

//
// Получает значение операнда
//
static vmopvalue_t vm_get_operand (vm_struct *vm, vm_operand *op) {

    switch (op->optype) {

        case VM_OPTYPE_REG_BYTE:
            if (op->value < VM_REG_COUNT) {
                return vm->regs[op->value] & 0x000000FF;
                }
            else {
                vm->state = VM_STATE_INVALID_OPERAND;
                return 0;
                }

        case VM_OPTYPE_REG_WORD:
            if (op->value < VM_REG_COUNT) {
                return vm->regs[op->value];
                }
            else {
                vm->state = VM_STATE_INVALID_OPERAND;
                return 0;
                }

        case VM_OPTYPE_IMMEDIATE:
            return op->value;

        case VM_OPTYPE_MEMORY_BYTE:
            if(op->value < VM_MEM_SIZE) {
                return vm->memory[op->value];
                }
            else{
                vm->state = VM_STATE_GENERAL_ERROR;
                return 0;
                }

        case VM_OPTYPE_MEMORY_WORD:
            if (op->value < VM_MEM_SIZE - 3) {
                return *((vmopvalue_t*)(vm->memory + op->value));
                }
            else {
                vm->state = VM_STATE_GENERAL_ERROR;
                return 0;
                }

        case VM_OPTYPE_MEMORY_REG_BYTE:
            if (op->value < VM_REG_COUNT &&
                vm->regs[op->value] < VM_MEM_SIZE) {
                return vm->memory[vm->regs[op->value]];
                }
            else {
                vm->state = VM_STATE_INVALID_OPERAND;
                return 0;
                }

        case VM_OPTYPE_MEMORY_REG_WORD:
            if (op->value < VM_REG_COUNT &&
                vm->regs[op->value] < VM_MEM_SIZE - 3) {
                return *((vmopvalue_t*)(vm->memory + vm->regs[op->value]));
                }
            else {
                vm->state = VM_STATE_INVALID_OPERAND;
                return 0;
                }

        default:
            vm->state = VM_STATE_INVALID_OPERAND;
            return 0;
        }
}

//--------------------

//
// Устанавливает значение операнда
//
static void vm_set_operand (vm_struct *vm, vm_operand *op, vmopvalue_t value) {

    switch(op->optype){

        case VM_OPTYPE_REG_WORD:
            if (op->value < VM_REG_COUNT) {
                vm->regs[op->value] = value;
                return;
                }
            else{
                vm->state = VM_STATE_INVALID_OPERAND;
                return;
                }

        case VM_OPTYPE_REG_BYTE:
            if (op->value < VM_REG_COUNT) {
                *((unsigned char*)(&vm->regs[op->value])) = (unsigned char)value;
                return;
                }
            else {
                vm->state = VM_STATE_INVALID_OPERAND;
                return;
                }

        case VM_OPTYPE_IMMEDIATE:
            vm->state = VM_STATE_INVALID_OPERAND;
            return;

        case VM_OPTYPE_MEMORY_BYTE:
            if (op->value < VM_MEM_SIZE) {
                vm->memory[op->value] = (unsigned char) value;
                }
            else{
                vm->state = VM_STATE_GENERAL_ERROR;
                return;
                }

        case VM_OPTYPE_MEMORY_WORD:
            if (op->value < VM_MEM_SIZE - 3) {
                *((vmopvalue_t*)(vm->memory + op->value)) = value;
                }
            else {
                vm->state = VM_STATE_GENERAL_ERROR;
                return;
                }

        case VM_OPTYPE_MEMORY_REG_BYTE:
            if (op->value < VM_REG_COUNT &&
                vm->regs[op->value] < VM_MEM_SIZE) {
                vm->memory[vm->regs[op->value]] = (unsigned char) value;
                }
            else {
                vm->state = VM_STATE_INVALID_OPERAND;
                return 0;
                }

        case VM_OPTYPE_MEMORY_REG_WORD:
            if (op->value < VM_REG_COUNT &&
                vm->regs[op->value] < VM_MEM_SIZE - 3) {
                *((vmopvalue_t*)(vm->memory + vm->regs[op->value])) = value;
                }
            else {
                vm->state = VM_STATE_INVALID_OPERAND;
                return;
                }

        default:
            vm->state = VM_STATE_INVALID_OPERAND;
            return;
        }
}

//--------------------
//--------------------

//
// Обработчик инструкции nop
//
static void vm_nop (vm_struct *vm) {

    return;
}

//--------------------

//
// Обработчик инструкции in
//
static void vm_in (vm_struct *vm) {

    unsigned int size;
    vmopvalue_t value;

    vm_instruction *ip = vm_get_current_instruction(vm->ip, vm);

    size = vm_get_opsize (ip->op1.optype);
    if (size == 1) {
        value = vm_get_byte (vm);
        vm_set_operand (vm, &ip->op1, value);
        }
    else if (size == 4) {
        value = vm_get_word(vm);
        vm_set_operand (vm, &ip->op1, value);
        }

    return;
}

//--------------------

//
// Обработчик инструкции out
//
static void vm_out (vm_struct *vm) {

    unsigned int size;
    vmopvalue_t value;

    vm_instruction *ip = vm_get_current_instruction(vm->ip, vm);

    size = vm_get_opsize (ip->op1.optype);
    if (size == 1) {
        value = vm_get_operand (vm, &ip->op1);
        vm_put_byte (vm, value);
        }
    else if (size == 4) {
        value = vm_get_operand (vm, &ip->op1);
        vm_put_word (vm, value);
        }

    return;
}

//--------------------

//
// Обработчик инструкции mov
//
static void vm_mov (vm_struct *vm) {

    vm_instruction *ip = vm_get_current_instruction(vm->ip, vm);

    vmopvalue_t value = vm_get_operand (vm, &ip->op2);

    if (vm->state == VM_STATE_OK) {
        vm_set_operand (vm, &ip->op1, value);
        }

    return;
}

//--------------------

//
// Обработчик инструкции add
//
static void vm_add (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm->ip, vm);

    value1 = vm_get_operand (vm, &ip->op1);
    value2 = vm_get_operand (vm, &ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 += value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return;
}

//--------------------

//
// Обработчик инструкции sub
//
static void vm_sub (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm->ip, vm);

    value1 = vm_get_operand (vm, &ip->op1);
    value2 = vm_get_operand (vm, &ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 -= value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return;
}

//--------------------

//
// Обработчик инструкции xor
//
static void vm_xor (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm->ip, vm);

    value1 = vm_get_operand (vm, &ip->op1);
    value2 = vm_get_operand (vm, &ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 ^= value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return;
}

//--------------------

//
// Обработчик инструкции and
//
static void vm_and (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm->ip, vm);

    value1 = vm_get_operand (vm, &ip->op1);
    value2 = vm_get_operand (vm, &ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 &= value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return;
}

//--------------------

//
// Обработчик инструкции or
//
static void vm_or (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm->ip, vm);

    value1 = vm_get_operand (vm, &ip->op1);
    value2 = vm_get_operand (vm, &ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 |= value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return;
}

//--------------------

//
// Обработчик инструкции hlt
//
static void vm_hlt (vm_struct *vm) {

    vm->state = VM_STATE_HALT;

    return;
}

//--------------------
//--------------------

//
// Дизассемблирует операнд
//
static void vm_disas_operand (vm_operand *op) {

    switch(op->optype){

        case VM_OPTYPE_REG_BYTE:
            printf ("byte ");
        case VM_OPTYPE_REG_WORD:
            printf ("r%d", op->value);
            break;

        case VM_OPTYPE_IMMEDIATE:
            printf ("0x%08x", op->value);
            break;

        case VM_OPTYPE_MEMORY_BYTE:
            printf ("byte ");
        case VM_OPTYPE_MEMORY_WORD:
            printf ("[%08x]", op->value);
            break;

        case VM_OPTYPE_MEMORY_REG_BYTE:
            printf ("byte ");
        case VM_OPTYPE_MEMORY_REG_WORD:
            printf ("[r%d]", op->value);
            break;
        }

    return;
}

//--------------------

//
// Дизассемблирует текущую инструкцию
// 
static void vm_disas_ins (vm_struct *vm) {

    vm_instruction *ip = vm_get_current_instruction(vm->ip, vm);

    if (ip->opcode >= VM_COUNT_INST) {
        printf ("invalid instruction\n");
        return;
        }

    printf ("%s ", vm_mnem[ip->opcode]);

    vm_disas_operand (&ip->op1);
    if (ip->op2.optype != VM_OPTYPE_NONE)
        printf(", ");

    vm_disas_operand (&ip->op2);

    return;
}

//--------------------

//
// Распечатывает текущее состояние виртуальной машины
//
static void vm_state_print(vm_struct *vm){

unsigned int i,j;

    printf ("\n");
    for (i = 0; i < VM_REG_COUNT / 4; ++i) {
        for (j = 0; j < 4; ++j) {
            printf ("r%d %08x\t", 4*i+j, vm->regs[4*i+j]);
            }
        printf("\n");
        }

    printf ("%08p: ", (unsigned int)vm->ip);
    vm_disas_ins (vm);
    printf ("\n");

    return;
}

//--------------------
//--------------------

//
// Исполняет текущую инструкцию
//
BOOL vm_run_current_instruction (vm_struct *vm) {

    vm_instruction *ip = vm_get_current_instruction (vm->ip, vm);

    if ((unsigned int) ip >= (unsigned int) vm->memory + VM_MEM_SIZE || 
        (unsigned int) ip < (unsigned int) vm->memory) {
        vm->state = VM_STATE_GENERAL_ERROR;
        return FALSE;
        }

    if (ip->opcode >= VM_COUNT_INST) {
        vm->state = VM_STATE_UNKNOW_INSTRUCTION;
        return FALSE;
        }

    vm_handlers[ip->opcode](vm);
    if(vm->state != VM_STATE_OK){
        return FALSE;
        }

    vm->ip++;

    return TRUE;
}

//--------------------

//
// Исполняет код, загруженный в виртуальную машину
//
void vm_run (vm_struct *vm) {

    while (vm->state != VM_STATE_HALT &&
           vm_run_current_instruction (vm));

    return;
}

//--------------------

//
// Инициализирует виртуальную машину
//
static void vm_init (vm_struct *vm) {

    vm->fdin = _fileno (stdin);
    vm->fdout = _fileno (stdout);
    vm->ip = (vm_instruction*) (VM_CODE_START);
    vm->state = VM_STATE_OK;

    memset (vm->memory, 0, VM_MEM_SIZE);
    memset (vm->regs, 0, VM_REG_COUNT * sizeof(vmopvalue_t));

    return;
}

//--------------------

//
// Создаёт "пустую" виртуальную машину
//
vm_struct * create_vm (void) {

    vm_struct *vm = (vm_struct*) malloc (sizeof(vm_struct));
    if (!vm) {
        return NULL;
        }

    vm_init (vm);

    return vm;
}

//--------------------

//
// Удаляет виртуальную машину
//
void destroy_vm (vm_struct *vm) {

    free (vm);

    return;
}

//--------------------

//
// Загружает код в виртуальную машину
//
BOOL vm_load_code (vm_struct *vm, unsigned char *code, unsigned int code_size) {

    if (code_size < VM_MEM_SIZE - VM_CODE_START) {
        memcpy (vm->memory + VM_CODE_START, code, code_size);
        return TRUE;
        }

    return FALSE;
}

//--------------------

//
// Общается с пользователем при трассировке
//
BOOL vm_interactive (vm_struct *vm) {

    char command[100];

    while (TRUE) {

        printf ("# ");
        command[vm_read (vm->fdin, command, 100)] = 0;

        if (command[0] == 'q') {
            return FALSE;
            }

        if (command[0] == 'r') {
            unsigned int number;
            sscanf (command + 1, "%d", &number);
            if (number < VM_REG_COUNT) {
                printf ("\n> %08x\n", vm->regs[number]);
                }
            else {
                printf ("> invalid reg number\n");
                }
            continue;
            }
        break;
        }

    return TRUE;
}

//--------------------

//
// Трассирует код, загруженный в виртуальную машину
//
void vm_trace (vm_struct *vm) {

    while (1) {

        vm_state_print (vm);

        if (!vm_interactive (vm)) {
            break;
            }

        if (!vm_run_current_instruction (vm)) {
            vm_print_error (vm);
            break;
            }
        }

    return;
}

//--------------------

//
// Распечатывает сообщение о состоянии виртуальной машины
//
void vm_print_error (vm_struct *vm) {

    if (vm->state != VM_STATE_OK) {
        printf ("%s\n", vm_state_message[vm->state]);
        }

    return;
}

//--------------------
//--------------------
