%{
#include <iostream>
#include <string>
#include <cstring>
#include "Node.h"
#include "Type.h"
#include "OpType.h"
using namespace std;

int yylex ();
int isValidIdentifier(char *id);
void declareVariable(char *identifier, int type);
void storeVariables(int leftOffset, int rightOffset);
void storeInteger(char *val, int offset);
void storeFloat(char *val, int offset);
void doMath(OpType type);
void doUnaryMinus();
void printInt(char *val);
void printString(string val);
void printFloat(char *val);
void printIdentifier(int offset);
void yyerror (const char *er);

Node *dataList = nullptr; // keeps list of strings to print in .data section
Node *varList = nullptr; // symbol table of all of the declared variables
extern int lineno;
%}
%union {
 char *str; //a string in C
 int i;
}


%token ECRIVEZ RIEN COMMENCEMENT 

%token <str> STRING IDENTIFIER FLOAT INT
%token <i> ENTIER REEL
%type <str> PRINTABLE
%type <i> EXPRESSION

%left '+' '-'
%left '*' '/' '%'
%nonassoc UMINUS

%%
MAIN : HEADER COMMANDS '}' { if(varList != nullptr) {
                                cout << "\tadd $sp,$sp," << varList->size() * 4 << endl;
                             }
                             cout << "\tli $v0,10" << endl; // exit system call code
                             cout << "\tsyscall" << endl; 
                             cout << endl << "\t.data" << endl;
                             if(dataList != nullptr) {
                                dataList->printData();
                             }
                           }
     | error '}' { yyerrok; }
     ;

HEADER : RIEN COMMENCEMENT '(' PARAMS ')' '{' { cout << "\t.text" << endl;
                                                cout << "\t.globl main" << endl;
                                                cout << "main:" << endl;
                                                cout << "\tmove $fp,$sp" << endl;
                                                cout << "\tsub $sp,$sp,4" << endl;
                                              }
       | error '{' { yyerrok; }
       ;

PARAMS :
       ;

COMMANDS : COMMANDS COMMAND
         |
         ;

COMMAND : STATEMENT ';'
        | EXPRESSION ';'
        | error ';'
        ;

EXPRESSION : EXPRESSION '+' EXPRESSION { doMath(OpType::ADD); }
           | EXPRESSION '-' EXPRESSION { doMath(OpType::SUB); }
           | EXPRESSION '/' EXPRESSION { doMath(OpType::DIV); } 
           | EXPRESSION '%' EXPRESSION { doMath(OpType::MOD); }
           | EXPRESSION '*' EXPRESSION { doMath(OpType::MULT); }
           | '(' EXPRESSION ')'
           | '-' EXPRESSION %prec UMINUS { doUnaryMinus(); } 
           | '+' EXPRESSION %prec UMINUS
           | INT { cout << "\tli $t0," << $1 << endl;  
                   cout << "\tsub $sp,$sp,4" << endl;
                   cout << "\tsw $t0,($sp)" << endl;
                 }
           | FLOAT
           | IDENTIFIER
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
           | IDENTIFIER '=' IDENTIFIER { int leftOffset, rightOffset;
                                         leftOffset = isValidIdentifier($1);
                                         rightOffset = isValidIdentifier($3);
                                         storeVariables(leftOffset, rightOffset); }
           ;

DECLARATION : ENTIER VARLIST { /* defines an integer */ }
            | REEL VARLIST { /* defines a float */ }
            ;

VARLIST : IDENTIFIER { declareVariable($1, $<i>0); }
        | VARLIST ',' IDENTIFIER { declareVariable($3, $<i>0); }
        ;

PRINT : ECRIVEZ '(' PRINTABLE ')'
      | error ')' { yyerrok; }
      ; 

PRINTABLE : INT { printInt($1); } 
          | STRING { printString(string($1)); }
          | FLOAT { printFloat($1); }
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
                string errMsg = "Identifier \"" + string(id) + "\" has not been declared yet in this scope";
                yyerror(errMsg.c_str());
                return -1;
        } 
        return offset;
}

void declareVariable(char *identifier, int type) {
        if(varList == nullptr || varList->findOffset(identifier) == -1) { // the variable doesn't already exist
                cout << "\tsub $sp,$sp,4" << endl;
                varList = new Node (identifier, static_cast<Type>(type), varList);
        } else {
                string errMsg = "variable redefinition";
                yyerror(errMsg.c_str());
        }  
}

void storeVariables(int leftOffset, int rightOffset) {
        Type leftType = varList->getType(leftOffset);
        Type rightType = varList->getType(rightOffset);

        if(leftType != rightType) {
                cout << "\tl.s $f0,-" << rightOffset << "($fp)" << endl;
                if(rightType == Type::INT_TYPE) {
                        cout << "\tcvt.s.w $f0,$f0" << endl;
                } else if (rightType == Type::FLOAT_TYPE) {
                        cout << "\tcvt.w.s $f0,$f0" << endl;
                }
                cout << "\ts.s $f0,-" << leftOffset << "($fp)" << endl;
        } else {
                cout << "\tlw $t0,-" << rightOffset << "($fp)" << endl; 
                cout << "\tsw $t0,-" << leftOffset << "($fp)" << endl;
        }
}

void storeInteger(char *val, int offset) {
        Type varType = varList->getType(offset);

        cout << "\tli $t0," << val << endl;
        if(varType == Type::INT_TYPE) {
                cout << "\tsw $t0,-" << offset << "($fp)" << endl;
        } else if (varType == Type::FLOAT_TYPE) {
                cout << "\tmtc1 $t0,$f0" << endl;
                cout << "\tcvt.s.w $f0,$f0" << endl;
                cout << "\ts.s $f0,-" << offset << "($fp)" << endl;
        }
}

void storeFloat(char *val, int offset) {
        dataList = new Node (val, Type::FLOAT_TYPE, dataList);
        Type varType = varList->getType(offset);

        cout << "\tl.s $f0," << dataList->getUniqueName() << endl;
        if(varType == Type::INT_TYPE) {
                cout << "\tcvt.w.s $f0,$f0" << endl;
        }
        cout << "\ts.s $f0,-" << offset << "($fp)" << endl;
}

void doMath(OpType type) {
        cout << "\tlw $t1,($sp)" << endl;
        cout << "\tlw $t0,4($sp)" << endl;
        switch(type) {
                case OpType::ADD: 
                        cout << "\tadd $t0,$t0,$t1" << endl;
                        break;
                case OpType::SUB:
                        cout << "\tsub $t0,$t0,$t1" << endl;
                        break;
                case OpType::MULT:
                        cout << "\tmul $t0,$t0,$t1" << endl;
                        break;
                case OpType::DIV:
                        cout << "\tdiv $t0,$t0,$t1" << endl;
                        break;
                case OpType::MOD:
                        cout << "\trem $t0,$t0,$t1" << endl; //modulo
                        break;
        }
        cout << "\tsw $t0,4($sp)" << endl;
        cout << "\tadd $sp,$sp,4" << endl;
}

void doUnaryMinus() {
        cout << "\tsub $sp,$sp,4" << endl;
        cout << "\tsw $t0,($sp)" << endl;
        cout << "\tlw $t0,($sp)" << endl;
        cout << "\tneg $t0,$t0" << endl;
        cout << "\tsw $t0,($sp)" << endl;
}

void printInt(char *val) {
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

void printFloat(char *val) {
        dataList = new Node (val, Type::FLOAT_TYPE, dataList);
        cout << "\tli $v0,2" << endl;
        cout << "\tl.s $f12," << dataList->getUniqueName() << endl;
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
                case Type::FLOAT_TYPE:
                        cout << "\tli $v0,2" << endl;
                        cout << "\tl.s $f12,-" << var->getOffset() << "($fp)" << endl;
                        cout << "\tsyscall" << endl;
                        break;
        }
}

void yyerror (const char *er) {
        cerr << "Error on line " << lineno << ": " << er << endl;
}