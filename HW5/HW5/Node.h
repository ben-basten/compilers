#ifndef _NODE_
#define _NODE_

#include <string>
#include "Type.h"

class Node {
private:
	char* data; // stores variable names or data list values
	float flData;
	std::string uniqueName; 
	Node* next;
	int offset = 4;
	Type type;

	void toLower(char *&val);
public:
	Node(char* newData, Type newType, Node* oldList);
	Node(float newData, Node* oldList);
	Node * getNext();
	int getOffset();
	Type getType();
	Type getType(int offset);
	std::string getUniqueName();
	int size();
	int findOffset(char *findMe); // returns offset if variable is found, -1 if not found
	Node *getNode(int findOffset);
	void printData();
};


#endif