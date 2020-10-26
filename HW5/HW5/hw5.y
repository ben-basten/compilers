%{
#include <iostream>
#include <string>
#include <cstring>
#include "Node.h"
#include "Type.h"
using namespace std;

int yylex ();
int isValidIdentifier(char *id);
void storeInteger(int val, int offset);
void storeFloat(float val, int offset);
void printInt(int val);
void printString(string val);
void printFloat(string val);
void printIdentifier(int offset);
void yyerror (const char *er);

Node *dataList = nullptr; // keeps list of strings to print in .data section
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
                             dataList->printData();
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
           | IDENTIFIER '=' FLOAT { int offset = isValidIdentifier($1);
                                    if(offset != -1) {
                                        storeFloat($3, offset);
                                    } 
                                  }
           | IDENTIFIER '=' INT { int offset = isValidIdentifier($1);
                                  if(offset != -1) {
                                        storeInteger($3, offset);
                                  } 
                                }
           | IDENTIFIER '=' IDENTIFIER { isValidIdentifier($1);
                                         isValidIdentifier($3); }
           ;

DECLARATION : ENTIER VARLIST { /* defines an integer */ }
            | REEL VARLIST { /* defines a float */ }
            ;

VARLIST : IDENTIFIER { varList = new Node ($1, static_cast<Type>($<i>0), varList); }
        | VARLIST ',' IDENTIFIER { varList = new Node ($3, static_cast<Type>($<i>0), varList); }
        ;

PRINT : ECRIVEZ '(' PRINTABLE ')' {}
      | error ')' { yyerrok; }
      ; 

PRINTABLE : INT { printInt($1); } 
          | STRING { printString(string($1)); }
          | FLOAT { printFloat(to_string($1)); }
          | IDENTIFIER { int offset = isValidIdentifier($1);
                         if(offset != -1) {
                                printIdentifier(offset);
                         } 
                       }
          ;

%%

// returns the offset if it is declared, or -1 if not
int isValidIdentifier(char *id) {
        int offset = -1;
        bool isEmpty = (varList == nullptr);
        if(!isEmpty) offset = varList->findOffset(id);
        if(!(!isEmpty && offset != -1)) {
                string errMsg = "Identifier \"" + string(id) + "\" has not been declared yet in this scope.";
                yyerror(errMsg.c_str());
                return -1;
        } 
        return offset;
}

void storeInteger(int val, int offset) {
        cout << "\tli $t0," << val << endl;
        cout << "\tsw $t0,-" << offset << "($fp)" << endl;
}

void storeFloat(float val, int offset) {
        dataList = new Node (strdup(to_string(val).c_str()), Type::FLOAT_TYPE, dataList);
        cout << "\tl.s $f0," << dataList->getUniqueName() << endl;
        cout << "\ts.s $f0,-" << offset << "($fp)" << endl;
}

void printInt(int val) {
        cout << "\tli $v0,1" << endl;
        cout << "\tli $a0," << val << endl;
        cout << "\tsyscall" << endl;
}

void printString(string val) {
        string noQuotes = val.substr(1, val.length() - 2);
        dataList = new Node (strdup(noQuotes.c_str()), Type::STRING_TYPE, dataList);
        cout << "\tli $v0,4" << endl;
        cout << "\tla $a0," << dataList->getUniqueName() << endl;
        cout << "\tsyscall" << endl;
}

void printFloat(string val) {
        dataList = new Node (strdup(val.c_str()), Type::STRING_TYPE, dataList);
        cout << "\tli $v0,4" << endl;
        cout << "\tla $a0," << dataList->getUniqueName() << endl;
        cout << "\tsyscall" << endl;
}

void printIdentifier(int offset) {
        Node *var = varList->getNode(offset);
        switch(var->getType()) {
                case Type::INT_TYPE:
                        cout << "\tli $v0,1" << endl;
                        cout << "\tlw $a0,-" << var->getOffset() << "($fp)" << endl;
                        cout << "\tsyscall" << endl;
                        break;
        }
}

void yyerror (const char *er) {
        cerr << "Error on line " << lineno << ": " << er << endl;
}