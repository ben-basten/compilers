#ifndef _NODE_
#define _NODE_

#include <string>
#include "Type.h"

class Node {
private:
	char* data; // stores variable names or data list values
	std::string uniqueName; 
	Node* next;
	int offset = 4;
	Type type;

	int size();
public:
	Node(char* newData, Type newType, Node* oldList);
	Node * getNext();
	int getOffset();
	Type getType();
	std::string getUniqueName();
	void print();
	void printData();
	bool isDeclared(char *findMe);
};


#endif