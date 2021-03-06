#pragma once
#include "list.h"
#include <stdbool.h>

typedef struct list_head Vlist;

typedef struct _var
{
    Vlist list;
    char *vname;
    int arr_len;
} Var;

bool vl_add(Vlist *head, char *vname, int arr_len);
void vl_del(Vlist *head);
bool vl_splice_tail(Vlist *head, Vlist *tail);
void vl_print(Vlist *head);