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

	if(next != nullptr) offset = next->getOffset() + 4;
}

Node * Node::getNext () {return next;}

int Node::getOffset () {return offset;}

Type Node::getType() {return type;}

string Node::getUniqueName() {return uniqueName;}
 
void Node::print() {
	cout << data << " - ";
	if(type == Type::INT_TYPE) cout << "int" << endl;
	else cout << "float" << endl;

	if(next != nullptr) next->print();
}

void Node::printData() {
	if(type == Type::STRING_TYPE) {
		cout << uniqueName << ":\t.asciiz \"" << data << "\"" << endl;
	} else if (type == Type::FLOAT_TYPE) {
		cout << uniqueName << ":\t.float " << data << endl;
	}

	if(next != nullptr) next->printData();
}

int Node::size() {
	if(next == nullptr) return 1;
	else return 1 + next->size();
}

bool Node::isDeclared(char *findMe) {
	if(strcmp(findMe, data) == 0) {
		return true;
	} else if (next != nullptr) {
		return next->isDeclared(findMe);
	} else {
		return false;
	}
}