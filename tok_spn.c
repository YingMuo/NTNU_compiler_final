#include <stdio.h>
#include <string.h>

#include "tok_spn.h"

char *var_delim = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_&";
char *arr_lit_delim = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_&[]";
char *num_lit_delim = "0123456789.";
char *int_lit_delim = "0123456789";

// split and get main expr to drop redundant
void tok_spn(char **token, char *origin, int delim)
{
    *token = origin;
    int len = 0;
    if (delim & VAR_DELIM)
        len = (len >= strspn(origin, var_delim)) ? len : strspn(origin, var_delim);
    if (delim & INT_LIT_DELIM)
        len = (len >= strspn(origin, int_lit_delim)) ? len : strspn(origin, int_lit_delim);
    if (delim & NUM_LIT_DELIM)
        len = (len >= strspn(origin, num_lit_delim)) ? len : strspn(origin, num_lit_delim);
    if (delim & ARR_LIT_DELIM)
        len = (len >= strspn(origin, arr_lit_delim)) ? len : strspn(origin, arr_lit_delim);
    *(*token+len) = '\0';
}