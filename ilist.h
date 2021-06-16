#pragma once
#include "list.h"
#include <stdbool.h>

typedef struct list_head Ilist;

typedef struct _ins
{
    char *label;
    char *iname;
    char *arg[3];
    Ilist list;
} Ins;

bool il_add(Ilist *head, char *label, char *iname, char *arg1, char *arg2, char *arg3);
void il_del(Ilist *head);
bool il_splice_tail(Ilist *head, Ilist *tail);
void il_print(Ilist *head);