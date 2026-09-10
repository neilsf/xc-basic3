module statement.incbin_stmt;

import std.file, std.path, std.string, std.conv;

import pegged.grammar;

import compiler.compiler;
import language.statement, language.expression;

class Incbin_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    /** Compiles the statement */
    void process()
    {
        string asmCode = "    INCBIN ";
        ParseTree incbinStatementNode = this.node.children[0];
        ParseTree fileNameNode = incbinStatementNode.children[0];
        const string fileName = getcwd() ~ dirSeparator ~ join(fileNameNode.matches[1 .. $ - 1]);
        if (!exists(fileName))
        {
            compiler.displayError("INCBIN: error opening file " ~ fileName);
        }
        asmCode ~= "\"" ~ fileName ~ "\"";
        import std.stdio; writeln(this.node);
        if (incbinStatementNode.children.length > 1)
        {
            ParseTree offsetNode = incbinStatementNode.children[1];
            Expression offsetExpression = new Expression(offsetNode, compiler);
            if (!offsetExpression.isConstant())
            {
                compiler.displayError("INCBIN: offset parameter must be constant");
            }
            auto offset = cast(int)offsetExpression.getConstVal();
            asmCode ~= ", " ~ to!string(offset);
        }
        this.appendCode(asmCode ~ "\n");
    }
}
