module statement.memset_stmt;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

class Memset_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree argList = this.node.children[0].children[0];
        Expression[3] e;
        Type[3] expectedTypes;
        expectedTypes[0] = compiler.getTypes().get(Type.UINT16);
        expectedTypes[1] = compiler.getTypes().get(Type.UINT16);
        expectedTypes[2] = compiler.getTypes().get(Type.UINT8);
        const ulong argsCount = argList.children.length;
        if(argsCount != 3) {
            compiler.displayError("Wrong number of arguments (expected 3)");
        }
        for(int i = 0; i < argsCount; i++) {
            e[i] = new Expression(argList.children[i], compiler);
            e[i].setExpectedType(expectedTypes[i]);
            e[i].eval();
        }
        // Fill value
        appendCode(e[2].toString());
        // Number of bytes
        appendCode(e[1].toString());
        // Start address
        appendCode(e[0].toString());
        // Call macro
        appendCode("    memset\n");
    }
}