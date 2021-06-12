%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%
\%\%.*\n  ;
[\t\n ]+        /* ignore whitespace */ ;
[Pp][Rr][Oo][Gg][Rr][Aa][Mm][ ][A-Za-z0-9._-]+\n {
    yylval.program_name = &yytext[8];
    return Program_name; }
[Bb][Ee][Gg][Ii][Nn] { return Begin; }
[Ee][Nn][Dd] {return End;}

[Dd][Ee][Cc][Ll][Aa][Rr][Ee] { return DECLARE; }
[Aa][Ss] { return AS; }

[Ii][Nn][Tt][Ee][Gg][Ee][Rr] { yylval.type=1; return TYPE; }
[Ff][Ll][Oo][Aa][Tt] { yylval.type=2; return TYPE; }

[A-Za-z][A-Za-z0-9]* { yylval.v_name = &yytext[0]; return VNAME; }
\[[1-9][0-9]*\] { yylval.array_len = atoi(&yytext[1]); return ARRAY_LEN; }

<<EOF>> { return 0; }

. { return yytext[0]; }
