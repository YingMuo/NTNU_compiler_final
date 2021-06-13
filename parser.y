%{
    #include <string.h>
    #include "vlist.h"

    Vlist *vlist_head;
    Vlist *i_vlist_head;
    Vlist *f_vlist_head;

    int tmp_val_idx = 1;

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
            printf("START %s\n", $1); 
            codegen_var();
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

            printf("STORE %s, %s\n", arg1, arg2);
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
            gen_tmp_var(&arg3);

            printf("ADD %s, %s, %s\n", arg1, arg2, arg3);
            $$ = arg3;
        }
    |   EXPR '-' EXPR
        {
            char *arg1, *arg2, *arg3;
            tok_spn(&arg1, $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg2, $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            gen_tmp_var(&arg3);

            printf("SUB %s, %s, %s\n", arg1, arg2, arg3);
            $$ = arg3;
        }
    |   EXPR '*' EXPR
        {
            char *arg1, *arg2, *arg3;
            tok_spn(&arg1, $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg2, $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            gen_tmp_var(&arg3);

            printf("MUL %s, %s, %s\n", arg1, arg2, arg3);
            $$ = arg3;
        }
    |   EXPR '/' EXPR
        {
            char *arg1, *arg2, *arg3;
            tok_spn(&arg1, $1, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            tok_spn(&arg2, $3, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            gen_tmp_var(&arg3);

            printf("DIV %s, %s, %s\n", arg1, arg2, arg3);
            $$ = arg3;
        }
    |	'-' EXPR %prec UMINUS
        {
            char *arg1, *arg2;
            tok_spn(&arg1, $2, VAR_DELIM | NUM_LIT_DELIM | INT_LIT_DELIM | ARR_LIT_DELIM);
            gen_tmp_var(&arg2);

            printf("UMINUS %s, %s\n", arg1, arg2);
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
            save_variable($1, 0);
        }
    |   VNAME '[' INT_LIT ']'
        {
            int len = strspn($1, var_delim);
            $1[len] = '\0';
            int arr_len = atoi($3);
            save_variable($1, arr_len);
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
// save variable
void save_variable(char *v_name, int array_len)
{
    Variable *tmp = malloc(sizeof(Variable));
    tmp->v_name = strdup(v_name);
    tmp->array_len = array_len;
    vl_push(&vlist_head, tmp);
}

// print variable
void print_variable(Vlist *list_head)
{
    Vlist *tmp = list_head;
    while (tmp)
    {
        Variable *variable = tmp->variable;
        printf("VNAME: %s, ARRAY_LEN: %d\n", variable->v_name, variable->array_len);
        tmp = tmp->next;
    }
}

// push vlist to i_vlist_head
void save_type_vlist(int type)
{
    if (type == 1)
        vl_concat(&i_vlist_head, &vlist_head);
    if (type == 2)
        vl_concat(&f_vlist_head, &vlist_head);
}

// code generate variable
void codegen_var()
{
    while (i_vlist_head)
    {
        Variable *variable = vl_pop(&i_vlist_head);
        if (variable->array_len)
            printf("Declare %s, Integer_array, %d\n", variable->v_name, variable->array_len);
        else
            printf("Declare %s, Integer\n", variable->v_name);
        free(variable);
    }

    while (f_vlist_head)
    {
        Variable *variable = vl_pop(&f_vlist_head);
        if (variable->array_len)
            printf("Declare %s, Float_array, %d\n", variable->v_name, variable->array_len);
        else
            printf("Declare %s, Float\n", variable->v_name);
        free(variable);
    }
}

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

// generate array literal by variable name and size
void gen_arr_lit(char **arr_lit, char *vname, char *size)
{
    *arr_lit = strdup(vname);
    realloc(*arr_lit, strlen(vname)+strlen(size)+1);
    strcat(*arr_lit, "[");
    strcat(*arr_lit, size);
    strcat(*arr_lit, "]");
}

// generate tmp variable
void gen_tmp_var(char **tmp_var)
{
    char num[7] = {0};
    sprintf(num, "%d", tmp_val_idx);
    *tmp_var = malloc(8);
    *(*tmp_var) = 'T';
    *(*tmp_var+1) = '&';
    strncat(*tmp_var, num, 6);
    ++tmp_val_idx;
}