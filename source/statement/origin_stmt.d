module statement.origin_stmt;

import std.array;


import pegged.grammar;

import compiler.compiler;
import language.statement, language.expression;

class Origin_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        const string address = join(this.node.children[0].children[0].matches);
        appendCode("    org " ~ address ~ "\n");
    }
}