%{
#include <iostream>
#include <string>
#include <cstring>
#include <cstdlib>
#include "hw8.tab.h"
using namespace std;

int lineno=1;

void IncrementLineNo(string text);
int yyparse();
%}

letter  [A-Za-z]
num     [0-9]
ws      (" "|\t)+
exp     e[-+]?[1-9]+

ecr     [Ee][Cc][Rr][Ii][Vv][Ee][Zz]
rien    [Rr][Ii][Ee][Nn]
ent     [Ee][Nn][Tt][Ii][Ee][Rr]
reel    [Rr][Ee][Ee][Ll]
com     [Cc][Oo][Mm][Mm][Ee][Nn][Cc][Ee][Mm][Ee][Nn][Tt]
pen     [Pp][Ee][Nn][Dd][Aa][Nn][Tt]
si      [Ss][Ii]
sinon   [Ss][Ii][Nn][Oo][Nn]
le      \<=
ge      >=
eq      ==
neq     !=
and     &&
or      \|\|
int     (0|([1-9][0-9]*))
fp      (((0|[1-9][0-9]*)\.[0-9]+{exp}?)|{int}{exp})
var     {letter}({letter}|{num})*
str     \"[^"\n]*\"
single  "//"(.)*\n
multi   "/*"([^*]|((\*)+[^*/]))*\*+\/
%%

{com}       { yylval.str = _strdup(yytext); return COMMENCEMENT; }
{ecr}       { yylval.str = _strdup(yytext); return ECRIVEZ; }
{rien}      { yylval.str = _strdup(yytext); return RIEN; }
{pen}       { yylval.str = _strdup(yytext); return PENDANT; }
{si}        { yylval.str = _strdup(yytext); return SI; }
{sinon}     { yylval.str = _strdup(yytext); return SINON; }
{le}        { yylval.str = _strdup(yytext); return LE; }
{ge}        { yylval.str = _strdup(yytext); return GE; }
{eq}        { yylval.str = _strdup(yytext); return EQ; }
{neq}       { yylval.str = _strdup(yytext); return NEQ; }
{and}       { yylval.str = _strdup(yytext); return AND; }
{or}        { yylval.str = _strdup(yytext); return OR; }
{ent}       { yylval.i = 1; return ENTIER; }
{reel}      { yylval.i = 2; return REEL; }
{fp}        { yylval.str = _strdup(yytext); return FLOAT; }
{int}       { yylval.str = _strdup(yytext); return INT; }
{str}       { yylval.str = _strdup(yytext); return STRING; }
{var}       { yylval.str = _strdup(yytext); return IDENTIFIER; }
{single}    { lineno++; }
{multi}     { IncrementLineNo(yytext); }
{ws}        {}
\n          { lineno++; }
.           { return yytext[0]; }
%%

void IncrementLineNo(string text) {
    for(int i = 0; i < text.length(); i++) {
        if(text[i] == '\n') lineno++;
    }
}

int yywrap () {
    return 1;
}

int main () {
    // yylex(); //Start doing stuff
    yyparse();
    return 0;
}