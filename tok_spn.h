#pragma once

#define VAR_DELIM 1
#define NUM_LIT_DELIM 2
#define INT_LIT_DELIM 4
#define ARR_LIT_DELIM 8

// split and get main expr to drop redundant
void tok_spn(char **token, char *origin, int delim);