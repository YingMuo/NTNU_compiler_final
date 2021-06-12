%{
    #include <string.h>
    #include "vlist.h"
    Vllist *vllist_head;
    Vlist *vlist_head;
    Vlist *i_vlist_head;
    Vlist *f_vlist_head;
%}

%union {
    int type;
    char *v_name;
    int array_len;
    char *program_name;
}

%token <type> TYPE
%token <v_name> VNAME
%token <array_len> ARRAY_LEN
%token <program_name> Program_name
%token Begin End DECLARE AS
%%
Start
    :   Program_name Begin STMT_LIST ';' End 
        {
            char *endline = strchr($1, '\n');
            if (endline)
                *endline = '\0';
            printf("START %s\n", $1); 
            codegen_var();
            // print_value(i_vlist_head);
            // print_value(f_vlist_head);
        }
    ;
STMT_LIST
    :   STMT
    |   STMT_LIST ';' STMT
    ;
STMT
    :   DECLARE VLIST AS TYPE
        {
            // printf("TYPE: %d\n", $4);
            save_type_vlist($4);
        }
    ;
VLIST
    :   VALUE
    |   VLIST ',' VALUE
    ;
VALUE
    :   VNAME
        {
            char *endstring = 0;
            if (strchr($1, ' '))
                endstring = strchr($1, ' ');
            if (strchr($1, ','))
                endstring = strchr($1, ',');
            if (endstring)
                *endstring = '\0';
            // printf("VNAME: %s\n", $1); 
            save_value($1, 0);
        }
    |   VNAME ARRAY_LEN 
        {
            char *endstring = strchr($1, '[');
            if (endstring)
                *endstring = 0;
            // printf("VNAME: %s, ARRAY_LEN: %d\n", $1, $2);
            save_value($1, $2);
        }
    ;

%%
// save value
void save_value(char *v_name, int array_len)
{
    Value *tmp = malloc(sizeof(Value));
    tmp->v_name = strdup(v_name);
    tmp->array_len = array_len;
    vl_push(&vlist_head, tmp);
}

// print value
void print_value(Vlist *list_head)
{
    Vlist *tmp = list_head;
    while (tmp)
    {
        Value *value = tmp->value;
        printf("VNAME: %s, ARRAY_LEN: %d\n", value->v_name, value->array_len);
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
        Value *value = vl_pop(&i_vlist_head);
        if (value->array_len)
            printf("Declare %s, Integer_array, %d\n", value->v_name, value->array_len);
        else
            printf("Declare %s, Integer\n", value->v_name);
        free(value);
    }

    while (f_vlist_head)
    {
        Value *value = vl_pop(&f_vlist_head);
        if (value->array_len)
            printf("Declare %s, Float_array, %d\n", value->v_name, value->array_len);
        else
            printf("Declare %s, Float\n", value->v_name);
        free(value);
    }
}
