#include <iostream>
#include <string>
#include <cstdlib>
#include <cstring>
#include "Node.h"
#include "Type.h"
using namespace std;

Node::Node(char* newName, Node* oldList) {
	name = newName;
	type = Type::UNDECLARED_TYPE;
	offset = -1;
	next = oldList;
}

Node::Node(char* newName, Type newType, Node* oldList) {
	name = newName;
	type = newType;
	offset = 0; 
	next = oldList;
}

char * Node::getName () {return name;}

Node * Node::getNext () {return next;}
 
void Node::print() {
	cout << name << " - ";
	if(type == Type::INT_TYPE) cout << "int" << endl;
	else cout << "float" << endl;

	if(next != nullptr) next->print();
}

bool Node::isDeclared(char *findMe) {
	if(strcmp(findMe, name) == 0) {
		return true;
	} else if (next != nullptr) {
		return next->isDeclared(findMe);
	} else {
		return false;
	}
}