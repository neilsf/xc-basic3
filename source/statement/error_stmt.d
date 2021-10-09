module statement.error_stmt;

import pegged.grammar;

import language.statement, compiler.compiler, language.expression, compiler.type;

class Error_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree[] args = this.node.children[0].children;
        Expression e = new Expression(args[0], compiler);
        e.setExpectedType(compiler.getTypes().get(Type.UINT8));
        e.eval();
        appendCode(e.toString());
        appendCode("    error\n");
    }
}