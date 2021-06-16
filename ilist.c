#include "vlist.h"
#include <stdlib.h>

void vl_push(Vlist **list_head, Variable *variable)
{
    Vlist *tmp = malloc(sizeof(Vlist));
    tmp->variable = variable;
    tmp->next = *list_head;
    *list_head = tmp;
}

Variable *vl_pop(Vlist **list_head)
{
    if (!*list_head)
        return NULL;
    
    Vlist *tmp = *list_head;
    Variable *variable = tmp->variable;
    *list_head = (*list_head)->next;
    free(tmp);
    return variable;
}

void vl_reverse(Vlist **list_head)
{
    Vlist *tmp = NULL;
    Vlist *next = NULL;
    while (*list_head)
    {
        next = (*list_head)->next;
        (*list_head)->next = tmp;
        tmp = *list_head;
        (*list_head) = next;
    }
    *list_head = tmp;
}

void vl_concat(Vlist **a, Vlist **b)
{
    Vlist *next = NULL;
    while (*b)
    {
        next = (*b)->next;
        (*b)->next = (*a);
        (*a) = (*b);
        (*b) = next;
    }
}