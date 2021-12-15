module compiler.codeblock;

import std.algorithm.mutation, std.algorithm.searching;

/** Represents a nestable code block */
class CodeBlock
{
    static const int TYPE_DO = 0;
    static const int TYPE_FOR = 1;
    static const int TYPE_FUNCTION = 2;
    static const int TYPE_IF = 3;
    
    protected static int idCounter;
    protected int id;
    protected int type;

    /** Class constructor */
    this(int type)
    {
        id = ++idCounter;
        this.type = type;
    }

    /** Getter method for id */
    public int getId()
    {
        return id;
    }

    /** Getter method for type */
    public int getType()
    {
        return type;
    }

    /** Get type as string (for error messages) */
    public string getTypeString()
    {
        switch(type) {
            case TYPE_DO: return "DO";
            case TYPE_FOR: return "FOR";
            case TYPE_FUNCTION: return "FUNCTION";
            case TYPE_IF: return "IF";
            default: return "";
        }
    }
}

/**
 * Simple implementation of a stack used for nested structures, e.g
 * IF, WHILE, FOR, etc
 */
struct Stack
{
    private CodeBlock[] elements;

    /** Push value onto stack */
    void push(CodeBlock block)
    {
        this.elements ~= block;
    }

    /** Pull value off of stack */
    CodeBlock pull()
    {
        if(elements.length == 0) {
            throw new Exception("Stack underflow");
        }
        else {
            CodeBlock top = this.elements[elements.length - 1];
            this.elements = this.elements.remove(elements.length - 1);
            return top;
        }
    }

    /** Read top value of stack without pulling it off */
    CodeBlock top()
    {
        if(elements.length == 0) {
            throw new Exception("Stack empty");
        }
        else {
            return this.elements[elements.length - 1];
        }
    }

    /** Returns the closest element that meets type criterion or null if none found */
    CodeBlock closest(int[] types)
    {
        foreach (CodeBlock key; reverse(elements)) {
            if(any!(type => type == key.getType())(types)) {
                return key;
            }
        }
        return null;
    }

    /** Returns wether the stack is empty */
    bool isEmpty()
    {
        return this.elements.length == 0;
    }
}