module statement.on_stmt;

import std.string, std.conv;
import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

import globals;

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
        string branchType;
        const string m1 = node.children[0].matches[1];
        switch(toLower(m1)) {
            case "error":
                branchType = toLower(join(args[0].matches));
                // It must be a GOTO
                if(branchType != "goto") {
                    compiler.displayError("ON ERROR must be followed by GOTO");
                }
                // Only one label allowed
                if(args.length > 2) {
                    compiler.displayError("ON ERROR GOTO must be followed by only one label");
                }
                const string lbl = join(args[1].matches);
                if(lbl == "0") {
                    appendCode("    seterrhandler 0\n") ;
                }
                else {
                    if(!compiler.getLabels().exists(lbl)) {
                        compiler.displayError("Label " ~ lbl ~ " does not exist");
                    }
                    appendCode("    seterrhandler " ~ compiler.getLabels().toAsmLabel(lbl) ~ "\n") ;
                }
                break;

            case "timer":
            case "sprite":
            case "background":
                useIrqs = true;
                branchType = toLower(join(args[0].matches));
                // It must be a GOSUB
                if(branchType != "gosub") {
                    compiler.displayError("ON " ~ toUpper(m1) ~ " must be followed by GOSUB");
                }
                // Only one label allowed
                if(args.length > 2) {
                    compiler.displayError("ON " ~ toUpper(m1) ~ " GOSUB must be followed by only one label");
                }
                const string lbl = join(args[1].matches);
                if(!compiler.getLabels().exists(lbl)) {
                    compiler.displayError("Label " ~ lbl ~ " does not exist");
                }
                appendCode("    onirqgosub IRQ_" ~ toUpper(m1) ~ ", " ~ compiler.getLabels().toAsmLabel(lbl) ~ "\n");
                break;

            default:
                branchType = toLower(join(args[1].matches));
                ParseTree e1 = args[0];
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
                break;
        } 
    }
}

/** Compiles an ON RASTER n GOSUB statement */
class On_raster_stmt : Statement
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
        ParseTree[] args = this.node.children[0].children;
        ParseTree e1 = args[0];
        Expression rc = new Expression(e1, compiler);
        rc.setExpectedType(compiler.getTypes().get(Type.UINT16));
        rc.eval();
        appendCode(rc.toString());
        const string lbl = join(args[1].matches);
        if(!compiler.getLabels().exists(lbl)) {
            compiler.displayError("Label " ~ lbl ~ " does not exist");
        }
        appendCode("    onirqgosub IRQ_RASTER, " ~ compiler.getLabels().toAsmLabel(lbl) ~ "\n");
    }
}