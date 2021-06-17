%{
    #include <string.h>
    #include "var_ctr.h"
    #include "ins_ctr.h"
    #include "tok_spn.h"
%}

%union {
    int type;
    char *v_name;
    int array_len;
    char *int_lit;
    char *num_lit;
    char *rvar;
    char *lvar;
    char *program_name;
}

%token <type> TYPE
%token <v_name> VNAME
%token <array_len> ARRAY_LEN
%token <program_name> Program_name
%token <int_lit> INT_LIT
%token <num_lit> NUM_LIT
%token Begin End DECLARE AS

%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%type <rvar> EXPR
%type <lvar> LVAR
%type <rvar> RVAR
%%
Start
    :   Program_name Begin STMT_LIST ';' End 
        {
            char *endline = strchr($1, '\n');
            if (endline)
                *endline = '\0';
            printf("        START %s\n", $1); 
            codegen_var();
            printf("\n");
            codegen_ins();
            printf("        HALT %s\n", $1); 
        }
    ;

STMT_LIST
    :   STMT
    |   STMT_LIST ';' STMT
    ;

STMT
    :   DECLARE DVLIST AS TYPE
        {
            save_type_vlist($4);
        }
    |   LVAR ':' '=' EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $4, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            if (!gen_ins(INS_STORE, 2, arg))
                yyerror("LVAR ':' '=' EXPR");
        }
    ;

DVLIST
    :   DVAR
    |   DVLIST ',' DVAR
    ;

EXPR
    :   EXPR '+' EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_ADD, 2, arg);
            if (!new_arg)
                yyerror("EXPR '+' EXPR type error");
            $$ = new_arg;
        }
    |   EXPR '-' EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_SUB, 2, arg);
            if (!new_arg)
                yyerror("EXPR '-' EXPR type error");
            $$ = new_arg;
        }
    |   EXPR '*' EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_MUL, 2, arg);
            if (!new_arg)
                yyerror("EXPR '*' EXPR type error");
            $$ = new_arg;
        }
    |   EXPR '/' EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_DIV, 2, arg);
            if (!new_arg)
                yyerror("EXPR '/' EXPR type error");
            $$ = new_arg;
        }
    |	'-' EXPR %prec UMINUS
        {
            char *arg[1];
            tok_spn(&arg[0], $2, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_UMINUS, 1, arg);
            if (!new_arg)
                yyerror("'-' EXPR %prec UMINUS error");
            $$ = new_arg;
        }
	|	'(' EXPR ')' { $$ = $2; }
    |   NUM_LIT
        {
            char *num_lit;
            tok_spn(&num_lit, $1, NUM_LIT_DELIM);
            $$ = num_lit;
        }
    |   INT_LIT
        {
            char *int_lit;
            tok_spn(&int_lit, $1, INT_LIT_DELIM);
            $$ = int_lit;
        }
    |   RVAR
    ;

DVAR
    :   VNAME
        {
            char *vname;
            tok_spn(&vname, $1, VAR_DELIM);
            if (!save_var(vname, 0))
                yyerror("save_var error");
        }
    |   VNAME '[' INT_LIT ']'
        {
            char *vname;
            tok_spn(&vname, $1, VAR_DELIM);
            int arr_len = atoi($3);
            if (!save_var(vname, arr_len))
                yyerror("save_var error");
        }
    ;

LVAR
    :   VNAME
        {
            char *vname;
            tok_spn(&vname, $1, VAR_DELIM);
            $$ = vname;
        }
    |   VNAME '[' EXPR ']'
        {
            char *arr_lit, *vname, *size;
            tok_spn(&vname, $1, VAR_DELIM);
            tok_spn(&size, $3, VAR_DELIM | INT_LIT_DELIM | NUM_LIT_DELIM | ARR_LIT_DELIM);
            gen_arr_lit(&arr_lit, vname, size);
            $$ = arr_lit;
        }
    ;

RVAR
    :   VNAME
        {
            char *vname;
            tok_spn(&vname, $1, VAR_DELIM);
            $$ = vname;
        }
    |   VNAME '[' EXPR ']'
        {
            char *arr_lit, *vname, *size;
            tok_spn(&vname, $1, VAR_DELIM);
            tok_spn(&size, $3, VAR_DELIM | INT_LIT_DELIM | NUM_LIT_DELIM | ARR_LIT_DELIM);
            gen_arr_lit(&arr_lit, vname, size);
            $$ = arr_lit;
        }
    ;
%%
