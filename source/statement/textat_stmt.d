module statement.textat_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;

import std.conv, std.format;

import globals;

/** Parses and compiles a TEXTAT statement */
class Textat_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    /** Compile */
    void process()
    {
        ParseTree argList = this.node.children[0].children[0];
        Expression[4] e;
        Type[4] expectedTypes;
        for (int i = 0; i < 4; i++)
        {
            expectedTypes[i] = compiler.getTypes().get(Type.UINT8);
        }
        const ulong argsCount = argList.children.length;
        const ulong minArgsCount = target == "nes" ? 4 : 3;
        const ulong maxArgsCount = target == "nes" ? 5 : 4;
        const int textArgIndex = target == "nes" ? 3 : 2;
        if (argsCount < minArgsCount || argsCount > maxArgsCount)
        {
            compiler.displayError(
				format(
					"Wrong number of arguments (expected %s or %s)",
					minArgsCount,
					maxArgsCount
				)
			);
        }
        for (int i = 0; i < argsCount; i++)
        {
            e[i] = new Expression(argList.children[i], compiler);
            if (i != textArgIndex)
            {
                e[i].setExpectedType(expectedTypes[i]);
            }
            e[i].eval();
        }
        if (!e[textArgIndex].getType().isPrimitive)
        {
            compiler.displayError("TEXTAT supports primitive types only.");
        }
        // Color
        if (argsCount == maxArgsCount)
		{
			appendCode(e[argsCount - 1].toString());
		}
        // Text
        appendCode(e[textArgIndex].toString());
		if (e[textArgIndex].getType().name != Type.STRING)
		{
			// Call STR$() to convert to string 
			appendCode("    F_str@_" ~ e[textArgIndex].getType().name ~ "\n");
		}
		// X and Y
		appendCode(e[target == "nes" ? 1 : 0].toString());
		appendCode(e[target == "nes" ? 2 : 1].toString());
		// Nametable index (NES only)
        if (target == "nes")
        {
			appendCode(e[0].toString());
		}
        appendCode(
			"    textat "
			~ (argsCount == maxArgsCount ? "1" : "0")
			~ "\n"
		);
    }
}
