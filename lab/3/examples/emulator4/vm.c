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
#include "vmvideo.h"

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

//----------------------------------------

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
#define     VM_BREAK    10
#define     VM_PUSH     11
#define     VM_POP      12
#define     VM_CALL     13
#define     VM_LAST_INS 13
// количество инструкций
#define VM_COUNT_INST   (VM_LAST_INS + 1)

static char *vm_mnem[] = {"nop", "in", "out", "mov", "add", "sub", "xor", "and", "or", "hlt", "brk", "push", "pop", "call"};

// тип обработчиков инструкций
typedef vm_ins_result (*vm_handler)(vm_struct *vm);

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

    //vm_instruction *ip; // указатель инструкций
    vmopvalue_t regs[VM_REG_COUNT];     // регистры

    vmvideo_struct *vmvideo;

    unsigned char memory[VM_MEM_SIZE];  // память

} vm_struct;


//----------------------------------------
// объявление функций

static unsigned int vm_get_word(vm_struct *vm);
static unsigned char vm_get_byte(vm_struct *vm);
static void vm_put_word(vm_struct *vm, unsigned int value);
static void vm_put_byte(vm_struct *vm, unsigned char value);

static unsigned int vm_get_opsize(vm_operand_type optype);

static vm_ins_result vm_get_operand(vm_struct *vm, vm_operand *op, vmopvalue_t *value);
static vm_ins_result vm_set_operand(vm_struct *vm, vm_operand *op, vmopvalue_t value);

static vm_ins_result vm_nop(vm_struct *vm);
static vm_ins_result vm_in(vm_struct *vm);
static vm_ins_result vm_out(vm_struct *vm);
static vm_ins_result vm_mov(vm_struct *vm);
static vm_ins_result vm_add(vm_struct *vm);
static vm_ins_result vm_sub(vm_struct *vm);
static vm_ins_result vm_xor(vm_struct *vm);
static vm_ins_result vm_and(vm_struct *vm);
static vm_ins_result vm_or(vm_struct *vm);
static vm_ins_result vm_hlt (vm_struct *vm);
static vm_ins_result vm_break (vm_struct *vm);
static vm_ins_result vm_push (vm_struct *vm);
static vm_ins_result vm_pop (vm_struct *vm);
static vm_ins_result vm_call (vm_struct *vm);

static void vm_init (vm_struct *vm);

static void vm_disas_current_ins (vm_struct *vm);

//----------------------------------------
// глобальные переменные

// таблица обработчиков инструкций (опкод инструкции является индексом ее обработчика)
vm_handler vm_handlers[VM_COUNT_INST] = {vm_nop, vm_in, vm_out, vm_mov, vm_add, vm_sub, vm_xor, vm_and, vm_or, vm_hlt, vm_break, vm_push, vm_pop, vm_call};


//----------------------------------------
// описание функций


vm_instruction * vm_get_current_instruction (vm_struct *vm) {
    
    return ((vm_instruction*)((unsigned int)vm->regs[VM_REG_IP] + (unsigned int)vm->memory));
}

//--------------------


vmopvalue_t vm_get_ip (vm_struct *vm) {
    
    return vm->regs[VM_REG_IP];
}

//--------------------

vm_ins_result vm_set_ip (vm_struct *vm, vmopvalue_t value) {

    if ((unsigned int) value < ((unsigned int) VM_MEM_SIZE - 10)) {
        (unsigned int) vm->regs[VM_REG_IP] = value;
        return VM_RESULT_OK;
        }
    else {
        vm->state = VM_STATE_GENERAL_ERROR;
        return VM_RESULT_GENERAL_ERROR;
        }
}

//--------------------

//
// Читает слово из дескриптора
//
static unsigned int vm_get_word (vm_struct *vm) {

unsigned int tmp;

    if (vm_read (vm->fdin, &tmp, 4) == 4) {
        return tmp;
        }
    else {
        //vm->state = VM_RESULT_IO_ERROR;
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
        //vm->state = VM_STATE_IO_ERROR;
        return 0;
        }
}

//--------------------

//
// Записывает слово в дескриптор
//
static void vm_put_word (vm_struct *vm, unsigned int value) {

    if (vm_write(vm->fdout, &value, 4) != 4 ) {
        //vm->state = VM_RESULT_IO_ERROR;
        }

    return;
}

//--------------------

//
// Записывает байт в дескриптор
//
static void vm_put_byte (vm_struct *vm, unsigned char value) {

    if (vm_write(vm->fdout, &value, 1) != 1 ) {
        //vm->state = VM_RESULT_IO_ERROR;
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
        case VM_OPTYPE_MEMORY_REG_BYTE:
            return 1;

        case VM_OPTYPE_REG_WORD:
        case VM_OPTYPE_IMMEDIATE:
        case VM_OPTYPE_MEMORY_WORD:
        case VM_OPTYPE_MEMORY_REG_WORD:
            return 4;
        }

    return 0;
} 

//--------------------
//--------------------

//
// Получает значение из памяти по адресу
//
BOOL vm_get_memory (
    vm_struct *vm,
    unsigned int addr,
    unsigned int count,
    vmopvalue_t *value) {

    if(addr < VM_MEM_SIZE) {
        memcpy (value, vm->memory + addr, count);
        return TRUE;
        }

    return FALSE;
}

//--------------------

//
// Получает значение из памяти по адресу в регистре
//
BOOL vm_get_memory_by_reg (
    vm_struct *vm,
    unsigned int reg,
    unsigned int count,
    vmopvalue_t *value) {

    if (reg < VM_REG_COUNT) {
        return vm_get_memory (vm, vm->regs[reg], count, value);
        }

    return FALSE;
}

//--------------------

//
// Получает байты регистра по индексу
//
BOOL vm_get_reg_byte (
    vm_struct *vm,
    unsigned int reg,
    unsigned int count,
    vmopvalue_t *value) {


    if (reg < VM_REG_COUNT) {
        memcpy (value, &vm->regs[reg], count);
        return TRUE;
        }

    return FALSE;
}

//--------------------

//
// Записывает значение в память по адресу
//
BOOL vm_put_memory (
    vm_struct *vm,
    unsigned int addr,
    unsigned int count,
    vmopvalue_t *value) {

    if (VM_VIDEOMEM_START <= addr && addr <= VM_VIDEOMEM_START + VM_VIDEOMEM_SIZE) {
        vmvideo_write_videomem (vm->vmvideo, addr - VM_VIDEOMEM_START, count, (unsigned char*)value);
        }

    if (addr < VM_MEM_SIZE) {
        memcpy (vm->memory + addr, value, count);
        return TRUE;
        }

    return FALSE;
}

//--------------------

//
// Записывает значение в память по адресу в регистре
//
BOOL vm_put_memory_by_reg (
    vm_struct *vm,
    unsigned int reg,
    unsigned int count,
    vmopvalue_t *value) {

    if (reg < VM_REG_COUNT) {
        return vm_put_memory (vm, vm->regs[reg], count, value);
        }

    return FALSE;
}

//--------------------

//
// Записывает байты регистра по индексу
//
BOOL vm_put_reg_bytes (
    vm_struct *vm,
    unsigned int reg,
    unsigned int count,
    vmopvalue_t *value) {


    if (reg < VM_REG_COUNT) {
        memcpy (&vm->regs[reg], value, count);
        return TRUE;
        }

    return FALSE;
}

//--------------------

//
// Получает значение операнда
//
static vm_ins_result vm_get_operand (vm_struct *vm, vm_operand *op, vmopvalue_t *value) {

    unsigned int count;
    BOOL res = FALSE;

    *value = 0;
    count = vm_get_opsize (op->optype);

    switch (op->optype) {

        case VM_OPTYPE_REG_BYTE:
        case VM_OPTYPE_REG_WORD:
            res = vm_get_reg_byte (vm, op->value, count, value);
            break;

        case VM_OPTYPE_IMMEDIATE:
            *value = op->value;
            return VM_RESULT_OK;

        case VM_OPTYPE_MEMORY_BYTE:
        case VM_OPTYPE_MEMORY_WORD:
            res = vm_get_memory (vm, op->value, count, value);
            break;
            
        case VM_OPTYPE_MEMORY_REG_BYTE:
        case VM_OPTYPE_MEMORY_REG_WORD:
            res = vm_get_memory_by_reg (vm, op->value, count, value);
            break;

        default:
            break;
        }

    if (!res) {
        return VM_RESULT_INVALID_OPERAND;
        }
    else {
        return VM_RESULT_OK;
        }
}


//--------------------

//
// Устанавливает значение операнда
//
static vm_ins_result vm_set_operand (vm_struct *vm, vm_operand *op, vmopvalue_t value) {

    unsigned int count;
    BOOL res = FALSE;

    count = vm_get_opsize (op->optype);

    switch(op->optype){

        case VM_OPTYPE_REG_BYTE:
        case VM_OPTYPE_REG_WORD:
            res = vm_put_reg_bytes (vm, op->value, count, &value);
            break;

        case VM_OPTYPE_MEMORY_BYTE:
        case VM_OPTYPE_MEMORY_WORD:
            res = vm_put_memory (vm, op->value, count, &value);
            break;
            
        case VM_OPTYPE_MEMORY_REG_BYTE:
        case VM_OPTYPE_MEMORY_REG_WORD:
            res = vm_put_memory_by_reg (vm, op->value, count, &value);
            break;

        default:
            break;
        }

    if (!res) {
        return VM_RESULT_INVALID_OPERAND;
        }
    else {
        return VM_RESULT_OK;
        }
}

//--------------------
//--------------------

//
// Обработчик инструкции nop
//
static vm_ins_result vm_nop (vm_struct *vm) {

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции in
//
static vm_ins_result vm_in (vm_struct *vm) {

    unsigned int size;
    vmopvalue_t value;

    vm_instruction *ip = vm_get_current_instruction(vm);

    size = vm_get_opsize (ip->op1.optype);
    if (size == 1) {
        value = vm_get_byte (vm);
        vm_set_operand (vm, &ip->op1, value);
        }
    else if (size == 4) {
        value = vm_get_word(vm);
        vm_set_operand (vm, &ip->op1, value);
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции out
//
static vm_ins_result vm_out (vm_struct *vm) {

    unsigned int size;
    vmopvalue_t value;

    vm_instruction *ip = vm_get_current_instruction(vm);

    size = vm_get_opsize (ip->op1.optype);
    if (size == 1) {
        vm_get_operand (vm, &ip->op1, &value);
        vm_put_byte (vm, value);
        }
    else if (size == 4) {
        vm_get_operand (vm, &ip->op1, &value);
        vm_put_word (vm, value);
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции mov
//
static vm_ins_result vm_mov (vm_struct *vm) {

    vm_instruction *ip = vm_get_current_instruction(vm);

    vmopvalue_t value;
    if (vm_get_operand (vm, &ip->op2, &value) == VM_RESULT_OK) {

        vm_set_operand (vm, &ip->op1, value);
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции add
//
static vm_ins_result vm_add (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm);

    if (vm_get_operand (vm, &ip->op1, &value1) == VM_RESULT_OK &&
        vm_get_operand (vm, &ip->op2, &value2) == VM_RESULT_OK) {

        value1 += value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции sub
//
static vm_ins_result vm_sub (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm);

    if (vm_get_operand (vm, &ip->op1, &value1) == VM_RESULT_OK &&
        vm_get_operand (vm, &ip->op2, &value2) == VM_RESULT_OK) {

        value1 -= value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции xor
//
static vm_ins_result vm_xor (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm);

    if (vm_get_operand (vm, &ip->op1, &value1) == VM_RESULT_OK &&
        vm_get_operand (vm, &ip->op2, &value2) == VM_RESULT_OK) {
        
        value1 ^= value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции and
//
static vm_ins_result vm_and (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm);

    if (vm_get_operand (vm, &ip->op1, &value1) == VM_RESULT_OK &&
        vm_get_operand (vm, &ip->op2, &value2) == VM_RESULT_OK) {

        value1 &= value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции or
//
static vm_ins_result vm_or (vm_struct *vm) {

    vmopvalue_t value1;
    vmopvalue_t value2;

    vm_instruction *ip = vm_get_current_instruction(vm);

    if (vm_get_operand (vm, &ip->op1, &value1) == VM_RESULT_OK &&
        vm_get_operand (vm, &ip->op2, &value2) == VM_RESULT_OK) {

        value1 |= value2;

        vm_set_operand (vm, &ip->op1, value1);
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции hlt
//
static vm_ins_result vm_hlt (vm_struct *vm) {

    vm->state = VM_STATE_HALT;

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции break
//
static vm_ins_result vm_break (vm_struct *vm) {

    return VM_RESULT_BREAK;
}

//--------------------

//
// Обработчик инструкции push
//
static vm_ins_result vm_push (vm_struct *vm) {

    vmopvalue_t value = 0;

    vm_instruction *ip = vm_get_current_instruction(vm);

    if (vm_get_operand (vm, &ip->op1, &value) == VM_RESULT_OK) {
        if (vm_put_memory (vm, vm->regs[VM_REG_SP] - 4, 4, &value)) {
            vm->regs[VM_REG_SP] -= 4;
            }
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции pop
//
static vm_ins_result vm_pop (vm_struct *vm) {

    vmopvalue_t value = 0;

    vm_instruction *ip = vm_get_current_instruction(vm);

    if (vm_get_memory (vm, vm->regs[VM_REG_SP], 4, &value)) {
        vm_set_operand (vm, &ip->op1, value);
        vm->regs[VM_REG_SP] += 4;
        }

    return VM_RESULT_OK;
}

//--------------------

//
// Обработчик инструкции call
//
static vm_ins_result vm_call (vm_struct *vm) {

    vmopvalue_t value = 0;
    vmopvalue_t oldIp = 0;
    vm_ins_result res;

    vm_instruction *curInst = vm_get_current_instruction (vm);

    res = vm_get_operand (vm, &curInst->op1, &value);

    if (res == VM_RESULT_OK) {

        oldIp = vm_get_ip (vm) + VM_INSTRUCTION_SIZE;
        if (vm_put_memory (vm, vm->regs[VM_REG_SP] - 4, 4, &oldIp)) {
            vm->regs[VM_REG_SP] -= 4;
            res = vm_set_ip (vm, value);
            if (res == VM_RESULT_OK) {
                res = VM_RESULT_CHANGE_IP;
                }
            }
        else {
            vm->state = VM_STATE_GENERAL_ERROR;
            res = VM_RESULT_GENERAL_ERROR;
            }
        }

    return res;
}


//--------------------
//--------------------

//
// Дизассемблирует операнд
//
static unsigned int vm_disas_operand (vm_operand *op, char *buf) {

unsigned int offset = 0;

    switch(op->optype){

        case VM_OPTYPE_REG_BYTE:
            offset += sprintf (buf, "byte ");
        case VM_OPTYPE_REG_WORD:
            offset += sprintf (buf + offset, "r%d", op->value);
            break;

        case VM_OPTYPE_IMMEDIATE:
            offset += sprintf (buf, "0x%08x", op->value);
            break;

        case VM_OPTYPE_MEMORY_BYTE:
            offset += sprintf (buf, "byte ");
        case VM_OPTYPE_MEMORY_WORD:
            offset += sprintf (buf + offset, "[%08x]", op->value);
            break;

        case VM_OPTYPE_MEMORY_REG_BYTE:
            offset += sprintf (buf, "byte ");
        case VM_OPTYPE_MEMORY_REG_WORD:
            offset += sprintf (buf + offset, "[r%d]", op->value);
            break;
        }

    return offset;
}

//--------------------

//
// Дизассемблирует текущую инструкцию
// 
static void vm_disas_current_ins (vm_struct *vm) {

char buf[100];

    vm_instruction *ip = vm_get_current_instruction(vm);

    vm_get_disas_ins (vm, ip, buf);
    printf ("%s", buf);

    return;
}

//--------------------

//
// Выдает дизассемблируемую инструкцию в буфер
// 
unsigned int vm_get_disas_ins (vm_struct *vm, vm_instruction *ins, char *buf) {

unsigned int offset = 0;
unsigned int i;

    if (ins->opcode >= VM_COUNT_INST) {
        return sprintf (buf, "invalid instruction\n");
        }

    offset += sprintf (buf + offset, "%08x:  ", (unsigned int)ins - (unsigned int)vm->memory);
    for (i = 0; i < VM_INSTRUCTION_SIZE; ++i) {
        offset += sprintf (buf + offset, "%02x  ", *((unsigned char*)ins + i));
        }
    offset += sprintf (buf + offset, "%s ", vm_mnem[ins->opcode]);

    offset += vm_disas_operand (&ins->op1, buf + offset);
    if (ins->op2.optype != VM_OPTYPE_NONE)
        offset += sprintf (buf + offset, ", ");

    offset += vm_disas_operand (&ins->op2, buf + offset);

    return offset;
}

//--------------------

//
// Распечатывает текущее состояние виртуальной машины
//
static void vm_print_context (vm_struct *vm) {

unsigned int i,j;

    vm_instruction *ip = vm_get_current_instruction(vm);

    printf ("\n");
    for (i = 0; i < VM_REG_COUNT / 4; ++i) {
        for (j = 0; j < 4; ++j) {
            printf ("r%d %08x\t", 4*i+j, vm->regs[4*i+j]);
            }
        printf ("\n");
        }

    printf ("%08p: ", (unsigned int)ip);
    vm_disas_current_ins (vm);
    printf ("\n");

    return;
}

//--------------------
//--------------------

//
// Исполняет текущую инструкцию
//
vm_ins_result vm_run_current_instruction (vm_struct *vm) {

    vm_ins_result res;
    vm_instruction *ip = vm_get_current_instruction (vm);

    if (vm->state != VM_STATE_OK) {
        return VM_RESULT_UNKNOW_ERROR;
        }

    if ((unsigned int) ip >= (unsigned int) vm->memory + VM_MEM_SIZE || 
        (unsigned int) ip < (unsigned int) vm->memory) {
        vm->state = VM_STATE_GENERAL_ERROR;
        return VM_RESULT_GENERAL_ERROR;
        }

    if (ip->opcode >= VM_COUNT_INST) {
        return VM_RESULT_UNKNOW_INSTRUCTION;
        }

    res = vm_handlers[ip->opcode](vm);
    if (res != VM_RESULT_OK &&
        res != VM_RESULT_BREAK &&
        res != VM_RESULT_CHANGE_IP) {
        return FALSE;
        }

    if (res != VM_RESULT_CHANGE_IP) {
        vm_set_ip (vm, vm_get_ip (vm) + VM_INSTRUCTION_SIZE);
        }
    else {
        res = VM_RESULT_OK;
        }

    return res;
}

//--------------------

//
// Исполняет код, загруженный в виртуальную машину
//
vm_state vm_run (vm_struct *vm) {

    vm_state state;

    while (vm->state == VM_STATE_OK &&
           vm_run_current_instruction (vm) == VM_RESULT_OK);

    state = vm->state;

    return state;
}

//--------------------

//
// Инициализирует виртуальную машину
//
static void vm_init (vm_struct *vm) {

    memset (vm->memory, 0, VM_MEM_SIZE);
    memset (vm->regs, 0, VM_REG_COUNT * sizeof(vmopvalue_t));

    vm->fdin = _fileno (stdin);
    vm->fdout = _fileno (stdout);
    vm->regs[VM_REG_IP] = VM_CODE_START;
    vm->regs[VM_REG_SP] = VM_STACK_START;
    vm->state = VM_STATE_OK;

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

    vm->vmvideo = create_vmvideo (VM_VIDEOMEM_WIDTH, VM_VIDEOMEM_HEIGHT);
    if (!vm->vmvideo) {
        free (vm);
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
        vm_init (vm);
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

        vm_print_context (vm);

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

//
// Возвращает значение регистра по его номеру.
//
vmopvalue_t vm_get_reg_full (vm_struct *vm, unsigned int reg_number) {

    vmopvalue_t value = 0;

    if (reg_number < VM_REG_COUNT) {
        value = vm->regs[reg_number];
        }

    return value;
}

//--------------------

//--------------------

//--------------------

//--------------------

