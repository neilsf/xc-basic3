module statement.on_stmt;

import std.string, std.conv;
import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

/** Compiles an ON .. GOTO / GOSUB statement */
class On_stmt : Statement
{
    private static int counter = 0;

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
        counter++;
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
            Expression ex = new Expression(e1, compiler);
            ex.setExpectedType(compiler.getTypes().get(Type.UINT8));
            ex.eval();
            appendCode(ex.toString());
            const string ctr = to!string(counter);
            appendCode("    on" ~ branchType ~ " _ON_LB" ~ ctr ~ ", _ON_HB" ~ ctr ~ "\n");
            if(branchType == "gosub") {
                appendCode("    jmp _ON_END" ~ ctr ~ "\n");
            }
            string[] lbs, hbs;
            for(int i = 2; i < args.length; i++) {
                string lbl = join(args[i].matches);
                if(!compiler.getLabels().exists(lbl)) {
                    compiler.displayError("Label does not exist: " ~ lbl);
                }
                lbl = compiler.getLabels().toAsmLabel(lbl);
                lbs ~= "<" ~ lbl; hbs ~= ">" ~ lbl;
            }
            appendCode("_ON_LB" ~ ctr ~ " DC.B " ~ lbs.join(",") ~ "\n");
            appendCode("_ON_HB" ~ ctr ~ " DC.B " ~ hbs.join(",") ~ "\n");
            appendCode("_ON_END" ~ ctr ~ "\n");
        }   
    }
}