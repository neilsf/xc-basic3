module statement.return_fn_stmt;

import pegged.grammar;

import language.statement, language.expression;
import compiler.compiler, compiler.type, compiler.variable;

import std.conv;

/** Compiles a RETURN <expr> statement */
class Return_fn_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Process the AST of the statement */
    void process()
    {
        if(!compiler.inProcedure) {
            compiler.displayError("Not in function");
        }

        Type functionType = compiler.currentProc.type;

        if(functionType.name == Type.VOID) {
            compiler.displayError("Void function " ~ compiler.currentProcName ~ " cannot return anything");
        }

        VariableAccess access = new VariableAccess(ParseTree(), compiler, false);
        access.setVariable(compiler.currentProc.returnValue);

        Expression expr = new Expression(node.children[0].children[0], compiler);
        expr.setExpectedType(functionType);
        expr.eval();
        
        this.appendCode(to!string(expr));
        this.appendCode(access.getPullCode());
        this.appendCode("    rts\n");
    }
}