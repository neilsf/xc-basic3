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
            case "XCBASIC.Address":
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
                    AccessorFactory af = new AccessorFactory(child, compiler); 
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
                ParseTree v = factor;
                immutable string identifier = join(v.children[0].matches);             
                
                // First check if it's a variable
                Variable variable = this.compiler.getVars().findVisible(identifier);
                if(variable !is null) {
                    VariableAccess access = new VariableAccess(node, compiler);
                    // Todo make VariableAccess class return an address                    
                    //this.asmCode = "    paddr " ~ variable.getAsmLabel() ~ "\n";
                    break;
                }

                // Check if it's a label
                if(this.compiler.getLabels().exists(identifier)) {
                    this.asmCode = "    paddr " ~ this.compiler.getLabels().toAsmLabel(identifier);
                    break;
                }

                // TODO implement the rest
/*
                if(this.program.procExists(varname)) {
                    // a procedure
                    lbl = this.program.findProcedure(varname).getLabel();
                    this.asmcode ~= "    paddr " ~ lbl ~ "\n";
                }
                else if(this.program.labelExists(varname)) {
                    // a label
                    lbl = this.program.getLabelForCurrentScope(varname);
                    this.asmcode ~= "    paddr " ~ lbl ~ "\n";
                }
                else if(this.program.is_variable(varname, sigil)) {
                    // a variable
                    Variable var = this.program.findVariable(varname, sigil);
                    if(var.isConst) {
                        this.program.error("A constant has no address");
                    }
                    lbl = var.getLabel();
                    if(v.children.length == 2) {
                        // single variable
                        this.asmcode ~= "    paddr " ~ lbl ~ "\n";
                    }
                    else {
                        // array
                        auto subscript = v.children[2];
                        XCBArray arr = new XCBArray(this.program, var, subscript);
                        asmcode ~= arr.get_address();
                    }
                }
                else {
                    this.program.error("Undefined variable or label: " ~ varname);
                }

*/

            break;
/*
            case "XCBASIC.Expression":
            case "XCBASIC.Parenthesis":
                ParseTree ex = ftype == "XCBASIC.Expression" ? this.node.children[0] : this.node.children[0].children[0];
                auto Ex = new Expression(ex, this.program);
                Ex.eval();
                this.asmcode ~= to!string(Ex);
            break;

         */   
            case "XCBASIC.String":
                string str = join(this.node.children[0].matches[1..$-1]);
                StringLiteral sl = new StringLiteral(str, compiler);
                sl.register();
                this.asmCode ~= "    pstringvar _S" ~ to!string(StringLiteral.id) ~ "\n";
            break;
        }

        // Apply unary operator ("not" | "-") if any
        if(unOp.length > 0) {
            if(!this.type.isNumeric()) {
                compiler.displayError("Cannot negate a non-numeric type");
            }
            if(this.type.name == Type.DEC) {
                compiler.displayError("Cannot negate decimal type");
            }
            if(unOp.toLower == "not" && !this.type.isIntegral()) {
                compiler.displayError("The NOT operator only works on integer types");
            }
            this.asmCode ~= "    neg" ~ to!(string)(this.type.name) ~ "\n";
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
