module statement.randomize_stmt;

import pegged.grammar;

import  language.statement, language.expression,
        compiler.compiler, compiler.type;

class Randomize_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    public void process()
    {
        ParseTree expNode = this.node.children[0].children[0];
        Expression exp = new Expression(expNode, compiler);
        exp.setExpectedType(compiler.getTypes().get(Type.INT24));
        exp.eval();
        appendCode(exp.toString());
        appendCode("    import I_RANDOMIZE\n");
        appendCode("    pllongvar MATH_RND\n");
    }
}