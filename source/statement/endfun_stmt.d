module statement.endfun_stmt;

import pegged.grammar;

import language.statement;
import compiler.compiler;

class Endfun_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Process the AST of the statement */
    void process()
    {
        if(!compiler.inProcedure) {
            compiler.displayError("Not in function");
        }

        if(!compiler.currentProc.recursed && !compiler.currentProc.getIsStatic()) {
            string type = compiler.currentProc.getIsMethod() ? "Method" : compiler.currentProc.getKeyword();
            compiler.displayWarning(type ~ " \"" ~ compiler.currentProc.getNameWithArgTypes() ~
                "\" never calls itself, consider making it STATIC");
        }

        appendCode("    rts\n    ENDIF\n\n");

        compiler.clearProc();
        compiler.currentProcName = "";
        compiler.currentProc = null;
    }
}