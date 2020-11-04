%{
#include <iostream>
#include <string>
#include <cstring>
#include "Node.h"
using namespace std;

int yylex ();
void yyerror (const char *er);

int strct=0;
Node *strlist = nullptr;
extern int lineno;
%}
%union {

 char *str; //a string in C
 int i;
}


%token ECRIVEZ RIEN
%token <str> FLOATING INTEGER STRING IDENTIFIER

%type <str> PRINTABLE

%%
MAIN : HEADER COMMANDS '}' { cout << "\tli $v0,10" << endl; // exit system call code
                             cout << "\tsyscall" << endl; 
                             cout << endl << "\t.data" << endl;
                             for(int i = strct; i>0;i--) {
                                cout << "str" << i << ":\t.asciiz \"" << strlist->gets() << "\"" << endl;
                                strlist = strlist->getnext();
                             }
                           }
     | error '}' { yyerrok; }
     ;

HEADER : RIEN IDENTIFIER '(' PARAMS ')' '{' { cout << "\t.text" << endl;
                                              cout << "\t.globl main" << endl;
                                              cout << "main:" << endl;}
       | error '{' { yyerrok; }
       ;

PARAMS :
       ;

COMMANDS : COMMANDS COMMAND
         |
         ;

COMMAND : PRINT ';' 
        | error ';' { yyerrok; }
        ;

PRINT : ECRIVEZ '(' PRINTABLE ')' { strct++;
                                    cout << "\tli $v0,4" << endl;
                                    cout << "\tla $a0,str" << strct << endl;
                                    cout << "\tsyscall" << endl; 
                                    strlist = new Node ($3, strlist); }
      | error ')' { yyerrok; }
      ; 

PRINTABLE : INTEGER 
          | STRING { string text = string($1);
                     text = text.substr(1, text.length() - 2);
                     $$ = _strdup(text.c_str()); }
          | FLOATING
          ;

%%
void yyerror (const char *er) {
    cerr << "Error on line " << lineno << ": " << er << endl;
}