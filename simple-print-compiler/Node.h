#ifndef _NODE_
#define _NODE_

class Node {
private:
	char* s;
	Node* next;
public:
	Node(char* S, Node* N);
    char * gets();
	Node * getnext();
};




#endif
