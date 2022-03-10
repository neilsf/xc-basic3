module statement.open_stmt;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

class Open_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree list = this.node.children[0].children[0];
        if(list.children.length < 1) {
            compiler.displayError("At least one parameter must be specified for OPEN");
        }
        Expression[4] e;
        for(int i = 0; i < list.children.length; i++) {
            e[i] = new Expression(list.children[i], compiler);
            e[i].setExpectedType(compiler.getTypes().get(i < 3 ? Type.UINT8 : Type.STRING));
        }
        if(list.children.length == 4) {
            // SETNAM
            e[3].eval();
            appendCode(e[3].toString());
            appendCode("    setnam 1\n");
        }
        else {
            appendCode("    setnam 0\n");
        }
        // logical filenumber
        e[0].eval();
        appendCode(e[0].toString());
        // device number
        if(list.children.length > 1) {
            e[1].eval();
            appendCode(e[1].toString());
        }
        else {
            // defaults to 1
            appendCode("    pbyte 1\n");
        }
        // secondary number
        if(list.children.length > 2) {
            e[2].eval();
            appendCode(e[2].toString());
        }
        else {
            // defaults to 0
            appendCode("    pbyte 0\n");
        }
        
        appendCode("    setlfs\n");
        appendCode("    open\n");
    }
}