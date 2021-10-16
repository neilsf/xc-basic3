module statement.sys_stmt;

import std.conv;

import std.string;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

class Sys_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    void process()
    {
        const bool isFast = toLower(this.node.children[0].matches[$-1]) == "fast";
        ParseTree addrNode = this.node.children[0].children[0];
        Expression e1 = new Expression(addrNode, compiler);
        e1.setExpectedType(compiler.getTypes().get(Type.UINT16));
        e1.eval();
        if(e1.isConstant) {
            appendCode("    sys_constaddr $" ~ to!string(to!int(e1.getConstVal()), 16) ~ (isFast ? ", 1" : ", 0") ~ "\n");
        }
        else {
            appendCode(e1.toString());
            appendCode("    sys " ~ (isFast ? "1" : "0") ~ "\n");
        }
    }
}