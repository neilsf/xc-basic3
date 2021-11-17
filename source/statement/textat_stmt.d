module statement.textat_stmt;

import language.statement, language.expression;

import compiler.compiler, compiler.type;
import pegged.grammar;

import std.conv;

/** Parses and compiles a TEXTAT statement */
class Textat_stmt : Statement
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
            if(i != 2) {
                e[i].setExpectedType(expectedTypes[i]);
            }
            e[i].eval();
        }
        if(!e[2].getType().isPrimitive) {
            compiler.displayError("TEXTAT supports primitive types only.");
        }
        if(argsCount == 4) {
            appendCode(e[3].toString());
        }
        appendCode(e[2].toString());
        if(e[2].getType().name != Type.STRING) {
            // Call STR$() to convert to string 
            appendCode("    F_str@_" ~ e[2].getType().name ~ "\n");
        }
        appendCode(e[0].toString());
        appendCode(e[1].toString());
        appendCode("    textat " ~ (argsCount == 4 ? "1" : "0") ~ "\n");
    }
}