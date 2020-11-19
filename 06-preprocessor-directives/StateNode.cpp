#include <iostream>
#include "StateNode.h"
using namespace std;

StateNode::StateNode(bool shouldCompile, StateNode *oldList) {
    compiling = shouldCompile;
    next = oldList;
}

StateNode *StateNode::pop() {
    StateNode *tempNext = next;
    delete this;
    return tempNext;
}

bool StateNode::isCompiling() {
    return compiling;
}

bool StateNode::isNodeNotCompiling() {
    if(!compiling) return true;
    else if (next != nullptr) return next->isNodeNotCompiling();
    return false;
}

bool StateNode::toggleState() {
    if(next != nullptr && next->isNodeNotCompiling()) {
        compiling = false;
        return compiling;
    } else {
        compiling = !compiling;
        return compiling;
    }
}

int StateNode::size() {
    if(next == nullptr) return 1;
    else return 1 + next->size();
}