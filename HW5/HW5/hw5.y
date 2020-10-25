%{
#include <iostream>
#include <string>
#include <cstring>
#include "Node.h"
#include "Type.h"
using namespace std;

int yylex ();
bool isValidIdentifier(char *id);
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
                                              cout << "main:" << endl;
                                              cout << "\tmove $fp,$sp" << endl; }
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

ASSIGNMENT : IDENTIFIER '=' STRING { isValidIdentifier($1); }
           | IDENTIFIER '=' FLOAT { isValidIdentifier($1); }
           | IDENTIFIER '=' INT { isValidIdentifier($1); }
           | IDENTIFIER '=' IDENTIFIER { isValidIdentifier($1);
                                         isValidIdentifier($3); }
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

PRINTABLE : INT { $$ = _strdup(to_string($1).c_str()); } 
          | STRING { string text = string($1);
                     text = text.substr(1, text.length() - 2);
                     $$ = _strdup(text.c_str()); }
          | FLOAT { $$ = _strdup(to_string($1).c_str()); }
          | IDENTIFIER { if(isValidIdentifier($1)) {
                                /* action code here */
                         } 
                       }
          ;

%%

bool isValidIdentifier(char *id) {
        if(!(varList != nullptr && varList->isDeclared(id))) {
                string errMsg = "Identifier \"" + string(id) + "\" has not been declared yet in this scope.";
                yyerror(errMsg.c_str());
                return false;
        } 
        return true;
}

void yyerror (const char *er) {
        cerr << "Error on line " << lineno << ": " << er << endl;
}