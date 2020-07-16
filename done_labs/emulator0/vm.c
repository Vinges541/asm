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


#define vm_read    _read
#define vm_write   _write


#define VM_REG_COUNT    32
#define VM_MEM_SIZE     (4096*1024)
#define VM_STACK_SIZE   (4096*64)

#define VM_CODE_START   4096

//----------------------------------------


typedef unsigned int vmopvalue_t;
typedef unsigned char vmopcode_t;

typedef int vmfd_t;

typedef unsigned char vm_opcodes;
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
#define     VM_POP      10
#define     VM_PUSH     11
#define VM_COUNT_HAND   (VM_PUSH + 1)

typedef void (*vm_handler)(vm_struct *vm);


typedef unsigned char vm_operand_type;

#define     VM_OPTYPE_NONE          0
#define     VM_OPTYPE_REG_BYTE      1
#define     VM_OPTYPE_REG_WORD      2
#define     VM_OPTYPE_IMMEDIATE     3
#define		VM_OPTYPE_IMMEDIATE_ADDRESS 4
#define		VM_OPTYPE_REG_ADDRESS 5


#pragma pack(1)
typedef struct _vm_operand{
    vm_operand_type optype;
    vmopvalue_t  value;
} vm_operand;
#pragma pack()


#pragma pack(1)
typedef struct _vm_instruction{
    vmopcode_t opcode;
    vm_operand op1;
    vm_operand op2;
} vm_instruction;
#pragma pack()


typedef enum _vm_state{
    VM_STATE_OK = 0,
    VM_STATE_UNKNOW_INSTRUCTION,
    VM_STATE_INVALID_OPERAND,
    VM_STATE_IO_ERROR,
    VM_STATE_GENERAL_ERROR,
    VM_STATE_UNKNOW_ERROR,
    VM_STATE_HALT,
	VM_STATE_STACK_UNDERFLOW,
	VM_STATE_STACK_OVERFLOW
} vm_state;

static char *vm_state_message[] = {
    "VM_STATE_OK", "VM_STATE_UNKNOWN_INSTRUCTION", "VM_STATE_INVALID_OPERAND",
    "VM_STATE_IO_ERROR", "VM_STATE_GENERAL_ERROR", "VM_STATE_UNKNOWN_ERROR",
    "VM_STATE_HALT", "VM_STATE_STACK_UNDERFLOW",
	"VM_STATE_STACK_OVERFLOW" };


typedef struct _vm_struct{

    vm_state state;
    vmfd_t fdin;
    vmfd_t fdout;

    vm_instruction *ip;
    vmopvalue_t regs[VM_REG_COUNT];
    unsigned char memory[VM_MEM_SIZE];

} vm_struct;

#define ESP vm->regs[31]

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
static void vm_hlt(vm_struct *vm);
static void vm_push(vm_struct *vm);
static void vm_pop(vm_struct *vm);
static void vm_init (vm_struct *vm);

//----------------------------------------
// global variable

vm_handler vm_handlers[VM_COUNT_HAND] = {vm_nop, vm_in, vm_out, vm_mov, vm_add, vm_sub, vm_xor, vm_and, vm_or, vm_hlt, vm_push, vm_pop};


//----------------------------------------
// definition function



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


static void vm_put_word (vm_struct *vm, unsigned int value) {

    if (vm_write(vm->fdout, &value, 4) != 4 ) {
        vm->state = VM_STATE_IO_ERROR;
        }

    return;
}

//--------------------


static void vm_put_byte (vm_struct *vm, unsigned char value) {

    if (vm_write(vm->fdout, &value, 1) != 1 ) {
        vm->state = VM_STATE_IO_ERROR;
        }

    return;
}

//--------------------
//--------------------


static unsigned int vm_get_opsize (vm_operand_type optype) {

    switch(optype){

        case VM_OPTYPE_NONE:
            return 0;

        case VM_OPTYPE_REG_BYTE:
            return sizeof(unsigned char);

        case VM_OPTYPE_REG_WORD:
        case VM_OPTYPE_IMMEDIATE:
		case VM_OPTYPE_IMMEDIATE_ADDRESS:
		case VM_OPTYPE_REG_ADDRESS:
            return sizeof(vmopvalue_t);
        }

    return 0;
} 

//--------------------
//--------------------


static vmopvalue_t vm_get_operand (vm_struct *vm, vm_operand *op) {

    switch (op->optype) {

        case VM_OPTYPE_REG_BYTE:
            if(op->value < VM_REG_COUNT) {
                return vm->regs[op->value] & 0x000000FF;
                }
            else{
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

		case VM_OPTYPE_IMMEDIATE_ADDRESS:
			if (op->value <= VM_MEM_SIZE - sizeof(vmopvalue_t)) {
				return *((vmopvalue_t*)(&vm->memory[op->value]));
			}
			else {
				vm->state = VM_STATE_INVALID_OPERAND;
				return 0;
			}

		case VM_OPTYPE_REG_ADDRESS:
			if (op->value < VM_REG_COUNT) {
				vmopvalue_t  ptr_reg = vm->regs[op->value];
				if(ptr_reg <= VM_MEM_SIZE - sizeof(vmopvalue_t))
					return *((vmopvalue_t*)(&vm->memory[ptr_reg]));
				else {
					vm->state = VM_STATE_INVALID_OPERAND;
					return 0;
				}
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


static void vm_set_operand(vm_struct *vm, vm_operand *op, vmopvalue_t value){

    switch(op->optype){

        case VM_OPTYPE_REG_WORD:
            if(op->value < VM_REG_COUNT){
                vm->regs[op->value] = value;
                return;
                }
            else{
                vm->state = VM_STATE_INVALID_OPERAND;
                return;
                }

        case VM_OPTYPE_REG_BYTE:
            if(op->value < VM_REG_COUNT){
                *((unsigned char*)(&vm->regs[op->value])) = (unsigned char)value;
                return;
                }
            else{
                vm->state = VM_STATE_INVALID_OPERAND;
                return;
                }

        case VM_OPTYPE_IMMEDIATE:
            vm->state = VM_STATE_INVALID_OPERAND;
            return;

		case VM_OPTYPE_IMMEDIATE_ADDRESS:
			if (op->value <= VM_MEM_SIZE - sizeof(vmopvalue_t)) {
				*((vmopvalue_t*)(&vm->memory[op->value])) = value;
				return;
			}
			else {
				vm->state = VM_STATE_INVALID_OPERAND;
				return;
			}

		case VM_OPTYPE_REG_ADDRESS:
			if (op->value < VM_REG_COUNT) {
				vmopvalue_t ptr_reg = vm->regs[op->value];
				if (ptr_reg <= VM_MEM_SIZE - sizeof(vmopvalue_t)) {
					*((vmopvalue_t*)(&vm->memory[ptr_reg])) = value;
					return;
				}
				else {
					vm->state = VM_STATE_INVALID_OPERAND;
					return;
				}
			}
			else {
				vm->state = VM_STATE_INVALID_OPERAND;
				return ;
			}

        default:
            vm->state = VM_STATE_INVALID_OPERAND;
            return;
        }
}

//--------------------
//--------------------


static void vm_nop(vm_struct *vm){

    return;
}


//--------------------


static void vm_in(vm_struct *vm){

unsigned int size;
vmopvalue_t value;

    size = vm_get_opsize(vm->ip->op1.optype);
    if(size == 1){
        value = vm_get_byte(vm);
        vm_set_operand(vm, &vm->ip->op1, value);
        }
    else if(size == 4){
        value = vm_get_word(vm);
        vm_set_operand(vm, &vm->ip->op1, value);
        }

    return;
}

//--------------------


static void vm_out(vm_struct *vm){

unsigned int size;
vmopvalue_t value;

    size = vm_get_opsize(vm->ip->op1.optype);
    if(size == 1){
        value = vm_get_operand(vm, &vm->ip->op1);
        vm_put_byte(vm, value);
        }
    else if(size == 4){
        value = vm_get_operand(vm, &vm->ip->op1);
        vm_put_word(vm, value);
        }

    return;
}

//--------------------


static void vm_mov(vm_struct *vm){

    vmopvalue_t value = vm_get_operand(vm, &vm->ip->op2);

    if (vm->state == VM_STATE_OK) {
        vm_set_operand(vm, &vm->ip->op1, value);
        }

    return;
}

//--------------------


static void vm_add(vm_struct *vm){

vmopvalue_t value1;
vmopvalue_t value2;

    value1 = vm_get_operand(vm, &vm->ip->op1);
    value2 = vm_get_operand(vm, &vm->ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 += value2;

        vm_set_operand(vm, &vm->ip->op1, value1);
        }

    return;
}

//--------------------


static void vm_sub(vm_struct *vm){

vmopvalue_t value1;
vmopvalue_t value2;

    value1 = vm_get_operand(vm, &vm->ip->op1);
    value2 = vm_get_operand(vm, &vm->ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 -= value2;

        vm_set_operand(vm, &vm->ip->op1, value1);
        }

    return;
}

//--------------------


static void vm_xor(vm_struct *vm){

vmopvalue_t value1;
vmopvalue_t value2;

    value1 = vm_get_operand(vm, &vm->ip->op1);
    value2 = vm_get_operand(vm, &vm->ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 ^= value2;

        vm_set_operand(vm, &vm->ip->op1, value1);
        }

    return;
}

//--------------------


static void vm_and(vm_struct *vm){

vmopvalue_t value1;
vmopvalue_t value2;

    value1 = vm_get_operand(vm, &vm->ip->op1);
    value2 = vm_get_operand(vm, &vm->ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 &= value2;

        vm_set_operand(vm, &vm->ip->op1, value1);
        }

    return;
}

//--------------------


static void vm_or(vm_struct *vm){

vmopvalue_t value1;
vmopvalue_t value2;

    value1 = vm_get_operand(vm, &vm->ip->op1);
    value2 = vm_get_operand(vm, &vm->ip->op2);

    if (vm->state == VM_STATE_OK) {
        value1 |= value2;

        vm_set_operand(vm, &vm->ip->op1, value1);
        }

    return;
}

//--------------------


static void vm_hlt(vm_struct *vm){

if (vm->state == VM_STATE_OK)
    vm->state = VM_STATE_HALT;
    return;
}

//--------------------


static void vm_push(vm_struct *vm){

	vmopvalue_t value = vm_get_operand(vm, &vm->ip->op1);
	if (vm->state == VM_STATE_OK) {
		if (ESP < VM_STACK_SIZE - sizeof(vmopvalue_t)) {
			*((vmopvalue_t*)(&vm->memory[++ESP])) = value;
		}
	}
    return;
}

//--------------------


static void vm_pop(vm_struct *vm){

	if (ESP > 0) {
		if (vm->ip->op1.optype != VM_OPTYPE_IMMEDIATE)
			vm_set_operand(vm, &vm->ip->op1, *((vmopvalue_t*)(&vm->memory[ESP--])));
		else {
			vm->state = VM_STATE_INVALID_OPERAND;
			return;
		}
	}
	else
		vm->state = VM_STATE_STACK_UNDERFLOW;
    return;
}

//--------------------
//--------------------

#ifdef _VM_DEBUG

static void vm_disas_operand(vm_operand *op){

    switch(op->optype){

        case VM_OPTYPE_REG_BYTE:
            printf("byte ");

        case VM_OPTYPE_REG_WORD:
            printf("r%d",op->value);
            break;

        case VM_OPTYPE_IMMEDIATE:
            printf("0x%08x",op->value);
            break;

		case VM_OPTYPE_IMMEDIATE_ADDRESS:
			printf("\[0x%08x\]", op->value);
			break;

		case VM_OPTYPE_REG_ADDRESS:
			printf("\[r%d\]", op->value);
			break;
        }

    return;
}

static void vm_disas_ins(vm_struct *vm){

vm_instruction *ins;
static char *mnem[] = {"nop", "in", "out", "mov", "add", "sub", "xor", "and", "or", "hlt", "push", "pop"};

    ins = vm->ip;

    if (ins->opcode >= VM_COUNT_HAND) {
        printf ("invalid instruction\n");
        return;
        }

    printf("%s ",mnem[ins->opcode]);

    vm_disas_operand(&ins->op1);
    if(ins->op2.optype != VM_OPTYPE_NONE)
        printf(", ");

    vm_disas_operand(&ins->op2);

    return;
}


static void vm_state_print(vm_struct *vm){

unsigned int i,j;

    printf ("\n");
    for (i = 0; i < VM_REG_COUNT / 4; ++i) {
        for (j = 0; j < 4; ++j) {
            printf ("r%d %08x\t", 4*i+j, vm->regs[4*i+j]);
            }
        printf("\n");
        }

    printf ("%08p: ", (unsigned int)vm->ip - (unsigned int)vm->memory);
    vm_disas_ins(vm);
    printf("\n");

    return;
}
#endif

//--------------------

//--------------------

BOOL vm_run_current_instruction (vm_struct *vm) {

    if ((unsigned int) vm->ip >= vm->memory + VM_MEM_SIZE) {
        vm->state = VM_STATE_GENERAL_ERROR;
        return FALSE;
        }

    if (vm->ip->opcode >= VM_COUNT_HAND) {
        vm->state = VM_STATE_UNKNOW_INSTRUCTION;
        return FALSE;
        }

    vm_handlers[vm->ip->opcode](vm);
    if(vm->state != VM_STATE_OK){
        return FALSE;
        }

    vm->ip++;

    return TRUE;
}

//--------------------

void vm_run (vm_struct *vm) {

    while (vm->state != VM_STATE_HALT &&
           vm_run_current_instruction (vm));

    return;
}

//--------------------

static void vm_init (vm_struct *vm) {

    vm->fdin = _fileno (stdin);
    vm->fdout = _fileno (stdout);
    vm->ip = (vm_instruction*) (vm->memory + VM_CODE_START);
    vm->state = VM_STATE_OK;

    memset (vm->memory, 0, VM_MEM_SIZE);
    memset (vm->regs, 0, VM_REG_COUNT * sizeof(vmopvalue_t));

    return;
}

//--------------------

vm_struct * create_vm (void) {

    vm_struct *vm = (vm_struct*) malloc (sizeof(vm_struct));
    if (!vm) {
        return NULL;
        }

    vm_init (vm);

    return vm;
}

//--------------------

void destroy_vm (vm_struct *vm) {

    free (vm);

    return;
}

//--------------------

BOOL vm_load_code (vm_struct *vm, unsigned char *code, unsigned int code_size) {

    if (code_size < VM_MEM_SIZE - VM_CODE_START) {
        memcpy (vm->memory + VM_CODE_START, code, code_size);
        return TRUE;
        }

    return FALSE;
}

//--------------------

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

void vm_print_error (vm_struct *vm) {

    if (vm->state != VM_STATE_OK) {
        printf ("%s\n", vm_state_message[vm->state]);
        }

    return;
}

//--------------------

//--------------------

