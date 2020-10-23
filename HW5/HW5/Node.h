#ifndef _NODE_
#define _NODE_

#include "Type.h"

class Node {
private:
	char* name;
	Type type;
	//char* type;
	int offset;
	Node* next;
public:
	Node(char* newName, Node* oldList);
	Node(char* newName, Type type, Node* oldList);
    char * getName();
	Node * getNext();
	void print();
	bool isDeclared(char *findMe);
};


#endif