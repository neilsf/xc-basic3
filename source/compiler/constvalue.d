module compiler.constvalue;

import std.conv, std.math;

/** Lowest integer value the compiler can handle (LONG range) */
enum long CONST_INT_MIN = -8_388_608;
/** Highest integer value the compiler can handle (LONG range) */
enum long CONST_INT_MAX = 8_388_607;

/** A numeric value that is known in compile time */
struct ConstValue
{
    /** Integer or real number */
    enum Kind
    {
        INTEGER,
        REAL
    }

    /** The kind of the value */
    Kind kind = Kind.INTEGER;
    /** The value, if integer */
    long intVal = 0;
    /** The value, if real */
    double realVal = 0.0;
    /**
     * Set when the value was produced by a bitwise complement (NOT).
     * Such a negative value represents a bit pattern and may be
     * stored in an unsigned type of the same width.
     */
    bool isBitPattern = false;

    /** Creates an integer value */
    static ConstValue fromInt(long value, bool bitPattern = false)
    {
        ConstValue v;
        v.kind = Kind.INTEGER;
        v.intVal = value;
        v.realVal = cast(double) value;
        v.isBitPattern = bitPattern && value < 0;
        return v;
    }

    /** Creates a real value */
    static ConstValue fromReal(double value)
    {
        ConstValue v;
        v.kind = Kind.REAL;
        v.realVal = value;
        v.intVal = 0;
        return v;
    }

    /** Whether the value is an integer */
    bool isInteger() const
    {
        return kind == Kind.INTEGER;
    }

    /** Whether the value is a real number */
    bool isReal() const
    {
        return kind == Kind.REAL;
    }

    /** The value as a double */
    double toDouble() const
    {
        return isInteger() ? cast(double) intVal : realVal;
    }

    /** The value as an integer (reals are truncated) */
    long toLong() const
    {
        return isInteger() ? intVal : cast(long) realVal;
    }

    /** Whether the value is zero */
    bool isZero() const
    {
        return isInteger() ? intVal == 0 : realVal == 0.0;
    }

    /** Whether the value is negative */
    bool isNegative() const
    {
        return isInteger() ? intVal < 0 : realVal < 0.0;
    }

    /** String representation */
    string toString() const
    {
        return isInteger() ? to!string(intVal) : to!string(cast(float) realVal);
    }
}

/** Thrown when a constant expression can not be evaluated */
class ConstEvalException : Exception
{
    /** Class constructor */
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

/** Integer division as performed by the runtime library (truncates toward zero) */
long runtimeIntDiv(long a, long b)
{
    if (b == 0)
    {
        throw new ConstEvalException("Division by zero");
    }
    return a / b;
}

/**
 * Integer modulo as performed by the runtime library
 * (the remainder of the absolute values, always non-negative)
 */
long runtimeIntMod(long a, long b)
{
    if (b == 0)
    {
        throw new ConstEvalException("Division by zero");
    }
    return abs(a) % abs(b);
}

/** Float modulo as performed by the runtime library: a - INT(a / b) * b */
double runtimeFloatMod(double a, double b)
{
    if (b == 0.0)
    {
        throw new ConstEvalException("Division by zero");
    }
    return a - floor(a / b) * b;
}

/**
 * Evaluates a binary operation on untyped values with exact
 * arithmetic. Throws ConstEvalException on error.
 */
ConstValue foldUntyped(string op, ConstValue a, ConstValue b)
{
    ConstValue result;
    if (a.isReal() || b.isReal())
    {
        immutable double x = a.toDouble();
        immutable double y = b.toDouble();
        switch (op)
        {
        case "+":
            result = ConstValue.fromReal(x + y);
            break;
        case "-":
            result = ConstValue.fromReal(x - y);
            break;
        case "*":
            result = ConstValue.fromReal(x * y);
            break;
        case "/":
            if (y == 0.0)
            {
                throw new ConstEvalException("Division by zero");
            }
            result = ConstValue.fromReal(x / y);
            break;
        case "mod":
            result = ConstValue.fromReal(runtimeFloatMod(x, y));
            break;
        default:
            throw new ConstEvalException("Can't do bitwise operation on a(n) float");
        }
        return result;
    }

    immutable long x = a.intVal;
    immutable long y = b.intVal;
    bool bitPattern = false;
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
        bitPattern = a.isBitPattern || b.isBitPattern;
        break;
    case "or":
        r = x | y;
        bitPattern = a.isBitPattern || b.isBitPattern;
        break;
    case "xor":
        r = x ^ y;
        bitPattern = a.isBitPattern || b.isBitPattern;
        break;
    default:
        assert(0, "Unknown operator " ~ op);
    }
    if (r < CONST_INT_MIN || r > CONST_INT_MAX)
    {
        throw new ConstEvalException("Constant overflow: the result of the constant expression ("
                ~ to!string(r) ~ ") is out of range (" ~ to!string(
                    CONST_INT_MIN) ~ " to " ~ to!string(CONST_INT_MAX) ~ ")");
    }
    return ConstValue.fromInt(r, bitPattern);
}

/** Compares two values */
bool compareValues(string op, ConstValue a, ConstValue b)
{
    int c;
    if (a.isReal() || b.isReal())
    {
        immutable double x = a.toDouble(), y = b.toDouble();
        c = x < y ? -1 : (x > y ? 1 : 0);
    }
    else
    {
        c = a.intVal < b.intVal ? -1 : (a.intVal > b.intVal ? 1 : 0);
    }
    switch (op)
    {
    case "<":
        return c < 0;
    case ">":
        return c > 0;
    case "=":
        return c == 0;
    case "<>":
        return c != 0;
    case "<=":
        return c <= 0;
    case ">=":
        return c >= 0;
    default:
        assert(0, "Unknown relational operator " ~ op);
    }
}

unittest
{
    assert(foldUntyped("+", ConstValue.fromInt(250), ConstValue.fromInt(6)).intVal == 256);
    assert(foldUntyped("-", ConstValue.fromInt(5), ConstValue.fromInt(10)).intVal == -5);
    assert(foldUntyped("/", ConstValue.fromInt(-7), ConstValue.fromInt(2)).intVal == -3);
    assert(foldUntyped("mod", ConstValue.fromInt(-7), ConstValue.fromInt(2)).intVal == 1);
    assert(foldUntyped("/", ConstValue.fromInt(7), ConstValue.fromReal(2.0)).realVal == 3.5);
    assert(compareValues("<", ConstValue.fromInt(1), ConstValue.fromInt(2)));
}
