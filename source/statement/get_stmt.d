module statement.get_stmt;

import pegged.grammar;

import compiler.compiler, compiler.type, compiler.variable;
import language.statement, language.expression;

class Get_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree args = this.node.children[0];
        //import std.stdio; writeln(args);
        bool hashStatement;
        int varIndex;
        if(args.children[0].name == "XCBASIC.Expression") {
            // GET# statement - input from file
            hashStatement = true;
            varIndex = 1;
            Expression fileIdExp = new Expression(args[0], compiler);
            fileIdExp.setExpectedType(compiler.getTypes().get(Type.UINT8));
            fileIdExp.eval();
            appendCode(fileIdExp.toString());
        }
        else {
            // GET statement - input from keyboard
            hashStatement = false;
            varIndex = 0;
        }
        if(args.children.length < varIndex) {
            compiler.displayError("Syntax error");
        }

        VariableAccess access;
        try {
            access = new VariableAccess(args.children[varIndex], compiler);
        }
        catch(Exception e) {
            compiler.displayError(e.msg);
        }
        
        if(access.isConstant()) {
            compiler.displayError("Can't use a constant in a GET statement");
        }
        if(access.isFunctionCall()) {
            compiler.displayError("Not a variable");
        }
        Variable var = access.getVariable();
        if((!var.type.isNumeric() && var.type.name != Type.STRING) || var.type.name == Type.DEC) {
            compiler.displayError("Variable of type " ~ var.type.name ~ " cannot be used in a GET statement");
        }
        appendCode("    get" ~ (hashStatement ? "_hash" : "") ~ "\n");
        if(var.type.name == Type.STRING) {
            appendCode("    bytetostr_or_empty\n");
        }
        else if(var.type.name != Type.UINT8) {
            appendCode("    F_c" ~ var.type.name ~ "_byte");
        }
        appendCode(access.getPullCode());
    }
}