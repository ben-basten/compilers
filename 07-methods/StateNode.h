#ifndef _STATENODE_
#define _STATENODE_

class StateNode {
    private:
        bool compiling;
        StateNode *next;

        bool isNodeNotCompiling();
    public:
        StateNode(bool shouldCompile, StateNode *oldList);
        StateNode *pop();
        bool isCompiling();
        bool toggleState();
        int size();
};

#endif