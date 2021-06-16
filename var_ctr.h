#include "vlist.h"

// save variable
bool save_var(char *vname, int arr_len);

// push vlist to i_vl_head
void save_type_vlist(int type);

// code generate variable
void codegen_var();

// generate array literal by variable name and size
void gen_arr_lit(char **arr_lit, char *vname, char *size);

// generate tmp variable
void gen_tmp_var(char **tmp_var, int type);

// get type from name of variable 
void get_var_type(int *type, char *name, int len);