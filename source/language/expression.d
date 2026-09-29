module language.expression;

import std.algorithm, std.array, std.conv, std.math, std.string;
import pegged.grammar;
import globals, compiler.type, compiler.compiler, compiler.petscii, compiler.number,
    compiler.constvalue, compiler.variable, compiler.routine;
import language.accessor, language.stringliteral;

/*
 * Expressions are compiled in two steps. First, the parse tree is
 * converted to an expression tree (see the *Node classes below).
 * While building the tree, constant sub-expressions are evaluated
 * (folded) and replaced with a single constant node.
 * Then the tree is used to generate the intermediate code.
 *
 * Typing rules:
 *
 * - Numeric literals and constants defined without an explicit type
 *   are untyped. Operations on untyped operands only are evaluated
 *   in compile time with exact precision.
 * - Operations where all operands are typed are evaluated in the
 *   type that has the highest precedence (see Type.comparePrecedence).
 * - If an operation has typed and untyped operands, the operation is
 *   evaluated in the type of the typed operands, unless an untyped
 *   constant doesn't fit in that type, in which case the operation is
 *   promoted to the smallest type that holds both the typed operands'
 *   range and the constant.
 * - When an untyped constant is converted to a target type (e.g it is
 *   assigned to a variable) it must fit in the target type.
 */

/** A node in the expression tree */
abstract class ExprNode
{
    protected Compiler compiler;

    /** Class constructor */
    this(Compiler compiler)
    {
        this.compiler = compiler;
    }

    /** The type of the value that this node evaluates to */
    abstract Type getType();

    /** Whether the node is a constant */
    bool isConstant()
    {
        return false;
    }

    /** Whether the node is an untyped constant */
    bool isUntyped()
    {
        return false;
    }

    /** Returns code that pushes the value onto the stack in its own type */
    abstract string emit();

    /** Returns code that pushes the value onto the stack, converted to the target type */
    string emitAs(Type target)
    {
        string code = this.emit();
        try
        {
            code ~= this.getType().getCastCode(target);
        }
        catch (Exception e)
        {
            compiler.displayError(e.msg);
        }
        return code;
    }
}

/** A constant value */
final class ConstNode : ExprNode
{
    /** The value */
    ConstValue value;
    private Type type;
    private bool untyped;

    /**
     * Class constructor
     * If type is null, the constant is untyped
     */
    this(Compiler compiler, ConstValue value, Type type = null)
    {
        super(compiler);
        this.value = value;
        if (type is null)
        {
            this.untyped = true;
            this.type = compiler.getTypes().getSmallestFitting(value);
        }
        else
        {
            this.untyped = false;
            this.type = type;
            if (type.isBinaryInteger() && value.isInteger())
            {
                this.value = ConstValue.fromInt(type.wrap(value.intVal));
            }
            else if (type.name == Type.FLOAT)
            {
                this.value = ConstValue.fromReal(value.toDouble());
            }
        }
    }

    override Type getType()
    {
        return this.type;
    }

    override bool isConstant()
    {
        return true;
    }

    override bool isUntyped()
    {
        return this.untyped;
    }

    override string emit()
    {
        return this.emitAs(this.type);
    }

    override string emitAs(Type target)
    {
        if (!target.isNumeric() || (!this.untyped && !this.type.isConvertable(target)))
        {
            try
            {
                return this.type.getCastCode(target);
            }
            catch (Exception e)
            {
                compiler.displayError(e.msg);
            }
            assert(0);
        }

        if (target.name == Type.FLOAT)
        {
            return "    pfloat " ~ Number.floatToHex(cast(float) value.toDouble()) ~ "\n";
        }

        if (value.isReal())
        {
            // Let the runtime do the conversion from float
            string code = "    pfloat " ~ Number.floatToHex(cast(float) value.realVal) ~ "\n";
            try
            {
                code ~= compiler.getTypes().get(Type.FLOAT).getCastCode(target);
            }
            catch (Exception e)
            {
                compiler.displayError(e.msg);
            }
            return code;
        }

        if (this.untyped && !target.canHold(value))
        {
            compiler.displayError("Constant value " ~ value.toString() ~ " is out of "
                    ~ toUpper(target.name) ~ " range (" ~ to!string(
                        target.minValue()) ~ " to " ~ to!string(target.maxValue()) ~ ")");
        }

        if (target.name == Type.DEC)
        {
            return "    pdecimal " ~ Number.getDecimalAsHex(cast(int) target.wrap(value.intVal))
                ~ "\n";
        }

        return "    p" ~ target.name ~ " " ~ to!string(target.wrap(value.intVal)) ~ "\n";
    }
}

/** A variable access, function or method call */
final class AccessorNode : ExprNode
{
    private AccessorInterface accessor;

    /** Class constructor */
    this(Compiler compiler, AccessorInterface accessor)
    {
        super(compiler);
        this.accessor = accessor;
    }

    override Type getType()
    {
        return accessor.getType();
    }

    override string emit()
    {
        if (this.getType().name == Type.VOID)
        {
            compiler.displayError("Void function used in expression");
        }
        string code;
        try
        {
            code = accessor.getPushCode();
            if (accessor.isFunctionCall() && accessor.getRoutine() == compiler.currentProc)
            {
                compiler.currentProc.recursed = true;
            }
        }
        catch (Exception e)
        {
            compiler.displayError(e.msg);
        }
        return code;
    }
}

/** Address of a variable, routine or label (@name) */
final class AddressNode : ExprNode
{
    private ParseTree node;

    /** Class constructor */
    this(Compiler compiler, ParseTree node)
    {
        super(compiler);
        this.node = node;
    }

    override Type getType()
    {
        return compiler.getTypes().get(Type.UINT16);
    }

    override string emit()
    {
        // First check if it's a variable or routine call
        try
        {
            AccessorFactory af = new AccessorFactory(node.children[0], compiler);
            AccessorInterface accessor = af.getAccessor();
            return accessor.getPushAddressCode();
        }
        catch (Exception e)
        {
            // No, maybe a label
            ParseTree v = node.children[0];
            immutable string identifier = join(v.children[0].matches);
            if (this.compiler.getLabels().exists(identifier, false))
            {
                return "    paddr " ~ this.compiler.getLabels()
                    .getReferenceToLabel(identifier) ~ "\n";
            }
            // Not a label, we give up
            compiler.displayError(e.msg);
        }
        assert(0);
    }
}

/** A string literal */
final class StringNode : ExprNode
{
    /** The string as it appears in the source code (without quotes) */
    string str;

    /** Class constructor */
    this(Compiler compiler, string str)
    {
        super(compiler);
        this.str = str;
    }

    override Type getType()
    {
        return compiler.getTypes().get(Type.STRING);
    }

    override string emit()
    {
        StringLiteral sl = new StringLiteral(str, compiler);
        sl.register();
        return "    pstringvar _S" ~ to!string(StringLiteral.id) ~ "\n";
    }
}

/** Unary operation (negation or NOT) on a non-constant operand */
final class UnaryNode : ExprNode
{
    private string op;
    private ExprNode operand;

    /** Class constructor */
    this(Compiler compiler, string op, ExprNode operand)
    {
        super(compiler);
        this.op = op;
        this.operand = operand;
    }

    override Type getType()
    {
        return operand.getType();
    }

    override string emit()
    {
        string code = operand.emit();
        checkUnaryOp(compiler, op, this.getType());
        return code ~ "    " ~ (op == "-" ? "neg" : "not") ~ this.getType().name ~ "\n";
    }
}

/** Checks whether a unary operation is possible on the type */
private void checkUnaryOp(Compiler compiler, string op, Type type)
{
    immutable string opName = toUpper(op);
    if (!type.isNumeric())
    {
        compiler.displayError("The " ~ opName ~ " operator cannot be used with non-numeric types");
    }
    if (op == "-" && (type.name == Type.DEC || type.name == Type.UINT8
            || type.name == Type.UINT16))
    {
        compiler.displayError("Cannot negate an unsigned type");
    }
    if (op == "not" && !type.isIntegral())
    {
        compiler.displayError("The NOT operator only works on integer types");
    }
}

/** Kinds of operator chains */
enum ChainKind
{
    /** AND, OR, XOR */
    BITWISE,
    /** +, - */
    ADDITIVE,
    /** *, /, MOD */
    MULTIPLICATIVE
}

/**
 * A chain of operands with operators of the same precedence
 * (e.g a + b - c). The whole chain is evaluated in a single type.
 */
final class ChainNode : ExprNode
{
    private ChainKind kind;
    private ExprNode[] operands;
    /** ops[i] is the operator between operands[i] and operands[i + 1] */
    private string[] ops;
    private Type type;

    /** Class constructor */
    this(Compiler compiler, ChainKind kind, ExprNode[] operands, string[] ops, Type type)
    {
        super(compiler);
        this.kind = kind;
        this.operands = operands;
        this.ops = ops;
        this.type = type;
    }

    override Type getType()
    {
        return this.type;
    }

    private void check()
    {
        final switch (kind)
        {
        case ChainKind.ADDITIVE:
            bool hasStringMember = false;
            bool hasNumericMember = false;
            foreach (ref operand; operands)
            {
                Type t = operand.getType();
                if (!t.isPrimitive)
                {
                    compiler.displayError("Only primitive types can be added or subtracted");
                }
                if (t.name == Type.STRING)
                {
                    hasStringMember = true;
                }
                else
                {
                    hasNumericMember = true;
                }
            }
            if (hasStringMember && hasNumericMember)
            {
                compiler.displayError(
                        "Mixed types (string and numeric) are not allowed in expression");
            }
            if (hasStringMember && ops.canFind("-"))
            {
                compiler.displayError("Strings cannot be subtracted");
            }
            break;

        case ChainKind.MULTIPLICATIVE:
            foreach (ref operand; operands)
            {
                Type t = operand.getType();
                if (!t.isNumeric())
                {
                    compiler.displayError("Only numeric types can be multiplied or divided");
                }
                if (t.name == Type.DEC)
                {
                    compiler.displayError(
                            "Multiplication or division of decimals is not supported");
                }
            }
            break;

        case ChainKind.BITWISE:
            if (!type.isIntegral())
            {
                compiler.displayError("Can't do bitwise operation on a(n) " ~ type.name);
            }
            break;
        }
    }

    override string emit()
    {
        this.check();
        string code = operands[0].emitAs(type);
        foreach (i, ref op; ops)
        {
            code ~= operands[i + 1].emitAs(type);
            code ~= "    " ~ opMnemonic(op) ~ type.name ~ "\n";
        }
        return code;
    }

    private static string opMnemonic(string op)
    {
        switch (op)
        {
        case "+":
            return "add";
        case "-":
            return "sub";
        case "*":
            return "mul";
        case "/":
            return "div";
        default:
            return op;
        }
    }
}

/** A relation (comparison) of two operands */
final class CompareNode : ExprNode
{
    private ExprNode left, right;
    private string op;
    private Type cmpType;

    /** Class constructor */
    this(Compiler compiler, ExprNode left, string op, ExprNode right, Type cmpType)
    {
        super(compiler);
        this.left = left;
        this.op = op;
        this.right = right;
        this.cmpType = cmpType;
    }

    override Type getType()
    {
        // The value of a relation is true or false
        return compiler.getTypes().get(Type.UINT8);
    }

    override string emit()
    {
        Type lType = left.getType();
        Type rType = right.getType();
        if ((lType.name == Type.STRING) != (rType.name == Type.STRING))
        {
            compiler.displayError("Strings can't be compared to other types (trying to compare '"
                    ~ lType.name ~ "' to '" ~ rType.name ~ "')");
        }
        if (!lType.isPrimitive || !rType.isPrimitive)
        {
            compiler.displayError("Only primitive types can be compared in a relation");
        }
        if (lType.name == Type.STRING && op != "=" && op != "<>")
        {
            compiler.displayError("Relational operator '" ~ op ~ "' not supported on strings");
        }
        return left.emitAs(cmpType) ~ right.emitAs(cmpType) ~ "    cmp" ~ cmpType.name
            ~ opMnemonic(op) ~ "\n";
    }

    private static string opMnemonic(string op)
    {
        switch (op)
        {
        case "<":
            return "lt";
        case ">":
            return "gt";
        case "=":
            return "eq";
        case "<>":
            return "neq";
        case "<=":
            return "lte";
        case ">=":
            return "gte";
        default:
            assert(0, "Unknown relational operator " ~ op);
        }
    }
}

/** Builds an expression tree from the parse tree, folding constants */
private class ExpressionBuilder
{
    private Compiler compiler;

    this(Compiler compiler)
    {
        this.compiler = compiler;
    }

    private Type getType(string name)
    {
        return compiler.getTypes().get(name);
    }

    /** Builds the tree from any expression member node */
    ExprNode build(ParseTree node)
    {
        switch (node.name)
        {
        case "XCBASIC.Expression":
            return buildChain(node, ChainKind.BITWISE, "XCBASIC.Relation");
        case "XCBASIC.Relation":
            return buildRelation(node);
        case "XCBASIC.Simplexp":
            return buildChain(node, ChainKind.ADDITIVE, "XCBASIC.Term");
        case "XCBASIC.Term":
            return buildChain(node, ChainKind.MULTIPLICATIVE, "XCBASIC.Factor");
        case "XCBASIC.Factor":
            return buildFactor(node);
        case "XCBASIC.Parenthesis":
            return build(node.children[0]);
        default:
            assert(0, "Unexpected node in expression: " ~ node.name);
        }
    }

    private ExprNode buildChain(ParseTree node, ChainKind kind, string childName)
    {
        ExprNode[] operands;
        string[] ops;
        foreach (ref child; node.children)
        {
            if (child.name == childName)
            {
                operands ~= build(child);
            }
            else
            {
                ops ~= toLower(strip(join(child.matches)));
            }
        }
        return makeChain(kind, operands, ops);
    }

    private ExprNode buildRelation(ParseTree node)
    {
        ExprNode left = build(node.children[0]);
        if (node.children.length == 1)
        {
            return left;
        }
        immutable string op = join(node.children[1].matches);
        ExprNode right = build(node.children[2]);
        return makeRelation(left, op, right);
    }

    private ExprNode buildFactor(ParseTree node)
    {
        int pos = 0;
        string unOp = "";
        if (node.children[0].name == "XCBASIC.UN_OP")
        {
            unOp = toLower(strip(join(node.children[0].matches)));
            pos++;
        }
        ParseTree child = node.children[pos];
        ExprNode inner;
        switch (child.name)
        {
        case "XCBASIC.Number":
            Number num = new Number(child, compiler);
            inner = new ConstNode(compiler, num.getValue(), num.isUntyped() ? null : num.type);
            break;

        case "XCBASIC.Accessor":
            try
            {
                AccessorInterface accessor = (new AccessorFactory(child, compiler)).getAccessor();
                VariableAccess varAccess = cast(VariableAccess) accessor;
                if (varAccess !is null && accessor.isConstant())
                {
                    Variable var = varAccess.getVariable();
                    inner = new ConstNode(compiler, var.constVal,
                            var.isUntypedConst ? null : var.type);
                }
                else
                {
                    inner = new AccessorNode(compiler, accessor);
                }
            }
            catch (Exception e)
            {
                compiler.displayError(e.msg);
            }
            break;

        case "XCBASIC.Address":
            inner = new AddressNode(compiler, child);
            break;

        case "XCBASIC.String":
            inner = new StringNode(compiler, join(child.matches[1 .. $ - 1]));
            break;

        case "XCBASIC.Expression":
        case "XCBASIC.Parenthesis":
            inner = build(child);
            break;

        default:
            assert(0, "Add case for " ~ child.name);
        }

        if (unOp.length > 0)
        {
            return makeUnary(unOp, inner);
        }
        return inner;
    }

    /** Displays error from a failed compile time evaluation */
    private ConstValue tryFold(lazy ConstValue expr)
    {
        try
        {
            return expr;
        }
        catch (ConstEvalException e)
        {
            compiler.displayError(e.msg);
        }
        assert(0);
    }

    private ExprNode makeUnary(string op, ExprNode operand)
    {
        if (!operand.isConstant())
        {
            return new UnaryNode(compiler, op, operand);
        }

        ConstNode c = cast(ConstNode) operand;
        ConstValue v = c.value;
        if (c.isUntyped())
        {
            if (op == "-")
            {
                if (v.isReal())
                {
                    return new ConstNode(compiler, ConstValue.fromReal(-v.realVal));
                }
                return new ConstNode(compiler, tryFold(foldUntyped("-", ConstValue.fromInt(0), v)));
            }
            if (v.isReal())
            {
                compiler.displayError("The NOT operator only works on integer types");
            }
            return new ConstNode(compiler, ConstValue.fromInt(~v.intVal, true));
        }

        Type t = c.getType();
        checkUnaryOp(compiler, op, t);
        if (t.name == Type.DEC)
        {
            // Let the runtime handle NOT on decimals
            return new UnaryNode(compiler, op, operand);
        }
        if (t.name == Type.FLOAT)
        {
            return new ConstNode(compiler, ConstValue.fromReal(-v.toDouble()), t);
        }
        return new ConstNode(compiler, ConstValue.fromInt(op == "-" ? -v.intVal : ~v.intVal), t);
    }

    /**
     * The type of an operation where all operands are typed
     * (the operand with the highest precedence wins)
     */
    private Type typedResultType(Type[] types)
    {
        Type result = getType(Type.UINT8);
        foreach (ref t; types)
        {
            if (!result.comparePrecedence(t))
            {
                result = t;
            }
        }
        return result;
    }

    /**
     * Returns the type in which an operation must be evaluated if one operand
     * is of type t and the other one is an untyped constant
     */
    private Type widen(Type t, ConstValue c)
    {
        if (!t.isNumeric() || t.name == Type.FLOAT)
        {
            return t;
        }
        if (c.isReal())
        {
            return getType(Type.FLOAT);
        }
        if (t.name == Type.DEC)
        {
            if (!t.canHold(c))
            {
                compiler.displayError("Constant value " ~ c.toString()
                        ~ " can't be used with DECIMAL type (range: 0 to 9999)");
            }
            return t;
        }
        if (t.canHold(c))
        {
            return t;
        }
        immutable string[] candidates = (!t.isSigned() && c.intVal >= 0)
            ? [Type.UINT16, Type.INT24] : [Type.INT16, Type.INT24];
        foreach (ref name; candidates)
        {
            Type candidate = getType(name);
            if (candidate.minValue() <= t.minValue() && candidate.maxValue() >= t.maxValue()
                    && candidate.canHold(c))
            {
                return candidate;
            }
        }
        compiler.displayError("Constant value " ~ c.toString() ~ " is out of range");
        assert(0);
    }

    /** Evaluates the type of an operation with the given operands */
    private Type operationType(ExprNode[] operands)
    {
        Type[] typedTypes;
        foreach (ref o; operands)
        {
            if (!o.isUntyped())
            {
                typedTypes ~= o.getType();
            }
        }
        Type t = typedResultType(typedTypes);
        foreach (ref o; operands)
        {
            if (o.isUntyped())
            {
                t = widen(t, (cast(ConstNode) o).value);
            }
        }
        return t;
    }

    /** Folds a binary operation in the given type (as the runtime would do it) */
    private ConstValue foldTyped(string op, ConstValue a, ConstValue b, Type t)
    {
        if (t.name == Type.FLOAT)
        {
            ConstValue r = foldUntyped(op, ConstValue.fromReal(a.toDouble()),
                    ConstValue.fromReal(b.toDouble()));
            // Round to the precision of the target
            return ConstValue.fromReal(cast(double) cast(float) r.realVal);
        }
        immutable long x = t.wrap(a.intVal);
        immutable long y = t.wrap(b.intVal);
        long r;
        switch (op)
        {
        case "+":
            r = x + y;
            break;
        case "-":
            r = x - y;
            break;
        case "*":
            r = x * y;
            break;
        case "/":
            r = runtimeIntDiv(x, y);
            break;
        case "mod":
            r = runtimeIntMod(x, y);
            break;
        case "and":
            r = x & y;
            break;
        case "or":
            r = x | y;
            break;
        case "xor":
            r = x ^ y;
            break;
        default:
            assert(0, "Unknown operator " ~ op);
        }
        return ConstValue.fromInt(t.wrap(r));
    }

    /** Whether a constant chain can be evaluated in compile time in the given type */
    private bool isFoldable(ChainKind kind, ExprNode[] operands, Type t)
    {
        foreach (ref o; operands)
        {
            if (!o.isUntyped() && !o.getType().isConvertable(t))
            {
                return false;
            }
        }
        if (t.isBinaryInteger())
        {
            return true;
        }
        if (t.name == Type.FLOAT)
        {
            return kind != ChainKind.BITWISE;
        }
        if (t.name == Type.DEC)
        {
            return kind == ChainKind.ADDITIVE;
        }
        return false;
    }

    /** Adds up untyped constants in an additive chain */
    private void combineAdditive(ref ExprNode[] operands, ref string[] ops)
    {
        ExprNode[] rest;
        string[] restSigns;
        ConstValue sum = ConstValue.fromInt(0);
        int constCount = 0;
        foreach (i, ref o; operands)
        {
            immutable string sign = i == 0 ? "+" : ops[i - 1];
            if (o.isUntyped())
            {
                sum = tryFold(foldUntyped(sign, sum, (cast(ConstNode) o).value));
                constCount++;
            }
            else
            {
                rest ~= o;
                restSigns ~= sign;
            }
        }

        if (rest.length == 0)
        {
            operands = [new ConstNode(compiler, sum)];
            ops = [];
            return;
        }

        if (constCount < 2)
        {
            return;
        }

        if (operands[0].isUntyped())
        {
            operands = [cast(ExprNode) new ConstNode(compiler, sum)] ~ rest;
            ops = restSigns;
        }
        else
        {
            operands = rest;
            ops = restSigns[1 .. $];
            if (!sum.isZero())
            {
                ConstValue absSum = sum.isReal()
                    ? ConstValue.fromReal(-sum.realVal) : ConstValue.fromInt(-sum.intVal);
                ops ~= sum.isNegative() ? "-" : "+";
                operands ~= new ConstNode(compiler, sum.isNegative() ? absSum : sum);
            }
        }
    }

    /**
     * Merges adjacent untyped constants in a multiplicative or bitwise chain
     * where it's safe to do so
     */
    private void combineAdjacent(ChainKind kind, ref ExprNode[] operands, ref string[] ops)
    {
        ExprNode[] outOperands = [operands[0]];
        string[] outOps;
        foreach (i, ref op; ops)
        {
            ExprNode x = operands[i + 1];
            ExprNode prev = outOperands[$ - 1];
            bool merge = false;
            if (x.isUntyped() && prev.isUntyped())
            {
                if (outOperands.length == 1)
                {
                    // Leading constants
                    merge = true;
                }
                else
                {
                    immutable string prevOp = outOps[$ - 1];
                    merge = kind == ChainKind.MULTIPLICATIVE
                        ? (prevOp == "*" && op == "*") : (prevOp == op);
                }
            }
            if (merge)
            {
                outOperands[$ - 1] = new ConstNode(compiler, tryFold(foldUntyped(op,
                        (cast(ConstNode) prev).value, (cast(ConstNode) x).value)));
            }
            else
            {
                outOperands ~= x;
                outOps ~= op;
            }
        }
        operands = outOperands;
        ops = outOps;
    }

    private ExprNode makeChain(ChainKind kind, ExprNode[] operands, string[] ops)
    {
        if (operands.length == 1)
        {
            return operands[0];
        }

        if (kind == ChainKind.ADDITIVE)
        {
            combineAdditive(operands, ops);
        }
        else
        {
            combineAdjacent(kind, operands, ops);
        }

        if (operands.length == 1)
        {
            return operands[0];
        }

        Type t = operationType(operands);

        if (all!(o => o.isConstant())(operands) && isFoldable(kind, operands, t))
        {
            ConstValue acc = (cast(ConstNode) operands[0]).value;
            foreach (i, ref op; ops)
            {
                ConstValue next = (cast(ConstNode) operands[i + 1]).value;
                acc = tryFold(foldTyped(op, acc, next, t));
            }
            return new ConstNode(compiler, acc, t);
        }

        return new ChainNode(compiler, kind, operands, ops, t);
    }

    private ExprNode makeRelation(ExprNode left, string op, ExprNode right)
    {
        Type cmpType;
        Type lType = left.getType();
        Type rType = right.getType();
        if (left.isUntyped() && right.isUntyped())
        {
            cmpType = null;
        }
        else if (left.isUntyped())
        {
            cmpType = widen(rType, (cast(ConstNode) left).value);
        }
        else if (right.isUntyped())
        {
            cmpType = widen(lType, (cast(ConstNode) right).value);
        }
        // If one type is UINT16 and another is INT16, then we
        // convert both to INT24 to make sure we get the correct result
        else if ((lType.name == Type.INT16 && rType.name == Type.UINT16)
                || (lType.name == Type.UINT16 && rType.name == Type.INT16))
        {
            cmpType = getType(Type.INT24);
        }
        else
        {
            cmpType = lType.comparePrecedence(rType) ? lType : rType;
        }

        if (left.isConstant() && right.isConstant())
        {
            ConstValue a = (cast(ConstNode) left).value;
            ConstValue b = (cast(ConstNode) right).value;
            bool result;
            bool folded = true;
            if (cmpType is null)
            {
                result = compareValues(op, a, b);
            }
            else if (!(left.isUntyped() || lType.isConvertable(cmpType))
                    || !(right.isUntyped() || rType.isConvertable(cmpType)))
            {
                // Let the code generator report the error
                folded = false;
            }
            else if (cmpType.isBinaryInteger() && a.isInteger() && b.isInteger())
            {
                result = compareValues(op, ConstValue.fromInt(cmpType.wrap(a.intVal)),
                        ConstValue.fromInt(cmpType.wrap(b.intVal)));
            }
            else if (cmpType.name == Type.FLOAT || cmpType.name == Type.DEC)
            {
                result = compareValues(op, a, b);
            }
            else
            {
                folded = false;
            }
            if (folded)
            {
                return new ConstNode(compiler, ConstValue.fromInt(result ? 255 : 0),
                        getType(Type.UINT8));
            }
        }

        return new CompareNode(compiler, left, op, right, cmpType);
    }
}

/** Compiles an expression */
class Expression
{
    protected ParseTree node;
    protected Compiler compiler;
    protected string asmCode;
    private ExprNode root;

    /** If set, the result of the expression will be cast to the expected type */
    protected Type expectedType;

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        this.node = node;
        this.compiler = compiler;
        this.root = (new ExpressionBuilder(compiler)).build(node);
    }

    /** Set what type we expect from the expression */
    public void setExpectedType(Type type)
    {
        this.expectedType = type;
    }

    /**
     * The type of the expression. For untyped constant expressions
     * it's the smallest type that can hold the value.
     */
    public Type getType()
    {
        return this.root.getType();
    }

    /** Whether the expression evaluates to a constant */
    public bool isConstant()
    {
        return this.root.isConstant();
    }

    /** Whether the expression evaluates to an untyped constant */
    public bool isUntypedConstant()
    {
        return this.root.isUntyped();
    }

    /** The value of the expression if it's constant */
    public ConstValue getConstValue()
    {
        if (!this.isConstant())
        {
            compiler.displayError("Expression is not constant");
        }
        return (cast(ConstNode) this.root).value;
    }

    /** The value of the expression as float if it's constant */
    public float getConstVal()
    {
        return cast(float) this.getConstValue().toDouble();
    }

    /** Whether the expression holds a single constant string */
    public bool isConstantString()
    {
        return (cast(StringNode) this.root) !is null;
    }

    /** Length of the constant string after PETSCII conversion */
    public ulong getConstantStringLength()
    {
        immutable string str = (cast(StringNode) this.root).str;
        bool truncated;
        ulong finalLength;
        asciiToHex(str, 0UL, truncated, finalLength, asciiMode);
        return finalLength;
    }

    /** Evaluate the expression */
    public void eval()
    {
        Type type = this.getType();
        if (this.expectedType is null)
        {
            this.asmCode = this.root.emit();
            return;
        }

        if (!this.root.isUntyped() && this.expectedType.length < type.length)
        {
            compiler.displayWarning(
                    "Downcasting from " ~ type.name ~ " to " ~ this.expectedType.name
                    ~ " truncates value");
        }
        this.asmCode = this.root.emitAs(this.expectedType);
    }

    override string toString()
    {
        return asmCode;
    }

    /** Cast the expression to another type */
    public void castTo(Type targetType)
    {
        this.asmCode ~= this.getType().getCastCode(targetType);
    }
}
