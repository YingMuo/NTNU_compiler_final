/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TYPE = 258,
    VNAME = 259,
    ARRAY_LEN = 260,
    PROG_NAME = 261,
    INT_LIT = 262,
    NUM_LIT = 263,
    LOGIC_OP = 264,
    Begin = 265,
    End = 266,
    DECLARE = 267,
    AS = 268,
    TO = 269,
    FOR = 270,
    ENDFOR = 271,
    IF = 272,
    THEN = 273,
    ELSE = 274,
    ENDIF = 275,
    print = 276,
    UMINUS = 277,
    IFX = 278
  };
#endif
/* Tokens.  */
#define TYPE 258
#define VNAME 259
#define ARRAY_LEN 260
#define PROG_NAME 261
#define INT_LIT 262
#define NUM_LIT 263
#define LOGIC_OP 264
#define Begin 265
#define End 266
#define DECLARE 267
#define AS 268
#define TO 269
#define FOR 270
#define ENDFOR 271
#define IF 272
#define THEN 273
#define ELSE 274
#define ENDIF 275
#define print 276
#define UMINUS 277
#define IFX 278

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 24 "parser.y"

    int type;
    char *v_name;
    int array_len;
    char *int_lit;
    char *num_lit;
    char *rvar;
    char *lvar;
    char *program_name;
    char *for_init_arg[3];
    char *label;
    int logic_op;
    struct _arg_list *arg_list;

#line 118 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
