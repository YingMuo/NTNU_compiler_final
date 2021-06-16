#include "vlist.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

bool vl_add(Vlist *head, char *vname, int arr_len)
{
    if (!head)
        return false;
    
    Var *new_var = malloc(sizeof(Var));
    if (!new_var)
        return false;

    char *new_vname = strdup(vname);
    if (!new_vname)
    {
        free(new_var);
        return false;
    }

    new_var->vname = new_vname;
    new_var->arr_len = arr_len;
    list_add_tail(&new_var->list, head);

    return true;
}
void vl_del(Vlist *head)
{
    if (!head)
        return;
    
    Var *tmp;
    while (!list_empty(head))
    {
        tmp = list_first_entry(head, Var, list);
        list_del(&tmp->list);
        free(tmp->vname);
        free(tmp);
    }
}

bool vl_splice_tail(Vlist *head, Vlist *tail)
{
    if (!head || !tail)
        return false;
    
    list_splice_tail(tail, head);
    INIT_LIST_HEAD(tail);
    return true;
}

void vl_print(Vlist *head)
{
    if (!head)
        return;
    
    Vlist *node;
    list_for_each(node, head)
    {
        Var *cur = list_entry(node, Var, list);
        printf("vname = %s, arr_len = %d\n", cur->vname, cur->arr_len);
    }
}