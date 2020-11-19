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

Node::Node(string name, Node *oldList) {
	uniqueName = name;
	next = oldList;
}

Node * Node::getNext () {return next;}

int Node::getOffset () {return offset;}

Type Node::getType() {return type;}

Type Node::getType(int offset) {
	return getNode(offset)->getType();
}

string Node::getUniqueName() { return uniqueName; }

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

bool Node::hasName(string findMe) {
	if(findMe == uniqueName) {
		return true;
	} else if (next != nullptr) {
		return next->hasName(findMe);
	} else {
		return false;
	}
}

Node* Node::getNode(int findOffset) {
	if(offset == findOffset) {
		return this;
	} else {
		return next->getNode(findOffset); // assumes that the node exists
	}
}

Node *Node::remove(std::string name, Node *prev, Node *first) {
	if(name != uniqueName) return next->remove(name, this, first);

	if(prev == nullptr) {
		Node *tempNext = next;
		delete this;
		return tempNext;
	} else {
		prev->next = next;
		delete this;
		return first;
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