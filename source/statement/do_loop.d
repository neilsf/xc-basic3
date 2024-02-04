module statement.do_loop;

import language.statement, language.expression;

import compiler.compiler, compiler.type, compiler.variable, compiler.codeblock;
import pegged.grammar;

import std.uni, std.conv, std.array;

class Do_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    public void process()
    {
        CodeBlock block = new CodeBlock(CodeBlock.TYPE_DO);
        compiler.blockStack.push(block);
        appendCode("_DO_" ~ to!string(block.getId()) ~ ":\n");
        if(node.children[0].children.length > 0) {
            // while or until?
            immutable bool isWhile = (toLower(node.children[0].matches[1]) == "while");
            Expression condition = new Expression(node.children[0].children[0], compiler);
            condition.eval();
            condition.castTo(compiler.getTypes().get(Type.UINT8));
            appendCode(to!string(condition));
            appendCode("    " ~ (isWhile ? "cond_stmt" : "neg_cond_stmt") ~ " _ED_"
                ~ to!string(block.getId()) ~ ", $10000\n");
        }
    }
}

class Loop_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    public void process()
    {
        int counter;
        CodeBlock block;

        try {
            block = compiler.blockStack.pull();
            if(block.getType() != CodeBlock.TYPE_DO) {
                compiler.displayError("Unclosed " ~ block.getTypeString() ~ " block before LOOP");
            }
        }
        catch(Exception e) {
            compiler.displayError("LOOP without DO");
        }
        
        counter = block.getId();
        // A label where CONTINUE can jump to
        appendCode("_CO_" ~ to!string(counter) ~ ":\n");

        if(node.children[0].children.length > 0) {
            // while or until?
            immutable bool isWhile = (toLower(node.children[0].matches[1]) == "while");
            Expression condition = new Expression(node.children[0].children[0], compiler);
            condition.eval();
            condition.castTo(compiler.getTypes().get(Type.UINT8));
            appendCode(to!string(condition));
            appendCode("    " ~ (isWhile ? "cond_stmt" : "neg_cond_stmt") ~ " _ED_" ~ to!string(counter) ~ ", $10000\n");
        }
        
        appendCode("    jmp _DO_" ~ to!string(counter) ~ "\n");
        // A label where EXIT DO can jump to
        appendCode("_ED_" ~ to!string(counter) ~ ":\n");
    }
}

class Cont_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    public void process()
    {
        int[] types;
        if(toLower(join(node.matches)[$-2..$]) == "do") {
            types = [CodeBlock.TYPE_DO];
        } else if(toLower(join(node.matches)[$-3..$]) == "for") {
            types = [CodeBlock.TYPE_FOR];
        } else {
            types = [CodeBlock.TYPE_DO, CodeBlock.TYPE_FOR];
        }
        CodeBlock block = compiler.blockStack.closest(types);
        if(block is null) {
            compiler.displayError("CONTINUE without DO or FOR");
        }
        
        appendCode("    jmp _CO_" ~ to!string(block.getId()) ~ "\n");
    }
}

class Exit_do_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    public void process()
    {
        CodeBlock block = compiler.blockStack.closest([CodeBlock.TYPE_DO]);
        if(block is null) {
            compiler.displayError("EXIT DO without DO");
        }
        
        appendCode("    jmp _ED_" ~ to!string(block.getId()) ~ "\n");
    }
}