#include "ilist.h"

typedef enum _INS_CODE
{
    INS_STORE,
} INS_CODE;

typedef enum _INS_T_CODE
{
    INS_UMINUS,
    INS_ADD,
    INS_SUB,
    INS_MUL,
    INS_DIV
} INS_T_CODE;

// get the type of expr
void get_arg_type(int *type, char *expr);

// generate instruction by codename
bool gen_ins(INS_CODE code, int arg_len, char *arg[]);

// generate instruction by codename but it will generate a new value as new argument and return it
char *gen_ins_t(INS_T_CODE code, int arg_len, char *arg[]);

// code generate instruction
void codegen_ins();