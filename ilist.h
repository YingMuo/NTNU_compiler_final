#pragma once
#include "list.h"
#include <stdbool.h>

typedef struct list_head Ilist;

typedef struct _ins
{
    Ilist list;
    char *label;
    char *iname;
    int arg_len;
    char **arg;
} Ins;

bool il_add(Ilist *head, char *label, char *iname, int arg_len, char *arg[]);
void il_del(Ilist *head);
bool il_splice_tail(Ilist *head, Ilist *tail);
void il_print(Ilist *head);