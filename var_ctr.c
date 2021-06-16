#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "var_ctr.h"

LIST_HEAD(vl_head);
LIST_HEAD(i_vl_head);
LIST_HEAD(f_vl_head);
int tmp_val_idx = 1;

// save variable
bool save_var(char *vname, int arr_len)
{
    return vl_add(&vl_head, vname, arr_len);
}

// push vlist to i_vl_head
void save_type_vlist(int type)
{
    if (type == 1)
        vl_splice_tail(&i_vl_head, &vl_head);
    else if (type == 2)
        vl_splice_tail(&f_vl_head, &vl_head);
    else
    {
        return;
    }
}

// code generate variable
void codegen_var()
{
    Vlist *node = NULL;
    Vlist *head = NULL;

    head = &i_vl_head;
    list_for_each(node, head)
    {
        Var *cur = list_entry(node, Var, list);
        printf("        ");
        // printf("node = %p, head = %p\n", node, head);
        if (cur->arr_len)
            printf("Declare %s, Integer_array, %d\n", cur->vname, cur->arr_len);
        else
            printf("Declare %s, Integer\n", cur->vname);
    }

    head = &f_vl_head;
    list_for_each(node, head)
    {
        Var *cur = list_entry(node, Var, list);
        printf("        ");
        // printf("node = %p, head = %p\n", node, head);
        if (cur->arr_len)
            printf("Declare %s, Float_array, %d\n", cur->vname, cur->arr_len);
        else
            printf("Declare %s, Float\n", cur->vname);
    }

    vl_del(&i_vl_head);
    vl_del(&f_vl_head);
}

// generate array literal by variable name and size
void gen_arr_lit(char **arr_lit, char *vname, char *size)
{
    *arr_lit = strdup(vname);
    realloc(*arr_lit, strlen(vname)+strlen(size)+1);
    strcat(*arr_lit, "[");
    strcat(*arr_lit, size);
    strcat(*arr_lit, "]");
}

// generate tmp variable
void gen_tmp_var(char **tmp_var, int type)
{
    char num[7] = {0};
    sprintf(num, "%d", tmp_val_idx);
    *tmp_var = malloc(8);
    *(*tmp_var) = 'T';
    *(*tmp_var+1) = '&';
    strncat(*tmp_var, num, 6);
    ++tmp_val_idx;

    save_var(*tmp_var, 0);
    save_type_vlist(type);
}

// get type from name of variable 
void get_var_type(int *type, char *name, int len)
{
    Vlist *node;
    list_for_each(node, &i_vl_head)
    {
        Var *cur = list_entry(node, Var, list);
        if (strncmp(name, cur->vname, len) == 0)
        {
            // printf("catch = %s\n", variable->v_name);
            *type = 1;
            return;
        }
    }

    list_for_each(node, &f_vl_head)
    {
        Var *cur = list_entry(node, Var, list);
        if (strncmp(name, cur->vname, len) == 0)
        {
            // printf("catch = %s\n", variable->v_name);
            *type = 2;
            return;
        }
    }
}