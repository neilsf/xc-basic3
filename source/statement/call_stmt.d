module statement.call_stmt;

import pegged.grammar;

import compiler.compiler, compiler.type, compiler.routine;
import language.statement, language.factor, language.accessor;

import std.conv, std.array;


/** Compiles a CALL statement */
class Call_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    public void process()
    {
        try {
            AccessorFactory factory = new AccessorFactory(node.children[0].children[0], compiler, false);
            AccessorInterface call = factory.getAccessor();
            if(call.getRoutine().type.name != Type.VOID) {
                compiler.displayError("Only SUBs can be called using the CALL statement");
            }
            appendCode(call.getPushCode());
            if(call.getRoutine() !is null) {
                if(call.getRoutine() == compiler.currentProc) {
                    compiler.currentProc.recursed = true;
                }    
            }
        }
        catch(Exception e) {
            compiler.displayError(e.msg);
        }
    }
}