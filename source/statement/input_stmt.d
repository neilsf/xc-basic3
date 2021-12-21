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
            appendCode("    plbytevar R9\n");
            appendCode("    chkin R9\n");
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
        ParseTree accessorList = args.children[varIndex];
        if(!hashStatement && accessorList.children.length > 1) {
            compiler.displayError("INPUT currently only supports one variable");
        }
        foreach (accessor; accessorList.children) {
            try {
                VariableAccess access = new VariableAccess(accessor, compiler);
                if(access.isConstant()) {
                    compiler.displayError("Can't use a constant in an INPUT statement");
                }
                if(access.isFunctionCall()) {
                    compiler.displayError("Not a variable");
                }
                Variable var = access.getVariable();
                if(var.type.name != Type.STRING) {
                    compiler.displayError("Only strings are allowed in INPUT statement, got " ~ var.type.name);
                }

                if(hashStatement) {
                    appendCode("    input_hash\n");
                }
                else {
                    appendCode("    input\n");
                    if(args.matches[$-1] != ";") {
                        appendCode("    printnl\n");
                    }
                }
                appendCode(access.getPullCode());
            }
            catch (Exception e) {
                compiler.displayError(e.msg);
            }    
        }
        if(hashStatement) {
            appendCode("    clrchn\n");
        }
    }
}