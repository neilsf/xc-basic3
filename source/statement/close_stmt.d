module statement.close_stmt;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

/** Compiles a CLOSE statement */
class Close_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        Expression e = new Expression(this.node.children[0].children[0], compiler);
        e.setExpectedType(compiler.getTypes().get(Type.UINT8));
        e.eval();
        appendCode(e.toString());
        appendCode("    close\n");
    }
}