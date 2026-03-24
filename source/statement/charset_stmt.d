module statement.charset_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;

import std.algorithm.searching, std.uni;

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
	if(canFind(["rom", "ram"], toLower(node.matches[1]))) {
	    appendCode("    charset" ~ toLower(node.matches[1]) ~ "\n");
	}
	Expression e = new Expression(node.children[0].children[0], compiler);
	e.setExpectedType(compiler.getTypes().get(Type.UINT8));
	e.eval();
	appendCode(e.toString());
	appendCode("    charset\n");
    }
}
