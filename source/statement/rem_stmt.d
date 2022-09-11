module statement.rem_stmt;

import std.regex, std.conv;
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
                string replaceVariable(Captures!(string) m) {
                    Variable v = compiler.getVars().findVisible(m.hit[1..$-1]);
                    if(!(v is null)) {
                        if(v.isConst) {
                            return to!string(v.constVal);
                        }
                        return v.getAsmLabel();
                    }
                    return m.hit;
                }
                string line = node.children[0].matches[1][1..$];
                auto r = regex(r"\{[a-zA-Z_0-9]+\}");
                line = replaceAll!(replaceVariable)(line, r);
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
