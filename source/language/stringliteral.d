module language.stringliteral;

import compiler.compiler, compiler.intermediatecode, compiler.petscii;
import std.conv;

/** Compiles string literals to appropriate HEX data */
class StringLiteral
{
    /** An id to refer to the last element */
    public static ushort id = 0;

    private Compiler compiler;
    private string str;

    /** Class constructor */
    this(string str, Compiler compiler)
    {
        id += 1;
        this.compiler = compiler;
        this.str = str;
    }

    /** Registers a string literal and outputs it in hex data to data segment */
    void register()
    {
        bool truncated;
        immutable data = asciiToPetsciiHex(this.str, 0UL, truncated);
        compiler.getImCode().appendSegment(
            IntermediateCode.DATA_SEGMENT,
            "_S" ~ to!string(id) ~ " " ~ data ~ "\n"
        );
    }
}
