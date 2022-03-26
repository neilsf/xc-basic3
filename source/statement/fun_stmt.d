module statement.fun_stmt;

import std.conv, std.string, std.array, std.uni, std.algorithm;
import pegged.grammar;
import language.statement;
import globals, compiler.helper;
import compiler.compiler, compiler.routine, compiler.variable, compiler.type;

/** Parses and compiles a (DECLARE) FUNCTION or (DECLARE) SUB statement */
class Fun_stmt : Statement
{
    private struct ArgumentStub
    {
        string name;
        Type type;
        ushort strLen;
    }

    private string keyword;
    private string name;
    private Type type;
    private bool isShared = false;
    private bool isStatic = false;
    private bool isPrivate = false;
    private bool isMethod = false;
    private bool isDeclaration = false;
    private bool isAlreadyDeclared = false;
    private bool isOverload = false;
    private bool isInline = false;
    private Routine routine;
    private ArgumentStub[] argStubs;
    private ushort strLen;

    /** Class constructor */
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
	}

    private void verifyContext()
    {
        if(compiler.inProcedure) {
            compiler.displayError("Routines can not be nested");
        }
    }

    private void verifyName()
    {
        if(compiler.getRoutines().exists(this.name)) {
            
            const Routine tmpRoutine = compiler.getRoutines().get(this.name, this.routine.getArgsHash());
            if(tmpRoutine !is null) {
                // Same fingerprint
                if(!isDeclaration && tmpRoutine.isDefined) {
                    this.compiler.displayError("Routine \""
                        ~ this.routine.getNameWithArgTypes() ~ "\" already defined");
                }
                else if(isDeclaration) {
                    this.compiler.displayError("Routine \""
                        ~ this.routine.getNameWithArgTypes() ~ "\" already declared");
                }
                isAlreadyDeclared = true;
            }
            else {
                // Same name is only allowed when overriding
                if(!isOverload) {
                    this.compiler.displayError(
                        "Use the OVERLOAD keyword if you wish to overload routine \"" ~ this.name ~ "\""
                    );
                }
            }
        }

        if(compiler.getVars().findVisible(this.name) !is null) {
            this.compiler.displayError("Identifier \"" ~ this.name ~ "\" already in use");
        }
    }

    private void readArgs(ParseTree varList)
    {
        foreach (ref arg; varList) {
            VariableReader reader = new VariableReader(arg, compiler);
            Variable tmpVariable = reader.read(null, this.isStatic, !this.isInline);
            if(tmpVariable.type.name == Type.VOID) {
                compiler.displayError("Can't define param as VOID");
            }
            this.argStubs ~= ArgumentStub(tmpVariable.name, tmpVariable.type, tmpVariable.strLen);
            this.routine.addArgType(tmpVariable.type);
        }
    }

    private string getArgsHash()
    {
        return argStubs.map!(argStub => argStub.type.name).array().join("_");
    }

    // Add routine to collection and variable with same name (holder of the return value)
    private void addRoutine()
    {
        // Start routine 
        compiler.setProc(fixSymbol(this.name) ~ "_" ~ this.getArgsHash());
        compiler.currentProc = this.routine;
        if(!this.isDeclaration) {
            this.routine.isDefined = true;
        }
        // Add arguments
        if(!this.isInline) {
            foreach (ArgumentStub stub; argStubs) {
                Variable argument = Variable.create(stub.name, stub.type, compiler);
                argument.isDynamic = !this.isStatic;
                argument.strLen = stub.strLen;
                this.routine.addArgument(argument);
                this.compiler.getVars().add(argument, false);
            }
        }
        // Add storage for return value
        if(this.type.name != Type.VOID && !this.isInline) {
            Variable v = Variable.create(this.name, this.type, compiler, true);
            v.isFnRetVal = true;
            if(this.type.name == Type.STRING) {
                v.strLen = this.strLen;
            }
            compiler.getVars().add(v, false);
            this.routine.returnValue = v;
        }
        // Add routine
        this.compiler.getRoutines().add(this.routine);
        // Quit routine mode as we're declaring only
        if(isDeclaration) {
            compiler.clearProc();
            compiler.currentProc = null;
        }
    }

    /** Parse and compile */
    public void process()
    {
        // What keyword is used, SUB or FUNCTION
        int pos = 0;
        if(toUpper(this.node.matches[pos]) == "DECLARE") {
            this.isDeclaration = true;
            pos++;
        }
        this.keyword = (toUpper(this.node.matches[pos]) == "SUB") ? "SUB" : "FUNCTION";
        
        verifyContext();

        // Get attributes first
        foreach (ref child; this.node.children[0].children) {
            if(child.name == "XCBASIC.Funcattrib") {
                final switch(toUpper(child.matches[0])) {
                    case "STATIC":
                        this.isStatic = true;
                        break;

                    case "PRIVATE":
                        this.isPrivate = true;
                        break;

                    case "SHARED":
                        this.isShared = true;
                    break;

                    case "OVERLOAD":
                        this.isOverload = true;
                    break;

                    case "INLINE":
                        this.isInline = true;
                    break;
                }
            }
        }

        // Get name and type
        ParseTree procNameAndType = this.node.children[0].children[0]; // XCBASIC.Var
        ParseTree procName = procNameAndType.children[0];
        this.name = procName.matches.join("");
        if(procNameAndType.children.length > 1) {
            ParseTree procType = procNameAndType.children[1];
            if(join(procType.matches) == "") {
                this.type = compiler.getTypes().get(Type.VOID);
            }
            else {
                if(procType.name == "XCBASIC.Subscript") {
                    compiler.displayError("Syntax error");
                }
                string typeName = procType.children[0].matches.join("");
                if(!compiler.getTypes.defined(typeName)) {
                    compiler.displayError("Undefined type: " ~ typeName);
                }
                this.type = compiler.getTypes().get(typeName);
                if(this.type.name == Type.STRING) {
                    if(procType.children.length == 1 && !this.isInline) {
                        compiler.displayError("String length is required");
                    }
                    
                    if(procType.children.length > 1) {
                        immutable int len = to!int(join(procType.children[1].matches)[1..$]);
                        if(len < 1 || len > stringMaxLength) {
                            compiler.displayError("String length must be between 1 and " ~ to!string(stringMaxLength));
                        }
                        this.strLen = to!ubyte(len);
                    }
                }
            }
        }
        else {
            this.type = compiler.getTypes().get(Type.VOID);
        }

        if(this.keyword == "SUB" && this.type.name != Type.VOID) {
            compiler.displayError("A SUB may not have a type as it cannot return anything");
        }

        if(compiler.inTypeDef) {
            this.name = compiler.currentTypeDef.name ~ "." ~ this.name;
            this.isMethod = true;
        }

        if(this.isMethod && this.isShared) {
            compiler.displayError("A type method cannot cannot be SHARED");
        }
        else if(!this.isMethod && this.isPrivate) {
            compiler.displayError("The PRIVATE modifier can only be applied to type methods");
        }

        this.routine = new Routine(
            name, isShared, compiler.currentFileId,
            compiler, this.keyword, isStatic, isMethod,
            isPrivate, isInline
        );
        this.routine.type = this.type;

        // Get arguments
        if(this.node.children[0].children.length > 1 && this.node.children[0].children[1].name == "XCBASIC.VarList") {
            readArgs(this.node.children[0].children[1]);
        }

        verifyName();

        if(!isDeclaration) {
            // Definition of already declared routine
            if(isAlreadyDeclared) {
                Routine tmpRoutine = compiler.getRoutines().get(this.name, this.routine.getArgsHash());
                if(tmpRoutine.getHash() != this.routine.getHash()) {
                    compiler.displayError("Routine \'" ~ this.routine.getNameWithArgTypes()
                        ~ "\" must be defined as its prototype");
                }    
                this.routine = tmpRoutine;
                this.routine.isDefined = true;
            }
            // Definition of new routine
            else {
                this.addRoutine();
            }

            compiler.setProc(fixSymbol(name) ~ "_" ~ this.getArgsHash());
            compiler.currentProc = this.routine;
            appendCode("    IFCONST I_" ~ this.routine.getLabel() ~ "_IMPORTED\n");
            appendCode(this.routine.getLabel() ~ " SUBROUTINE\n");
        }
        // Routine declaration
        else {
            this.addRoutine();
        }
    }
}