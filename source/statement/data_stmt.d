module statement.data_stmt;

import std.array, std.conv, std.range;

import pegged.grammar;

import language.statement, compiler.petscii, compiler.variable,
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
        float floatVal;
        int intVal;
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
                if(datum.name == "XCBASIC.Number") {
                    Number num = new Number(datum, compiler, type.name == Type.FLOAT);
                    floatVal = num.floatVal;
                    intVal = num.intVal;
                } else {
                    // A constant
                    Variable var = compiler.getVars().findVisible(datum.matches.join);
                    if(var !is null) {
                        if(!var.isConst) {
                            compiler.displayError("DATA must be constant");
                        }
                        // a constant
                        floatVal = var.constVal;
                        intVal = to!int(var.constVal);
                    }
                    else {
                        compiler.displayError("Unknown constant \"" ~ datum.matches.join ~ "\"");
                    }
                }
                try {
                    switch(type.name) {
                        case Type.FLOAT:
                            listItems ~= Number.floatToHex(floatVal, "$");
                        break;

                        case Type.DEC:
                            listItems ~= Number.getDecimalAsHex(intVal, "$");
                        break;

                        default:
                            listItems ~= Number.integralToHex(intVal, type, true, "$");
                        break;
                    }
                }
                catch(Exception e) {
                    compiler.displayError(e.msg);
                }
                
            }
        }
        if(listItems.length > 0) {
            foreach(chunk; chunks(listItems, 8)) {
                 compiler.getImCode().appendSegment(
                    inlineData ? IntermediateCode.PROGRAM_SEGMENT : IntermediateCode.DATA_SEGMENT,
                    "    DC.B " ~ chunk.join(",") ~ "\n"
                );
            }
        }
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