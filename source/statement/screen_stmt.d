module statement.screen_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;

/** Parses and compiles a SCREEN statement */
class Screen_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compile */
    void process()
    {
        ParseTree arg = this.node.children[0].children[0];
        Expression e = new Expression(arg, compiler);
        e.setExpectedType(compiler.getTypes().get(Type.UINT8));
        e.eval();
        appendCode(e.toString());
        appendCode("    screen\n");
    }
}