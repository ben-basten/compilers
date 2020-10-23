%{
#include <iostream>
#include <string>
#include <cstring>
#include "Node.h"
#include "Type.h"
using namespace std;

int yylex ();
void yyerror (const char *er);

int strct=0;
Node *stringList = nullptr; // keeps list of strings to print in .data section
Node *varList = nullptr; // symbol table of all of the declared variables
extern int lineno;
%}
%union {
 char *str; //a string in C
 int i;
 float fl;
}


%token ECRIVEZ RIEN COMMENCEMENT 
%token <str> STRING IDENTIFIER
%token <i> INT ENTIER REEL
%token <fl> FLOAT

%type <str> PRINTABLE

%%
MAIN : HEADER COMMANDS '}' { cout << "\tli $v0,10" << endl; // exit system call code
                             cout << "\tsyscall" << endl; 
                             cout << endl << "\t.data" << endl;
                             for(int i = strct; i>0;i--) {
                                cout << "str" << i << ":\t.asciiz \"" << stringList->getName() << "\"" << endl;
                                stringList = stringList->getNext();
                             }
                             varList->print();
                           }
     | error '}' { yyerrok; }
     ;

HEADER : RIEN COMMENCEMENT '(' PARAMS ')' '{' { cout << "\t.text" << endl;
                                              cout << "\t.globl main" << endl;
                                              cout << "main:" << endl;}
       | error '{' { yyerrok; }
       ;

PARAMS :
       ;

COMMANDS : COMMANDS COMMAND
         |
         ;

COMMAND : STATEMENT ';'
        | error ';'
        ;

STATEMENT : DECLARATION
          | ASSIGNMENT
          | PRINT
          ;

ASSIGNMENT : IDENTIFIER '=' STRING
           | IDENTIFIER '=' FLOAT
           | IDENTIFIER '=' INT
           | IDENTIFIER '=' IDENTIFIER
           ;

DECLARATION : ENTIER VARLIST { /* defines an integer */ }
            | REEL VARLIST { /* defines a float */ }
            ;

VARLIST : IDENTIFIER { varList = new Node ($1, static_cast<Type>($<i>0), varList); }
        | VARLIST ',' IDENTIFIER { varList = new Node ($3, static_cast<Type>($<i>0), varList); }
        ;

PRINT : ECRIVEZ '(' PRINTABLE ')' { strct++;
                                    cout << "\tli $v0,4" << endl;
                                    cout << "\tla $a0,str" << strct << endl;
                                    cout << "\tsyscall" << endl; 
                                    stringList = new Node ($3, stringList); }
      | error ')' { yyerrok; }
      ; 

PRINTABLE : INT { string val = to_string($1);
                  $$ = _strdup(val.c_str()); } 
          | STRING { string text = string($1);
                     text = text.substr(1, text.length() - 2);
                     $$ = _strdup(text.c_str()); }
          | FLOAT { string val = to_string($1);
                    $$ = _strdup(val.c_str()); }
          ;

%%

void yyerror (const char *er) {
        cerr << "Error on line " << lineno << ": " << er << endl;
}