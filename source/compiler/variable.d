module compiler.variable;

import std.algorithm.searching, std.conv, std.array, std.string, std.math;

import language.expression;
import compiler.compiler, compiler.type, compiler.number, compiler.intermediatecode,
        compiler.routine, compiler.helper;

import globals;

import pegged.grammar;

private string getLabelInCurrentScope(string variableName, Compiler compiler) {
    return compiler.currentFileId ~ "."
            ~ (compiler.inProcedure ? (compiler.currentProcName ~ compiler.currentProc.getArgsHash()
            ~ "." ~ fixSymbol(variableName)) : fixSymbol(variableName));
}

private string getLabelInGlobalScope(string variableName, Compiler compiler) {
    return compiler.currentFileId ~ "." ~ fixSymbol(variableName);
}

/** Holds data about a variable */
// TODO shared and common variables
class Variable
{
    /** Variable name */
	string name;
	/** Variable type */
    Type type;
    /** Variable visibility */
    int visibility = Compiler.VIS_GLOBAL;
    /** Array dimensions */
	ushort[3] dimensions = [1, 1, 1];
    /** How many dimensions (0=scalar, 1=linear, 2=flat, 3=cubic) */
    ubyte dimCount = 0;
    /** Is it a constant */
    bool isConst        = false;
    /** Was it defined in a data statement */
	bool isData         = false;
    /** Is it stored on ZP */
    bool isFast         = false;
    /** Is forced address */
    bool isExplicitAddr = false;
    /** Address, if forced */
    ushort address;
    /** Address, if forced and equals to a label, not a number */
    string addressLabel;
    /** Private variables are added by the compiler */
    bool isPrivate      = false;
    /** Is it the return value of a function */
    bool isFnRetVal     = false;
    /** Procedure name if local variable */
	string procName;
    /** In what source file the variable was defined in */
    string fileId;
    /** Value if constant */
	float constVal = 0;
    /** For strings, the string length */
    ushort strLen = 0;
    /** If this is a field, the byte offset from the start of its type */
    ushort offsetWithinType;
    /** Variables are static by default */
    bool isDynamic = false;
    /** If this is a dynamic variable, the byte offset from the start of the frame */
    int offsetWithinFrame = 0;

    /** Label for internal use */
    protected string getLabel()
    {
        immutable string name = fixSymbol(this.name);
        if(this.visibility == Compiler.VIS_COMMON) {
            return name;
        }
        else if(this.visibility == Compiler.VIS_GLOBAL) {
            return this.fileId ~ "." ~ name;
        }
        else {
            return this.fileId ~ "." ~ this.procName ~ "." ~ name;
        }
    }

    /** Label used to identify variable in the assembly listing */
	public string getAsmLabel()
	{
        string prefix = this.isPrivate ? "X_" : "V_";
        return prefix ~ this.getLabel();
	}

    /** How many bytes in memory a single array member reserves */
    public int getSingleLength()
    {
        return this.strLen > 0 ? this.strLen : this.type.length;
    }

    /** How many bytes in memory this variable reserves */
    public int getLength()
    {
        return getSingleLength() * dimensions[0] * dimensions[1] * dimensions[2];
    }

    /** Returns true if variable was defined as an array */
    public bool isArray()
    {
        return dimensions[0] * dimensions[1] * dimensions[2] > 1;
    }

    /** Creates a variable by name and type */
    public static Variable create(string name, Type type, Compiler compiler, bool forceStatic = false)
    {
        Variable var = new Variable();
        var.name = toLower(name);
        var.type = type;
        var.fileId = compiler.currentFileId;
        if(compiler.inProcedure) {
            var.visibility = compiler.VIS_LOCAL;
            var.procName = compiler.currentProcName;
            if(!forceStatic && !compiler.currentProc.getIsStatic()) {
                var.isDynamic = true;
                compiler.currentProc.addDynamicVariable(var);
            }
        }
        return var;
    }
}

/** The special variable "this" */
class ThisVariable : Variable
{
    /** Returns true if variable was defined as an array */
    override public bool isArray()
    {
        return false;
    }

    /** Class constructor */
    this(Compiler compiler)
    {
        this.type = compiler.currentProc.parentType;
    }
}

/** Holds all program variables */
class VariableCollection
{
    private Compiler compiler;

    /** Lower bound of free ZP area */
    static const ubyte zpLow  = 0x14;
    /** Upper bound of free ZP area */
    static const ubyte zpHigh = 0x2a;
    /** Points to the next free addr in ZP area */
    static ubyte zpPtr = zpLow;

    private Variable[] variables;

    /** Class constructor */
    this(Compiler compiler)
    {
        this.compiler = compiler;
    }

    /** Add variable to the Collection */
    public void add(Variable variable, bool isFast)
    {
        if(existsInInnerScope(variable.name)) {
            this.compiler.displayError(
                "Duplicate definition: '" ~ variable.name ~ "' already exists in this scope"
            );
        }

        if(existsInOuterScope(variable.name)) {
            this.compiler.displayWarning(
                "'" ~ variable.name ~ "' shadows global or common variable with the same name"
            );
        }

        if(isFast) {
            if(zpPtr + variable.getLength() - 1 <= zpHigh) {
                variable.isFast = true;
                variable.address = ushort(zpPtr);
                zpPtr += variable.getLength();
            }
            else {
                this.compiler.displayWarning(
                    "Out of zeropage space, ignoring FAST option for variable " ~ variable.name
                );
            }
        }

        this.variables ~= variable;

        // Add the variable to the intermediate code
        if(!variable.isConst && !variable.isDynamic) {
            int length = variable.getLength();
            if(variable.type.name == Type.STRING) {
                // Need one more byte for strings
                length += (variable.dimensions[0] * variable.dimensions[1] * variable.dimensions[2]);
            }
            string code;
            if(variable.isExplicitAddr || variable.isFast) {
                if(variable.addressLabel != "") {
                    code = variable.getAsmLabel() ~ " EQU " ~ variable.addressLabel ~ "\n";
                }
                else {
                    code = variable.getAsmLabel() ~ " EQU " ~ to!string(variable.address) ~ "\n";
                }
            }
            else {
                code = variable.getAsmLabel() ~ " DS.B " ~ to!string(length) ~ "\n";
            }
            this.compiler.getImCode().appendSegment(IntermediateCode.VAR_SEGMENT, code);
        }
    }

    /** Returns whether variable exist in the current scope */
    public bool existsInInnerScope(string variableName)
    {
        immutable string label = getLabelInCurrentScope(variableName, compiler);
        return any!(v => v.getLabel() == label)(variables);
    }

    /** Returns whether variable exist outside the current scope */
    public bool existsInOuterScope(string variableName)
    {
        string label;
        // Search for variable in global scope
        if(this.compiler.inProcedure) {
            label = getLabelInGlobalScope(toLower(variableName), compiler);
        }
        // Search for shared variable with same name
        else {
            label = toLower(variableName);
        }
        return any!(v => v.getLabel() == label)(variables);
    }
    
    /** Returns a variable that is visible in the current scope or NULL if none found */
    public Variable findVisible(string name)
    {
        name = toLower(name);
        foreach (Variable var; variables) {
            if(var.name != name) {
                continue;
            }
           
            bool visible = false;

            // Function return value within function
            if(compiler.inProcedure && compiler.currentProc.returnValue == var) {
                visible = true;
            }
            else if(!var.isFnRetVal) {
                // Same name in same scope
                if(compiler.inProcedure && var.visibility != Compiler.VIS_GLOBAL && compiler.currentProcName == var.procName) {
                    visible = true;
                }
                // Shared or global var
                if(var.visibility == Compiler.VIS_COMMON || (var.visibility == Compiler.VIS_GLOBAL && var.fileId == compiler.currentFileId)) {
                    visible = true;
                }
            }

            if(visible) {
                return var;
            }
        }

        return null;
    }

    public Variable[] getAll()
    {
        return this.variables;
    }
}

/** Reads variable metadata from AST and creates Variable object */
class VariableReader
{
    private Compiler compiler;
    private ParseTree node;

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
    {
        this.node = node;
        this.compiler = compiler;
    }

    /** Returns variable object built from AST (found in Dim, Let, For, etc...) */
    public Variable read(Type inferredType = null, bool forceStatic = false, bool stringLengthRequired = true)
    {
        ushort[3] dimensions = [1, 1, 1];
        string name;
        ubyte dimCount;
        ushort strLen;
        Type type;

        for(int i = 0; i < node.children.length; i++) {
            const ParseTree child = node.children[i];
            switch(child.name) {
                case "XCBASIC.Varname":
                    name = join(child.matches);
                    break;

                case "XCBASIC.Subscript":
                    ubyte ix = 0;
                    foreach(ref x; child.children) {

                        ParseTree expr = cast(ParseTree)x;

                        if(!((new Expression(expr, this.compiler)).isConstant())) {
                            compiler.displayError("Array dimensions must be constant");
                        }

                        string dim = join(expr.matches);
                        int dimLength = 0;

                        // Case 1: test for a defined constant
                        Variable constVar = compiler.getVars().findVisible(dim);
                        if(constVar !is null) {
                            if(!constVar.isConst) {
                                compiler.displayError("Array dimension must be a constant");
                            }
                            if(!canFind([Type.UINT8, Type.INT16, Type.UINT16], constVar.type.name)) {
                                compiler.displayError("Array dimensions must be of type byte, int or word.");
                            }

                            dimLength = to!int(constVar.constVal);
                        }
                        // Case 2: test for numeric literal
                        else {
                            if(expr.children.length > 1) {
                                compiler.displayError("Array dimensions must be constant");
                            }
                            Number num = new Number(expr.children[0].children[0].children[0].children[0].children[0], this.compiler);
                            if(num.type == compiler.getTypes.get(Type.FLOAT)) {
                                compiler.displayError("Array dimension must be integer");
                            }
                            dimLength = num.intVal;
                        }

                        if(dimLength < 1) {
                            compiler.displayError("Array dimension must be greater than zero");
                        }

                        dimensions[ix] = to!ushort(dimLength);
                        ix++;
                    }
                    if(ix == 0) {
                        compiler.displayError("Empty array subscript");
                    }
                    dimensions = dimensions;
                    dimCount = ix;
                    break;

                case "XCBASIC.Vartype":
                    string typeName;
                    if(join(child.matches) == "") {
                        typeName = "";
                    }
                    else {
                        typeName = toLower(join(child.children[0].matches));
                    }
                    if(typeName == "") {
                        typeName = inferredType is null ? Type.INT16 : inferredType.name;
                    }                    
                    else if(typeName == Type.STRING && stringLengthRequired) {
                        if(child.children.length < 2) {
                            compiler.displayError("String length is required");
                        }
                        immutable int len = to!int(join(child.children[1].matches)[1..$]);
                        if(len < 1 || len > stringMaxLength) {
                            compiler.displayError("String length must be between 1 and " ~ to!string(stringMaxLength));
                        }
                        strLen = to!ubyte(len);
                    }
                    if(!compiler.getTypes().defined(typeName)) {
                        compiler.displayError("Undefined type: " ~ typeName);
                    }

                    type = compiler.getTypes().get(typeName);
                    break;

                default:
                    assert(0);
            }
        }

        if(type is null) {
            if(inferredType !is null) {
                type = inferredType;
            }
            else {
                type = compiler.getTypes().get(Type.INT16);
            }
        }
    
        Variable v = Variable.create(name, type, compiler, forceStatic);
        v.dimensions = dimensions;
        v.dimCount = dimCount;
        v.strLen = strLen;
        return v;
    }
}

/** 
 * Reads a VarAccess node from AST and creates assembly source that
 * reads or writes the value in the appropriate memory location
 */
class VariableAccess : AccessorInterface
{
    private Compiler compiler;
    private ParseTree node;
    private Variable variable;
    private Type type;
    private bool isConstantSubscript;
    private Expression[3] indices;
    private int[3] constSubscript = [0, 0, 0];
    private bool fastArrayAccess = false;

    /** Class constructor */
    this(ParseTree node, Compiler compiler, bool failIfNotFound = true)
    {
        this.node = node;
        this.compiler = compiler;
        if(node.children.length > 0) {
            string varName = join(node.children[0].matches);
            if(toLower(varName) == "this") {
                if(!compiler.inProcedure || !compiler.currentProc.getIsMethod()) {
                    compiler.displayError("Keyword THIS may only be used in a method");
                }
                variable = new ThisVariable(compiler);
            }
            else {
                variable = compiler.getVars().findVisible(varName);
            }
            if(variable is null && failIfNotFound) {
                throw new Exception("Variable \"" ~ varName ~ "\" does not exist or is unknown in this scope");
            }
        }
    }
    
    /** Returns whether this is a sub, function or method call rather than a var access */
    public bool isFunctionCall() const
    {
        return false;
    }

    /** Returns variable if found */
    public Variable getVariable()
    {
        return this.variable;
    }

    /** Set variable (e. g when it is implicitly defined outside this class) */
    public void setVariable(Variable var)
    {
        this.variable = var;
    }

    /** Returns whether we're accessing a constant */
    public bool isConstant()
    {
        return variable.isConst;
    }

    /** Returns the value if it's a constant */
    public float getConstVal()
    {
        return variable.constVal;
    }

    /** Returns assembly source for accessing variable for writing */
    public string getPullCode()
    {
        return this.getCode("pl");
    }

    /** Returns assembly source for accessing variable for reading */
    public string getPushCode()
    {
        string asmCode = "";
        if(variable.isConst) {
            asmCode ~= "    p" ~ variable.type.name ~ " ";
            final switch(variable.type.name) {
                case Type.UINT8:
                case Type.UINT16:
                case Type.INT16:
                case Type.INT24:
                    asmCode ~= to!string(to!int(variable.constVal));
                    break;

                case Type.FLOAT:
                    asmCode ~= Number.floatToHex(variable.constVal);
                    break;

                case Type.DEC:
                    asmCode ~= Number.getDecimalAsHex(to!int(variable.constVal)); 
                    break;
            }
            return asmCode ~ "\n";
        }

        return this.getCode("p");
    }

    public string getPushAddressCode()
    {      
        if(hasSubscript()) {
            parseSubscript();
            if(isConstantSubscript) {
                ushort offset = cast(ushort)(getFieldOffset() + getAddressOffset());
                return "    pword [" ~ variable.getAsmLabel() ~ " + " ~ to!string(offset) ~ "]\n";
            }
            else {
                string asmCode;
                asmCode ~= getArrayOffsetCode();
                if(fastArrayAccess) {
                    asmCode ~= "    F_cword_byte\n";
                }
                asmCode ~= "    pword " ~ variable.getAsmLabel() ~ "\n";
                asmCode ~= "    addword\n";
                return asmCode;
            }
        }
        else {
            return "    pword " ~ variable.getAsmLabel() ~ "\n";
        }
    }

    /** How far the accessed field is from the start of the variable */
    private ushort getFieldOffset()
    {
        ushort addressOffset = 0;
        const int ix = findChild(node, "XCBASIC.Varname", 1);
        if(ix != -1) {
            string dotNotation = "";
            for(int i = ix; i < node.children.length; i++) {
                dotNotation ~= node.children[i].matches.join("");
                if(i + 1 < node.children.length) {
                    dotNotation ~= ".";
                }
            }
            try {
                addressOffset += variable.type.getMemberOffset(dotNotation);
            }
            catch(Exception e) {
                compiler.displayError(e.msg);
            }
        }

        return addressOffset;
    }

    /**
     * How far the accessed array member is from the start of the variable
     * (in case array indices are constant)
     */
    private ushort getAddressOffset()
    {
        return  to!ushort(variable.getSingleLength() * (constSubscript[0] 
                + variable.dimensions[0] * constSubscript[1]
                + (variable.dimensions[0] * variable.dimensions[1]) * constSubscript[2]));
    }

    private bool hasSubscript()
    {
        return node.children.length > 1 && node.children[1].name == "XCBASIC.Subscript";
    }

    private void parseSubscript()
    {
        isConstantSubscript = true;
        if(hasSubscript()) {
            ParseTree ptSubscript = node.children[1];
            if(ptSubscript.children.length != variable.dimCount) {
                compiler.displayError("Bad subscript");
            }
            for(int i = 0; i < 3; i++) {
                if(ptSubscript.children.length > i) {
                    Expression e = new Expression(ptSubscript.children[i], compiler);
                    Type eType = e.getType();
                    if(!eType.isIntegral()) {
                        compiler.displayError("Array index must be an integral type, got " ~ eType.name);
                    }
                    if(e.isConstant()) {
                        constSubscript[i] = to!int(e.getConstVal());
                        if(constSubscript[i] < 0) {
                            compiler.displayError("Array index must positive");
                        }
                        if(constSubscript[i] >= variable.dimensions[i]) {
                            compiler.displayError("Index out of bounds");
                        }
                    }
                    else {
                        isConstantSubscript = false;
                    }
                    indices[i] = e;
                }
            }
        }
    }

    /** Creates runtime code to calculate offset */
    private string getArrayOffsetCode()
    {
        if(!hasSubscript()) {
            assert(0, "getArrayOffsetCode was called with no array subscript");
        }
        string asmCode = "";
        
        int varLen = variable.getSingleLength();
        fastArrayAccess = variable.getLength() <= 256;
        string indexTypeName = fastArrayAccess ? Type.UINT8 : Type.UINT16;
        Type indexType = compiler.getTypes.get(indexTypeName);
        ParseTree ptSubscript = node.children[1];

        bool hasThird = false;
        // third dimension
        if(ptSubscript.children.length > 2) {
            hasThird = true;
            if(constSubscript[2] > 0) {
                asmCode ~= "    p" ~ indexTypeName ~ " " ~ to!string(variable.dimensions[0] * variable.dimensions[1]
                            * constSubscript[2]) ~ "\n";
            }
            else {
                indices[2].setExpectedType(indexType);
                indices[2].eval();
                asmCode ~= "    p" ~ indexTypeName ~ " " ~ to!string(variable.dimensions[0] * variable.dimensions[1]) ~ "\n";
                asmCode ~= to!string(indices[2]);
                asmCode ~= "    mul" ~ indexTypeName ~ "\n";
            }
        }

        bool hasSecond = false;
        // second dimension
        if(ptSubscript.children.length > 1) {
            hasSecond = true;
            if(constSubscript[1] > 0) {
                asmCode ~= "    p" ~ indexTypeName ~ " " ~ to!string(variable.dimensions[0] * constSubscript[1]) ~ "\n";
            }
            else {
                indices[1].setExpectedType(indexType);
                indices[1].eval();
                asmCode ~= "    p" ~ indexTypeName ~ " " ~ to!string(variable.dimensions[0]) ~ "\n";
                asmCode ~= to!string(indices[1]);
                asmCode ~= "    mul" ~ indexTypeName ~ "\n";
            }
        }

        if(hasThird && hasSecond) {
            asmCode ~= "    add" ~ indexTypeName ~ "\n";
        }

        // first dimension
        if(constSubscript[0] > 0) {
            asmCode ~= "    p" ~ indexTypeName ~ " " ~ to!string(constSubscript[0]) ~ "\n";
        }
        else {
            indices[0].setExpectedType(indexType);
            indices[0].eval();
            asmCode ~= to!string(indices[0]);
        }

        if(hasSecond) {
            asmCode ~= "    add" ~ indexTypeName ~ "\n";
        }

        // optimize if variable length is power of two
        if(ceil(log2(varLen)) == floor(log2(varLen))) {
            if(varLen > 1) { // No need to do anything if it's 1
                asmCode ~= "    lshift" ~ indexTypeName ~ "wconst "  ~ to!string(log2(varLen)) ~ "\n";
            }
        }
        else {
            asmCode ~= "    p" ~ indexTypeName ~ " " ~ to!string(varLen) ~ "\n";
            asmCode ~= "    mul" ~ indexTypeName ~ "\n";
        }
        
        return asmCode;
    }

    // direction: "p" means push, "pl" means pull
    private string getCode(string direction)
    {
        string asmCode;        
        ushort offset = this.getFieldOffset();

        if(hasSubscript()) {
            parseSubscript();
            if(isConstantSubscript) {
                offset += getAddressOffset();
            }
            else {
                asmCode ~= getArrayOffsetCode();
            }
        }
        
        const bool isArray = variable.isArray && !isConstantSubscript;   
        const string typeName = this.getType().isPrimitive ? this.getType().name : "udt";
      
        if(cast(ThisVariable)variable) {
            asmCode ~= "    " ~ direction ~ "relative" ~ typeName ~ "var " ~ to!string(offset);
            if(!this.getType().isPrimitive) {
                asmCode ~= ", " ~ to!string(this.getType().length);
            }
        }
        else {
            asmCode ~= "    " ~ direction ~ (variable.isDynamic ? "dyn" : "") ~ typeName 
                            ~ (isArray ? ("array" ~ (fastArrayAccess ? "fast" : "" )) : "var");
        
            if(offset > 0) {
                asmCode ~= " [" ~ variable.getAsmLabel() ~ " + " ~ to!string(offset) ~ "]";
            }
            else {
                asmCode ~= " " ~ variable.getAsmLabel();
            }
            if(!this.getType().isPrimitive) {
                asmCode ~= ", " ~ to!string(this.getType().length);
            }
            if(direction == "pl" && this.getType().name == Type.STRING) {
                asmCode ~= ", " ~ to!string(this.variable.getSingleLength());
            }
        }
        
        return asmCode ~ "\n";   
    }


    /** The final type of the expression */
    public Type getType()
    {
        if(this.type is null) {
            const int ix = findChild(node, "XCBASIC.Varname", 1);
            if(ix != -1) {
                string dotNotation = "";
                for(int i = ix; i < node.children.length; i++) {
                    dotNotation ~= node.children[i].matches.join("");
                    if(i + 1 < node.children.length) {
                        dotNotation ~= ".";
                    }
                }
                this.type = variable.type.getMemberType(dotNotation);
            }
            else {
                this.type = variable.type;
            }
        }
        return this.type;
    }

    /** This is just to satisfy the interface, there's no routine here */
    public Routine getRoutine()
    {
        return null;
    }
}