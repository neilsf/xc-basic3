module compiler.routine;

import pegged.grammar;

import std.conv, std.algorithm.searching, std.algorithm.iteration, std.array, std.uni;
import compiler.compiler, compiler.variable, compiler.type, compiler.helper;
import language.expression, language.accessor;

/** A routine (or function) */
class Routine
{
    /** The keyword that was used: SUB or FUNCTION */
    protected string keyword;
    /** Identifier */
    protected string name;
    /** Arguments */
	protected Variable[] arguments;
    /** Argument types */
    protected Type[] argTypes;
    /** variable holding the return value of the function */
    public Variable returnValue;
    /** Shared routines are visible outside the source file where they're defined */
    protected bool isShared = false;
    /** Private applies to methods, meaning it can only be called within the same type */
    protected bool isPrivate = false;
    /** Identifier of the file where the routine was defined */
    protected string fileId = "";
    /** Whether the routine is static or dynamic */
    protected bool isStatic = false;
    /** Is it inside a TYPE definition and thus being the method of a type? */
    protected bool isMethod = false;
    /** The size of stack frame that must be allocated upon calling the routine */
    protected int stackFrameSize = 0;
    /** A reference to the compiler object */
    protected Compiler compiler;
    /** The return type, VOID if it's a SUB */
    public Type type;
    /** To which Type the method belongs to */
    public Type parentType;
    /** Flag indicating whether the routine ever called itself */
    public bool recursed = false;
    /** Flag indicating whether the routine is defined (true) or declared only (false) */
    public bool isDefined = false;
    /** If false, the hashing routines will not use argument's as they're not added yet */
    public bool isDeclarationComplete = false;
    /** Inline function */
    protected bool isInline = false;

     /** Class constructor */
    this(string name, bool isShared, string fileId, Compiler compiler, string keyword,
         bool isStatic = false, bool isMethod = false, bool isPrivate = false, bool isInline = false)
    {
        this.name = toLower(name);
        this.isShared = isShared;
        this.fileId = fileId;
        this.isStatic = isStatic;
        this.compiler = compiler;
        this.keyword = keyword;
        this.isMethod = isMethod;
        if(isMethod) {
            this.parentType = compiler.currentTypeDef;
        }
        this.isPrivate = isPrivate;
        this.isInline = isInline;
    }

    /** The assembly label of the entry point of this routine */
    public string getLabel()
    {
        return "F_" ~ (this.isShared ? "" : (compiler.currentFileId ~ "."))
                ~ fixSymbol(this.name) ~ (this.argTypes.length > 0 ? "_" ~ getArgsHash() : "");
    }

    /** Add an argument to the routine's argument list */
    public void addArgument(Variable var)
	{
		this.arguments ~= var;
	}

    /** Add an argument type to the routine's argument type list */
    public void addArgType(Type type)
    {
        this.argTypes ~= type;
    }

    /** Add dynamic variable. Currently only cares about stack frame offset */
    public void addDynamicVariable(Variable var)
    {
        var.offsetWithinFrame = this.stackFrameSize;
        this.compiler.getImCode().appendProgramSegment(var.getAsmLabel() ~ " EQU " ~ to!string(var.offsetWithinFrame) ~ "\n");
        this.increaseStackFrameSize(var.getLength());
    }

    /** How many bytes must be allocated on stack for this routine */
    public int getStackFrameSize()
    {
        return this.stackFrameSize;
    }

    protected void increaseStackFrameSize(int incSize)
    {
        this.stackFrameSize += incSize;
        if(this.stackFrameSize > 256) {
            compiler.displayError("Maximum stack frame size of function exceeded");
        }
    }

    private string[] getArgTypeNames()
    {
        return argTypes.map!(argType => argType.name).array();
    }

    /** Returns the identifier of this variant among multiple implementations */
    public string getArgsHash()
    {
        return this.getArgTypeNames().join("_");
    }

    /** Returns the identifier of the function without its overloaded variants */
    public string getFunctionHash()
    {
        return [
            fileId,
            keyword,
            name,
            type.name,
            (isMethod ? parentType.name : "."),
            (isStatic ? "S" : "."),
            (isPrivate ? "P" : "."),
            (isShared ? "H" : "."),
            (isMethod ? "M" : ".")
        ].join("|");
    }

    /** Returns a unique hash that identifies this routine */ 
    public string getHash()
    {
        return getFunctionHash() ~ "|" ~ getArgsHash();
    }

    /** Returns routine name with argument types in parenthesis */
    public string getNameWithArgTypes()
    {
        return this.name ~ "(" ~ this.getArgTypeNames().join(", ") ~ ")";
    }

    /** Getter for isStatic */
    public bool getIsStatic()
    {
        return isStatic;
    }

    /** Getter for isMethod */
    public bool getIsMethod()
    {
        return isMethod;
    }

    /** Getter for name */
    public string getName()
    {
        return name;
    }
    
    /** Getter for keyword */
    public string getKeyword()
    {
        return keyword;
    }

    /** Getter for arguments */
    public Variable[] getArguments()
    {
        return this.arguments;
    }
}

/** Container class for routies */
class RoutineCollection
{
    private Compiler compiler;
    private Routine[] routines;

    /** Class constructor */
    this(Compiler compiler)
    {
        this.compiler = compiler;
    }

    /** Find a routine by name and arg hash */
    public Routine get(string name, string argHash)
    {
        Routine[] r = find!(
            routine =>
                routine.name == toLower(name)
                && (routine.isShared || routine.fileId == compiler.currentFileId)
                && routine.getArgsHash() == argHash
        )(routines);
        if(r.length > 0) {
            return r[0];
        }
        return null;
    }

    /** Find all variants of a routine by name */
    public Routine[] getVariants(string name)
    {
        return routines.filter!(
            routine =>
                routine.name == toLower(name)
                && (routine.isShared || routine.fileId == compiler.currentFileId)
        ).array;
    }

    /** Check if routine exists by name */
    public bool exists(string name)
    {
        return this.getVariants(name).length > 0;
    }

    /** Add a routine to the collection */
    public void add(Routine routine)
    {
        this.routines ~= routine;
    }
}

/** Parses and compiles a routine call in AST */
class RoutineCall : AccessorInterface
{
    // XCBASIC.Accessor
    protected ParseTree node;
    protected Routine[] candidates;
    protected Routine routine;
    protected Compiler compiler;
    protected string routineName;
    protected Variable thisVar;

    /** Class constructor */
    this(ParseTree node, Compiler compiler, bool failIfNotFound = true)
    {
        this.node = node;
        this.compiler = compiler;
        this.findCandidates();
        if(failIfNotFound && (candidates.length == 0)) {
            AccessorException e = new AccessorException("SUB or FUNCTION \"" ~ routineName ~ "\" not found");
            e.isFatal = false;
            throw e;
        }
        this.findRoutine();
        if(failIfNotFound && (routine is null)) {
            string[] typeNames;
            foreach (ref t; getCallerArgTypes()) {
                typeNames ~= t.name;
            }
            string argTypesEnum = typeNames.join(", ");
            AccessorException e = new AccessorException("SUB or FUNCTION \"" ~ routineName
                                ~ "\" not callable using argument(s) ("
                                ~ argTypesEnum ~ ")");
            e.isFatal = true;
            throw e;
        }
    }

    /** Is it a constant expression */
    public bool isConstant()
    {
        return false;
    }

    /** Returns the value if it's a constant */
    public float getConstVal()
    {
        return 0.0;
    }
    
    /** Get the type of the expression */
    public Type getType()
    {
        return routine.type;
    }

    protected ParseTree getExprList()
    {
        return node.children[$ - 1];
    }

    private Type[] getCallerArgTypes()
    {
        Type[] types;
        getExprList().children.each!((expr) {
            Expression e = new Expression(expr, compiler);
            types ~= e.getType();
        });
        return types;
    }

    protected string getCallerArgHash()
    {
        return getCallerArgTypes().map!(type => type.name).array().join("_");
    }

    protected string getPushArgs()
    {
        string asmCode = "";
        ParseTree exprList = getExprList();
        if(exprList.children.length != routine.argTypes.length) {
            compiler.displayError("Wrong number of arguments");
        }
        int argNo = 0;
        Variable arg;
        Type argType;
        foreach (ref expr; exprList.children) {
            Expression e = new Expression(expr, compiler);
            argType = routine.argTypes[argNo];
            e.setExpectedType(argType);
            e.eval();
            asmCode ~= to!string(e);
            if(routine.isStatic && !routine.isInline) {
                arg = routine.arguments[argNo];
                asmCode ~= "    pl" ~ arg.type.name ~ "var " ~ arg.getAsmLabel() ~ "\n";
            }
            argNo++;
        }

        if(!routine.isStatic && !routine.isInline) {
            asmCode ~= "    framealloc " ~ to!string(routine.getStackFrameSize()) ~ "\n";
            for(argNo -= 1; argNo >= 0; argNo--) {
                arg = routine.arguments[argNo];
                asmCode ~= "    pldyn" ~ arg.type.name ~ "var " ~ arg.getAsmLabel() ~ "\n";
            }
        }
        return asmCode;
    }

    protected string getExecCode()
    {
        string asmCode;
        if(!routine.isInline) {
            asmCode = "    import I_" ~ routine.getLabel() ~ "\n";
            asmCode ~= "    jsr " ~ routine.getLabel() ~ "\n";
            if(!routine.isStatic) {
                asmCode ~= "    framefree " ~ to!string(routine.getStackFrameSize()) ~ "\n";
            }
        }
        else {
            asmCode ~= "    " ~ routine.getLabel() ~ "\n";
        }
        return asmCode;
    }

    protected string getPullCode()
    {
        if(routine.type.name != Type.VOID && !routine.isInline) {
            return "    p" ~ routine.type.name ~ "var " ~ routine.returnValue.getAsmLabel() ~ "\n";
        }
        return "";
    }

    /** Returns intermediate code to call the routine and push its return value onto stack */
    public string getPushCode()
    {
        return getPushArgs() ~ getExecCode() ~ getPullCode();
    }

    protected void findCandidates()
    {
        routineName = node.children[0].matches.join("");
        candidates = compiler.getRoutines().getVariants(routineName);
    }

    protected void findRoutine()
    {
        import std.stdio;
        immutable string callerArgHash = getCallerArgHash();
        Type[] callerArgTypes = getCallerArgTypes();
        int i, j;
        int[int] score;
        j = 0;
        // Best case: find exact match
        foreach (ref candidate; candidates) {
            if(candidate.argTypes.length != callerArgTypes.length) {
                score[j] = int.max;
                continue;
            }
            if(candidate.getArgsHash() == callerArgHash) {
                // perfect match
                routine = candidate;
                return;
            }
            score[j] = 0;
            foreach (ref calleeType; candidate.argTypes) {
                Type callerType = callerArgTypes[i];
                //writeln("testing " ~ callerType.name ~ " against " ~ calleeType.name);
                if(!callerType.isConvertable(calleeType)) {
                   score[j] = int.max;
                   break;
                }
                else {
                    score[j] += callerType.getConversionPenalty(calleeType);    
                }
            }
            j++;
        }
        int minIx = -1; int minVal = int.max;
        for(i = 0; i < j; i++) {
            if(score[i] < minVal) {
                minVal = score[i];
                minIx = i;
            }
        }
        if(minVal < int.max) {
            routine = candidates[minIx];
        }
    }

    /** Getter method for this.routine */
    public Routine getRoutine()
    {
        return this.routine;
    }

    /** Returns whether this is a sub, function or method call rather than a var access */
    public bool isFunctionCall() const
    {
        return true;
    }
}

/** Parses and compiles a method call in AST */
class MethodCall : RoutineCall
{
    private ushort thisOffset = 0;
    private bool callWithinSameType = false;
    private bool callToOtherType = false;

    /** Class constructor */
    this(ParseTree node, Compiler compiler, bool failIfNotFound = true)
    {
        super(node, compiler, failIfNotFound);
    }

    override protected void findCandidates()
    {
        // Not a method call if less than 2 members in dot notation
        if(count!((child) => child.name == "XCBASIC.Varname")(node.children) < 2) {
            return;
        }
        Type t;
        // Get method name
        immutable string methodName = node.children[$ - 2].matches.join("");
        // Get variable name
        immutable string varName = node.children[0].matches.join("");
        // Get type in which the method is called
        if(toLower(varName) == "this" && node.children.length == 2 /* && compiler.inTypeDef */) {
            // THIS.method()
            t = compiler.currentTypeDef;
            callWithinSameType = true;
        }
        else if(toLower(varName) == "this") {
            // THIS.member...method()
            t = compiler.currentTypeDef;
            callToOtherType = true;
        }
        else {
            thisVar = compiler.getVars().findVisible(varName);
            if(thisVar is null) {
                return;
            }
            t = thisVar.type;
        }
        
        string dotNotation = getDotNotation();
        
        this.thisOffset = t.getMemberOffset(dotNotation);
        immutable string methodFullName = t.getMemberType(dotNotation).name ~ "." ~ methodName;
        candidates = compiler.getRoutines().getVariants(methodFullName);
    }

    private string getDotNotation()
    {
        string[] parts;
        node.children[1 .. $ - 2].each!((child) {
            if(child.name == "XCBASIC.Varname") {
                parts ~= child.matches.join("");
            }
        });
        return parts.join(".");
    }

    override protected void findRoutine()
    {
        super.findRoutine();
        if(this.routine !is null) {
            if(this.routine.isPrivate && compiler.currentTypeDef != this.routine.parentType) {
                immutable string methodName = node.children[$ - 2].matches.join("");
                compiler.displayError("PRIVATE method \"" ~ methodName ~ "\" not visible in this scope");
            }
        }
                
    }

    private string getSetThis()
    {
        assert(thisVar !is null, "Bad things going on here");
        string th = thisOffset > 0 ? "(" ~ thisVar.getAsmLabel() ~ " + " ~ to!string(thisOffset) ~ ")" : thisVar.getAsmLabel();
        return 
            (compiler.inTypeDef ? "    pthis\n" : "") ~
            "    setthis " ~ th ~ "\n";
    }

    private string getOffsetThis()
    {
        return "    pthis\n    offsetthis " ~ to!string(thisOffset) ~ "\n";
    }

    private string getRestoreThis()
    {
        return !compiler.inTypeDef ? "" : "    plthis\n";
    }

    /** Returns intermediate code to call the routine and push its return value onto stack */
    override public string getPushCode()
    {
        return getPushArgs() 
                ~ (callWithinSameType ? "" : (callToOtherType ? getOffsetThis() : getSetThis()))
                ~ getExecCode()
                ~ (callWithinSameType ? "" : getRestoreThis()) 
                ~ getPullCode();
    }
}