module statement.charset_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;

import std.algorithm.searching, std.uni;

import globals;

/** Parses and compiles a CHARAT statement */
class Charset_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
	super(node, compiler);
    }

    /** Compile */
    void process()
    {
		string romOrRam = "";
		string expectedTypeName;
		if (canFind(["rom", "ram"], toLower(node.matches[1]))) {
			romOrRam = toLower(node.matches[1]);
			appendCode("    charset" ~ romOrRam ~ "\n");
		}
		Expression e = new Expression(node.children[0].children[0], compiler);
		switch (target) {
			case "x16":
				expectedTypeName = Type.UINT16;
				break;
			
			case "mega65":
				expectedTypeName = Type.INT24;
				break;

			default:
				expectedTypeName = Type.UINT8;
				break;
		}
		e.setExpectedType(compiler.getTypes().get(expectedTypeName));
		e.eval();
		appendCode(e.toString());
		appendCode("    charset\n");
    }
}
