module language.factor;

import pegged.grammar;

import compiler.compiler;
import compiler.number, compiler.variable, compiler.routine;
import compiler.type;
import language.expression, language.accessor, language.stringliteral;

import std.array;
import std.conv;
import std.stdio;
import std.string;

/** Represents the smallest building block of an expression */
class Factor : AbstractExpression
{
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    /** Returns whether the factor is a constant value */
    override public bool isConstant()
    {
        ParseTree child = this.node.children[0];
        switch(child.name) {
            case "XCBASIC.UN_OP":
                return false;

            case "XCBASIC.Number":
                return true;

            case "XCBASIC.Accessor":
                try {
                    return (new AccessorFactory(child, compiler)).getAccessor().isConstant();
                }
                catch(Exception e) {
                    compiler.displayError(e.msg);
                }
                assert(0);
            
            case "XCBASIC.Parenthesis":
            case "XCBASIC.Expression":
                return (new Expression(child, this.compiler)).isConstant();
        
            default:
                return false;
        }
    }
    
    /** Get value if constant */
    override public float getConstVal()
    {
        ParseTree child = this.node.children.length == 1 ? this.node.children[0] : this.node.children[1];
        switch(child.name) {
            case "XCBASIC.Number":
                Number num = new Number(child, compiler);
                return num.type == compiler.getTypes().get(Type.FLOAT) ? num.floatVal : cast(float)num.intVal;

            case "XCBASIC.Accessor":
                try {
                    return (new AccessorFactory(child, compiler)).getAccessor().getConstVal();
                }
                catch(Exception e) {
                    compiler.displayError(e.msg);
                }
                assert(0);
                
            case "XCBASIC.Parenthesis":
            case "XCBASIC.Expression":
                return (new Expression(child, compiler)).getConstVal();

            default:
                return 0.0;
        }
    }

    override protected void detectType()
    {
        int pos = 0;
        ParseTree child = this.node.children[pos];
        if(child.name == "XCBASIC.UN_OP") {
            pos++;
        }
        child = this.node.children[pos];
        switch(child.name) {
            case "XCBASIC.Number":
                Number num = new Number(child, compiler);
                this.type = num.type;
                break;
            
            case "XCBASIC.Accessor":
                try {
                    this.type = (new AccessorFactory(child, compiler)).getAccessor().getType();
                }
                catch(Exception e) {
                    compiler.displayError(e.msg);
                }
                break;

            case "XCBASIC.Address":
                this.type = compiler.getTypes().get(Type.UINT16);
                break;

            case "XCBASIC.String":
                this.type = compiler.getTypes().get(Type.STRING);
                break;

            case "XCBASIC.Expression":
            case "XCBASIC.Parenthesis":
                ParseTree expNode = (child.name == "XCBASIC.Expression" ? child : child.children[0]);
                auto ex = new Expression(expNode, compiler);
                this.type = ex.getType();
                break;

            default:
                throw new Exception("Add case for " ~ child.name);
        }
    }

    /** Evaluates the factor */
    public void eval()
    {
        this.asmCode = "";
        string unOp = "";
        int pos = 0;
        ParseTree child = this.node.children[pos];
        if(child.name == "XCBASIC.UN_OP") {
            unOp = child.matches.join();
            pos++;
        }

        ParseTree factor = this.node.children[pos];
    	const string factName = factor.name;
        final switch(factName) {
            case "XCBASIC.Number":
                Number num = new Number(factor, compiler);
                this.asmCode = num.getPushCode();
            break;

            case "XCBASIC.Accessor":
                try {
                    AccessorFactory af = new AccessorFactory(factor, compiler); 
                    AccessorInterface accessor = af.getAccessor();
                    this.asmCode = accessor.getPushCode();
                    if(accessor.isFunctionCall()) {
                        if(accessor.getRoutine() == compiler.currentProc) {
                            compiler.currentProc.recursed = true;
                        }
                    }
                }
                catch(Exception e) {
                    compiler.displayError(e.msg);
                }
            break;

            case "XCBASIC.Address":
                // First check if it's a variable or routine call
                try {
                    AccessorFactory af = new AccessorFactory(factor.children[0], compiler); 
                    AccessorInterface accessor = af.getAccessor();
                    this.asmCode = accessor.getPushAddressCode();
                }
                catch(Exception e) {
                    // No, maybe a label
                    ParseTree v = factor.children[0];
                    immutable string identifier = join(v.children[0].matches);
                    if(this.compiler.getLabels().exists(identifier, false)) {
                        this.asmCode = "    paddr " ~ this.compiler.getLabels().getReferenceToLabel(identifier) ~ "\n";
                    } else {
                        // Not a label, we give up
                        compiler.displayError(e.msg);
                    }
                }
            break;

            case "XCBASIC.Expression":
            case "XCBASIC.Parenthesis":
                ParseTree expNode = (factor.name == "XCBASIC.Expression" ? factor : factor.children[0]);
                auto ex = new Expression(expNode, compiler);
                ex.eval();
                this.asmCode ~= ex.toString();
            break;
  
            case "XCBASIC.String":
                string str = join(this.node.children[0].matches[1..$-1]);
                StringLiteral sl = new StringLiteral(str, compiler);
                sl.register();
                this.asmCode ~= "    pstringvar _S" ~ to!string(StringLiteral.id) ~ "\n";
            break;
        }

        // Apply unary operator ("not" | "-") if any
        if(unOp.length > 0) {
            unOp = unOp.toUpper;
            if(!this.type.isNumeric()) {
                compiler.displayError("The " ~ unOp ~ " operator cannot be used with non-numeric types");
            }
            if(unOp == "-" && (this.type.name == Type.DEC || this.type.name == Type.UINT8 || this.type.name == Type.UINT16)) {
                compiler.displayError("Cannot negate an unsigned type");
            } 
            if(unOp == "NOT" && !this.type.isIntegral()) {
                compiler.displayError("The NOT operator only works on integer types");
            }
            const string opCode = unOp == "-" ? "neg" : "not";
            this.asmCode ~= "    " ~ opCode ~ to!(string)(this.type.name) ~ "\n";
        }

        // Typecast if required
        if(!(this.expectedType is null)) {
            this.asmCode ~= this.type.getCastCode(this.expectedType);
        }
    }

    override protected ExpressionInterface makeChild(ParseTree node)
    {
        return null;
    }

    override protected string getChildName()
    {
        return "";
    }
}
