module statement.exitfun_stmt;

import pegged.grammar;

import language.statement;
import compiler.compiler;

class Exitfun_stmt : Statement
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

        appendCode("    rts\n");
    }
}