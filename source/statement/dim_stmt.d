module statement.dim_stmt;

import compiler.compiler, compiler.type, compiler.variable, compiler.type;
import language.statement;
import compiler.number;
import language.expression;
import pegged.grammar;
import std.string, std.conv, std.algorithm.searching;
import std.uni;

import std.stdio;

/** Compiles a DIM statement */
class Dim_stmt : Statement
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    private const string ATTR_COMMON = "shared";
    private const string ATTR_FAST   = "fast";

    private bool isFast = false;
    private bool isCommon = false;
    private bool isStatic = false;
    private Variable variable;
    private ubyte strLen = 0;
    private ushort[3] dimensions;
    private ushort addr = 0;
    private string addrLabel = "";

    private void parseAttrib(ParseTree node)
    {
        const string attr = join(node.matches).toLower;
        if(attr == ATTR_FAST) {
            this.isFast = true;
        }
        else if(attr == ATTR_COMMON) {
            if(compiler.inProcedure) {
                compiler.displayError("Local variables cannot be SHARED");
            }
            this.isCommon = true;
        }
    }

    private void parseVar(ParseTree node)
    {
        VariableReader reader = new VariableReader(node, compiler);
        this.variable = reader.read(null, this.isStatic);
        if(this.variable.type.name == Type.VOID) {
            compiler.displayError("Can't define a variable as void");
        }
    }

    private void parseAddress(ParseTree node)
    {
        if(isFast) {
            this.compiler.displayError("Can't use FAST together with @");
        }

        if(compiler.inTypeDef) {
            compiler.displayError("Can't use @ in a field definition");
        }

        if(node.name == "XCBASIC.Number") {
            Number num = new Number(node, compiler);
            if(num.type.name == Type.FLOAT || num.intVal < 0 || num.intVal > 0xFFFF) {
                compiler.displayError("Address must be an integer in range 0-65535");
            }
            addr = to!ushort(num.intVal);
        }
        else {
            immutable string lbl = node.matches.join("");
            if(compiler.getLabels().exists(lbl)) {
                // a label
                addrLabel = compiler.getLabels().toAsmLabel(lbl);
            }
            else {
                Variable var = compiler.getVars().findVisible(lbl);
                if(var !is null) {
                    if(!var.isConst) {
                        compiler.displayError("Address must a constant");
                    }
                    // a constant
                    if(!var.type.isIntegral() || var.constVal < 0 || var.constVal > 0xFFFF) {
                        compiler.displayError("Address must be an integer in range 0-65535");
                    }
                    addrLabel = var.getAsmLabel();
                }
                else  {
                    compiler.displayError("Unknown constant \"" ~ lbl ~ "\"");
                }
            }
        }
    }

    /** Process AST */
    void process()
    {
        ParseTree statement = this.node.children[0];
        this.isStatic = (
            toLower(statement.matches[0]) == "static"
            || (compiler.inProcedure && compiler.currentProc.getIsStatic())
            || !compiler.inProcedure
        );
        for (int i = 0; i < statement.children.length; i++) {
            ParseTree node = statement.children[i];
            switch(node.name) {
                // Attributes
                case "XCBASIC.Varattrib":
                    parseAttrib(node);
                    break;
                // Name, dimensions, type
                case "XCBASIC.Var":
                    parseVar(node);
                    break;

                // Address
                case "XCBASIC.Number":
                case "XCBASIC.Label_ref":
                    parseAddress(node);
                    break;

                default:
                    assert(0);
            }
        }

        if(addr > 0) {
            variable.isExplicitAddr = true;
            variable.address = addr;
        }
        else if(addrLabel != "") {
            variable.isExplicitAddr = true;
            variable.addressLabel = addrLabel;
        }

        if(compiler.inProcedure) {
            variable.visibility = Compiler.VIS_LOCAL;
        }
        else if(isCommon) {
            variable.visibility = Compiler.VIS_COMMON;
        }

        variable.isDynamic = !this.isStatic;
        compiler.getVars().add(variable, isFast);
    }
}
