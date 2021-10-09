module statement.input_stmt;

import std.array, std.conv;

import pegged.grammar;

import compiler.compiler, compiler.type, compiler.variable;
import language.statement, language.expression, language.stringliteral;

class Input_stmt : Statement
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
        bool hashStatement;
        int varIndex;
        if(args.children[0].name == "XCBASIC.Expression") {
            // INPUT# statement - input from file
            hashStatement = true;
            varIndex = 1;
            Expression fileIdExp = new Expression(args[0], compiler);
            fileIdExp.setExpectedType(compiler.getTypes().get(Type.UINT8));
            fileIdExp.eval();
            appendCode(fileIdExp.toString());
        }
        else {
            hashStatement = false;
            // INPUT statement - input from keyboard
            if(args.children[0].name == "XCBASIC.String") {
                // Prompt provided
                varIndex = 1;
                StringLiteral str = new StringLiteral(args.children[0].matches[1 .. $-1].join(), compiler);
                str.register();
                appendCode("    pword _S" ~ to!string(StringLiteral.id) ~ "\n");
                appendCode("    printstaticstring\n");
            }
            else {
                // No prompt
                varIndex = 0;
            }
        }
        if(args.children.length < varIndex) {
            compiler.displayError("Syntax error");
        }
        try {
            VariableAccess access = new VariableAccess(args.children[varIndex], compiler);
            if(access.isConstant()) {
                compiler.displayError("Can't use a constant in an INPUT statement");
            }
            if(access.isFunctionCall()) {
                compiler.displayError("Not a variable");
            }
            Variable var = access.getVariable();
            if(var.type.name != Type.STRING) {
                compiler.displayError("Variable of type " ~ var.type.name ~ " cannot be used in an INPUT statement");
            }
            appendCode("    input" ~ (hashStatement ? "_hash" : "") ~ "\n");
            if(!hashStatement && args.matches[$-1] != ";") {
                appendCode("    printnl\n");
            }
            appendCode(access.getPullCode());
        }
        catch (Exception e) {
            compiler.displayError(e.msg);
        }
    }
}