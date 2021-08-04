module statement.let_stmt;

import std.array, std.conv;

import pegged.grammar;

import compiler.compiler, compiler.variable;
import language.statement, language.expression;

/** Compiles a LET statement */
class Let_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree varNode = this.node.children[0].children[0];
        ParseTree expNode = this.node.children[0].children[1];

        Expression exp = new Expression(expNode, compiler);
        
        VariableAccess access = new VariableAccess(varNode, compiler, false);
        if(access.getVariable() is null) {
            // Variable not defined, try implicit definition
            if(varNode.children.length > 1) {
                compiler.displayError("Cannot implicitly define variable with subscript and/or field access");
            }
            if(!exp.getType().isNumeric()) {
                compiler.displayError("Only variables of numeric types can be implicitly defined. Use DIM to define \"" 
                    ~ join(varNode.matches) ~ "\"");
            }
            Variable var = Variable.create(join(varNode.matches), exp.getType(), compiler);
            compiler.getVars().add(var, false);
            access.setVariable(var);
            compiler.displayNotice("Variable \"" ~ var.name ~ "\" implicitly defined as " ~ var.type.name);
        }

        if(access.getVariable().isConst) {
            compiler.displayError("Constants can not change value");
        }
        
        exp.setExpectedType(access.getType());
        exp.eval();
        this.appendCode(to!string(exp));
        this.appendCode(access.getPullCode());
    }
}