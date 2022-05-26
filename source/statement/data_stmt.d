module statement.data_stmt;

import std.array, std.conv;

import pegged.grammar;

import language.statement, compiler.petscii,
        compiler.compiler, compiler.type, compiler.number, compiler.intermediatecode;

import globals;

class Data_stmt : Statement
{
    private Type type;

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    public void process()
    {
        const ParseTree varTypeNode = node.children[0].children[0];
        string typeName = varTypeNode.children[0].matches.join("");
        if(!compiler.getTypes().defined(typeName)) {
            compiler.displayError("Unknown type: " ~ typeName);
        }
        type = compiler.getTypes().get(typeName);
        if(!type.isPrimitive) {
            compiler.displayError("Only primitive types are allowed in a DATA statement");
        }
        ubyte strLen;
        if(type.name == Type.STRING) {
            if(varTypeNode.children.length < 2) {
                compiler.displayError("String length must be specified");
            }
            immutable int len = to!int(join(varTypeNode.children[1].matches)[1..$]);
            if(len < 1 || len > stringMaxLength) {
                compiler.displayError("String length must be between 1 and " ~ to!string(stringMaxLength));
            }
            strLen = to!ubyte(len);
        }

        const ParseTree dataListNode = node.children[0].children[1];
        string[] listItems;
        bool truncated;
        ulong finalLength;
        foreach (datum; dataListNode.children) {
            if(type.name == Type.STRING) {
                if(datum.name != "XCBASIC.String") {
                    compiler.displayError("Type mismatch: expected string, got number");
                }
                compiler.getImCode().appendSegment(
                    inlineData ? IntermediateCode.PROGRAM_SEGMENT : IntermediateCode.DATA_SEGMENT,
                    "    "  ~ asciiToPetsciiHex(join(datum.matches[1..$-1]), strLen, truncated, finalLength) ~ "\n"
                );
                if(truncated) {
                    compiler.displayWarning("String truncated to " ~ to!string(strLen) ~ " characters");
                }
            }
            else {
                if(datum.name == "XCBASIC.String") {
                    compiler.displayError("Type mismatch: expected number, got string");
                }
                Number num = new Number(datum, compiler, type.name == Type.FLOAT);
                try {
                    switch(type.name) {
                        case Type.FLOAT:
                            listItems ~= Number.floatToHex(num.floatVal, "$");
                        break;

                        case Type.DEC:
                            listItems ~= Number.getDecimalAsHex(num.intVal, "$");
                        break;

                        default:
                            listItems ~= Number.integralToHex(num.intVal, type, true, "$");
                        break;
                    }
                }
                catch(Exception e) {
                    compiler.displayError(e.msg);
                }
                
            }
        }
        compiler.getImCode().appendSegment(
            inlineData ? IntermediateCode.PROGRAM_SEGMENT : IntermediateCode.DATA_SEGMENT,
            "    DC.B " ~ listItems.join(",") ~ "\n"
        );
    }

    // Immediately preceding labels should go to DATA segment
    override protected void dumpLabels()
    {
        compiler.getImCode().appendSegment(
            inlineData ? IntermediateCode.PROGRAM_SEGMENT : IntermediateCode.DATA_SEGMENT,
            compiler.getAndClearCurrentLabels()
        );
    }
}