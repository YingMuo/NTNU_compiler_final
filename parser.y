%{
    #include <string.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include "var_ctr.h"
    #include "ins_ctr.h"
    #include "tok_spn.h"

    extern int line;

    typedef struct _arg_list
    {
        int arg_len;
        char **arg;
    } Alist;

    int yyerror(char *msg)
    {
        printf("error: %d: %s\n", line, msg);
        exit(EXIT_FAILURE);
    }
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
    char *for_init_arg[3];
    char *label;
    int logic_op;
    struct _arg_list *arg_list;
}

%token <type> TYPE
%token <v_name> VNAME
%token <array_len> ARRAY_LEN
%token <program_name> PROG_NAME
%token <int_lit> INT_LIT
%token <num_lit> NUM_LIT
%token <logic_op> LOGIC_OP
%token Begin End DECLARE AS TO FOR ENDFOR IF THEN ELSE ENDIF print

%left '-' '+'
%left '*' '/'
%nonassoc UMINUS
%nonassoc IFX
%nonassoc ELSE

%type <rvar> EXPR
%type <for_init_arg> FOR_INIT_STMT
%type <label> IF_INIT_STMT
%type <label> ELSE_INIT_STMT
%type <program_name> PROG_INIT_STMT
%type <arg_list> EXPR_LIST
%type <lvar> LVAR
%type <rvar> RVAR
%%
Start
    :   PROG_INIT_STMT Begin STMT_LIST End 
        {
            char *endline = strchr($1, '\n');
            if (endline)
                *endline = '\0';
            char *arg[1];
            arg[0] = $1;
            if (!gen_ins(INS_HALT, 1, arg))
                yyerror("generate start instruction wrong");
            gen_ins_dec(0);
        }
    ;
PROG_INIT_STMT
    :   PROG_NAME
        {
            char *endline = strchr($1, '\n');
            if (endline)
                *endline = '\0';
            char *arg[1];
            arg[0] = $1;
            if (!gen_ins(INS_START, 1, arg))
                yyerror("generate halt instruction wrong");
        }
    ;

STMT_LIST
    :   STMT
    |   STMT_LIST STMT
    ;

STMT
    :   DECLARE DVLIST AS TYPE ';'
        {
            gen_ins_dec($4);
            save_type_vlist($4);
        }
    |   LVAR ':' '=' EXPR ';'
        {
            char *arg[2];
            tok_spn(&arg[0], $4, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            if (!gen_ins(INS_STORE, 2, arg))
                yyerror("assignment");
        }
    |   FOR '(' FOR_INIT_STMT ')' STMT_LIST ENDFOR
        {
            char *arg_inc[1];
            tok_spn(&arg_inc[0], $3[0], VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            if (!gen_ins(INS_INC, 1, arg_inc))
                yyerror("generate inc instruction wrong");

            char *arg_cmp[2];
            tok_spn(&arg_cmp[0], $3[0], VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg_cmp[1], $3[1], VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            if (!gen_ins(INS_CMP, 2, arg_cmp))
                yyerror("generate cmp instruction wrong");

            char *arg_jl[1];
            tok_spn(&arg_jl[0], $3[2], VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            if (!gen_ins(INS_JL, 1, arg_jl))
                yyerror("generate jl instruction wrong");
        }
    |   IF '(' IF_INIT_STMT ')' THEN STMT_LIST ENDIF %prec IFX
        {
            char *label;
            tok_spn(&label, $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            next_label = label;
        }
    |   IF ELSE_INIT_STMT ELSE STMT_LIST ENDIF
        {
            char *label;
            tok_spn(&label, $2, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            next_label = label;
        }
    |   print '(' EXPR_LIST ')' ';'
        {
            int arg_len = $3->arg_len+1;
            char *arg[arg_len];
            arg[0] = "print";
            for (int i = 1; i < arg_len; ++i)
                tok_spn(&arg[i], $3->arg[i-1], VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            
            if (!gen_ins(INS_CALL, arg_len, arg))
                yyerror("generate call instruction wrong");
        }
    ;

ELSE_INIT_STMT
    :   '(' IF_INIT_STMT ')' THEN STMT_LIST
        {
            char *arg[1];
            arg[0] = gen_label();
            if (!gen_ins(INS_J, 1, arg))
                yyerror("generate j instruction wrong");

            char *label;
            tok_spn(&label, $2, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            next_label = label;

            $$ = arg[0];
        }
    ;

IF_INIT_STMT
    :   EXPR LOGIC_OP EXPR
        {
            char *arg_cmp[2];
            tok_spn(&arg_cmp[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg_cmp[1], $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            
            gen_ins(INS_CMP, 2, arg_cmp);
            
            int lop = get_lop_rev($2);
            char *arg_jmp[1];
            arg_jmp[0] = gen_label();

            if (lop == LOP_G)
            {
                if (!gen_ins(INS_JG, 1, arg_jmp))
                    yyerror("generate jg instruction wrong");
            }
            else if (lop == LOP_GE)
            {
                if (!gen_ins(INS_JGE, 1, arg_jmp))
                    yyerror("generate jge instruction wrong");
            }
            else if (lop == LOP_E)
            {
                if (!gen_ins(INS_JE, 1, arg_jmp))
                    yyerror("generate je instruction wrong");
            }
            else if (lop == LOP_NE)
            {
                if (!gen_ins(INS_JNE, 1, arg_jmp))
                    yyerror("generate jne instruction wrong");
            }
            else if (lop == LOP_LE)
            {
                if (!gen_ins(INS_JLE, 1, arg_jmp))
                    yyerror("generate jle instruction wrong");
            }
            else if (lop == LOP_L)
            {
                if (!gen_ins(INS_JL, 1, arg_jmp))
                    yyerror("generate jl instruction wrong");
            }
            else
                yyerror("no this logic operation");

            $$ = arg_jmp[0];
        }
    ;


FOR_INIT_STMT
    :   LVAR ':' '=' EXPR TO EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $4, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            int lvar_type;
            get_var_type(&lvar_type, arg[1], strlen(arg[1]));
            if (lvar_type != TYPE_INT)
                yyerror("var need to be int in for");

            if (!gen_ins(INS_STORE, 2, arg))
                yyerror("generate store instruction wrong");
            next_label = gen_label();

            char *to_arg;
            tok_spn(&to_arg, $6, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            int to_type;
            get_arg_type(&to_type, to_arg);
            if (to_type != TYPE_INT)
                yyerror("to_value need to be int in for");
            
            $$[0] = arg[1];
            $$[1] = to_arg;
            $$[2] = next_label;
        }
    ;

EXPR_LIST
    :   EXPR
        {
            Alist *arg_list = malloc(sizeof(Alist));
            arg_list->arg_len = 1;
            arg_list->arg = malloc(arg_list->arg_len * sizeof(char *));
            tok_spn(&arg_list->arg[arg_list->arg_len - 1], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            $$ = arg_list;
        }
    |   EXPR ',' EXPR_LIST
        {
            Alist *arg_list = $3;
            ++arg_list->arg_len;
            arg_list->arg = realloc(arg_list->arg, arg_list->arg_len * sizeof(char *));
            tok_spn(&arg_list->arg[arg_list->arg_len - 1], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            $$ = arg_list;
        }
    ;

EXPR
    :   EXPR '+' EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_ADD, 2, arg);
            if (!new_arg)
                yyerror("a + b error");
            $$ = new_arg;
        }
    |   EXPR '-' EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_SUB, 2, arg);
            if (!new_arg)
                yyerror("a - b error");
            $$ = new_arg;
        }
    |   EXPR '*' EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_MUL, 2, arg);
            if (!new_arg)
                yyerror("a * b error");
            $$ = new_arg;
        }
    |   EXPR '/' EXPR
        {
            char *arg[2];
            tok_spn(&arg[0], $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg[1], $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_DIV, 2, arg);
            if (!new_arg)
                yyerror("a / b error");
            $$ = new_arg;
        }
    |	'-' EXPR %prec UMINUS
        {
            char *arg[1];
            tok_spn(&arg[0], $2, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            char *new_arg = gen_ins_t(INS_UMINUS, 1, arg);
            if (!new_arg)
                yyerror("-a error");
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

DVLIST
    :   DVAR
    |   DVLIST ',' DVAR
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
