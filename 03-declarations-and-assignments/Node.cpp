#include <iostream>
#include <string>
#include <cstdlib>
#include <cstring>
#include "Node.h"
#include "Type.h"
using namespace std;

Node::Node(char* newData, Type newType, Node* oldList) {
	data = newData;
	next = oldList;
	type = newType;

	if(newType == Type::STRING_TYPE) uniqueName = "str" + to_string(size());
	else if (newType == Type::FLOAT_TYPE) uniqueName = "fl" + to_string(size());
	else uniqueName = "error";

	if(next != nullptr) offset = next->getOffset() + 4;
}

Node * Node::getNext () {return next;}

int Node::getOffset () {return offset;}

Type Node::getType() {return type;}

Type Node::getType(int offset) {
	return getNode(offset)->getType();
}

string Node::getUniqueName() {return uniqueName;}

int Node::size() {
	if(next == nullptr) return 1;
	else return 1 + next->size();
}

void Node::toLower(char *&val) {
	int i = 0;
	char temp;
	while(val[i]) {
		temp = val[i];
		val[i] = tolower(temp);
		i++;
	}
}

int Node::findOffset(char *findMe) {
	toLower(findMe);
	if(strcmp(findMe, data) == 0) {
		return offset;
	} else if (next != nullptr) {
		return next->findOffset(findMe);
	} else {
		return -1;
	}
}

Node* Node::getNode(int findOffset) {
	if(offset == findOffset) {
		return this;
	} else {
		return next->getNode(findOffset); // assumes that the node exists
	}
}

void Node::printData() {
	if(type == Type::STRING_TYPE) {
		cout << uniqueName << ":\t.asciiz \"" << data << "\"" << endl;
	} else if (type == Type::FLOAT_TYPE) {
		cout << uniqueName << ":\t.float " << data << endl; // assumes there is a value in flData
	}

	if(next != nullptr) next->printData();
}

/*
// for debugging purposes - prints out what's in the list
void Node::print() {
	cout << data << " - ";
	if(type == Type::INT_TYPE) cout << "int" << endl;
	else cout << "float" << endl;

	if(next != nullptr) next->print();
}
*/