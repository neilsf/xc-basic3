module statement.incbin_stmt;

import std.file, std.path, std.string;

import pegged.grammar;

import compiler.compiler;
import language.statement, language.expression;

class Incbin_stmt : Statement
{
     /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        const string fileName = getcwd() ~ dirSeparator ~ join(this.node.children[0].children[0].matches[1..$-1]);
        if(!exists(fileName)) {
            compiler.displayError("File cannot be read: " ~ fileName);
        }
        appendCode("    INCBIN \"" ~ fileName ~ "\"\n");
    }
}