module statement.open_stmt;

import std.array, std.conv;

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
        Expression[4] e;
        for(int i = 0; i < list.children.length; i++) {
            e[i] = new Expression(list.children[i], compiler);
            e[i].setExpectedType(compiler.getTypes().get(i < 3 ? Type.UINT8 : Type.STRING));
        }
        if(list.children.length == 4) {
            // SETNAM
            e[3].eval();
            appendCode(e[3].toString());
            appendCode("    strtonullterm\n");
            appendCode("    setnam\n");
        }
    }
}