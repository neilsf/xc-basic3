module statement.poke_stmt;

import std.conv;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

class Poke_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    void process()
    {
        ParseTree addrNode = this.node.children[0].children[0];
        ParseTree valueNode = this.node.children[0].children[1];
        Expression e1 = new Expression(addrNode, compiler);
        e1.setExpectedType(compiler.getTypes().get(Type.UINT16));
        e1.eval();
        Expression e2 = new Expression(valueNode, compiler);
        e2.setExpectedType(compiler.getTypes().get(Type.UINT8));
        e2.eval();
        appendCode(e2.toString());
        if(e1.isConstant()) {
            appendCode("    poke_constaddr $" ~ to!string(to!int(e1.getConstVal()), 16) ~ "\n");
        }
        else {
            appendCode(e1.toString());
            appendCode("    poke\n");
        }
    }
}