module statement.let_stmt;

import std.array, std.conv;

import pegged.grammar;

import compiler.compiler, compiler.variable, compiler.type;
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
        bool evaluated = false;
        
        VariableAccess access = new VariableAccess(varNode, compiler, false);
        if(access.getVariable() is null) {
            // Variable not defined, try implicit definition
            if(varNode.children.length > 1) {
                compiler.displayError("Cannot implicitly define variable with subscript and/or field access");
            }
            if(exp.getType().name == Type.STRING && !exp.isConstantString()) {
                compiler.displayError("Cannot implicitly define variable of type STRING unless the right-hand side is a constant");
            } else if(!exp.getType().isPrimitive) {
                compiler.displayError("Only variables of primitive types can be implicitly defined. Use DIM to define \"" 
                    ~ join(varNode.matches) ~ "\"");
            }
            ulong strLen = 0;
            if(exp.getType().name == Type.STRING) {
                exp.eval();
                evaluated = true;
                strLen = exp.getConstantStringLength();
            }
            Variable var = Variable.create(
                join(varNode.matches), exp.getType(), compiler,
                false, [1, 1, 1], 0, to!ushort(strLen)
            );
            compiler.getVars().add(var, false);
            access.setVariable(var);
            compiler.displayNotice("Variable \"" ~ var.name ~ "\" implicitly defined as " ~ var.type.name
                ~ (strLen > 0 ? (" * " ~ to!string(strLen)) : ""));
        }

        if(access.getVariable().isConst) {
            compiler.displayError("Constants can not change value");
        }
        
        if(!evaluated) {
            exp.setExpectedType(access.getType());
            exp.eval();
        }
        this.appendCode(exp.toString());
        this.appendCode(access.getPullCode());
    }
}
