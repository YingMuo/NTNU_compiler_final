#pragma once

typedef struct _instr
{
    char *label;
    char *iname;
    char *arg[3];
} Instr;

typedef struct _ilist
{
    Instr *instr;
    struct _ilist *next;
} Ilist;

void vl_push(Ilist **list_head, Instr *variable);
Instr *vl_pop(Ilist **list_head);
void vl_reverse(Ilist **list_head);
void vl_concat(Ilist **a, Ilist **b);