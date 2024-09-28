module statement.memmove_stmt;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

import globals;

abstract class Memmove_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    abstract protected string getMacroName();

    /** Compiles the statement */
    void process()
    {
        ParseTree argList = this.node.children[0].children[0];
        Expression[3] e;
        Type[3] expectedTypes;
        expectedTypes[0] = expectedTypes[1] = compiler.getTypes().get(
            target == "mega65" ? Type.INT24 : Type.UINT16
        ); // addresses
        expectedTypes[2] = compiler.getTypes().get(Type.UINT16); // length
        const ulong argsCount = argList.children.length;
        if(argsCount != 3) {
            compiler.displayError("Wrong number of arguments (expected 3)");
        }
        for(int i = 0; i < argsCount; i++) {
            e[i] = new Expression(argList.children[i], compiler);
            e[i].setExpectedType(expectedTypes[i]);
            e[i].eval();
        }
        // Number of bytes
        appendCode(e[2].toString());
        // Destination address
        appendCode(e[1].toString());
        // Start address
        appendCode(e[0].toString());
        // Call macro
        appendCode("    " ~ this.getMacroName() ~ "\n");
    }
}

final class Memcpy_stmt : Memmove_stmt
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    override protected string getMacroName()
    {
        return "memcpy";
    }
}

final class Memshift_stmt : Memmove_stmt
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    override protected string getMacroName()
    {
        return "memshift";
    }
}