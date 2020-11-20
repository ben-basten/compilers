#include <iostream>
#include <string>
#include <cstdlib>
#include <cstring>
#include "SymbolNode.h"
#include "Type.h"
using namespace std;

SymbolNode::SymbolNode(char* newData, Type newType, SymbolNode* oldList) {
	data = newData;
	next = oldList;
	type = newType;

	if(newType == Type::STRING_TYPE) uniqueName = "str" + to_string(size());
	else if (newType == Type::FLOAT_TYPE) uniqueName = "fl" + to_string(size());
	else uniqueName = "error";

	if(next != nullptr) offset = next->getOffset() + 4;
}

SymbolNode::SymbolNode(string name, SymbolNode *oldList) {
	uniqueName = name;
	next = oldList;
}

SymbolNode * SymbolNode::getNext () {return next;}

int SymbolNode::getOffset () {return offset;}

Type SymbolNode::getType() {return type;}

Type SymbolNode::getType(int offset) {
	return getNode(offset)->getType();
}

string SymbolNode::getUniqueName() { return uniqueName; }

int SymbolNode::size() {
	if(next == nullptr) return 1;
	else return 1 + next->size();
}

void SymbolNode::toLower(char *&val) {
	int i = 0;
	char temp;
	while(val[i]) {
		temp = val[i];
		val[i] = tolower(temp);
		i++;
	}
}

int SymbolNode::findOffset(char *findMe) {
	toLower(findMe);
	char* tempData = data;
	toLower(tempData);
	if(strcmp(findMe, tempData) == 0) {
		return offset;
	} else if (next != nullptr) {
		return next->findOffset(findMe);
	} else {
		return -1;
	}
}

bool SymbolNode::hasName(string findMe) {
	if(findMe == uniqueName) {
		return true;
	} else if (next != nullptr) {
		return next->hasName(findMe);
	} else {
		return false;
	}
}

SymbolNode* SymbolNode::getNode(int findOffset) {
	if(offset == findOffset) {
		return this;
	} else {
		return next->getNode(findOffset); // assumes that the node exists
	}
}

SymbolNode *SymbolNode::remove(std::string name, SymbolNode *prev, SymbolNode *first) {
	if(name != uniqueName) return next->remove(name, this, first);

	if(prev == nullptr) {
		SymbolNode *tempNext = next;
		delete this;
		return tempNext;
	} else {
		prev->next = next;
		delete this;
		return first;
	}
}

void SymbolNode::printData() {
	if(type == Type::STRING_TYPE) {
		cout << uniqueName << ":\t.asciiz \"" << data << "\"" << endl;
	} else if (type == Type::FLOAT_TYPE) {
		cout << uniqueName << ":\t.float " << data << endl; // assumes there is a value in flData
	}

	if(next != nullptr) next->printData();
}