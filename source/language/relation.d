module language.relation;

import std.array, std.conv;

import pegged.grammar;

import compiler.type, compiler.compiler;
import language.expression;
import language.simplexp;

/** Evaluates a relation */
class Relation : AbstractExpression
{
    private string[string] opMap;

    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
        opMap = [
            "<" :  "lt",
            ">" :  "gt",
            "=" :  "eq",
            "<>" : "neq",
            "<=" : "lte",
            ">=" : "gte"
        ];
    }

    override protected void detectType()
    {
        if(this.node.children.length > 1) {
            // The value of a relation is true or false
            this.type = compiler.getTypes().get(Type.UINT8);
        }
        else {
            // Otherwise it's the same as the single member's type
            super.detectType();
        }
    }

    override protected ExpressionInterface makeChild(ParseTree node)
    {
        return new Simplexp(node, compiler);
    }

    override protected string getChildName()
    {
        return "XCBASIC.Simplexp";
    }

    /** Evaluate and create ASM code */
    public void eval()
    {
        this.asmCode = "";

        Type expectedType = this.type;

        ExpressionInterface left = this.makeChild(this.node.children[0]);
        ExpressionInterface right;

        // Has left and right
        if(this.node.children.length > 1) {
            right = this.makeChild(this.node.children[1]);
            // If one type is UINT16 and another is INT16, then we
            // convert both to INT24 to make sure we get the correct result
            if(
                (left.getType().name == Type.INT16 && right.getType().name == Type.UINT16) || 
                (left.getType().name == Type.UINT16 && right.getType().name == Type.INT16)
                ) {
                expectedType = compiler.getTypes().get(Type.INT24);
            }
            // If one type is a string and another one is numeric then
            // we can't evaluate
            else if(
                (left.getType().name == Type.STRING && right.getType().name != Type.STRING) || 
                (left.getType().name != Type.STRING && right.getType().name == Type.STRING)
                ) {
                compiler.displayError("Strings can't be compared to other types");
            }
            // Only primitive types can be compared
            else if(!left.getType().isPrimitive || !right.getType().isPrimitive) {
                compiler.displayError("Only primitive types can be compared in a relation");
            }
            // Otherwise convert to the larger one as usual
            else {
                expectedType = left.getType().comparePrecedence(right.getType()) ? left.getType() : right.getType();
            }

            left.setExpectedType(expectedType);
            right.setExpectedType(expectedType);

            left.eval();
            right.eval();

            this.asmCode ~= to!string(left) ~ to!string(right);

            const string op = join(this.node.children[2].matches);
            const string asmOp = opMap[op];

            if(left.getType().name == Type.STRING) {
                if(op != "=" && op != "<>") {
                    compiler.displayError("Relational operator '" ~ op ~ "' not supported on strings");
                }
            }

            this.asmCode ~= "    cmp" ~ expectedType.name ~ asmOp ~"\n";
        }
        // Has left only
        else {
            left.eval();
            this.asmCode ~= to!string(left);
            /* This should be checked at the statement
            if(this.type.name != Type.UINT8) {
                this.asmCode ~= this.type.getCastCode(compiler.getTypes().get(Type.UINT8));    
            }*/
        }
        
        // Typecast if required
        if(!(this.expectedType is null)) {
            this.asmCode ~= this.type.getCastCode(this.expectedType);
        }
    }
}