module statement.const_stmt;

import std.string, std.conv;

import pegged.grammar;

import language.statement, language.expression, compiler.compiler, compiler.type,
    compiler.variable, compiler.constvalue;

/** Compiles a CONST statement */
class Const_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    /** Compiles the statement */
    void process()
    {
        immutable bool isShared = (toLower(node.matches[0]) == "shared");
        ParseTree varNode = node.children[0].children[0];
        Expression e = new Expression(node.children[0].children[1], compiler);
        if (!e.isConstant())
        {
            compiler.displayError("Constant value must be a constant expression");
        }
        Type exprType = e.getType();
        if (!exprType.isNumeric())
        {
            compiler.displayError("Constant can only be a numeric type");
        }
        ConstValue value = e.getConstValue();

        bool explicitType = false;
        foreach (ref child; varNode.children)
        {
            if (child.name == "XCBASIC.Vartype" && join(child.matches) != "")
            {
                explicitType = true;
            }
        }

        VariableReader reader = new VariableReader(varNode, compiler);
        Variable var = reader.read(exprType);
        // Sanity checks
        if (!var.type.isNumeric())
        {
            compiler.displayError("Constant can only be a numeric type");
        }
        if (var.isArray())
        {
            compiler.displayError("Array cannot be constant");
        }
        if (compiler.inProcedure && isShared)
        {
            compiler.displayError("Local constant cannot be shared");
        }

        if (explicitType)
        {
            Type t = var.type;
            if (t.name == Type.FLOAT)
            {
                if (!e.isUntypedConstant() && !exprType.isConvertable(t))
                {
                    compiler.displayError("Type mismatch");
                }
                value = ConstValue.fromReal(value.toDouble());
            }
            else
            {
                if (value.isReal() || (!e.isUntypedConstant() && !exprType.isConvertable(t)))
                {
                    compiler.displayError("Type mismatch");
                }
                if (e.isUntypedConstant() && !t.canHold(value))
                {
                    compiler.displayError("Constant value " ~ value.toString() ~ " is out of "
                            ~ toUpper(t.name) ~ " range (" ~ to!string(t.minValue()) ~ " to "
                            ~ to!string(t.maxValue()) ~ ")");
                }
                value = ConstValue.fromInt(t.wrap(value.intVal));
            }
            var.isUntypedConst = false;
        }
        else
        {
            var.isUntypedConst = e.isUntypedConstant();
            if (!var.isUntypedConst && !value.isReal() && exprType.name != Type.FLOAT)
            {
                value = ConstValue.fromInt(exprType.wrap(value.intVal));
            }
        }

        var.isConst = true;
        var.constVal = value;
        if (compiler.inProcedure)
        {
            var.visibility = compiler.VIS_LOCAL;
            var.procName = compiler.currentProcName;
        }
        else
        {
            var.visibility = isShared ? compiler.VIS_COMMON : compiler.VIS_GLOBAL;
        }
        compiler.getVars().add(var, false);
    }
}
