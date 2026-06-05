module statement.asm_stmt;

import pegged.grammar;
import compiler.compiler;
import language.statement;

/** Beginning of an ASM block */
class Asm_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process(bool emitLineNumber)
    {
        if (emitLineNumber) {
            this.emitLineNumber();
        }
        compiler.startInlineAssembly();
        appendCode("    ; !!opt_end!!\n");
    }
}

/** End of an ASM block */
class Endasm_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process(bool emitLineNumber)
    {
        if (emitLineNumber) {
            this.emitLineNumber();
        }
        appendCode("    ; !!opt_start!!\n");
        compiler.endInlineAssembly();
    }
}