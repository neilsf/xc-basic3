module statement.scroll_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;

import std.string, std.conv;

import globals;

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
        ParseTree args = node.children[0].children[0];
        const ulong expectedArgCount = target == "x16" ? 2 : 1;
        if (args.children.length != expectedArgCount) {
            compiler.displayError("Wrong number of arguments, expected " ~ to!string(expectedArgCount) ~ ", got " ~ to!string(args.children.length));
        }
        ulong ix = 0;
        string layer = "0";
        if (args.children.length == 2) {
            Expression e1 = new Expression(args.children[ix], compiler);
            if (!e1.isConstant()) {
                compiler.displayError("Argument #1 of " ~ toUpper(node.matches[0]) ~ "SCROLL must be a constant 0 or 1");
            }
            ubyte v = to!ubyte(e1.getConstVal());
            if (v > 1 || v < 0) {
                compiler.displayError("Argument #1 of " ~ toUpper(node.matches[0]) ~ "SCROLL must be between 0 or 1");
            }
            layer = to!string(v);
            ix++;
        }
        Expression e2 = new Expression(args.children[ix], compiler);    
        e2.setExpectedType(compiler.getTypes().get(target == "x16" ? Type.UINT16 : Type.UINT8));
        e2.eval();
        appendCode(e2.toString());
        appendCode("    " ~ toLower(node.matches[0]) ~ "scroll " ~ layer ~ "\n");
    }
}