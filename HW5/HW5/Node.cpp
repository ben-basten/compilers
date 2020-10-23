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
	offset = 0;
	next = oldList;
}

Node::Node(char* newName, Type newType, Node* oldList) {
	name = newName;
	type = newType;
	offset = 0; // fix this
	next = oldList;
}

char * Node::getName () {return name;}

Node * Node::getNext () {return next;}
