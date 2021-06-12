%{
    #include <string.h>
    #include "vlist.h"
    Vllist *vllist_head;
    Vlist *vlist_head;
    Vlist *i_vlist_head;
    Vlist *f_vlist_head;
    char *var_delim = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";
    char *num_delim = "0123456789.";
    char *integer_delim = "0123456789";
%}

%union {
    int type;
    char *v_name;
    int array_len;
    char *integer;
    char *number;
    char *rvar;
    char *lvar;
    char *program_name;
}

%token <type> TYPE
%token <v_name> VNAME
%token <array_len> ARRAY_LEN
%token <program_name> Program_name
%token <integer> INTEGER
%token <number> NUMBER
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
    :   DECLARE VLIST AS TYPE
        {
            save_type_vlist($4);
        }
    |   LVAR ':' '=' EXPR { printf("LVAR ':' '=' EXPR\n%s + %s\n%s\n%s\n\n", $1, $4, $1, $4); }
    ;

VLIST
    :   DVAR
    |   VLIST ',' DVAR
    ;

EXPR
    :   EXPR '+' EXPR { printf("EXPR '+' EXPR\n%s + %s\n%s\n%s\n\n", $1, $3, $1, $3); }
    |   EXPR '-' EXPR { printf("EXPR '-' EXPR\n%s - %s\n%s\n%s\n\n", $1, $3, $1, $3); }
    |   EXPR '*' EXPR { printf("EXPR '*' EXPR\n%s * %s\n%s\n%s\n\n", $1, $3, $1, $3); }
    |   EXPR '/' EXPR { printf("EXPR '/' EXPR\n%s / %s\n%s\n%s\n\n", $1, $3, $1, $3); }
    |   NUMBER
        {
            int len = strspn($1, num_delim);
            $1[len] = '\0';
            $$ = $1;
        }
    |   INTEGER
        {
            int len = strspn($1, integer_delim);
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
    |   VNAME ARRAY_LEN 
        {
            int len = strspn($1, var_delim);
            $1[len] = '\0';
            save_variable($1, $2);
        }
    ;

LVAR
    :   VNAME
        {
            int len = strspn($1, var_delim);
            $1[len] = '\0';
            printf("LVAR\n%s, %d\n\n", $1, len);
            $$ = $1;
        }

RVAR
    :   VNAME
        {
            int len = strspn($1, var_delim);
            $1[len] = '\0';
            printf("RVAR\n%s, %d\n\n", $1, len);
            $$ = $1;
        }
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
