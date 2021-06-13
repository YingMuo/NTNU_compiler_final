#pragma once

typedef struct _node
{
    char *v_name;
    int array_len;
} Variable;

typedef struct _list
{
    Variable *variable;
    struct _list *next;
} Vlist;

void vl_push(Vlist **list_head, Variable *variable);
Variable *vl_pop(Vlist **list_head);
void vl_reverse(Vlist **list_head);
void vl_concat(Vlist **a, Vlist **b);