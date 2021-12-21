module statement.print_stmt;

import std.stdio, std.conv;

import pegged.grammar;

import std.algorithm.searching;

import language.statement, language.expression;
import compiler.compiler, compiler.type;

/** Parses and compiles a PRINT statement */
class Print_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        int ix = 0;
        bool hasHash = false;
        if(this.node.children[0].children[ix].name == "XCBASIC.Expression") {
            ParseTree fileNoNode = this.node.children[0].children[ix];
            Expression fileNoExp = new Expression(fileNoNode, compiler);
            fileNoExp.setExpectedType(compiler.getTypes().get(Type.UINT8));
            fileNoExp.eval();
            appendCode(fileNoExp.toString());
            appendCode("    plbytevar R9\n");
            appendCode("    chkout R9\n");
            hasHash = true;
            ix++;
        }
        bool nlSuppAtEnd = false;
        ParseTree list = this.node.children[0].children[ix];
        for(ix = 0; ix < list.children.length; ix++) {
            ParseTree child = list.children[ix];
            final switch(child.name) {
                case "XCBASIC.Expression":
                    Expression e = new Expression(child, compiler);
                    if(!hasHash) {
                        e.eval();
                        immutable string asmCode = to!string(e);
                        this.appendCode(asmCode);
                        this.appendCode("    print" ~ to!string(e.getType()) ~ "\n");
                    } else {
                        if(!e.getType().isPrimitive) {
                            compiler.displayError("User-defined types not supported in PRINT# statement");
                        }
                        e.eval();
                        appendCode(e.toString());
                        if(e.getType().name != Type.STRING) {
                            appendCode("    F_str@_" ~ e.getType().name ~ "\n");
                        }
                        appendCode("    printstring\n");
                    }
                    
                    break;

                case "XCBASIC.TabSep":
                    if(!hasHash) {
                        this.appendCode("    printtab\n");
                    } else {
                        this.appendCode("    chrout $2c\n");
                    }
                    break;

                case "XCBASIC.NlSupp":
                    if(ix + 1 == list.children.length) {
                        nlSuppAtEnd = true;
                    }
                    break;
            }
        }

        if(!nlSuppAtEnd) {
            if(!hasHash) {
                this.appendCode("    printnl\n");
            } else {
                this.appendCode("    chrout $0d\n");
            }
        }

        if(hasHash) {
            appendCode("    clrchn\n");
        }
    }
}