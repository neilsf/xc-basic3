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
                                "Loop_stmt", "Cont_stmt", "Exit_do_stmt", "For_stmt", "Next_stmt", "Exit_for_stmt",
                                "Data_stmt", "Rem_stmt", "Swap_stmt", "Randomize_stmt", "On_stmt", "Error_stmt",
                                "Open_stmt", "Get_stmt", "Close_stmt", "Asm_stmt", "Endasm_stmt", "Incbin_stmt",
                                "Input_stmt", "Locate_stmt", "Load_stmt", "Save_stmt", "Memset_stmt",
                                "Memcpy_stmt", "Memshift_stmt", "Origin_stmt", "End_stmt", "Poke_stmt", "Sys_stmt",
                                "Write_stmt", "Read_stmt", "Charat_stmt", "Screen_stmt", "Textat_stmt",
                                "Wait_stmt", "Option_stmt", "Sprite_stmt", "Sprite_multicolor_stmt", "Sprite_clearhit_stmt",
                                "Border_stmt", "Background_stmt", "Scroll_stmt", "VMode_stmt"]) {
            mixin("case \"XCBASIC." ~ key ~"\": return new " ~ key ~ "(node, compiler);");
        }    
        default:
            compiler.displayError("Not implemented: " ~ stmtClass);
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
        const string labels = compiler.getAndClearCurrentLabels();
        if(labels != "\n") {
            this.compiler.getImCode().appendProgramSegment(labels);    
        }
    }
}