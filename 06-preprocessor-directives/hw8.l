%{
#include <iostream>
#include <stdio.h>
#include <fstream>
#include <string>
#include <cstring>
#include <cstdlib>
#include "StateNode.h"
#include "SymbolNode.h"
#include "hw8.tab.h"
using namespace std;

int lineno=1;

YY_BUFFER_STATE buf;
ofstream compilerout;

StateNode *stateStack;      // keeps track of precompiler states
SymbolNode *compilerVars;         // keeps track of compiler variables
// FileNode *fileStack;        // keeps track of include files

string parseIncludeString(string input);
string parseCompilerVar(string input);
void setState(bool shouldCompile);
void IncrementLineNo(string text);
int yyparse();
int main (int argc, char **argv);
%}

%x IFFALSE

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
psinon  #{sinon}
fin     #[Ff][Ii][Nn]
le      \<=
ge      >=
eq      ==
neq     !=
and     &&
or      \|\|
int     (0|([1-9][0-9]*))
fp      (((0|[1-9][0-9]*)\.[0-9]+{exp}?)|{int}{exp})
var     {letter}({letter}|{num})*
sip     #[Ss][Ii][Pp][Dd][Ee][Ff][ ]{var}
sid     #[Ss][Ii][Dd][Ee][Ff][ ]{var}
def     #[Dd][Ee][Ff][Ii][Nn][Ii][Ss][Ss][Ee][Zz][ ]{var}
undef   #[Uu][Nn][Dd][Ee][Ff][ ]{var}
str     \"[^"\n]*\"
inc     #[Ii][Nn][Cc][Ll][Uu][Ss][Ee][Zz][ ]{str}
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
<INITIAL,IFFALSE>{sip}      { /* IFNDEF */
                              string name = parseCompilerVar(yytext);
                              bool shouldCompile = ((compilerVars != nullptr && !compilerVars->hasName(name)) || compilerVars == nullptr);
                              stateStack = new StateNode(shouldCompile, stateStack);
                              setState(shouldCompile);
                            }
<INITIAL,IFFALSE>{sid}      { /* IFDEF */
                              string name = parseCompilerVar(yytext);
                              bool shouldCompile = !((compilerVars != nullptr &&   !compilerVars->hasName(name)) || compilerVars == nullptr);
                              stateStack = new StateNode(shouldCompile, stateStack);
                              setState(shouldCompile);
                            }
<INITIAL,IFFALSE>{psinon}   {  bool shouldCompile = stateStack->toggleState();
                               setState(shouldCompile);
                            }
<INITIAL,IFFALSE>{fin}      { if(stateStack != nullptr) stateStack = stateStack->pop();
                              else cerr << "Error on line " << lineno << ": unmatched #endif";
                              bool shouldCompile;
                              if(stateStack == nullptr) shouldCompile = true;
                              else shouldCompile = stateStack->isCompiling();
                              setState(shouldCompile);
                            }
<INITIAL,IFFALSE>{def}      { compilerVars = new SymbolNode(parseCompilerVar(yytext), compilerVars); }
<INITIAL,IFFALSE>{undef}    { string name = parseCompilerVar(yytext);
                              if(compilerVars != nullptr && compilerVars->hasName(name)) {
                                  compilerVars = compilerVars->remove(name, nullptr, compilerVars);
                              }
                            }
{inc}                       { string filename = parseIncludeString(yytext);
                            }                    
{single}    { lineno++; }
{multi}     { IncrementLineNo(yytext); }
{ws}        {}
<INITIAL,IFFALSE>\n          { lineno++; }
.           { return yytext[0]; }
<IFFALSE>.  {}
%%

string parseIncludeString(string input) {
    string filename = parseCompilerVar(input);
    return filename.substr(1, filename.length() - 2);
}

string parseCompilerVar(string input) {
    size_t pos = input.find(" ");
    string res = input.substr(pos + 1);
    return res;
}

void setState(bool shouldCompile) {
    if(!shouldCompile) {
        BEGIN IFFALSE;
    } else {
      BEGIN INITIAL;
    } 
}

void IncrementLineNo(string text) {
    for(int i = 0; i < text.length(); i++) {
        if(text[i] == '\n') lineno++;
    }
}

int yywrap () {
    return 1;
}

int main (int argc, char **argv) {
    if(argc < 3) {
        fprintf(stderr, "Please provide filenames for the input and output.\n");
        return 1;
    }
    
    FILE *f = fopen (argv[1],"r");
    buf = yy_create_buffer (f,YY_BUF_SIZE);
    yy_switch_to_buffer (buf);

    // redirecting cout to the file
    compilerout.open (argv[2]);
    cout.rdbuf (compilerout.rdbuf());

    yyparse();

    fclose(stdin);

    return 0;
}