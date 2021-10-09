module statement.rem_stmt;

import pegged.grammar;

import language.statement, compiler.compiler;

class Rem_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    public void process()
    {
        if(compiler.inlineAssembly) {
            appendCode(node.children[0].matches[1] ~ "\n");
        }
    }

    // Leave labels in accu
    override protected void dumpLabels()
    {
        //
    }
}