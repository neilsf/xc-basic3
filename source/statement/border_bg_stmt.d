module statement.border_bg_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;
import globals;

import std.conv;

/** Parses and compiles a BORDER or BACKGROUND statement */
abstract class Border_bg_stmt : Statement
{
    abstract protected string macroName(); 

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compile */
    void process()
    {
        ParseTree argList = this.node.children[0].children[0];
        Expression[2] e;
        const ulong reqArgs = (target == "cplus4" || target == "c16") ? 2 : 1;
        const ulong argsCount = argList.children.length;
        if(argsCount != reqArgs) {
            compiler.displayError("Wrong number of arguments (expected max " ~ to!string(reqArgs) ~ ")");
        }
        for(int i = cast(int)argsCount - 1; i >= 0; i--) {
            e[i] = new Expression(argList.children[i], compiler);
            e[i].setExpectedType(compiler.getTypes().get(Type.UINT8));
            e[i].eval();
            appendCode(e[i].toString());    
        }
        appendCode("    " ~ macroName() ~ "\n");
    }
}

class Border_stmt : Border_bg_stmt
{
    override protected string macroName()
    {
        return "border";
    } 

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}
}

class Background_stmt : Border_bg_stmt
{
    override protected string macroName()
    {
        return "background";
    } 

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}
}