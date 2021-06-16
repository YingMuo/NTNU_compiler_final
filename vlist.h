#pragma once

typedef struct _var
{
    char *v_name;
    int array_len;
} Variable;

typedef struct _vlist
{
    Variable *variable;
    struct _vlist *next;
} Vlist;

void il_push(Vlist **list_head, Variable *variable);
Variable *il_pop(Vlist **list_head);
void il_reverse(Vlist **list_head);
void il_concat(Vlist **a, Vlist **b);