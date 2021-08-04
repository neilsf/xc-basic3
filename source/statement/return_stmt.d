module statement.return_stmt;

import pegged.grammar;

import compiler.compiler;
import language.statement;

/** Compiles a RETURN statement */
class Return_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        appendCode("    rts\n");
    }
}