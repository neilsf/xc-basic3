module language.accessor;

import std.array, std.uni;
import compiler.compiler, compiler.variable, compiler.routine;
import pegged.grammar;

/** Accessors must specify whether the compiler should stop or try more options */
class AccessorException : Exception
{
    /** Whether compilation should fail with error */
    public bool isFatal = false;

    /** Class constructor */
    @nogc @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null)
    {
        super(msg, file, line, nextInChain);
    }
}

/** Interprets a dot-notation syntax that can represent a variable or a function call as well */
class AccessorFactory
{
    private ParseTree node;
    private Compiler compiler;
    private bool tryVariableAccess;

    /** Can't be interpreted */
    enum TYPE_INVALID    = 0;
    /** Access to a variable */
    enum TYPE_VARACCESS  = 1;
    /** Function call */
    enum TYPE_FNCALL     = 2;
    /** Method call */
    enum TYPE_METHODCALL = 3;
    
    /** Class constructor */
    this(ParseTree node, Compiler compiler, bool tryVariableAccess = true)
    {
        this.node = node;
        this.compiler = compiler;
        this.tryVariableAccess = tryVariableAccess;
    }

    public AccessorInterface getAccessor()
    {
        // Last node is not ()
        ParseTree last;
        try {
            last = node.children[$ - 1];
        } catch (Error e) {
            import std.stdio; writeln(node);
        }
        
        if(last.name == "XCBASIC.Varname") {
            return new VariableAccess(node, compiler);
        }
        
        // TODO To make errors more descriptive, introduce 2 levels
        // of exceptions
        // E. g. Function was not found -> go check if it's a variable access
        //       Function was found but not callable with arguments > stop with error

        try {
            return new MethodCall(node, compiler);
        }
        catch(AccessorException e) {
            if(e.isFatal) {
                throw e;
            }
        }

        try {
            return new RoutineCall(node, compiler);
        }
        catch(AccessorException e) {
             if(e.isFatal) {
                throw e;
            }
        }

        if(tryVariableAccess) {
            return new VariableAccess(node, compiler);
        }

        compiler.displayError("Unknown identifier: " ~ node.matches[0]);
        assert(0);
    }
}