%{
#include <iostream>
#include <stdio.h>
#include <fstream>
#include <string>
#include <cstring>
#include <cstdlib>
#include "StateNode.h"
#include "SymbolNode.h"
#include "hw9.tab.h"
using namespace std;

int lineno=1;
const char* activeFile;

YY_BUFFER_STATE buf;
ofstream compilerout;

extern void yyerror (const char *er);

class FileNode {
private:
	const char *nodeFilename;
    YY_BUFFER_STATE bufferState;
    int line;
    FileNode *next;
public:
	FileNode(const char *fn, YY_BUFFER_STATE bs, int newLine, FileNode *oldList) {
        nodeFilename = strdup(fn);
        bufferState = bs; 
        line = newLine;
        next = oldList;
    }

    int size() {
	    if(next == nullptr) return 1;
	    else return 1 + next->size();
    }

    FileNode *pop() {
        FileNode *tempNext = next;
        delete this;
        return tempNext;
    }

    YY_BUFFER_STATE getBufferState() { return bufferState; }

    const char *getFilename() { 
        return nodeFilename; 
    }

    int getLine() { return line; }
};

StateNode *stateStack;      // keeps track of precompiler states
SymbolNode *compilerVars;         // keeps track of compiler variables
FileNode *fileStack;        // keeps track of include files

void openNewFile(const char* filename);
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
<INITIAL,IFFALSE>{fin}      { if(stateStack != nullptr) {
                                stateStack = stateStack->pop();
                              } else {
                                string errMsg = "unmatched #endif";
                                yyerror(errMsg.c_str());
                              } 
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
                              openNewFile(filename.c_str());
                            }                    
{single}    { lineno++; }
{multi}     { IncrementLineNo(yytext); }
{ws}        {}
<INITIAL,IFFALSE>\n          { lineno++; }
.           { return yytext[0]; }
<IFFALSE>.  {}
%%

void openNewFile(const char* filename) {
    activeFile = strdup(filename);

    FILE *f = fopen (activeFile,"r");
    buf = yy_create_buffer (f,YY_BUF_SIZE);
    fileStack = new FileNode(activeFile, buf, lineno, fileStack);
    yy_switch_to_buffer (buf);
    lineno = 1;
}

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
    if(fileStack->size() > 1) {
        fileStack = fileStack->pop();

        YY_BUFFER_STATE newBuf = fileStack->getBufferState();
        yy_switch_to_buffer (newBuf);
        yy_delete_buffer(buf);
        buf = newBuf;

        activeFile = fileStack->getFilename();
        FILE *f = fopen (activeFile,"r");

        lineno = fileStack->getLine();
        return 0;
    } else {
        return 1;
    }
}

int main (int argc, char **argv) {
    if(argc < 3) {
        cerr << "Missing filenames for the input and output." << endl;
        return 1;
    }
    
    openNewFile(argv[1]);

    // redirecting cout to the file
    compilerout.open (argv[2]);
    cout.rdbuf (compilerout.rdbuf());

    yyparse();

    fclose(stdin);

    return 0;
}