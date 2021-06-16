#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ins_ctr.h"

LIST_HEAD(il_head);

// save instruction
void save_ins(char *label, char *iname, char *arg1, char *arg2, char *arg3)
{
    if (!il_add(&il_head, label, iname, arg1, arg2, arg3))
        yyerror("id_add error: label = %s, iname = %s, arg1 = %s, arg2 = %s, arg3 = %s\n", label, iname, arg1, arg2, arg3);
}

// code generate instruction
void codegen_ins()
{
    Ilist *node = NULL;
    Ilist *head = NULL;

    head = &il_head;
    list_for_each(node, head)
    {
        Ins *cur = list_entry(node, Ins, list);
        // printf("node = %p, head = %p\n", node, head);
        if (cur->label)
        {
            printf("%s", cur->label);
            for (int i = 0; i < 8 - strlen(cur->label); ++i)
                printf(" ");
        }
        else
        {
            for (int i = 0; i < 8; ++i)
                printf(" ");
        }

        printf("%s ", cur->iname);

        for (int i = 0; i < 3; ++i)
        {
            if (cur->arg[i])
                printf("%s", cur->arg[i]);
            if (i != 2 &&cur->arg[i+1])
                printf(", ");
        }
        printf("\n");
    }
    il_del(&il_head);
}