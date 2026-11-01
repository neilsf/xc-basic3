module statement.charat_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;

import std.format;

import globals;

/** Parses and compiles a CHARAT statement */
class Charat_stmt : Statement
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
        Expression[5] e;
        Type[5] expectedTypes;
        for (int i = 0; i < 5; i++)
        {
            expectedTypes[i] = compiler.getTypes().get(Type.UINT8);
        }
        const ulong argsCount = argList.children.length;
        const ulong minArgsCount = target == "nes" ? 4 : 3;
        const ulong maxArgsCount = target == "nes" ? 5 : 4;
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
            e[i].setExpectedType(expectedTypes[i]);
            e[i].eval();
        }
        if (target == "nes")
        {	// Argument push order: [color,] sc, x, y, namtbl
			if (argsCount == 5)
			{
				appendCode(e[4].toString());
			}
			appendCode(e[3].toString());
			appendCode(e[1].toString());
			appendCode(e[2].toString());
			appendCode(e[0].toString());
		}
		else
		{	// Argument push order: [color,] sc, x, y
			if (argsCount == 4)
			{
				appendCode(e[3].toString());
			}
			appendCode(e[2].toString());
			appendCode(e[0].toString());
			appendCode(e[1].toString());
		}
        appendCode("    charat "
					~ (argsCount == maxArgsCount ? "1" : "0")
					~ "\n");
    }
}
