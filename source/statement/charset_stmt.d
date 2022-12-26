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
    { import std.stdio; writeln(target);
		string romOrRam = "";
		if (canFind(["rom", "ram"], toLower(node.matches[1]))) {
			romOrRam = toLower(node.matches[1]);
			appendCode("    charset" ~ romOrRam ~ "\n");
		}
		Expression e = new Expression(node.children[0].children[0], compiler);
		e.setExpectedType(compiler.getTypes().get((target == "x16") ? Type.UINT16 : Type.UINT8));
		e.eval();
		appendCode(e.toString());
		appendCode("    charset\n");
    }
}
