#include "ilist.h"

extern char *next_label;

typedef enum _INS_CODE
{
    INS_START,
    INS_HALT,
    INS_STORE,
    INS_INC,
    INS_CMP,
    INS_J,
    INS_JG,
    INS_JGE,
    INS_JE,
    INS_JNE,
    INS_JLE,
    INS_JL,
    INS_CALL,
} INS_CODE;

typedef enum _INS_T_CODE
{
    INS_UMINUS,
    INS_ADD,
    INS_SUB,
    INS_MUL,
    INS_DIV
} INS_T_CODE;

typedef enum _LOGIC_OP
{
    LOP_G = 1,
    LOP_GE = 2,
    LOP_E = 3,
    LOP_NE = 4,
    LOP_L = 5,
    LOP_LE = 6,
    LOP_TOTAL = 7
} LOP;

// get the type of expr
void get_arg_type(int *type, char *expr);

// generate label
char *gen_label();

int get_lop_rev(int lop);
bool gen_ins_dec(int type);

// generate instruction by codename and save it to ilist
bool gen_ins(INS_CODE code, int arg_len, char *arg[]);

// generate instruction by codename but it will generate a new value as new argument and return it, and then save insttruction to ilist
char *gen_ins_t(INS_T_CODE code, int arg_len, char *arg[]);

// code generate instruction
void codegen_ins();