#include "ilist.h"
#include <stdlib.h>

void il_push(Ilist **list_head, Instr *instr)
{
    Ilist *tmp = malloc(sizeof(Ilist));
    tmp->instr = instr;
    tmp->next = *list_head;
    *list_head = tmp;
}

Instr *il_pop(Ilist **list_head)
{
    if (!*list_head)
        return NULL;
    
    Ilist *tmp = *list_head;
    Instr *instr = tmp->instr;
    *list_head = (*list_head)->next;
    free(tmp);
    return instr;
}

void il_reverse(Ilist **list_head)
{
    Ilist *tmp = NULL;
    Ilist *next = NULL;
    while (*list_head)
    {
        next = (*list_head)->next;
        (*list_head)->next = tmp;
        tmp = *list_head;
        (*list_head) = next;
    }
    *list_head = tmp;
}

void il_concat(Ilist **a, Ilist **b)
{
    Ilist *next = NULL;
    while (*b)
    {
        next = (*b)->next;
        (*b)->next = (*a);
        (*a) = (*b);
        (*b) = next;
    }
}