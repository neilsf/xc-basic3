module language.expression;

import std.algorithm.mutation, std.conv, std.string;
import pegged.grammar;
import compiler.type, compiler.compiler;
import language.relation;

/** Expression members (Expression, Relation, Simplexp, Term, Factor) must implement this */
interface ExpressionInterface
{
    /** The evaluated type of the expression */
    public Type getType();
    /** Whether the expression holds a single constant */
    public bool isConstant();
    /** The value of the expression if it's constant */
    public float getConstVal();
    /** Evaluate the expression */
    public void eval();
    /** What type we expect from the expression */
    public void setExpectedType(Type type);
}

/** Base class for expression members */
abstract class AbstractExpression : ExpressionInterface
{
    protected ParseTree node;
    protected Compiler compiler;
    protected string asmCode;
    protected Type type;

    /** If set, the type of the member will be cast to the expected type */
    protected Type expectedType;

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        this.node = node.dup;
        this.compiler = compiler;
        this.reorderChildren();
        this.detectType();
    }

    public void setExpectedType(Type type)
    {
        this.expectedType = type;
    }

    abstract protected string getChildName();
    
    abstract protected ExpressionInterface makeChild(ParseTree node);

    /** Whether the expression holds a single constant */
    public bool isConstant()
    {
        if(this.node.children.length > 1) {
            return false;
        }

        return this.makeChild(this.node.children[0]).isConstant();
    }

    public float getConstVal()
    {
        if(!this.isConstant()) {
            compiler.displayError("Expression is not constant");
        }
        return this.makeChild(this.node.children[0]).getConstVal();
    }

    protected void detectType()
    {
        this.type = compiler.getTypes().get(Type.UINT8);
        foreach (ref child; this.node.children) {
            if(child.name == this.getChildName()) {
                Type fType = this.makeChild(child).getType();
                if(!this.type.comparePrecedence(fType)) {
                    this.type = fType;
                }
            }
        }
    }

    public Type getType()
    {
        return this.type;
    }

    protected void reorderChildren()
    {
        for(int i = 1; (i + 1) < this.node.children.length; i += 2) {
            this.node.children.swapAt(i, i + 1);
        }
    }

    override string toString()
    {
        return asmCode;
    }
}

/** Compiles an expression */
class Expression : AbstractExpression
{
    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        super(node, compiler);
    }

    override protected ExpressionInterface makeChild(ParseTree node)
    {
        return new Relation(node, this.compiler);
    }

    override protected string getChildName()
    {
        return "XCBASIC.Relation";
    }

    /** Evaluate the expression */
    public void eval()
    {
        this.asmCode = "";
        
        int count = 0;
        foreach (ref child; this.node.children) {
            if(child.name == "XCBASIC.Relation") {
                ExpressionInterface t = this.makeChild(child);
                t.setExpectedType(this.type);
                t.eval();
                this.asmCode ~= to!string(t);
            }
            else if(child.name == "XCBASIC.BW_OP") {
                const string op = toLower(join(child.matches));
                this.asmCode ~= "    " ~ op ~ to!string(this.type) ~ "\n";
            }
            count++;
        }

        // Check both types
        if(!this.getType().isIntegral() && count > 1) {
            compiler.displayError("Can't do bitwise operation on a(n) " ~ this.getType().name);
        }

        // Typecast if required
        if(this.expectedType !is null) {
            try {
                if(this.expectedType.length < this.type.length) {
                    compiler.displayWarning("Downcasting from " ~ this.type.name ~ " to " ~ this.expectedType.name ~ " truncates value");
                }
                this.asmCode ~= this.type.getCastCode(this.expectedType);
            }
            catch(Exception e) {
                compiler.displayError(e.msg);
            }
        }
    }
}