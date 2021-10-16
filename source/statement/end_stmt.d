module statement.end_stmt;

import pegged.grammar;

import compiler.compiler;
import language.statement;

class End_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        appendCode("    xend\n");
    }
}