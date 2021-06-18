#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "ins_ctr.h"
#include "var_ctr.h"

LIST_HEAD(il_head);
char *next_label = NULL;
int label_idx = 1;
FILE *output_file = NULL;

extern char *var_delim; // = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_&";
extern char *arr_lit_delim; // = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_&[]";
extern char *num_lit_delim; // = "0123456789.";
extern char *int_lit_delim; // = "0123456789";

extern Vlist vl_head;

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
    sprintf(num, "%d", label_idx);
    char *label = malloc(8);
    label[0] = 'l';
    label[1] = 'b';
    label[2] = '&';
    strncat(label, num, 7);
    label[3+strlen(num)] = ':';
    ++label_idx;
    return label;
}

int get_lop_rev(int lop)
{
    lop = LOP_TOTAL - lop;
    return lop;
}

// generate declaration instruction
bool gen_ins_dec(int type)
{
    char *label = next_label;
    next_label = NULL;

    Vlist *node = NULL;
    list_for_each(node, &vl_head)
    {
        Var *cur = list_entry(node, Var, list);
        int arg_len = cur->arr_len ? 3 : 2;
        char *arg[arg_len];

        if (!cur->vname)
            return false;
        arg[0] = cur->vname;

        if (type == TYPE_INT)
            arg[1] = cur->arr_len ? "Integer_array" : "Integer";
        else if (type == TYPE_FLOAT)
            arg[1] = cur->arr_len ? "Float_array" : "Float";
        else
            return false;
        
        if (cur->arr_len)
        {
            char *num = malloc(16);
            sprintf(num, "%d", cur->arr_len);
            arg[2] = num;
        }

        if (!il_add(&il_head, label, "DECLARE", arg_len, arg))
            return false;

        if (cur->arr_len)
            free(arg[2]);
    }
    return true;
}

// TODO: finish gen_ins
// generate instruction by codename
bool gen_ins(INS_CODE code, int arg_len, char *arg[])
{
    char *label = next_label;
    next_label = NULL;
    
    // start
    if (code == INS_START)
    {
        if (!il_add(&il_head, label, "START", 1, arg))
            return false;
        
        return true;
    }

    // halt
    if (code == INS_HALT)
    {
        if (!il_add(&il_head, label, "HALT", 1, arg))
            return false;
        
        return true;
    }

    // store
    if (code == INS_STORE)
    {
        int type[arg_len];
        for (int i = 0; i < arg_len; ++i)
            get_arg_type(&type[i], arg[i]);
        
        if (arg[1][0] > 'z' || arg[1][0] < 'a' && arg[1][0] > 'Z' || arg[1][0] < 'A')
            return false;
        if (type[1] == TYPE_INT && type[0] == TYPE_FLOAT)
            return false;
        else if (type[1] == TYPE_INT && type[0] == TYPE_INT )
        {
            if (!il_add(&il_head, label, "I_STORE", 2, arg))
                return false;
        }
        else if (type[1] == TYPE_FLOAT && type[0] & (TYPE_INT | TYPE_FLOAT))
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
        int type[arg_len];
        for (int i = 0; i < arg_len; ++i)
            get_arg_type(&type[i], arg[i]);
        
        if (type[0] == TYPE_FLOAT)
            return false;
        if (!il_add(&il_head, label, "INC", 1, arg))
            return false;
        
        return true;
    }

    // compare
    if (code == INS_CMP)
    {
        int type[arg_len];
        for (int i = 0; i < arg_len; ++i)
            get_arg_type(&type[i], arg[i]);
        
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

    // jmp
    if (code == INS_J)
    {
        if (!il_add(&il_head, label, "J", 1, arg))
            return false;
        
        return true;
    }

    // jmp less than
    if (code == INS_JG)
    {
        if (!il_add(&il_head, label, "JG", 1, arg))
            return false;
        
        return true;
    }

    // jmp less than
    if (code == INS_JGE)
    {
        if (!il_add(&il_head, label, "JGE", 1, arg))
            return false;
        
        return true;
    }

    // jmp less than
    if (code == INS_JE)
    {
        if (!il_add(&il_head, label, "JE", 1, arg))
            return false;
        
        return true;
    }

    // jmp less than
    if (code == INS_JNE)
    {
        if (!il_add(&il_head, label, "JNE", 1, arg))
            return false;
        
        return true;
    }

    // jmp less than
    if (code == INS_JLE)
    {
        if (!il_add(&il_head, label, "JLE", 1, arg))
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

    // call
    if (code == INS_CALL)
    {
        if (!il_add(&il_head, label, "CALL", arg_len, arg))
            return false;
        
        return true;
    }

    if (label)
        free(label);
}

// generate instruction by codename but it will generate a new value as new argument and return it
char *gen_ins_t(INS_T_CODE code, int arg_len, char *arg[])
{
    char *label = next_label;
    next_label = NULL;

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
            fprintf(output_file, "%s", cur->label);
            for (int i = 0; i < 12 - strlen(cur->label); ++i)
                fprintf(output_file, " ");
        }
        else
        {
            for (int i = 0; i < 12; ++i)
                fprintf(output_file, " ");
        }

        fprintf(output_file, "%s ", cur->iname);

        for (int i = 0; i < cur->arg_len; ++i)
        {
            fprintf(output_file, "%s", cur->arg[i]);
            if (i != cur->arg_len-1)
                fprintf(output_file, ", ");
        }
        fprintf(output_file, "\n");
    }
    il_del(&il_head);
}