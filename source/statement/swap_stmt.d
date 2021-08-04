module statement.swap_stmt;

import std.array, std.conv;

import pegged.grammar;

import compiler.compiler, compiler.variable;
import language.statement, language.expression;

/** Compiles a SWAP statement */
class Swap_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree varNode1 = this.node.children[0].children[0];
        ParseTree varNode2 = this.node.children[0].children[1];

        VariableAccess access1 = new VariableAccess(varNode1, compiler, true);
        Variable var1 = access1.getVariable();
        VariableAccess access2 = new VariableAccess(varNode2, compiler, true);
        Variable var2 = access2.getVariable();

        if(var1.isConst || var2.isConst) {
            compiler.displayError("Can't use constants in a SWAP statement");
        }
        if(var1.type != var2.type) {
            compiler.displayError("Type mismatch (" ~ var1.type.name ~ " and " ~ var2.type.name ~ ")");
        }

        // Push var1
        appendCode(access1.getPushCode());
        // Push var2
        appendCode(access2.getPushCode());
        // Pull var1
        appendCode(access1.getPullCode());
        // Pull var2
        appendCode(access2.getPullCode());
    }
}