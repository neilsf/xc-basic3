module statement.rem_stmt;

import std.regex;
import pegged.grammar;
import language.statement, compiler.compiler, compiler.variable;

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
            if(node.children[0].matches.length > 1) {
                string line = node.children[0].matches[1][1..$];
                auto r = regex(r"\{[a-zA-Z_0-9]+\}");
                auto match = matchFirst(line, r);
                if(match) {
                    string varName = match[0][1..$-1];
                    Variable v = compiler.getVars().findVisible(varName);
                    if(!(v is null)) {
                        line = replaceFirst(line, r, v.getAsmLabel());
                    }
                }
                appendCode(line ~ "\n");
            }
        }
    }

    // Leave labels in accu
    override protected void dumpLabels()
    {
        //
    }
}