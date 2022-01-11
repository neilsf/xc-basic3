module statement.data_stmt;

import std.array;

import pegged.grammar;

import language.statement, compiler.compiler, compiler.type, compiler.number, compiler.intermediatecode;

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
            compiler.displayError("Only primitive types are allowed in a DATA statement");
        }
        type = compiler.getTypes().get(typeName);
        if(!type.isPrimitive) {
            compiler.displayError("Only primitive types are allowed in a DATA statement");
        }

        const ParseTree dataListNode = node.children[0].children[1];
        string[] listItems;
        foreach (datum; dataListNode.children) {
            if(type.name == Type.STRING) {
                if(datum.name != "XCBASIC.String") {
                    compiler.displayError("Type mismatch: expected string, got number");
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