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

        foreach (datum; dataListNode.children) {
            switch (datum.name) {
                case "XCBASIC.String":
                    if (type.name != Type.STRING) {
                        compiler.displayError("Type mismatch: expected number, label reference or constant, got string");
                    }
                    compiler.getImCode().appendSegment(
                        inlineData ? IntermediateCode.PROGRAM_SEGMENT : IntermediateCode.DATA_SEGMENT,
                        "    "  ~ asciiToPetsciiHex(join(datum.matches[1..$-1]), strLen, truncated, finalLength) ~ "\n"
                    );
                    if(truncated) {
                        compiler.displayWarning("String truncated to " ~ to!string(strLen) ~ " characters");
                    }
                break;

                case "XCBASIC.Number":
                    if (type.name == Type.STRING) {
                        compiler.displayError("Type mismatch: expected string, got number");
                    }
                    Number num = new Number(datum, compiler, type.name == Type.FLOAT);
                    listItems ~= getNumberAsString(num.intVal, num.floatVal, type);
                break;

                case "XCBASIC.Varname":
                    if (type.name == Type.STRING) {
                        compiler.displayError("Type mismatch: expected string, got constant");
                    }
                    Variable var = compiler.getVars().findVisible(datum.matches.join);
                    if (var !is null) {
                        if (!var.isConst) {
                            compiler.displayError("DATA must be constant");
                        }
                        listItems ~= getNumberAsString(to!int(var.constVal), var.constVal, type);
                    }
                    else {
                        compiler.displayError("Unknown constant \"" ~ datum.matches.join ~ "\"");
                    }
                break;

                case "XCBASIC.Label_deref":
                    if (type.name == Type.STRING) {
                        compiler.displayError("Type mismatch: expected string, got label reference");
                    }
                    if (type.name != Type.UINT16 && type.name != Type.INT16) {
                        compiler.displayError("Type mismatch: a label reference can only be part of INT or WORD data");
                    }
                    immutable string identifier = join(datum.children[0].matches);
                    if (compiler.getLabels().exists(identifier, false)) {
                        immutable string localLabel = compiler.getLabels().toAsmLabel(identifier);
                        listItems ~= "<" ~ localLabel;
                        listItems ~= ">" ~ localLabel;
                    } else {
                        compiler.displayError("Unknown label \"" ~ identifier ~ "\"");
                    }
                break;

                default:
                    assert(0);
            }
        }
            
        if (listItems.length > 0) {
            foreach(chunk; chunks(listItems, 8)) {
                compiler.getImCode().appendSegment(
                    inlineData ? IntermediateCode.PROGRAM_SEGMENT : IntermediateCode.DATA_SEGMENT,
                    "    DC.B " ~ chunk.join(",") ~ "\n"
                );
            }
        }
    }

    // Translates a numeric value to its string representation
    private string getNumberAsString(int intVal, float floatVal, Type type)
    {
        switch(type.name) {
            case Type.FLOAT:
                return Number.floatToHex(floatVal, "$");

            case Type.DEC:
                return Number.getDecimalAsHex(intVal, "$");

            default:
                return Number.integralToHex(intVal, type, true, "$");
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