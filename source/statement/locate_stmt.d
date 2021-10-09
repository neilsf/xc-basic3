module statement.locate_stmt;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

class Locate_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        Expression e;
        for(int i = 0; i <= 1; i++) {
            e = new Expression(this.node.children[0].children[i], compiler);
            e.setExpectedType(compiler.getTypes().get(Type.UINT8));
            e.eval();
            appendCode(e.toString());
        }
        appendCode("    locate\n");
    }
}