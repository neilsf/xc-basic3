module statement.on_stmt;

import std.string, std.conv;
import pegged.grammar;

import compiler.compiler;
import language.statement, language.expression;

/** Compiles an ON .. GOTO / GOSUB statement */
class On_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree[] args = this.node.children[0].children;
        ParseTree e1 = args[0];
        const string branchType = toLower(join(args[1].matches));
        if(toLower(join(e1.matches)) == "error") {
            // It must be a GOTO
            if(branchType != "goto") {
                compiler.displayError("ON ERROR must be followed by GOTO");
            }
            // Only one label allowed
            if(args.length > 3) {
                compiler.displayError("ON ERROR GOTO must be followed by only one label");
            }
            const string lbl = join(args[2].matches);
            if(lbl == "0") {
                appendCode("    seterrhandler 0\n") ;
            }
            else {
                if(!compiler.getLabels().exists(lbl)) {
                    compiler.displayError("Label " ~ lbl ~ " does not exist");
                }
                appendCode("    seterrhandler " ~ compiler.getLabels().toAsmLabel(lbl) ~ "\n") ;
            }
            
        }
        else {

        }
    }
}