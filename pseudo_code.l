%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pseudo_code.tab.h"
%}

%%

[ \t\r\n]+          { /* skip whitespace */ }
[sS][tT][aA][rR][tT]         { return START; }
[eE][nN][dD]                  { return END; }
[dD][eE][cC][lL][aA][rR][eE]  { return DECLARE; }
[iI][nN][pP][uU][tT]          { return INPUT; }
[pP][rR][iI][nN][tT]          { return PRINT; }
[fF][uU][nN][cC][tT][iI][oO][nN] { return FUNCTION; }
[rR][eE][tT][uU][rR][nN]      { return RETURN; }
[iI][fF]                      { return IF; }
[eE][lL][sS][eE]              { return ELSE; }
[wW][hH][iI][lL][eE]          { return WHILE; }
[dD][oO]                      { return DO; }
[fF][oO][rR]                  { return FOR; }

"="            { return EQUAL; }
","            { return ','; }
"("            { return '('; }
")"            { return ')'; }
"{"            { return '{'; }
"}"            { return '}'; }
";"            { return ';'; }
"+"            { return '+'; }
"-"            { return '-'; }
"*"            { return '*'; }
"/"            { return '/'; }
">="           { return GE; }
"<="           { return LE; }
"=="           { return EQ; }
"!="           { return NE; }
">"            { return GT; }
"<"            { return LT; }

[0-9]+         { yylval.num = atoi(yytext); return NUMBER; }
[A-Za-z_][A-Za-z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }

.              { printf("Unknown token: %s\n", yytext); }

%%

int yywrap() { return 1; }
