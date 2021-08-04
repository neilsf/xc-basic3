module language.term;

import std.conv;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.factor, language.expression;

/** Represents a Term (multiplication or division) */
class Term : AbstractExpression
{
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    override protected ExpressionInterface makeChild(ParseTree node)
    {
        return new Factor(node, compiler);
    }

    override protected string getChildName()
    {
        return "XCBASIC.Factor";
    }

    /** Evaluates the term */
    void eval()
    {
        this.asmCode = "";
        int count = 0;
        foreach (ref child; this.node.children) {
            if(child.name == this.getChildName()) {
                ExpressionInterface f = this.makeChild(child);
                if(f.getType().name == Type.VOID) {
                    compiler.displayError("Void function used in expression");
                }
                f.setExpectedType(this.type);
                f.eval();
                if(!f.getType().isNumeric() && this.node.children.length > 1) {
                    typeError();
                }
                if(f.getType().name == Type.DEC && this.node.children.length > 1) {
                    compiler.displayError("Multiplication or division of decimals is not implemented");
                }
                this.asmCode ~= to!string(f);
            }
            else if(child.name == "XCBASIC.T_OP") {
                const string op = child.matches[0];
                final switch(op) {
                    case "*":
                        this.asmCode ~= "    mul" ~ to!string(this.type) ~ "\n";
                    break;

                    case "/":
                        this.asmCode ~= "    div" ~ to!string(this.type) ~ "\n";
                    break;
                }
            }
            count++;
        }

         // Typecast if required
        if(this.expectedType !is null) {
            this.asmCode ~= this.type.getCastCode(this.expectedType);
        }
    }

    private void typeError()
    {
        compiler.displayError("Only numeric types can be multiplied or divided");
    }
}
