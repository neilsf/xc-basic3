module statement.const_stmt;

import std.string, std.conv;

import pegged.grammar;

import language.statement, compiler.compiler, compiler.number, compiler.variable;

/** Compiles a CONST statement */
class Const_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        immutable bool isShared = (toLower(node.matches[0]) == "shared");
        Number num = new Number(node.children[0].children[1], compiler);
        VariableReader reader = new VariableReader(node.children[0].children[0], compiler);
        Variable var = reader.read(num.type);
        // Sanity checks
        if(!var.type.isNumeric()) {
            compiler.displayError("Constant can only be a numeric type");
        }
        if(var.isArray()) {
            compiler.displayError("Array cannot be constant");
        }
        if(compiler.inProcedure && isShared) {
            compiler.displayError("Local constant cannot be shared");
        }
        if(num.type.isIntegral() ^ var.type.isIntegral()) {
            compiler.displayError("Type mismatch");
        }
        var.isConst = true;
        var.constVal = num.type.isIntegral() ? to!float(num.intVal) : num.floatVal;
        if(compiler.inProcedure) {
            var.visibility = compiler.VIS_LOCAL;
            var.procName = compiler.currentProcName;
        }
        else {
            var.visibility = isShared ? compiler.VIS_COMMON : compiler.VIS_GLOBAL;
        }
        compiler.getVars().add(var, false);
    }
}