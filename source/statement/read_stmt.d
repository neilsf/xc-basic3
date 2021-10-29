module statement.read_stmt;

import pegged.grammar;

import std.conv;

import compiler.compiler, compiler.type, compiler.variable;
import language.statement, language.expression;

class Read_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree fileNoNode = this.node.children[0].children[0];
        Expression fileNoExp = new Expression(fileNoNode, compiler);
        fileNoExp.setExpectedType(compiler.getTypes().get(Type.UINT8));
        fileNoExp.eval();
        appendCode(fileNoExp.toString());
        appendCode("    plbytevar R9\n");
        appendCode("    chkin R9\n");
        ParseTree accessorList = this.node.children[0].children[1];
        const ulong count = accessorList.children.length;
        VariableAccess v;
        for (int i = 0; i < count; i++) {
            try {
                v = new VariableAccess(accessorList[i], compiler);
                appendCode("    read " ~ to!string(v.getVariable.getAsmLabel()) ~ ", " ~ to!string(v.getVariable().type.length) ~ "\n");
            }
            catch (Exception e) {
                compiler.displayError(e.msg);
            }
        }
        appendCode("    clrchn\n");
    }
}