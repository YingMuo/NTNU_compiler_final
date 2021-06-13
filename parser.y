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

            int type1 = 0, type2 = 0;
            get_expr_type(&type1, arg1);
            get_expr_type(&type2, arg2);

            if (type1 == 1 && type2 == 2)
                yyerror("LVAR ':' '=' EXPR LVAR is int and EXPR is float");
            else if (type1 == 1 && type2 == 1 )
                printf("I_STORE %s, %s\n", arg1, arg2);
            else if (type1 == 2 && type2 & 3)
                printf("F_STORE %s, %s\n", arg1, arg2);
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
                printf("I_ADD %s, %s, %s\n", arg1, arg2, arg3);
            else if (type3 == 2)
                printf("F_ADD %s, %s, %s\n", arg1, arg2, arg3);
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
                printf("I_SUB %s, %s, %s\n", arg1, arg2, arg3);
            else if (type3 == 2)
                printf("F_SUB %s, %s, %s\n", arg1, arg2, arg3);
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
                printf("I_MUL %s, %s, %s\n", arg1, arg2, arg3);
            else if (type3 == 2)
                printf("F_MUL %s, %s, %s\n", arg1, arg2, arg3);
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
                printf("I_DIV %s, %s, %s\n", arg1, arg2, arg3);
            else if (type3 == 2)
                printf("F_DIV %s, %s, %s\n", arg1, arg2, arg3);
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
                printf("I_UMINUS %s, %s\n", arg1, arg2);
            else if (type2 == 2)
                printf("F_UMINUS %s, %s\n", arg1, arg2);
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
void gen_tmp_var(char **tmp_var, int type)
{
    char num[7] = {0};
    sprintf(num, "%d", tmp_val_idx);
    *tmp_var = malloc(8);
    *(*tmp_var) = 'T';
    *(*tmp_var+1) = '&';
    strncat(*tmp_var, num, 6);
    ++tmp_val_idx;

    save_variable(*tmp_var, 0);
    save_type_vlist(type);
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

    if (*type == 0)
    {
        Vlist *tmp = NULL;

        tmp = i_vlist_head;
        while (tmp)
        {
            Variable *variable = tmp->variable;
            if (strncmp(expr, variable->v_name, len) == 0)
            {
                // printf("catch = %s\n", variable->v_name);
                *type = 1;
                return;
            }
            tmp = tmp->next;
        }

        tmp = f_vlist_head;
        while (tmp)
        {
            Variable *variable = tmp->variable;
            if (strncmp(expr, variable->v_name, len) == 0)
            {
                // printf("catch = %s\n", variable->v_name);
                *type = 2;
                return;
            }
            tmp = tmp->next;
        }
    }
}