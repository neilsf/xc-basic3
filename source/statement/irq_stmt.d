module statement.irq_stmt;

import std.string, std.conv;
import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

import globals;

class Irq_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        useIrqs = true;
        const string irqType = toUpper(node.matches[0]);
        bool enable = toUpper(node.matches[2]) == "ON";
        appendCode("    irq" ~ (enable ? "en" : "dis") ~ "able IRQ_" ~ irqType ~ " \n");
    }
}