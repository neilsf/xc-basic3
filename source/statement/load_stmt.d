module statement.load_stmt;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

class Load_stmt : Statement
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
        expectedTypes[0] = compiler.getTypes().get(Type.STRING);
        expectedTypes[1] = compiler.getTypes().get(Type.UINT8);
        expectedTypes[2] = compiler.getTypes().get(Type.UINT16);
        const ulong argsCount = argList.children.length;
        if(argsCount < 2 || argsCount > 3) {
            compiler.displayError("Wrong number of arguments (expected 2 or 3)");
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
        appendCode("    pbyte 1\n");
        appendCode(e[1].toString()); // device no
        appendCode(argsCount > 2 ? "    pbyte 0\n" : "    pbyte 1\n"); // secondary address, 0=specified, 1=unspecified
        appendCode("    setlfs\n");
        // Address
        if(argsCount > 2) {
            appendCode(e[2].toString());
        }
        // Load
        appendCode("    load " ~ (argsCount > 2 ? "0" : "1") ~ "\n");
    }
}