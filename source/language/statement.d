module language.statement;

import pegged.grammar;
import compiler.compiler;
import std.string, std.conv, std.stdio, std.file, std.path;

import statement;

/** Returns a matching Statement object for an AST node */
Statement stmtFactory(ParseTree node, Compiler compiler) {
	immutable string stmtClass = node.children[0].name;
    switch(stmtClass) {
        static foreach (key; ["Dim_stmt", "Type_stmt", "Field_def", "Endtype_stmt", "Let_stmt",
                                "Print_stmt", "Const_stmt", "Fun_stmt", "Endfun_stmt", "Exitfun_stmt",
                                "If_stmt", "If_sa_stmt", "Else_stmt", "Endif_stmt", "Goto_stmt",
                                "Gosub_stmt", "Call_stmt", "Return_stmt", "Return_fn_stmt", "Do_stmt",
                                "Loop_stmt", "Cont_stmt", "Exit_do_stmt", "For_stmt", "Next_stmt",
                                "Data_stmt", "Rem_stmt", "Swap_stmt"]) {
            mixin("case \"XCBASIC." ~ key ~"\": return new " ~ key ~ "(node, compiler);");
        }    
        default:
            compiler.displayError("Unknown statement: " ~ stmtClass);
            assert(0);
    }
}

interface StatementInterface
{
    /** Compiles given AST to intermediate code */
	public void process();
}

abstract class Statement : StatementInterface
{
	protected ParseTree node;
	protected Compiler compiler;

    /** Class constructor */
	this(ParseTree node, Compiler compiler)
	{
		this.node = node;
		this.compiler = compiler;
        this.dumpLabels();
	}

    protected void appendCode(string code)
    {
        this.compiler.getImCode().appendProgramSegment(code);
    }

    // In normal case the last labels are dumped before each statement
    // but this can be overridden if necessary
    protected void dumpLabels()
    {
        this.compiler.getImCode().appendProgramSegment(compiler.getAndClearCurrentLabels());
    }
}