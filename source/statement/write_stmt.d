module statement.write_stmt;

import std.stdio, std.conv;

import pegged.grammar;

import std.algorithm.searching;

import language.statement, language.expression;
import compiler.compiler, compiler.type;

/** Compiles a WRITE# statement */
class Write_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    public void process()
    {
        ParseTree exprList = this.node.children[0].children[0];
        const ulong exprCount = exprList.children.length;
        if(exprCount < 2) {
            compiler.displayError("WRITE# expects at least 2 parameters, " ~ to!string(exprCount) ~ " provided");
        }
        ParseTree fileNoNode = exprList.children[0];
        Expression fileNoExp = new Expression(fileNoNode, compiler);
        fileNoExp.setExpectedType(compiler.getTypes().get(Type.UINT8));
        fileNoExp.eval();
        appendCode(fileNoExp.toString());
        appendCode("    plbytevar R9\n");
        appendCode("    chkout R9\n");
        Expression e;
        for (int i = 1; i < exprCount; i++) {
            e = new Expression(exprList.children[i], compiler);
            e.eval();
            appendCode(e.toString());
            appendCode("    write " ~ to!string(e.getType().length) ~ "\n");
        }
        appendCode("    clrchn\n");
    }
}