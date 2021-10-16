module statement.print_stmt;

import std.stdio, std.conv;

import pegged.grammar;

import std.algorithm.searching;

import language.statement, language.expression;
import compiler.compiler, compiler.type;

/** Parses and compiles a PRINT statement */
class Print_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree list = this.node.children[0].children[0];
        foreach (ref child; list) {
            if(child.name == "XCBASIC.Expression") {
                Expression e = new Expression(child, compiler);
                e.eval();
                immutable string asmCode = to!string(e);
                // TODO leave this with the optimizer
                //immutable bool isStaticString = (e.getType().name == Type.STRING && asmCode.count('\n') == 1);
                this.appendCode(asmCode);
                this.appendCode("    print" ~ to!string(e.getType()) ~ "\n");
            }
            else if(child.name == "XCBASIC.TabSep") {
                this.appendCode("    printtab\n");
            }
        }

        if(list.children[$ - 1].name != "XCBASIC.NlSupp") {
            this.appendCode("    printnl\n");
        }
    }
}

/** Compiles a PRINT# statement */
class Print_hash_stmt : Statement
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
            compiler.displayError("PRINT# expects at least 2 parameters, " ~ to!string(exprCount) ~ " provided");
        }
        ParseTree fileNoNode = exprList.children[0];
        Expression fileNoExp = new Expression(fileNoNode, compiler);
        fileNoExp.setExpectedType(compiler.getTypes().get(Type.UINT8));
        fileNoExp.eval();
        appendCode(fileNoExp.toString());
        Expression e;
        bool isLast;
        const bool noEOL = this.node.matches[$-1] != ";";
        for (int i = 1; i < exprCount; i++) {
            e = new Expression(exprList.children[i], compiler);
            e.eval();
            if(!e.getType().isPrimitive) {
                compiler.displayError("User-defined types are not allowed as operands of PRINT#");
            }
            appendCode(e.toString());
            if(e.getType().name != Type.STRING) {
                appendCode("    F_str@_" ~ e.getType().name ~ "\n");
            }
            isLast = i == exprCount - 1 && !noEOL;
            appendCode("    print_hash " ~ (isLast ? "1" : "0") ~ "\n");
        }

    }
}