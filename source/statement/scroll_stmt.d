module statement.scroll_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;

import std.string;

/** Parses and compiles a HSCROLL/VSCROLL statement */
class Scroll_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compile */
    void process()
    {
        ParseTree arg = node.children[0].children[0];
        Expression e = new Expression(arg, compiler);
        e.setExpectedType(compiler.getTypes().get(Type.UINT8));
        e.eval();
        appendCode(e.toString());
        appendCode("    " ~ toLower(node.matches[0]) ~ "scroll\n");
    }
}