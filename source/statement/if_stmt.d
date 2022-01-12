module statement.if_stmt;

import pegged.grammar;

import compiler.compiler, compiler.codeblock;
import language.statement, language.expression;

import std.conv;

/** Compiles a single line IF .. THEN .. [ELSE] statement */
class If_stmt : Statement
{
    private static int counter = 0x10000;

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        ParseTree ifStatement = this.node.children[0];
        const bool hasElse = ifStatement.children.length > 2;
        Expression condition = new Expression(ifStatement.children[0], compiler);
        condition.eval();
        appendCode(to!string(condition));
        appendCode("    cond_stmt _EI_" ~ to!string(counter)
                ~ (hasElse ? ", _EL_" ~ to!string(counter) : ", 0") ~ "\n");
        ParseTree thenBody = ifStatement.children[1];
        foreach (ref child; thenBody) {
            Statement stmt = stmtFactory(child, compiler);
            stmt.process();
        }
        if(hasElse) {
            ParseTree elseBody = ifStatement.children[2];
            appendCode("    jmp _EI_" ~ to!string(counter)  ~ "\n");
            appendCode("_EL_" ~ to!string(counter) ~ ":\n");
            foreach (ref child; elseBody) {
                Statement stmt = stmtFactory(child, compiler);
                stmt.process();
            }
        }
        appendCode("_EI_" ~ to!string(counter) ~ ":\n");
        counter++;
    }
}

/** Compiles a multiline IF .. THEN statement */
class If_sa_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    public void process()
    {
        CodeBlock block = new CodeBlock(CodeBlock.TYPE_IF);
        compiler.blockStack.push(block);
        ParseTree ifStatement = this.node.children[0];
        Expression condition = new Expression(ifStatement.children[0], compiler);
        condition.eval();
        appendCode(to!string(condition));
        appendCode("    cond_stmt _EI_" ~ to!string(block.getId()) ~ ", _EL_" ~ to!string(block.getId()) ~ "\n");        
    }
}

/** Compiles an ELSE statement */
class Else_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        string label;
        try {
            CodeBlock block = compiler.blockStack.top();
             if(block.getType() != CodeBlock.TYPE_IF) {
                compiler.displayError("Unclosed " ~ block.getTypeString() ~ " block before ELSE");
            }
            block.hasElse = true;
            label = to!string(block.getId());
        }
        catch(Exception e) {
            compiler.displayError("ELSE without IF");
        }
        appendCode("    jmp _EI_" ~ label ~ "\n");
        appendCode("_EL_" ~ label ~ ":\n");
    }
}

/** Compiles an END IF statement */
class Endif_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Compiles the statement */
    void process()
    {
        try {
            CodeBlock block = compiler.blockStack.pull();
            if(block.getType() != CodeBlock.TYPE_IF) {
                compiler.displayError("Unclosed " ~ block.getTypeString() ~ " block before END IF");
            }

            if(!block.hasElse) {
                appendCode("_EL_" ~ to!string(block.getId()) ~ ":\n");        
            }
            appendCode("_EI_" ~ to!string(block.getId()) ~ ":\n");    
        }
        catch(Exception e) {
            compiler.displayError("END IF without IF");
        }
    }
}

