module statement.option_stmt;

import app, globals;
import pegged.grammar;
import std.array, std.algorithm.searching, std.string;
import compiler.compiler, language.statement, compiler.number;

class Option_stmt: Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        if(compiler.getStatementsBegan()) {
           compiler.displayError("You must place the OPTION directive before any other statements."); 
        }
        ParseTree stmt = node.children[0];
        ParseTree opt = stmt.children[0];
        immutable string optionName = opt.matches.join().toUpper;
        Number numVal;
        string optionValueString;
        if(stmt.children.length > 1) {
            if(stmt.children[1].name == "XCBASIC.Number") {
                numVal = new Number(stmt.children[1], compiler);
            } else {
                optionValueString = stmt.children[1].matches[1 .. $-1].join().toLower;
            }
        }
        switch(optionName) {
            case "TARGET":
                if(!canFind(targetOpts, optionValueString)) {
                    compiler.displayError(optionValueString ~ " is not a valid target");
                }
                target = optionValueString;
                break;
            case "NOBASICLOADER":
                basicLoader = false;
                break;
            case "STARTADDRESS":
                if(numVal is null || !numVal.type.isIntegral()) {
                    compiler.displayError("OPTION STARTADDRESS expects an integer number");
                }
                startAddress = numVal.intVal;
                break;
            case "INLINEDATA":
                inlineData = true;
                break;
            case "FASTINTERRUPT":
                fastIrqs = true;
                break;
            default:
                compiler.displayError("Unrecognized option: " ~ optionName);
                break;
        }

        setStartAddress();
    }
} 
