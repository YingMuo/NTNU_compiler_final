#include "ilist.h"

extern bool next_label;

typedef enum _INS_CODE
{
    INS_STORE,
    INS_INC,
    INS_CMP,
    INS_JL,
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

// generate label
char *gen_label();

// generate instruction by codename and save it to ilist
bool gen_ins(INS_CODE code, int arg_len, char *arg[]);

// generate instruction by codename but it will generate a new value as new argument and return it, and then save insttruction to ilist
char *gen_ins_t(INS_T_CODE code, int arg_len, char *arg[]);

// code generate instruction
void codegen_ins();