module compiler.number;

import std.stdio, std.conv, std.string, std.algorithm, std.math, std.system,
        std.array, std.range, std.format;
import pegged.grammar;
import compiler.compiler, compiler.petscii, compiler.type;

/** Parses a numeric literal */
class Number
{
    /** The parsed value, if integral type */
    public int intVal;
    /** The parsed value, if real type */
    public float floatVal;
    /** The inferred type */
    public Type type;

    private static const int intRangeLow = -8_388_608;
    private static const int intRangeHigh = 8_388_607;

    /** Class constructor */
    this(const ParseTree node, Compiler compiler, bool forceFloat = false)
    {
        string numString = join(node.matches);
        int num;
        final switch(node.children[0].name) {
            case "XCBASIC.Integer":
                num = to!int(numString);
                if(num < intRangeLow || num > intRangeHigh) {
                    compiler.displayError("Number out of range");
                }
                this.intVal = num;
                break;

            case "XCBASIC.Hexa":
                numString = numString[1..$];
                num = to!int(numString, 16);
                if(num > intRangeHigh) {
                    compiler.displayError("Number out of range");
                }
                this.intVal = num;
                break;

            case "XCBASIC.Binary":
                numString = numString[1..$];
                num = to!int(numString, 2);
                if(num > intRangeHigh) {
                    compiler.displayError("Number out of range");
                }
                this.intVal = num;
                break;

            case "XCBASIC.Floating":
            case "XCBASIC.Scientific":
                try {
                    this.floatVal = to!real(numString);
                    this.type = compiler.getTypes().get(Type.FLOAT);
                }
                catch(Exception e) {
                    compiler.displayError("Can't parse number " ~ numString);
                }
                break;

            case "XCBASIC.Decimal":
                this.intVal = to!int(numString[0..$-1]);
                this.type = compiler.getTypes().get(Type.DEC);
                if(intVal < 0 || intVal > 9999) {
                    compiler.displayError("Number out of range");
                }
                break;
        }

        if(this.type is null) {
            if(this.intVal < -32_768 || this.intVal > 65_535) {
                this.type = compiler.getTypes().get(Type.INT24);
            }
            else if(this.intVal > 32_767) {
                this.type = compiler.getTypes().get(Type.UINT16);
            }
            else if(this.intVal >= 0 && this.intVal < 256) {
                this.type = compiler.getTypes().get(Type.UINT8);
            }
            else {
                this.type = compiler.getTypes().get(Type.INT16);
            }
        }

        if((this.type.name != Type.FLOAT) && forceFloat) {
            this.floatVal = to!float(this.intVal);
            this.type = compiler.getTypes().get(Type.FLOAT);
        }
    }

    /** Convert binary float to Hexadecimal */
    public static string floatToHex(float value, string prefix = "")
    {   
        // Zero is special case
        if(value == 0.0) {
            return "00,00,00,00";
        }

        const int bias = 128; 
        immutable bool sign = value < 0;
        int exponent;
        float mantissa = abs(frexp(value, exponent));
        exponent += bias;

        ubyte[3] mantToBin(float mantissa) {
            uint mantAsInt = 0;
            float div;
            float mod;
            float v;
            int bit = 23;
            while(bit >= 0 && mantissa > 0) {
                v = pow(2f, bit - 24);
                div = floor(mantissa / v);
                mod = mantissa - div * v;
                mantissa = mod;
                mantAsInt += cast(int)(div * pow(2, bit));
                bit--;
            }

            return [cast(ubyte)(mantAsInt >> 16),
                    cast(ubyte)((mantAsInt & 0x00ff00) >> 8),
                    cast(ubyte)(mantAsInt & 0x0000ff)];
        }

        ubyte[3] binaryMant = mantToBin(mantissa);
        if(sign) {
            binaryMant[0] |= 0x80;
        }
        else {
            binaryMant[0] &= 0x7f;
        }

        return format("%s%02x,%s%02x,%s%02x,%s%02x", 
            prefix, exponent,
            prefix, binaryMant[0],
            prefix, binaryMant[1],
            prefix, binaryMant[2]
        );
    }

    /** Returns assembly code that pushes the number on stack */
    public string getPushCode()
    {
        if(this.type.name == Type.FLOAT) {
            return "    pfloat " ~ floatToHex(this.floatVal) ~ "\n";
        }
        else if(this.type.name == Type.DEC) {
            return "    pdecimal " ~ getDecimalAsHex(this.intVal) ~ "\n";
        }

        return "    p" ~ this.type.name ~ " " ~ to!string(this.intVal) ~ "\n";
    }

    /** Convert binary decimal to Hexadecimal */
    public static string getDecimalAsHex(int value, string prefix = "")
    {
        immutable string fullNum = to!string(rightJustifier(to!string(value), 4, '0'));
        return prefix ~ fullNum[2..$] ~ "," ~ prefix ~ fullNum[0..2];
    }

    /** Convert any integral type to hexadecimal, optionnaly validating the number */
    public static string integralToHex(int value, Type type, bool validate = false, string prefix = "")
    {
        if(validate) {
            bool valid;
            switch(type.name) {
                case Type.UINT8:
                    valid = (value >= 0 && value <= 255);
                    break;
                case Type.INT16:
                    valid = (value >= -32_768 && value <= 32_767);
                    break;
                case Type.UINT16:
                    valid = (value >= 0 && value <= 65_535);
                    break;
                case Type.INT24:
                    valid = (value >= intRangeLow && value <= intRangeHigh);
                    break;
                default:
                    assert(0, "Not an integral type");    
            }
            if(!valid) {
                throw new Exception("Number is out of " ~ toUpper(type.name) ~ " range");
            }
        }
        string[] bytes;
        for(int i = 0; i < type.length; i++) {
            bytes ~= prefix ~ to!string(rightJustifier(to!string((value & (255 << (i * 8))) >> (i * 8), 16), 2, '0'));
        }
        return bytes.join(",");
    }
}