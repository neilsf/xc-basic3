module statement.charat_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;

/** Parses and compiles a CHARAT statement */
class Charat_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compile */
    void process()
    {
        ParseTree argList = this.node.children[0].children[0];
        Expression[4] e;
        Type[4] expectedTypes;
        for(int i = 0; i < 4 ; i++) {
            expectedTypes[i] = compiler.getTypes().get(Type.UINT8);
        }
        const ulong argsCount = argList.children.length;
        if(argsCount < 3 || argsCount > 4) {
            compiler.displayError("Wrong number of arguments (expected 3 or 4)");
        }
        for(int i = 0; i < argsCount; i++) {
            e[i] = new Expression(argList.children[i], compiler);
            e[i].setExpectedType(expectedTypes[i]);
            e[i].eval();
        }
        if(argsCount == 4) {
            appendCode(e[3].toString());
        }
        appendCode(e[2].toString());
        appendCode(e[0].toString());
        appendCode(e[1].toString());
        appendCode("    charat " ~ (argsCount == 4 ? "1" : "0") ~ "\n");
    }
}