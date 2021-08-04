module statement.goto_stmt;

import pegged.grammar;

import compiler.compiler;
import language.statement;

import std.array;

/** Compiles a GOTO statement */
class Goto_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        string lbl = join(this.node.children[0].children[0].matches);
        if(!compiler.getLabels().exists(lbl)) {
            compiler.displayError("Label \"" ~ lbl ~ "\" unknown in this scope");
        }

        appendCode("    jmp " ~ compiler.getLabels().toAsmLabel(lbl) ~ "\n");
    }
}