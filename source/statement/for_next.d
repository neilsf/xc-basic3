module statement.for_next;

import language.statement, language.expression;

import compiler.compiler, compiler.type, compiler.variable, compiler.codeblock;
import pegged.grammar;

import language.expression;

import std.uni, std.conv, std.array;

class For_stmt : Statement
{
    private Variable counterVar;

    private static Variable[int] counterVariables;
    private static Variable[int] stepVariables;

    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    /** Returns saved counter variable for check in NEXT statement */
    public static Variable getCounterVariable(int blockId)
    {
        return counterVariables[blockId];
    }

    /** Returns saved step variable for check in NEXT statement */
    public static Variable getStepVariable(int blockId)
    {
        return stepVariables[blockId];
    }

    public void process()
    {
        CodeBlock block = new CodeBlock(CodeBlock.TYPE_FOR);
        compiler.blockStack.push(block);

        bool stepPresent = false;
        ParseTree varNode = node.children[0].children[0];
        Expression initExp = new Expression(node.children[0].children[1], compiler);
        Expression limitExp = new Expression(node.children[0].children[2], compiler);
        Expression stepExp;
        if(node.children[0].children.length > 3) {
            stepExp = new Expression(node.children[0].children[3], compiler);
            stepPresent = true;
            stepExp.eval();
        }
        
        VariableAccess access = new VariableAccess(varNode, compiler, false);
        if(access.getVariable() is null) {
            // Variable not defined, try implicit definition
            if(join(varNode.children[1].matches) == "") {
                compiler.displayError("Variable " ~ join(varNode.children[0].matches) ~ " used in FOR statement is not defined. Please use the syntax 'FOR <varname> AS <type>' or use a predefined variable.");
            }
            VariableReader reader = new VariableReader(varNode, compiler);
            counterVar = reader.read(null, true);
            access.setVariable(counterVar);
            compiler.getVars().add(counterVar, false);
            if(compiler.inProcedure && !compiler.currentProc.getIsStatic()) {
                compiler.displayNotice("Variable " ~ counterVar.name ~ " auto-defined as STATIC because it is the counter of a FOR loop");
            }
        }
        else {
            counterVar = access.getVariable();
            if(counterVar.isDynamic) {
                compiler.displayError("Using a dynamic variable as counter in a FOR loop is not supported. Please define "
                ~ counterVar.name ~ " as STATIC");
            }
        }

        if(counterVar.isConst) {
            compiler.displayError("Counter of a FOR loop can not be a constant");
        }

        if(counterVar.type.name == Type.STRING || counterVar.type.name == Type.DEC || !counterVar.type.isPrimitive) {
            compiler.displayError("Counter of a FOR loop can not be of type " ~ counterVar.type.name);
        }

        // Save variable for later check with NEXT
        counterVariables[block.getId()] = counterVar;
        
        // Evaluate startValue
        initExp.setExpectedType(counterVar.type);
        initExp.eval();
        this.appendCode(to!string(initExp));
        this.appendCode(access.getPullCode());

        // evaluate endValue and create endValue variable (if necessary)
        string limitValue; bool isLimitConstant;
        limitExp.setExpectedType(counterVar.type);
        limitExp.eval();
        if(limitExp.isConstant() && counterVar.type.isIntegral()) {
            limitValue = to!string(limitExp.getConstVal());
            isLimitConstant = true;
        } else {
            Variable limitVar = Variable.create("FORLIM" ~ to!string(block.getId()), counterVar.type, compiler, true);
            limitVar.isPrivate = true;
            compiler.getVars.add(limitVar, false);
            this.appendCode(to!string(limitExp));
            this.appendCode("    pl" ~ counterVar.type.name ~ "var " ~ limitVar.getAsmLabel() ~ "\n");
            limitValue = limitVar.getAsmLabel();
            isLimitConstant = false;
        }
        
        Variable stepVar;
        if(stepPresent) {
            // Create stepValue variable and evaluate stepValue
            stepVar = Variable.create("FORSTEP" ~ to!string(block.getId()), counterVar.type, compiler, true);
            stepVar.isPrivate = true;
            compiler.getVars.add(stepVar, false);
            stepExp.setExpectedType(counterVar.type);
            stepExp.eval();
            if(!counterVar.type.isSigned() && stepExp.isConstant() && stepExp.getConstVal() < 0) {
                compiler.displayWarning("FOR loop with unsigned index will never be entered if STEP is negative. Use a signed type.");
            }
            this.appendCode(to!string(stepExp));
            this.appendCode("    pl" ~ counterVar.type.name ~ "var " ~ stepVar.getAsmLabel() ~ "\n");
        }

        stepVariables[block.getId()] = stepVar;

        immutable string blockId = to!string(block.getId());
        appendCode("_FOR_" ~ blockId ~ ":\n");
        appendCode("    for" ~ counterVar.type.name ~ " " ~ blockId ~ ", " ~ counterVar.getAsmLabel() ~ 
                ", " ~ limitValue ~ ", " ~ (stepPresent ? stepVar.getAsmLabel() : "\"_void_\"")
                ~ ", " ~ (isLimitConstant ? "1" : "0") ~ "\n");
        
    }
}

class Next_stmt : Statement
{
    private Variable counterVar;

    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    public void process()
    {
        CodeBlock block = compiler.blockStack.pull();
        if(block.getType() != CodeBlock.TYPE_FOR) {
            compiler.displayError("Unclosed " ~ block.getTypeString() ~ " block before NEXT");
        }
        counterVar = For_stmt.getCounterVariable(block.getId());
        if(node.children[0].children.length > 0) {
            ParseTree varNode = node.children[0].children[0];
            try {
                Variable v = compiler.getVars().findVisible(varNode.matches.join());
                 if(v != counterVar) {
                    compiler.displayError("Variable used in NEXT statement must match variable used in FOR statement");
                }
            }
            catch(Exception e) {
                compiler.displayError(e.msg);
            }
        }
        Variable stepVar = For_stmt.getStepVariable(block.getId());
        const string blockId = to!string(block.getId());
        // A label where CONTINUE can jump to
        appendCode("_CO_" ~ blockId ~ ":\n");
        appendCode("    next" ~ counterVar.type.name ~ " " ~ blockId ~
                    ", " ~ counterVar.getAsmLabel() ~ (stepVar is null ? ", \"_void_\"" : ", " ~ stepVar.getAsmLabel()) ~ "\n");
        appendCode("_ENDFOR_" ~ blockId ~ ":\n");
    }
}

class Exit_for_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    public void process()
    {
        CodeBlock block = compiler.blockStack.closest([CodeBlock.TYPE_FOR]);
        if(block is null) {
            compiler.displayError("Not in a FOR block");
        }
        appendCode("    jmp _ENDFOR_" ~ to!string(block.getId()) ~ "\n");
    }
}