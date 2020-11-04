%{
#include <iostream>
using namespace std;

int lineno=1;

void IncrementLineNo(string text);

//multi   \/\*[^*]*\*
%}
letter  [A-Za-z]
num     [0-9]
ws      (" "|\t)+
exp     e[-+]?[1-9]+

int     [-+]?(0|([1-9][0-9]*))
fp      [-+]?(((0|[1-9][0-9]*)\.[0-9]+{exp}?)|{int}{exp})
var     {letter}({letter}|{num})*
str     \"[^"\n]*\"
single  "//"(.)*\n
multi   "/*"([^*]|((\*)+[^*/]))*\*+\/
err     [^\ \n\t]+
%%
{fp} { cout << yytext << " is a floating-point number on line " << lineno << "." << endl; }
{int}   { cout << yytext << " is an integer on line " << lineno << "." << endl; }
{str}   { cout << yytext << " is a string on line " << lineno << "." << endl; }
{var}   { cout << yytext << " is a variable on line " << lineno << "." << endl; }
{err}   { cout << yytext << " is an error on line " << lineno << "." << endl; }
{single} { lineno++; }
{multi} { IncrementLineNo(yytext); }
{ws}
\n  { lineno++; }
%%
int yywrap () {
 /* yywrap indicates what we should do when we reach EOF.
    "return 1" just means we're done */
 return 1;
}

int main () {
  yylex(); //Start doing stuff
}

void IncrementLineNo(string text) {
    for(int i = 0; i < text.length(); i++) {
        if(text[i] == '\n') lineno++;
    }
}