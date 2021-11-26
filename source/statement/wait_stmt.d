module statement.wait_stmt;

import std.string, std.conv;
import pegged.grammar;
import language.statement, language.expression;
import compiler.compiler, compiler.type;

class Wait_stmt: Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    void process()
    {
        ParseTree[] args = this.node.children[0].children;
        Expression address = new Expression(args[0], compiler);
        address.setExpectedType(compiler.getTypes().get(Type.UINT16));
        address.eval();
        
        Expression mask = new Expression(args[1], compiler);
        mask.setExpectedType(compiler.getTypes().get(Type.UINT8));
        mask.eval();

        if(args.length > 2) {
            Expression trig = new Expression(args[2], compiler);
            trig.setExpectedType(compiler.getTypes().get(Type.UINT8));
            trig.eval();
            appendCode(to!string(trig));
        }
        else {
            appendCode("    pfalse\n");
        }

        appendCode(to!string(mask));
        appendCode(to!string(address));
        appendCode("    wait\n");
    }
}
