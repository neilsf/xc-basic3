module statement.origin_stmt;

import std.array;


import pegged.grammar;

import compiler.compiler, compiler.number, compiler.variable, compiler.type;
import language.statement, language.expression;

class Origin_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ushort address;
        const ParseTree addrNode = this.node.children[0].children[0];
        if(addrNode.name == "XCBASIC.Number") {
            Number num = new Number(addrNode, this.compiler);
            address = to!ushort(num.intVal);
        } else {
            Variable var = compiler.getVars().findVisible(addrNode.matches.join);
            if(var !is null) {
                if(!var.isConst) {
                    compiler.displayError("ORIGIN must be constant");
                }
                // a constant
                address = to!ushort(var.constVal);
            }
            else {
                compiler.displayError("Unknown constant \"" ~ addrNode.matches.join ~ "\"");
            }
        }
        if(address < 0 || address > 0xFFFF) {
            this.compiler.displayError("Address out of range");
        }
        appendCode("    org "
            ~ to!string(address) ~ "\n");
    }
}