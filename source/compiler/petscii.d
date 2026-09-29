module compiler.petscii;

import std.string, std.conv, std.array, std.algorithm.searching,
        std.algorithm.comparison, std.algorithm.iteration;

private ubyte[] petscii = [
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x14, 0x20, 0x0d, 0x11,
    0x93, 0x0a, 0x0e, 0x0f, 0x10, 0x0b, 0x12, 0x13, 0x08, 0x15, 0x16, 0x17,
    0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23,
    0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b,
    0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
    0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf, 0xd0, 0xd1, 0xd2, 0xd3,
    0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f,
    0xc0, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b,
    0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57,
    0x58, 0x59, 0x5a, 0xdb, 0xdc, 0xdd, 0xde, 0xdf, 0x80, 0x81, 0x82, 0x83,
    0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
    0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b,
    0x9c, 0x9d, 0x9e, 0x9f, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7,
    0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf, 0xb0, 0xb1, 0xb2, 0xb3,
    0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
    0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b,
    0x6c, 0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,
    0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f, 0xe0, 0xe1, 0xe2, 0xe3,
    0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
    0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb,
    0xfc, 0xfd, 0xfe, 0xff
];

private ubyte[string] escapeSequencesPETSCII;
private ubyte[string] escapeSequencesASCII;

static this()
{
    escapeSequencesPETSCII = [
        "CLR": 0x93,
        "CLEAR": 0x93,
        "HOME": 0x13,
        "INSERT": 0x94,
        "INS": 0x94,
        "DELETE": 0x14,
        "DEL": 0x14,
        "CR": 0x0d,
        "RETURN": 0x0d,
        "REV_ON": 0x12,
        "REVERSE ON": 0x12,
        "REV_OFF": 0x92,
        "REVERSE OFF": 0x92,
        "CRSR_UP": 0x91,
        "UP": 0x91,
        "CRSR_DOWN": 0x11,
        "DOWN": 0x11,
        "CRSR_LEFT": 0x9d,
        "LEFT": 0x9d,
        "CRSR_RIGHT": 0x1d,
        "RIGHT": 0x1d,
        "SPACE": 0x20,
        "WHITE": 0x05,
        "RED": 0x1c,
        "GREEN": 0x1e,
        "BLUE": 0x1f,
        "ORANGE": 0x81,
        "BLACK": 0x90,
        "BROWN": 0x95,
        "LIGHT_RED": 0x96,
        "PINK": 0x96,
        "DARK_GRAY": 0x97,
        "DARK GRAY": 0x97,
        "MED_GRAY": 0x98,
        "GRAY": 0x98,
        "LIGHT_GREEN": 0x99,
        "LIGHT GREEN": 0x99,
        "LIGHT_BLUE": 0x9a,
        "LIGHT BLUE": 0x9a,
        "LIGHT_GRAY": 0x9b,
        "LIGHT GRAY": 0x9b,
        "PURPLE": 0x9c,
        "YELLOW": 0x9e,
        "CYAN": 0x9f,
        "LOWER_CASE": 0x0e,
        "UPPER_CASE": 0x8e,
        "F1": 0x85,
        "F2": 0x86,
        "F3": 0x87,
        "F4": 0x88,
        "F5": 0x89,
        "F6": 0x8a,
        "F7": 0x8b,
        "F8": 0x8c,
        "POUND": 0x5c,
        "ARROW UP": 0x5e,
        "ARROW_UP": 0x5e,
        "ARROW LEFT": 0x5f,
        "ARROW_LEFT": 0x5f,
        "PI": 0xff,
        "QUOTE": 0x22
    ];

    escapeSequencesASCII = [
        "QUOTE": 0x22,
        "LCUB": 0x7b,
        "RCUB": 0x7d,
        "DEL": 0x7f
    ];
}

/** Translates ASCII string to ASCII or PETSCII HEX expression */
string asciiToHex(
    string asciiString,
    ulong forcedLength,
    out bool truncated,
    out ulong finalLength,
    bool asciiMode = false
)
{
    ubyte[] bytes;
    if (asciiMode)
    {
        bytes = cast(ubyte[])(unescapeString(asciiString, escapeSequencesASCII));
    }
    else
    {
        bytes = asciiToPetsciiBytes(unescapeString(asciiString, escapeSequencesPETSCII));
    }
    

    if (forcedLength > 0)
    {
        if (bytes.length > forcedLength)
        {
            finalLength = forcedLength;
            truncated = true;
        }
        else
        {
            finalLength = forcedLength;
            truncated = false;
        }
    }
    else
    {
        finalLength = bytes.length;
        truncated = false;
    }

    ulong length = forcedLength > 0 ? min(bytes.length, forcedLength) : bytes.length;
    string hex = "HEX " ~ rightJustify(to!string(length, 16), 2, '0') ~ " ";

    int counter = 0;
    ubyte value;
    for (ubyte i = 0; i < finalLength; i++)
    {
        value = (i < bytes.length ? bytes[i] : 0);
        hex ~= rightJustify(to!string(value, 16), 2, '0') ~ " ";
        counter++;
        if (counter == 16 && (i + 1 < finalLength))
        {
            hex ~= "\n\tHEX ";
            counter = 0;
        }
    }
    return hex;
}

private string unescapeString(string str, ubyte[string] escapeSequences)
{
    bool inEscapeSequence = false;
    string unescapedStr = "";
    string accu = "";
    for (int i = 0; i < str.length; i++)
    {
        char curChar = str[i];
        if (inEscapeSequence)
        {
            if (curChar == '}')
            {
                inEscapeSequence = false;
                if (isNumeric(accu))
                {
                    accu = to!string(cast(char) to!ubyte(accu));
                }
                else
                {
                    ubyte* replaced = toUpper(accu) in escapeSequences;
                    accu = (replaced !is null) ? to!string(cast(char)*replaced) : "";
                }
                unescapedStr ~= accu;
                accu = "";
            }
            else
            {
                accu ~= curChar;
            }
        }
        else
        {
            if (curChar == '{')
            {
                inEscapeSequence = true;
                accu = "";
            }
            else
            {
                unescapedStr ~= curChar;
            }
            
        }
    }
    return unescapedStr;
}

private ubyte[] asciiToPetsciiBytes(string asciiString)
{
    return (cast(const(ubyte)[]) asciiString).map!(c => petscii[c]).array;
}

unittest
{
    import fluent.asserts;

    // unescapeString: plain text is passed through unchanged
    Assert.equal(unescapeString("HELLO", escapeSequencesPETSCII), "HELLO");

    // unescapeString: named escape sequence is replaced with its byte value
    Assert.equal(unescapeString("{CLR}", escapeSequencesPETSCII), "\x93");
    Assert.equal(unescapeString("{HOME}", escapeSequencesPETSCII), "\x13");

    // unescapeString: escape sequence lookup is case-insensitive
    Assert.equal(unescapeString("{clr}", escapeSequencesPETSCII), "\x93");

    // unescapeString: numeric escape sequence is converted to the raw byte
    Assert.equal(unescapeString("{65}", escapeSequencesPETSCII), "A");
    Assert.equal(unescapeString("{0}", escapeSequencesPETSCII), "\x00");

    // unescapeString: unknown escape sequence is dropped, leaving an empty replacement
    Assert.equal(unescapeString("{UNKNOWN}", escapeSequencesPETSCII), "");

    // unescapeString: escape sequences mixed in with plain text
    Assert.equal(unescapeString("A{CLR}B", escapeSequencesPETSCII), "A\x93B");

    // unescapeString: ASCII escape sequence table is used when specified
    Assert.equal(unescapeString("{QUOTE}", escapeSequencesASCII), "\"");
    Assert.equal(unescapeString("{DEL}", escapeSequencesASCII), "\x7f");

    // asciiToPetsciiBytes: uppercase ASCII letters map to PETSCII screen codes
    Assert.equal(asciiToPetsciiBytes("A"), [0xc1]);
    Assert.equal(asciiToPetsciiBytes("ABC"), [0xc1, 0xc2, 0xc3]);

    // asciiToPetsciiBytes: digits and space map to themselves
    Assert.equal(asciiToPetsciiBytes("0"), [0x30]);
    Assert.equal(asciiToPetsciiBytes(" "), [0x20]);

    // asciiToHex: simple string produces a HEX literal with a byte-count prefix
    bool truncated;
    ulong finalLength;
    string hex = asciiToHex("AB", 0, truncated, finalLength);
    Assert.equal(hex, "HEX 02 C1 C2 ");
    Assert.isFalse(truncated);
    Assert.equal(finalLength, 2);

    // asciiToHex: forced length shorter than the string marks it as truncated
    hex = asciiToHex("ABCD", 2, truncated, finalLength);
    Assert.equal(hex, "HEX 02 C1 C2 ");
    Assert.isTrue(truncated);
    Assert.equal(finalLength, 2);

    // asciiToHex: forced length longer than the string pads with zero bytes
    hex = asciiToHex("A", 3, truncated, finalLength);
    Assert.equal(hex, "HEX 03 C1 00 00 ");
    Assert.equal(truncated, false);
    Assert.equal(finalLength, 3);

    // asciiToHex: escape sequences are resolved before conversion to PETSCII
    hex = asciiToHex("{CLR}", 0, truncated, finalLength);
    Assert.equal(hex, "HEX 01 93 ");
    Assert.equal(truncated, true);
    Assert.equal(finalLength, 1);

    hex = asciiToHex("A{CLR}B", 0, truncated, finalLength);
    Assert.equal(hex, "HEX 03 C1 93 C2 ");
    Assert.equal(finalLength, 3);
}