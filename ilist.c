#include "ilist.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

bool il_add(Ilist *head, char *label, char *iname, int arg_len, char *arg[])
{
    if (!head)
        return false;
    
    Ins *new_ins = malloc(sizeof(Ins));
    if (!new_ins)
        return false;


    char *new_label = label ? strdup(label) : NULL;

    char *new_iname = strdup(iname);
    if (!new_iname)
    {
        free(new_ins);
        return false;
    }

    char **new_arg = malloc(arg_len * sizeof(char *));
    for (int i = 0; i < arg_len; ++i)
    {
        new_arg[i] = strdup(arg[i]);
        if (!new_arg[i])
        {
            free(new_ins);
            return false;
        }
    }

    new_ins->label = new_label;
    new_ins->iname = new_iname;
    new_ins->arg_len = arg_len;
    new_ins->arg = new_arg;

    list_add_tail(&new_ins->list, head);

    return true;
}
void il_del(Ilist *head)
{
    if (!head)
        return;
    
    Ins *tmp;
    while (!list_empty(head))
    {
        tmp = list_first_entry(head, Ins, list);
        list_del(&tmp->list);
        free(tmp->label);
        free(tmp->iname);
        for (int i = 0; i < tmp->arg_len; ++i)
            free(tmp->arg[i]);
        free(tmp->arg);
        free(tmp);
    }
}

bool il_splice_tail(Ilist *head, Ilist *tail)
{
    if (!head || !tail)
        return false;
    
    list_splice_tail(tail, head);
    INIT_LIST_HEAD(tail);
    return true;
}

void il_print(Ilist *head)
{
    if (!head)
        return;
    
    Ilist *node;
    list_for_each(node, head)
    {
        Ins *cur = list_entry(node, Ins, list);
        printf("label = %s, iname = %s", cur->label, cur->iname);
        for (int i = 0; i < cur->arg_len; ++i)
            printf(", arg%d = %s", i+1, cur->arg[i]);
        printf("\n");
    }
}