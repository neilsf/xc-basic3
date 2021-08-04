module language.simplexp;

import std.conv;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.term, language.expression;

/** Represents a Simplexp (addition or subtraction) */
class Simplexp : AbstractExpression
{
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    override protected ExpressionInterface makeChild(ParseTree node)
    {
        return new Term(node, compiler);
    }

    override protected string getChildName()
    {
        return "XCBASIC.Term";
    }

    /** Evaluates the simplexp */
    void eval()
    {
        bool hasStringMember = false;
        bool hasNumericMember = false;
        bool hasSubtraction = false;
        
        this.asmCode = "";
        
        int count = 0;
        foreach (ref child; this.node.children) {
            if(child.name == "XCBASIC.Term") {
                ExpressionInterface t = this.makeChild(child);
                t.setExpectedType(this.type);
                t.eval();
                if(!t.getType().isPrimitive && count > 0) {
                    typeError();
                }
                if(t.getType().name == Type.STRING) {
                    hasStringMember = true;
                }
                else {
                    hasNumericMember = true;
                }
                this.asmCode ~= to!string(t);
            }
            else if(child.name == "XCBASIC.E_OP") {
                const string op = child.matches[0];
                final switch(op) {
                    case "+":
                        this.asmCode ~= "    add" ~ to!string(this.type) ~ "\n";
                    break;

                    case "-":
                        this.asmCode ~= "    sub" ~ to!string(this.type) ~ "\n";
                        hasSubtraction = true;
                    break;
                }
            }
            count++;
        }

        if(hasStringMember && hasNumericMember) {
            compiler.displayError("Mixed types (string and numeric) are not allowed in expression");
        }

        if(hasStringMember && hasSubtraction) {
            compiler.displayError("Strings cannot be subtracted");
        }

        // Typecast if required
        if(!(this.expectedType is null)) {
            this.asmCode ~= this.type.getCastCode(this.expectedType);
        }
    }

    private void typeError()
    {
        compiler.displayError("Only primitive types can be added or subtracted");
    }
}