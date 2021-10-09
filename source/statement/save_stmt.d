module statement.save_stmt;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

class Save_stmt : Statement
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
        Expression[4] e;
        Type[4] expectedTypes;
        expectedTypes[0] = compiler.getTypes().get(Type.STRING);
        expectedTypes[1] = compiler.getTypes().get(Type.UINT8);
        expectedTypes[2] = compiler.getTypes().get(Type.UINT16);
        expectedTypes[3] = compiler.getTypes().get(Type.UINT16);
        const ulong argsCount = argList.children.length;
        if(argsCount != 4) {
            compiler.displayError("Wrong number of arguments (expected 4)");
        }
        for(int i = 0; i < argsCount; i++) {
            e[i] = new Expression(argList.children[i], compiler);
            e[i].setExpectedType(expectedTypes[i]);
            e[i].eval();
        }
        // Filename
        appendCode(e[0].toString());
        appendCode("    setnam\n");
        // Device no
        appendCode("    pbyte 0\n");
        appendCode(e[1].toString()); // device no
        appendCode("    pbyte 0\n");
        appendCode("    setlfs\n");
        // End address (add one)
        appendCode(e[3].toString());
        appendCode("    pword 1\n");
        appendCode("    addword\n");
        // Start address
        appendCode(e[2].toString());
        // Save
        appendCode("    save\n");
    }
}