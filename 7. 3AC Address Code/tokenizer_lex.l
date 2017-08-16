/* recognize tokens from the input and print them out */

%{
#include <string.h>
# include "grammer_bison.tab.h"
%}

integer	[+][0-9]*[.]?[0-9]+
id	[a-zA-Z][a-zA-Z0-9]*
decimal [0-9]+[.][0-9]+
real 	({integer}|{decimal})[e|E][+-][0-9]+
num 	[0-9]+("."[0-9]+)?

%%
"+"	{ return ADD; }
"-"	{ return SUB; }
"*"	{ return MUL; }
"/"	{ return DIV; }
"|"     { return ABS; }
"("     { return OP; }
")"     { return CP; }
":="	{ return ASSIGN;}
","	{ return COMMA; }
";"	{ return SEMICOL; }
{num}	{ yylval = strdup(yytext); return NUMBER; }
{id}	{ yylval = strdup(yytext); return ID; }
{real}	{ yylval = strdup(yytext); return REAL; }
{integer}	{ yylval = strdup(yytext); return INTEGER; }




\n      { return EOL; }
"//".*  
[ \t]   { /* ignore white space */ }
%%