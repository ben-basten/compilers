#include <iostream>
#include <string>
#include <cstdlib>
#include <cstring>
#include "Node.h"
using namespace std;

Node::Node(char* S, Node* N) {

	s = S;
	next = N;
}

char * Node::gets () {return s;}

Node * Node::getnext () {return next;}
