module statement.vmode_stmt;

import std.string, std.conv;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

class VMode_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    void process()
    {
        ParseTree stmtNode = node.children[0];
        foreach(ref subCmd; stmtNode.children) {
            ParseTree node = subCmd.children[0];
            final switch(node.name) {
                case "XCBASIC.VModeSubCmdTextBitmap":
                    const string mode = toUpper(node.matches.join());
                    appendCode("    vmode VMODE_" ~ mode ~ "\n");
                break;

                case "XCBASIC.VModeSubCmdColor":
                    const string mode = toUpper(node.matches.join());
                    appendCode("    vmodecolor VMODE_" ~ mode ~ "\n");
                break;

                case "XCBASIC.VModeSubCmdRsel":
                case "XCBASIC.VModeSubCmdCsel":
                    Expression e =  new Expression(node.children[0], compiler);
                    if(!e.isConstant()) {
                        compiler.displayError("Please provide a constant for " ~ toUpper(node.matches[0]));
                    }
                    e.setExpectedType(compiler.getTypes().get(Type.UINT8));
                    e.eval();
                    const int val = cast(int)e.getConstVal();
                    int selVal;
                    string mac;
                    final switch (toLower(node.matches[0])) {
                        case "cols":
                            mac = "CSEL";
                            if(val == 38) {
                                selVal = 0;
                            } else if(val == 40) {
                                selVal = 1;
                            } else {
                                selVal = -1;
                            }
                            break;
                        case "rows":
                            mac = "RSEL";
                            if(val == 24) {
                                selVal = 0;
                            } else if(val == 25) {
                                selVal = 1;
                            } else {
                                selVal = -1;
                            }
                            break;
                    }
                    if(selVal == -1) {
                        compiler.displayError("Wrong value for " ~ toUpper(node.matches[0]));
                    }
                    appendCode("    " ~ mac ~ " " ~ to!string(selVal) ~ "\n");
                break;
            }
        }
    }
}