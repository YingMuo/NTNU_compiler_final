#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "ins_ctr.h"
#include "var_ctr.h"

LIST_HEAD(il_head);
bool next_label = false;
int label_idx = 2;

extern char *var_delim; // = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_&";
extern char *arr_lit_delim; // = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_&[]";
extern char *num_lit_delim; // = "0123456789.";
extern char *int_lit_delim; // = "0123456789";

// get the type of expr
void get_arg_type(int *type, char *expr)
{
    int len = 0;
    if (len <= strspn(expr, var_delim))
    {
        len = strspn(expr, var_delim);
        *type = 0;
    }
    if (len <= strspn(expr, num_lit_delim))
    {
        len = strspn(expr, num_lit_delim);
        *type = TYPE_FLOAT;
    }
    if (len <= strspn(expr, int_lit_delim))
    {
        len = strspn(expr, int_lit_delim);
        *type = TYPE_INT;
    }

    // expr is var
    if (*type == 0)
        get_var_type(type, expr, len);
}

// generate label
char *gen_label()
{
    char num[7] = {0};
    sprintf(num, "%d", label_idx/2);
    char *label = malloc(8);
    label[0] = 'l';
    label[1] = 'b';
    label[2] = '&';
    strncat(label, num, 7);
    label[3+strlen(num)] = ':';
    ++label_idx;
    return label;
}


// TODO: finish gen_ins
// generate instruction by codename
bool gen_ins(INS_CODE code, int arg_len, char *arg[])
{
    char *label = next_label ? gen_label() : NULL;
    next_label = false;

    int type[arg_len];
    for (int i = 0; i < arg_len; ++i)
        get_arg_type(&type[i], arg[i]);
    
    // store
    if (code == INS_STORE)
    {
        if (arg[1][0] > 'z' || arg[1][0] < 'a' && arg[1][0] > 'Z' || arg[1][0] < 'A')
            return false;
        if (type[0] == TYPE_INT && type[1] == TYPE_FLOAT)
            return false;
        else if (type[0] == TYPE_INT && type[1] == TYPE_INT )
        {
            if (!il_add(&il_head, label, "I_STORE", 2, arg))
                return false;
        }
        else if (type[0] == TYPE_FLOAT && type[1] & (TYPE_INT | TYPE_FLOAT))
        {
            if (!il_add(&il_head, label, "F_STORE", 2, arg))
                return false;
        }
        else
            return false;
        
        return true;
    }

    // inc
    if (code == INS_INC)
    {
        if (type[0] == TYPE_FLOAT)
            return false;
        if (!il_add(&il_head, label, "INC", 1, arg))
            return false;
        
        return true;
    }

    // compare
    if (code == INS_CMP)
    {
        if (type[0] != type[1])
            return false;
        else if (type[0] == TYPE_INT && type[1] == TYPE_INT )
        {
            if (!il_add(&il_head, label, "I_CMP", 2, arg))
                return false;
        }
        else if (type[0] == TYPE_FLOAT && type[1] == TYPE_FLOAT)
        {
            if (!il_add(&il_head, label, "F_CMP", 2, arg))
                return false;
        }
        else
            return false;
        
        return true;
    }

    // jmp less than
    if (code == INS_JL)
    {
        if (!il_add(&il_head, label, "JL", 1, arg))
            return false;
        
        return true;
    }

    if (label)
        free(label);
}

// generate instruction by codename but it will generate a new value as new argument and return it
char *gen_ins_t(INS_T_CODE code, int arg_len, char *arg[])
{
    char *label = next_label ? gen_label() : NULL;
    next_label = false;

    int type[arg_len];
    char *new_arg[arg_len+1];
    for (int i = 0; i < arg_len; ++i)
    {
        get_arg_type(&type[i], arg[i]);
        new_arg[i] = arg[i];
    }

    int new_type = 0;

    // arithmetic
    if (code == INS_ADD || code == INS_SUB || code == INS_MUL || code == INS_DIV )
    {
        if (!type[0] || !type[1])
            return NULL;
        
        if ((type[0] | type[1]) & TYPE_FLOAT)
            new_type = TYPE_FLOAT;
        else if (type[0] & type[1] == TYPE_INT)
            new_type = TYPE_INT;
        
        gen_tmp_var(&new_arg[arg_len], new_type);

        // add
        if (code == INS_ADD)
        {
            if (new_type == TYPE_INT)
            {
                if (!il_add(&il_head, label, "I_ADD", arg_len+1, new_arg))
                    return false;
            }
            else if (new_type == TYPE_FLOAT)
            {
                if (!il_add(&il_head, label, "F_ADD", arg_len+1, new_arg))
                    return false;
            }
            else
                return false;
        }

        // sub
        if (code == INS_SUB)
        {
            if (new_type == TYPE_INT)
            {
                if (!il_add(&il_head, label, "I_SUB", arg_len+1, new_arg))
                    return false;
            }
            else if (new_type == TYPE_FLOAT)
            {
                if (!il_add(&il_head, label, "F_SUB", arg_len+1, new_arg))
                    return false;
            }
            else
                return false;
        }

        // mul
        if (code == INS_MUL)
        {
            if (new_type == TYPE_INT)
            {
                if (!il_add(&il_head, label, "I_MUL", arg_len+1, new_arg))
                    return false;
            }
            else if (new_type == TYPE_FLOAT)
            {
                if (!il_add(&il_head, label, "F_MUL", arg_len+1, new_arg))
                    return false;
            }
            else
                return false;
        }

        // div
        if (code == INS_DIV)
        {
            if (new_type == TYPE_INT)
            {
                if (!il_add(&il_head, label, "I_DIV", arg_len+1, new_arg))
                    return false;
            }
            else if (new_type == TYPE_FLOAT)
            {
                if (!il_add(&il_head, label, "F_DIV", arg_len+1, new_arg))
                    return false;
            }
            else
                return false;
        }

        return new_arg[arg_len];
    }

    // UMINUS
    if (code == INS_UMINUS)
    {
        if (!type[0])
            return NULL;
        
        if (type[0] & TYPE_FLOAT)
            new_type = TYPE_FLOAT;
        else if (type[0] & TYPE_INT)
            new_type = TYPE_INT;
        
        gen_tmp_var(&new_arg[arg_len], new_type);

        if (new_type == TYPE_INT)
        {
            if (!il_add(&il_head, label, "I_UMINUS", arg_len+1, new_arg))
                return false;
        }
        else if (new_type == TYPE_FLOAT)
        {
            if (!il_add(&il_head, label, "F_UMINUS", arg_len+1, new_arg))
                return false;
        }
        else
            return false;
        
        return new_arg[arg_len];
    }
    if (label)
        free(label);
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