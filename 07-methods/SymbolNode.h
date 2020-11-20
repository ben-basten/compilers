#ifndef _SYMBOLNODE_
#define _SYMBOLNODE_

#include <string>
#include "Type.h"

class SymbolNode {
private:
	char* data; // stores variable names or data list values
	std::string uniqueName; 
	SymbolNode* next;
	int offset = 4;
	Type type;

	void toLower(char *&val);
public:
	SymbolNode(char* newData, Type newType, SymbolNode *oldList);
	SymbolNode(std::string name, SymbolNode *oldList);
	SymbolNode * getNext();
	int getOffset();
	Type getType();
	Type getType(int offset);
	std::string getUniqueName();
	int size();
	int findOffset(char *findMe); // returns offset if variable is found, -1 if not found
	bool hasName(std::string findMe);
	SymbolNode *getNode(int findOffset);
	SymbolNode *remove(std::string name, SymbolNode *prev, SymbolNode *first);
	void printData();
};


#endif