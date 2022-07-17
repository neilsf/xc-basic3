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
                    e.setExpectedType(compiler.getTypes().get(Type.UINT8));
                    e.eval();
                    appendCode(e.toString());
                    appendCode("    " ~ toLower(node.matches[0]) ~ "\n");
                break;
            }
        }
    }
}