module compiler.type;

import std.algorithm.searching;
import std.array, std.string;

import compiler.variable, compiler.constvalue;

/**
 * This class represents a variable type of the
 * language. The type can be primitive or user-defined.
 */
class Type
{
    static const string UINT8 = "byte";
    static const string UINT16 = "word";
    static const string INT16 = "int";
    static const string INT24 = "long";
    static const string FLOAT = "float";
    static const string STRING = "string";
    static const string DEC = "decimal";
    static const string VOID = "void";

    /** The name of the type as defined internally or by the user */
    string name;
    /** The number of bytes this type reserves in memory */
    ushort length;
    /** Primitive or user-defined type */
    bool isPrimitive = true;

    private Variable[] fields;

    /** Class constructor */
    this(string name, ushort length = 0)
    {
        this.name = toLower(name);
        this.length = length;
    }

    /** When this object is used in string context */
    override string toString()
    {
        return this.name;
    }

    /**
     * Returns true if this type's precedence is
     * higher than that of other_type's, false
     * otherwise
     */
    public bool comparePrecedence(Type that)
    {
        if (this.name == INT16 && that.name == UINT16)
        {
            return true;
        }
        // Force strings to be higher precedence
        if (this.name == STRING)
        {
            return true;
        }
        else if (that.name == STRING)
        {
            return false;
        }
        // Let the length decide
        return this.length > that.length;
    }

    /**
     * Calculates a theoretic "penalty" score that comes
     * with converting this type to another type.
     * This score can be used to choose among overloaded functions
     */
    public int getConversionPenalty(Type that)
    {
        if (this.name == INT16 && that.name == UINT16)
        {
            return 0;
        }
        if (this.length == that.length)
        {
            return 0;
        }
        if (this.length < that.length)
        {
            return that.length - this.length;
        }
        return (this.length - that.length) * 4;
    }

    /**
     * Add new field
     */
    public void addField(Variable field)
    {
        field.offsetWithinType = this.length;
        this.fields ~= field;
        this.length += field.getLength();
        if (this.length > 64)
        {
            throw new Exception("Type too wide (max: 64 bytes)");
        }
    }

    /**
     * Returns true if field identified by name
     * already exists
     */
    public bool hasField(string name)
    {
        return any!(t => t.name == name)(this.fields);
    }

    /**
     * Returns a reference to a field by name
     * make sure to call hasField beforehands
     */
    public Variable getField(string name)
    {
        foreach (ref var; fields)
        {
            if (var.name == name)
            {
                return var;
            }
        }

        assert(0);
    }

    /**
     * Takes a dot accessor notation (e.g x.y.z)
     * and returns how far the member is from the start
     * of a variable of this type
     */
    public ushort getMemberOffset(string dotNotation)
    {
        ushort len = 0;
        string[] chain = dotNotation.split(".");
        Variable field;
        Type t = this;
        for (int i = 0; i < chain.length; i++)
        {
            string key = toLower(chain[i]);
            if (t.hasField(key))
            {
                field = t.getField(key);
                len += field.offsetWithinType;
                t = field.type;
            }
            else
            {
                throw new Exception("Unknown field " ~ key ~ " in type " ~ this.name);
            }
        }
        return len;
    }

    /**
     * Takes a dot accessor notation (e.g x.y.z)
     * and returns the type of the last member
     */
    public Type getMemberType(string dotNotation)
    {
        string[] chain = dotNotation.split(".");
        Type t = this;
        for (int i = 0; i < chain.length; i++)
        {
            string key = toLower(chain[i]);
            if (t.hasField(key))
            {
                t = t.getField(key).type;
            }
            else
            {
                throw new Exception("Unknown field " ~ key ~ " in type " ~ this.name);
            }
        }
        return t;
    }

    /** Whether this type can be cast to another type */
    public bool isConvertable(Type target)
    {
        // Same types - sure
        if (this.name == target.name)
        {
            return true;
        }

        // Not internal types - no way
        if (!this.isPrimitive || !target.isPrimitive)
        {
            return false;
        }

        // Numeric/string mismatch
        if (this.isNumeric() ^ target.isNumeric())
        {
            return false;
        }

        // Cannot cast from/to decimal
        if (this.name == DEC || target.name == DEC)
        {
            return false;
        }

        return true;
    }

    /** Returns assembly code that casts number on stack to another type */
    public string getCastCode(Type target)
    {
        if (!isConvertable(target))
        {
            throw new Exception("Type " ~ this.name ~ " cannot be casted to type " ~ target.name);
        }

        // Same types - do nothing
        if (this.name == target.name)
        {
            return "";
        }

        // All the rest should be defined as a macro (might be a macro that does nothing)
        return "    F_c" ~ target.name ~ "_" ~ this.name ~ "\n";
    }

    /** Whether type holds a single number */
    public bool isNumeric()
    {
        return this.isPrimitive && this.name != STRING;
    }

    /** Whether this is an integral (integer) type */
    public bool isIntegral()
    {
        return this.isNumeric() && this.name != FLOAT;
    }

    /** Whether this is a signed type */
    public bool isSigned()
    {
        return this.isNumeric() && this.name != UINT8 && this.name != UINT16 && this.name != DEC;
    }

    /** Whether this is a binary integer type (BYTE, INT, WORD or LONG) */
    public bool isBinaryInteger()
    {
        return this.name == UINT8 || this.name == INT16 || this.name == UINT16
            || this.name == INT24;
    }

    /** Lowest value of an integer or decimal type */
    public long minValue()
    {
        switch (this.name)
        {
        case INT16:
            return -32_768;
        case INT24:
            return CONST_INT_MIN;
        case UINT8:
        case UINT16:
        case DEC:
            return 0;
        default:
            assert(0, "Not an integer type: " ~ this.name);
        }
    }

    /** Highest value of an integer or decimal type */
    public long maxValue()
    {
        switch (this.name)
        {
        case UINT8:
            return 255;
        case INT16:
            return 32_767;
        case UINT16:
            return 65_535;
        case INT24:
            return CONST_INT_MAX;
        case DEC:
            return 9999;
        default:
            assert(0, "Not an integer type: " ~ this.name);
        }
    }

    /** Whether a constant value can be represented in this type without loss */
    public bool canHold(ConstValue value)
    {
        if (this.name == FLOAT)
        {
            return true;
        }
        if (this.name == DEC)
        {
            return value.isInteger() && value.intVal >= 0 && value.intVal <= 9999;
        }
        if (!this.isBinaryInteger() || !value.isInteger())
        {
            return false;
        }
        if (value.intVal >= this.minValue() && value.intVal <= this.maxValue())
        {
            return true;
        }
        // A negative bit pattern (e.g NOT 0) fits in an unsigned type of the same width
        return value.isBitPattern && !this.isSigned()
            && value.intVal >= -(1L << (this.length * 8 - 1));
    }

    /**
     * Wraps an integer to the range of this type, the same way
     * as it happens on the target machine
     */
    public long wrap(long value)
    {
        if (this.name == DEC)
        {
            return ((value % 10_000) + 10_000) % 10_000;
        }
        immutable int bits = this.length * 8;
        long result = value & ((1L << bits) - 1);
        if (this.isSigned() && result >= (1L << (bits - 1)))
        {
            result -= (1L << bits);
        }
        return result;
    }
}

/** Holds all types defined in the program */
final class TypeCollection
{
    private Type[] types;

    /** Class constructor */
    this()
    {
        // Create the default types;
        add(new Type(Type.VOID, 0));
        add(new Type(Type.UINT8, 1));
        add(new Type(Type.INT16, 2));
        add(new Type(Type.UINT16, 2));
        add(new Type(Type.INT24, 3));
        add(new Type(Type.FLOAT, 4));
        add(new Type(Type.DEC, 2));
        // String length is defined in the variable, not here
        add(new Type(Type.STRING));
    }

    /** Add a type to the collection */
    public void add(Type type)
    {
        this.types ~= type;
    }

    /** Retrieve a type by name */
    public Type get(string typeName)
    {
        foreach (Type t; this.types)
        {
            if (toLower(t.name) == toLower(typeName))
            {
                return t;
            }
        }

        assert(0);
    }

    /**
     * Returns the smallest type that can hold the value
     * (FLOAT for real numbers)
     */
    public Type getSmallestFitting(ConstValue value)
    {
        if (value.isReal())
        {
            return get(Type.FLOAT);
        }
        immutable long v = value.intVal;
        if (v < -32_768 || v > 65_535)
        {
            return get(Type.INT24);
        }
        if (v > 32_767)
        {
            return get(Type.UINT16);
        }
        if (v >= 0 && v < 256)
        {
            return get(Type.UINT8);
        }
        return get(Type.INT16);
    }

    /** Returns whether the type is already defined */
    public bool defined(string name)
    {
        return any!(t => toLower(t.name) == toLower(name))(this.types);
    }
}
