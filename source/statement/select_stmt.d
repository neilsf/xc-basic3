module statement.select_stmt;

import pegged.grammar;

import compiler.compiler, compiler.variable, compiler.codeblock, compiler.type;
import language.statement, language.expression;

import std.conv;

class Select_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    /** A static register for selector types */
    static string[int] selectType;

    /** Compiles the statement */
    void process()
    {
        CodeBlock block = new CodeBlock(CodeBlock.TYPE_SELECT);
        compiler.blockStack.push(block);
        int counter = block.getId();
        ParseTree selectStatement = this.node.children[0];
        Expression baseExp = new Expression(selectStatement.children[0], compiler);
        baseExp.eval();
        if (!baseExp.getType().isPrimitive)
        {
            compiler.displayError("Expected expression of primitive type, got " ~ baseExp.getType()
                    .name);
        }
        appendCode(to!string(baseExp));
        selectType[counter] = baseExp.getType().name;
    }
}

class Case_stmt : Statement
{
    /*
     * The number of the current CASE statement within a SELECT CASE
     * The array case is the blockId for the SELECT block
     */
    private static int[int] caseCounter;

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    public static int getBlockId(Compiler compiler)
    {
        return compiler.blockStack.closest([CodeBlock.TYPE_SELECT]).getId();
    }

    public static int getCounter(Compiler compiler)
    {
        int blockId = getBlockId(compiler);
        if (blockId in caseCounter)
        {
            return caseCounter[blockId];
        }
        else
        {
            caseCounter[blockId] = 0;
            return 0;
        }
    }

    private int incCounter()
    {
        int blockId = getBlockId(this.compiler);
        if (blockId in caseCounter)
        {
            return ++caseCounter[blockId];
        }
        else
        {
            caseCounter[blockId] = 0;
            return 0;
        }
    }

    private Variable createTmpVar(string stmtBlockId)
    {
        const string varName = "casetmp_" ~ stmtBlockId;
        Variable var = Variable.create(varName, compiler.getTypes().get(Type.UINT8), compiler);
        var.isPrivate = true;
        compiler.getVars().add(var, false);
        return var;
    }

    /** Compiles the statement */
    void process()
    {
        if (compiler.blockStack.isEmpty() || compiler.blockStack.top()
                .getType() != CodeBlock.TYPE_SELECT)
        {
            compiler.displayError("Not in a SELECT CASE block");
        }
        string typeName = Select_stmt.selectType[getBlockId(compiler)];
        Type type = compiler.getTypes().get(typeName);
        int caseId;
        const string blockId = to!string(getBlockId(this.compiler));
        ParseTree caseStatement = this.node.children[0].children[0];
        string stmtBlockId = "case_stmt_" ~ blockId ~ "_" ~ to!string(getCounter(this.compiler));
        final switch (caseStatement.name)
        {
        case "XCBASIC.Case_set_stmt":
            ParseTree exprList = caseStatement.children[0];
            foreach (ref exprNode; exprList.children)
            {
                Expression e = new Expression(exprNode, compiler);
                e.setExpectedType(type);
                e.eval();
                caseId = incCounter();
                if (caseId != 1)
                {
                    appendCode("    jmp end_select_" ~ blockId ~ "\n");
                }
                appendCode("case_" ~ blockId ~ "_" ~ to!string(caseId) ~ ":\n");
                appendCode(e.toString());
                appendCode("    cmp" ~ type.name ~ "eq_lfs\n"); // leave select value on stack
                appendCode("    case " ~ stmtBlockId ~ ", " ~ "case_" ~ blockId ~ "_" ~ to!string(
                        caseId + 1) ~ "\n");
            }
            break;

        case "XCBASIC.Case_range_stmt":
            if (!type.isNumeric())
            {
                compiler.displayError("Only numeric types can be tested for a range");
            }
            caseId = incCounter();
            if (caseId != 1)
            {
                appendCode("    jmp end_select_" ~ blockId ~ "\n");
            }
            appendCode("case_" ~ blockId ~ "_" ~ to!string(caseId) ~ ":\n");
            Variable tmpVar = createTmpVar("tmpcase_" ~ blockId ~ "_" ~ to!string(caseId));
            string[2] cmpOps = ["gte", "lte"];
            for (int i = 0; i <= 1; i++)
            {
                Expression e = new Expression(caseStatement.children[i], compiler);
                e.setExpectedType(type);
                e.eval();
                appendCode(e.toString());
                appendCode("    cmp" ~ type.name ~ cmpOps[i] ~ "_lfs\n");
                if (i == 0) {
                    appendCode("    plbytevar " ~ tmpVar.getAsmLabel() ~ "\n");
                }
            }
            appendCode("    pbytevar " ~ tmpVar.getAsmLabel() ~ "\n");
            appendCode("    andbyte\n");
            appendCode("    case " ~ stmtBlockId ~ ", " ~ "case_" ~ blockId ~ "_" ~ to!string(
                    caseId + 1) ~ "\n");
            break;

        case "XCBASIC.Case_is_stmt":
            caseId = incCounter();
            string relOp = caseStatement.children[0].matches[0];
            string[string] opMap = [
                "<": "lt", ">": "gt", "=": "eq", "<>": "neq", "<=": "lte",
                ">=": "gte"
            ];
            if (!type.isNumeric() && relOp != "=" && relOp != "<>")
            {
                compiler.displayError("Only numeric types can be tested for " ~ relOp);
            }
            string opName = opMap[relOp];
            Expression e = new Expression(caseStatement.children[1], compiler);
            e.setExpectedType(type);
            e.eval();
            if (caseId != 1)
            {
                appendCode("    jmp end_select_" ~ blockId ~ "\n");
            }
            appendCode("case_" ~ blockId ~ "_" ~ to!string(caseId) ~ ":\n");
            appendCode(e.toString());
            appendCode("    cmp" ~ type.name ~ opName ~ "_lfs\n");
            appendCode("    case " ~ stmtBlockId ~ ", " ~ "case_" ~ blockId ~ "_" ~ to!string(
                    caseId + 1) ~ "\n");
            break;

        case "XCBASIC.Case_else_stmt":
            caseId = incCounter();
            if (caseId != 1)
            {
                appendCode("    jmp end_select_" ~ blockId ~ "\n");
            }
            appendCode("case_" ~ blockId ~ "_" ~ to!string(caseId) ~ ":\n");
            break;
        }

        appendCode(stmtBlockId ~ ":\n");
    }
}

class Endselect_stmt : Statement
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    /** Compiles the statement */
    void process()
    {
        if (compiler.blockStack.isEmpty() || compiler.blockStack.top()
                .getType() != CodeBlock.TYPE_SELECT)
        {
            compiler.displayError("Not in a SELECT CASE block");
        }
        string typeName = Select_stmt.selectType[Case_stmt.getBlockId(compiler)];
        Type type = compiler.getTypes().get(typeName);
        int caseId = Case_stmt.getCounter(this.compiler);
        caseId++;
        const string blockId = to!string(Case_stmt.getBlockId(this.compiler));
        appendCode("end_select_" ~ blockId ~ ":\n");
        appendCode("case_" ~ blockId ~ "_" ~ to!string(caseId) ~ ": ; END SELECT\n");
        appendCode("    discard" ~ type.name ~ "\n");
        compiler.blockStack.pull();
    }

}
