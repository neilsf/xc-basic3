module statement.poke_stmt;

import std.conv, std.uni;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

import globals;

/** POKE or DOKE command */
class Poke_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    void process()
    {
        const string opCode = toLower(this.node.children[0].matches[0]) ~ (target == "mega65" ? "l" : "");
        const bool isDoke = (opCode[0] == 'd');
        Type addrType = compiler.getTypes().get(target == "mega65" ? Type.INT24 : Type.UINT16);
        ParseTree addrNode = this.node.children[0].children[0];
        ParseTree valueNode = this.node.children[0].children[1];
        Expression e1 = new Expression(addrNode, compiler);
        e1.setExpectedType(addrType);
        e1.eval();
        Expression e2 = new Expression(valueNode, compiler);
        e2.setExpectedType(isDoke ? compiler.getTypes().get(Type.UINT16) : compiler.getTypes().get(Type.UINT8));
        e2.eval();
        appendCode(e2.toString());
        if(e1.isConstant()) {
            appendCode("    " ~ opCode ~ "_constaddr $" ~ to!string(to!int(e1.getConstVal()), 16) ~ "\n");
        }
        else {
            appendCode(e1.toString());
            appendCode("    " ~ opCode ~ "\n");
        }
    }
}