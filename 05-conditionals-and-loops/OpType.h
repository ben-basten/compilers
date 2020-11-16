#ifndef _OPTYPE_
#define _OPTYPE_
enum class OpType : char {
	ADD = 1,
    SUB,
    MULT,
    DIV,
    MOD,
    LT,         // less than
    GT,         // greater than
    LTE,        // less than or equal to
    GTE,        // greater than or equal to
    EQUAL,      // equal to
    NEQUAL,     // not equal to
    AND,
    OR
};
#endif