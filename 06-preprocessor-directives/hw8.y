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
void assignVariable(char *identifier, Type rightType);
int doMath(OpType type, Type leftType, Type rightType);
void doComparison(OpType type, Type leftType, Type rightType);
void doUnaryMinus(Type numType);
void skipAndOr(OpType opType, int count);
void printExpression(Type exprType);
void printString(string val);
void printIdentifier(int offset);
void yyerror (const char *er);

Node *dataList = nullptr; // keeps list of strings to print in .data section
Node *varList = nullptr; // symbol table of all of the declared variables
extern int lineno;
int labelCount = 0;
int scopeLevel = 0;

%}
%union {
 char *str; //a string in C
 int i;
}


%token ECRIVEZ RIEN COMMENCEMENT SINON LE GE EQ NEQ
%token <str> STRING IDENTIFIER FLOAT INT
%token <i> ENTIER REEL SI PENDANT AND OR

%type <i> EXPRESSION

%left OR
%left AND
%left EQ NEQ
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/' '%'

%nonassoc UMINUS
%nonassoc LOWER_THAN_SINON
%nonassoc SINON

%%
MAIN : HEADER STATEMENTS '}' { if(varList != nullptr) {
                                cout << "\tadd $sp,$sp," << varList->size() * 4 << endl;
                             }
                             scopeLevel--;
                             cout << "\tli $v0,10" << endl; // exit system call code
                             cout << "\tsyscall" << endl; 
                             cout << endl << "\t.data" << endl;
                             if(dataList != nullptr) {
                                dataList->printData();
                             }
                           }
     | error '}' { yyerrok; }
     ;

HEADER : RIEN COMMENCEMENT '(' PARAMS ')' '{' { scopeLevel++;
                                                cout << "\t.text" << endl;
                                                cout << "\t.globl main" << endl;
                                                cout << "main:" << endl;
                                                cout << "\tmove $fp,$sp" << endl;
                                              }
       | error '{' { yyerrok; }
       ;

PARAMS :
       ;

STATEMENTS : STATEMENTS STATEMENT
           |
           ;

STATEMENT : DECLARATION ';' { if(scopeLevel > 1) {
                                string errMsg = "internal variable declaration";
                                yyerror(errMsg.c_str());
                              }  
                            }
          | ASSIGNMENT ';'
          | PRINT ';'
          | IF
          | WHILE
          | '{' { scopeLevel++; } STATEMENTS '}' { scopeLevel--; }
          | error ';'
          ;

EXPRESSION : EXPRESSION '+' EXPRESSION { $$ = doMath(OpType::ADD, static_cast<Type>($1), static_cast<Type>($3)); }
           | EXPRESSION '-' EXPRESSION { $$ = doMath(OpType::SUB, static_cast<Type>($1), static_cast<Type>($3)); }
           | EXPRESSION '/' EXPRESSION { $$ = doMath(OpType::DIV, static_cast<Type>($1), static_cast<Type>($3)); } 
           | EXPRESSION '%' EXPRESSION { $$ = doMath(OpType::MOD, static_cast<Type>($1), static_cast<Type>($3)); }
           | EXPRESSION '*' EXPRESSION { $$ = doMath(OpType::MULT, static_cast<Type>($1), static_cast<Type>($3)); }
           | '(' EXPRESSION ')' { $$ = $2; }
           | '-' EXPRESSION %prec UMINUS { doUnaryMinus(static_cast<Type>($2));
                                           $$ = $2; 
                                         } 
           | '+' EXPRESSION %prec UMINUS { $$ = $2; }
           | INT { $$ = 1;
                   cout << "\tli $t0," << $1 << endl;  
                   cout << "\tsub $sp,$sp,4" << endl;
                   cout << "\tsw $t0,($sp)" << endl;
                 }
           | FLOAT { $$ = 2;
                     dataList = new Node ($1, Type::FLOAT_TYPE, dataList);
                     cout << "\tl.s $f0," << dataList->getUniqueName() << endl;
                     cout << "\tsub $sp,$sp,4" << endl;
                     cout << "\ts.s $f0,($sp)" << endl;
                   }
           | IDENTIFIER { int offset = isValidIdentifier($1); 
                          if (offset != -1) {
                                Type type = varList->getType(offset);
                                if(type == Type::INT_TYPE) {
                                        $$ = 1;
                                        cout << "\tlw $t0,-" << offset << "($fp)" << endl;
                                        cout << "\tsub $sp,$sp,4" << endl;
                                        cout << "\tsw $t0,($sp)" << endl;
                                } else if (type == Type::FLOAT_TYPE) {
                                        $$ = 2;
                                        cout << "\tl.s $f0,-" << offset << "($fp)" << endl;
                                        cout << "\tsub $sp,$sp,4" << endl;
                                        cout << "\ts.s $f0,($sp)" << endl;
                                }
                          }
                        }
           | EXPRESSION '<' EXPRESSION { $$ = 1; doComparison(OpType::LT, static_cast<Type>($1), static_cast<Type>($3)); }
           | EXPRESSION '>' EXPRESSION { $$ = 1; doComparison(OpType::GT, static_cast<Type>($1), static_cast<Type>($3)); }
           | EXPRESSION LE EXPRESSION { $$ = 1; doComparison(OpType::LTE, static_cast<Type>($1), static_cast<Type>($3)); }
           | EXPRESSION GE EXPRESSION { $$ = 1; doComparison(OpType::GTE, static_cast<Type>($1), static_cast<Type>($3)); }
           | EXPRESSION EQ EXPRESSION { $$ = 1; doComparison(OpType::EQUAL, static_cast<Type>($1), static_cast<Type>($3)); }
           | EXPRESSION NEQ EXPRESSION { $$ = 1; doComparison(OpType::NEQUAL, static_cast<Type>($1), static_cast<Type>($3)); }
           | EXPRESSION AND { labelCount++; $2 = labelCount; skipAndOr(OpType::AND, $2); } EXPRESSION { $$ = 1; cout << "_skipand" << $2 << ":" << endl; }
           | EXPRESSION OR { labelCount++; $2 = labelCount; skipAndOr(OpType::OR, $2); } EXPRESSION { $$ = 1; cout << "_skipor" << $2 << ":" << endl; }
           | '!' '(' EXPRESSION ')' { $$ = 1;
                                      cout << "\tlw $t0,($sp)" << endl;
                                      cout << "\tseq $t0,$t0,0" << endl;
                                      cout << "\tsw $t0,($sp)" << endl;
                                    }
           ;

DECLARATION : ENTIER VARLIST { /* defines an integer */ }
            | REEL VARLIST { /* defines a float */ }
            ;

VARLIST : IDENTIFIER { declareVariable($1, $<i>0); }
        | VARLIST ',' IDENTIFIER { declareVariable($3, $<i>0); }
        ;

ASSIGNMENT : IDENTIFIER '=' EXPRESSION { assignVariable($1, static_cast<Type>($3)); }
           ;

IF : SI '(' EXPRESSION ')' FALSEIF STATEMENT { cout << "_falseif" << $1 << ":" << endl; } %prec LOWER_THAN_SINON
   | SI '(' EXPRESSION ')' FALSEIF STATEMENT SINON { cout << "\tb _endif" << $1 << endl; cout << "_falseif" << $1 << ":" << endl; } STATEMENT { cout << "_endif" << $1 << ":" << endl; }
   ;

FALSEIF : { labelCount++;
            $<i>-3 = labelCount;
            cout << "\tlw $t0,($sp)" << endl;
            cout << "\tadd $sp,$sp,4" << endl;
            cout << "\tbeq $t0,0,_falseif" << labelCount << endl; } 
        ;

WHILE : PENDANT COUNTWHILE '(' EXPRESSION ')' ENDWHILE STATEMENT { cout << "\tb _begwhile" << $1 << endl; cout << "_endwhile" << $1 << ":" << endl; }
      | error '}'
      ;

COUNTWHILE : { labelCount++;
               $<i>0 = labelCount; 
               cout << "_begwhile" << labelCount << ":" << endl; 
             }
         ;

ENDWHILE : { cout << "\tlw $t0,($sp)" << endl;
             cout << "\tadd $sp,$sp,4" << endl;
             cout << "\tbeq $t0,0,_endwhile" << $<i>-4 << endl; }
         ;

PRINT : ECRIVEZ '(' STRING ')' { printString(string($3)); }
      | ECRIVEZ '(' EXPRESSION ')' { printExpression(static_cast<Type>($3)); }
      | error ')' { yyerrok; }
      ; 

%%

// returns the offset if it is declared, or -1 if not
int isValidIdentifier(char *id) {
        int offset = -1;
        bool isEmpty = (varList == nullptr);
        if(!isEmpty) offset = varList->findOffset(id);
        if(!(!isEmpty && offset != -1)) {
                string errMsg = "identifier \"" + string(id) + "\" has not been declared yet in this scope";
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

void assignVariable(char *identifier, Type rightType) {
        int offset = isValidIdentifier(identifier);
        if (offset != -1) {
                Type leftType = varList->getType(offset);
                if(leftType == Type::INT_TYPE && rightType == Type::INT_TYPE) {
                        cout << "\tlw $t0,($sp)" << endl;
                        cout << "\tsw $t0,-" << offset << "($fp)" << endl;
                } else if (leftType == Type::FLOAT_TYPE && rightType == Type::FLOAT_TYPE) {
                        cout << "\tl.s $f0,($sp)" << endl;
                        cout << "\ts.s $f0,-" << offset << "($fp)" << endl;
                } else if (leftType == Type::INT_TYPE && rightType == Type::FLOAT_TYPE)  {
                        cout << "\tl.s $f0,($sp)" << endl;
                        cout << "\tcvt.w.s $f0,$f0" << endl;
                        cout << "\ts.s $f0,-" << offset << "($fp)" << endl;
                } else { // left type = float, right type = int
                        cout << "\tl.s $f0,($sp)" << endl;
                        cout << "\tcvt.s.w $f0,$f0" << endl;
                        cout << "\ts.s $f0,-" << offset << "($fp)" << endl;
                }
                cout << "\tadd $sp,$sp,4" << endl; //pop the expression off the stack
        }
}

// returns an integer of the resulting type
int doMath(OpType op, Type leftType, Type rightType) {
        int finalType = -1;

        if(leftType == Type::INT_TYPE && rightType == Type::INT_TYPE) {
                finalType = 1;
                cout << "\tlw $t1,($sp)" << endl;
                cout << "\tlw $t0,4($sp)" << endl;
                switch(op) {
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
        } else if (op == OpType::MOD) {
                string errMsg = "modulo can only be performed on integer types";
                yyerror(errMsg.c_str());
        } else { // at least one of the operands is a float
                finalType = 2;
                cout << "\tl.s $f2,($sp)" << endl;
                cout << "\tl.s $f0,4($sp)" << endl;
                if (leftType == Type::FLOAT_TYPE && leftType != rightType) { // left side = float, ride side = int
                        cout << "\tcvt.s.w $f2,$f2" << endl;
                } else if (rightType == Type::FLOAT_TYPE && leftType != rightType) { // left side = int, right side = float
                        cout << "\tcvt.s.w $f0,$f0" << endl;
                }
                switch(op) {
                        case OpType::ADD: 
                                cout << "\tadd.s $f0,$f0,$f2" << endl;
                                break;
                        case OpType::SUB:
                                cout << "\tsub.s $f0,$f0,$f2" << endl;
                                break;
                        case OpType::MULT:
                                cout << "\tmul.s $f0,$f0,$f2" << endl;
                                break;
                        case OpType::DIV:
                                cout << "\tdiv.s $f0,$f0,$f2" << endl;
                                break;
                }
                cout << "\ts.s $f0,4($sp)" << endl;
                cout << "\tadd $sp,$sp,4" << endl;
        }
        return finalType;
}

void doComparison(OpType opType, Type leftType, Type rightType) {
        if(leftType == Type::INT_TYPE && rightType == Type::INT_TYPE) {
                cout << "\tlw $t1,($sp)" << endl;
                cout << "\tlw $t0,4($sp)" << endl;
                switch (opType) {
                        case OpType::LT:
                                cout << "\tslt $t0,$t0,$t1" << endl;
                                break;       
                        case OpType::GT:
                                cout << "\tsgt $t0,$t0,$t1" << endl;               
                                break;
                        case OpType::LTE:
                                cout << "\tsle $t0,$t0,$t1" << endl;
                                break;
                        case OpType::GTE:
                                cout << "\tsge $t0,$t0,$t1" << endl;
                                break;
                        case OpType::EQUAL:
                                cout << "\tseq $t0,$t0,$t1" << endl;
                                break;
                        case OpType::NEQUAL:
                                cout << "\tsne $t0,$t0,$t1" << endl;
                                break;
                }
                cout << "\tsw $t0,4($sp)" << endl;
                cout << "\tadd $sp,$sp,4" << endl;
        } else {
                labelCount++;
                cout << "\tl.s $f2,($sp)" << endl;
                cout << "\tl.s $f0,4($sp)" << endl;
                if(leftType == Type::FLOAT_TYPE && leftType != rightType) {  // left type float, right type int
                        cout << "\tcvt.s.w $f2,$f2" << endl;
                } else if (rightType == Type::FLOAT_TYPE && rightType != leftType) {
                        cout << "\tcvt.s.w $f0,$f0" << endl;
                }
                switch (opType) {
                        case OpType::LT:
                                cout << "\tc.lt.s $f0,$f2" << endl;
                                break;       
                        case OpType::GT:
                                cout << "\tc.lt.s $f2,$f0" << endl;               
                                break;
                        case OpType::LTE:
                                cout << "\tc.le.s $f0,$f2" << endl;
                                break;
                        case OpType::GTE:
                                cout << "\tc.lt.s $f0,$f2" << endl;
                                break;
                        case OpType::EQUAL:
                                cout << "\tc.eq.s $f0,$f2" << endl;
                                break;
                        case OpType::NEQUAL:
                                // cout << "\tc.ne.s $f0,$f2" << endl;
                                cout << "\terr: != for floats not implemented yet" << endl;
                                break;
                }
                cout << "\tbc1t _cmp" << labelCount << endl;
                cout << "\tli $t0,0" << endl;
                cout << "\tb _aftercmp" << labelCount << endl; 
                cout << "_cmp" << labelCount << ":" << endl; 
                cout << "\tli $t0,1" << endl;
                cout << "_aftercmp" << labelCount << ":" << endl; 
                cout << "\tsw $t0,4($sp)" << endl;
                cout << "\tadd $sp,$sp,4" << endl;
        }
}

void doUnaryMinus(Type numType) {
        if(numType == Type::INT_TYPE) {
                cout << "\tlw $t0,($sp)" << endl;
                cout << "\tneg $t0,$t0" << endl;
                cout << "\tsw $t0,($sp)" << endl;
        } else if (numType == Type::FLOAT_TYPE) {
                cout << "\tl.s $f0,($sp)" << endl;
                cout << "\tneg.s $f0,$f0" << endl;
                cout << "\ts.s $f0,($sp)" << endl;
        }
}

void skipAndOr(OpType opType, int count) {
        cout << "\tlw $t0,($sp)" << endl;
        if (opType == OpType::AND) {
                cout << "\tbeq $t0,0,_skipand" << count << endl;
        } else { // opType == OR
                cout << "\tbne $t0,0,_skipor" << count << endl;
        }
        cout << "\tadd $sp,$sp,4" << endl;
}

void printExpression(Type exprType) {
        if(exprType == Type::INT_TYPE) {
                cout << "\tli $v0,1" << endl;
                cout << "\tlw $a0,($sp)" << endl;
        } else { // exprType == Type::FLOAT_TYPE
                cout << "\tli $v0,2" << endl;
                cout << "\tl.s $f12,($sp)" << endl;
        }
        cout << "\tsyscall" << endl;
        cout << "\tadd $sp,$sp,4" << endl;
}

void printString(string val) {
        string noQuotes = val.substr(1, val.length() - 2);
        dataList = new Node (strdup(noQuotes.c_str()), Type::STRING_TYPE, dataList);
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