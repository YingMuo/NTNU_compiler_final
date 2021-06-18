%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
int line = 1;
%}

%%
\%\%.*\n  { ++line; };
[\t ]+        /* ignore whitespace */ ;
\n { ++line; }
[Pp][Rr][Oo][Gg][Rr][Aa][Mm][ ][A-Za-z0-9._-]+\n {
    ++line;
    yylval.program_name = &yytext[8];
    return PROG_NAME;
    }
[Bb][Ee][Gg][Ii][Nn] { return Begin; }
[Ee][Nn][Dd] {return End;}

[Dd][Ee][Cc][Ll][Aa][Rr][Ee] { return DECLARE; }
[Aa][Ss] { return AS; }

[Ff][Oo][Rr] { return FOR; }
[Ee][Nn][Dd][Ff][Oo][Rr] { return ENDFOR; }
[Tt][Oo] { return TO; }

[Ii][Ff] { return IF; }
[Tt][Hh][Ee][Nn] { return THEN; }
[Ee][Nn][Dd][Ii][Ff] { return ENDIF; }
[Ee][Ll][Ss][Ee] { return ELSE; }

[Ii][Nn][Tt][Ee][Gg][Ee][Rr] { yylval.type=1; return TYPE; }
[Ff][Ll][Oo][Aa][Tt] { yylval.type=2; return TYPE; }

print { return print; }

\> { yylval.logic_op = 1; return LOGIC_OP; }
\>= { yylval.logic_op = 2; return LOGIC_OP; }
== { yylval.logic_op = 3; return LOGIC_OP; }
\!= { yylval.logic_op = 4; return LOGIC_OP; }
\< { yylval.logic_op = 5; return LOGIC_OP; }
\<= { yylval.logic_op = 6; return LOGIC_OP; }

[0-9]+\.[0-9]* {
    yylval.num_lit = yytext;
    return NUM_LIT;
    }
[1-9][0-9]* {
    yylval.int_lit = yytext;
    return INT_LIT;
    }

[A-Za-z][A-Za-z0-9_]* {
    yylval.v_name = yytext;
    return VNAME;
    }

<<EOF>> { return 0; }

. { return yytext[0]; }
