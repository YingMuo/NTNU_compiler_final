%{
    #include <string.h>
    #include "var_ctr.h"
    #include "ins_ctr.h"

    char *var_delim = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_&";
    char *arr_lit_delim = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_&[]";
    char *num_lit_delim = "0123456789.";
    char *int_lit_delim = "0123456789";

    #define VAR_DELIM 1
    #define NUM_LIT_DELIM 2
    #define INT_LIT_DELIM 4
    #define ARR_LIT_DELIM 8
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
            char *arg1, *arg2;
            tok_spn(&arg1, $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg2, $4, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            int type1 = 0, type2 = 0;
            get_expr_type(&type1, arg1);
            get_expr_type(&type2, arg2);

            if (type1 == 1 && type2 == 2)
                yyerror("LVAR ':' '=' EXPR LVAR is int and EXPR is float");
            else if (type1 == 1 && type2 == 1 )
                save_ins(NULL, "I_STORE", arg1, arg2, NULL);
            else if (type1 == 2 && type2 & 3)
                save_ins(NULL, "F_STORE", arg1, arg2, NULL);
            else
                yyerror ("LVAR ':' '=' EXPR type error");
        }
    ;

DVLIST
    :   DVAR
    |   DVLIST ',' DVAR
    ;

EXPR
    :   EXPR '+' EXPR
        {
            char *arg1, *arg2, *arg3;
            tok_spn(&arg1, $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg2, $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            int type1 = 0, type2 = 0, type3 = 0;
            get_expr_type(&type1, arg1);
            get_expr_type(&type2, arg2);

            if (!type1 || !type2)
                yyerror("EXPR '+' EXPR type error");
            
            if ((type1 | type2) & 2)
                type3 = 2;
            else if (type1 & type2 == 1)
                type3 = 1;
            
            gen_tmp_var(&arg3, type3);

            if (type3 == 1)
                save_ins(NULL, "I_ADD", arg1, arg2, arg3);
            else if (type3 == 2)
                save_ins(NULL, "F_ADD", arg1, arg2, arg3);
            else
                yyerror("EXPR '+' EXPR type error");
            $$ = arg3;
        }
    |   EXPR '-' EXPR
        {
            char *arg1, *arg2, *arg3;
            tok_spn(&arg1, $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg2, $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            int type1 = 0, type2 = 0, type3 = 0;
            get_expr_type(&type1, arg1);
            get_expr_type(&type2, arg2);

            if (!type1 || !type2)
                yyerror("EXPR '-' EXPR type error");
            
            if ((type1 | type2) & 2)
                type3 = 2;
            else if (type1 & type2 == 1)
                type3 = 1;
            
            gen_tmp_var(&arg3, type3);

            if (type3 == 1)
                save_ins(NULL, "I_SUB", arg1, arg2, arg3);
            else if (type3 == 2)
                save_ins(NULL, "F_SUB", arg1, arg2, arg3);
            else
                yyerror("EXPR '-' EXPR type error");
            $$ = arg3;
        }
    |   EXPR '*' EXPR
        {
            char *arg1, *arg2, *arg3;
            tok_spn(&arg1, $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg2, $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            int type1 = 0, type2 = 0, type3 = 0;
            get_expr_type(&type1, arg1);
            get_expr_type(&type2, arg2);

            if (!type1 || !type2)
                yyerror("EXPR '*' EXPR type error");
            
            if ((type1 | type2) & 2)
                type3 = 2;
            else if (type1 & type2 == 1)
                type3 = 1;
            
            gen_tmp_var(&arg3, type3);

            if (type3 == 1)
                save_ins(NULL, "I_MUL", arg1, arg2, arg3);
            else if (type3 == 2)
                save_ins(NULL, "F_MUL", arg1, arg2, arg3);
            else
                yyerror("EXPR '*' EXPR type error");
            $$ = arg3;
        }
    |   EXPR '/' EXPR
        {
            char *arg1, *arg2, *arg3;
            tok_spn(&arg1, $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg2, $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            int type1 = 0, type2 = 0, type3 = 0;
            get_expr_type(&type1, arg1);
            get_expr_type(&type2, arg2);

            if (!type1 || !type2)
                yyerror("EXPR '/' EXPR type error");
            
            if ((type1 | type2) & 2)
                type3 = 2;
            else if (type1 & type2 == 1)
                type3 = 1;
            
            gen_tmp_var(&arg3, type3);

            if (type3 == 1)
                save_ins(NULL, "I_DIV", arg1, arg2, arg3);
            else if (type3 == 2)
                save_ins(NULL, "F_DIV", arg1, arg2, arg3);
            else
                yyerror("EXPR '/' EXPR type error");
            $$ = arg3;
        }
    |	'-' EXPR %prec UMINUS
        {
            char *arg1, *arg2;
            tok_spn(&arg1, $2, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);

            int type1 = 0, type2 = 0;
            get_expr_type(&type1, arg1);

            if (!type1)
                yyerror("'-' EXPR %prec UMINUS type error");
            
            if (type1 & 2)
                type2 = 2;
            else if (type1 & 1)
                type2 = 1;
            
            gen_tmp_var(&arg2, type2);

            if (type2 == 1)
                save_ins(NULL, "I_UMINUS", arg1, arg2, NULL);
            else if (type2 == 2)
                save_ins(NULL, "F_UMINUS", arg1, arg2, NULL);
            else
                yyerror("'-' EXPR %prec UMINUS type error");
            $$ = arg2;
        }
	|	'(' EXPR ')' { $$ = $2; }
    |   NUM_LIT
        {
            int len = strspn($1, num_lit_delim);
            $1[len] = '\0';
            $$ = $1;
        }
    |   INT_LIT
        {
            int len = strspn($1, int_lit_delim);
            $1[len] = '\0';
            $$ = $1;
        }
    |   RVAR
    ;

DVAR
    :   VNAME
        {
            int len = strspn($1, var_delim);
            $1[len] = '\0';
            if (!save_var($1, 0))
                yyerror("save_var error");
        }
    |   VNAME '[' INT_LIT ']'
        {
            int len = strspn($1, var_delim);
            $1[len] = '\0';
            int arr_len = atoi($3);
            if (!save_var($1, arr_len))
                yyerror("save_var error");
        }
    ;

LVAR
    :   VNAME
        {
            int len = strspn($1, var_delim);
            $1[len] = '\0';
            $$ = $1;
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
            int len = strspn($1, var_delim);
            $1[len] = '\0';
            $$ = $1;
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
// split and get main expr to drop redundant
void tok_spn(char **token, char *origin, int delim)
{
    *token = origin;
    int len = 0;
    if (delim & VAR_DELIM)
        len = (len >= strspn(origin, var_delim)) ? len : strspn(origin, var_delim);
    if (delim & INT_LIT_DELIM)
        len = (len >= strspn(origin, int_lit_delim)) ? len : strspn(origin, int_lit_delim);
    if (delim & NUM_LIT_DELIM)
        len = (len >= strspn(origin, num_lit_delim)) ? len : strspn(origin, num_lit_delim);
    if (delim & ARR_LIT_DELIM)
        len = (len >= strspn(origin, arr_lit_delim)) ? len : strspn(origin, arr_lit_delim);
    *(*token+len) = '\0';
}

void get_expr_type(int *type, char *expr)
{
    // printf("expr = %s\n", expr);
    int len = 0;
    if (len <= strspn(expr, var_delim))
    {
        len = strspn(expr, var_delim);
        *type = 0;
        // printf("var\n");
    }
    if (len <= strspn(expr, num_lit_delim))
    {
        len = strspn(expr, num_lit_delim);
        *type = 2;
        // printf("num_lit\n");
    }
    if (len <= strspn(expr, int_lit_delim))
    {
        len = strspn(expr, int_lit_delim);
        *type = 1;
        // printf("int_lit\n");
    }

    // expr is var
    if (*type == 0)
        get_var_type(type, expr, len);
}
