module compiler.compiler;

import app;

import std.stdio, std.array, std.algorithm, std.file, std.conv, std.ascii;
import std.typecons, std.string;
import core.stdc.stdlib;

import pegged.grammar;
import language.grammar;

import compiler.labelcollection, compiler.intermediatecode, compiler.sourcefile,
       compiler.variable, compiler.type, language.statement, compiler.routine,
       compiler.codeblock, compiler.helper;

/** Verbosity level: errors only */
public enum VERBOSITY_ERROR   = 0;
/** Verbosity level: errors and warnings */
public enum VERBOSITY_WARNING = 1;
/** Verbosity level: errors, warnings and notices */
public enum VERBOSITY_NOTICE  = 2;
/** Verbosity level: all informational messages */
public enum VERBOSITY_INFO    = 3;

/** This class is responsible for compiling a valid AST to assembly code */
final class Compiler
{
    /** Compiler passes */
    enum PASS_PARSE_LABELS = 1;
    enum PASS_PRECOMPILE   = 2;
    enum PASS_COMPILE      = 3;
    enum PASS_OPTIMIZE     = 4;

    /* Visibility options */
    
    /** Visible in the current sub only */
    enum VIS_LOCAL         = 1;
    /** Visible in the entire module */
    enum VIS_GLOBAL        = 2;
    /** Visible across modules */
    enum VIS_COMMON        = 3;

    /** The current line in the AST being processed */
    private ParseTree currentNode;

    /** Verbosity level set in command argument */
    public int verbosity = VERBOSITY_INFO;

    /** The current source file being compiled */
    public string currentFileName = "";

    /** A short id to the source file being compiled */
    public string currentFileId = "";

    /** Whether statements other than REM or OPTION were already encountered */
    private bool statementsBegan = false;
    
    /** True if the current line should be copied varbatim to the intermediate code */
    public bool inlineAssembly = false;

    /** Labels in the source code */
    private LabelCollection labels;

    /** The intermediate assembly code */
    private IntermediateCode imCode;
    
    /** Program variables */
    private VariableCollection vars;

    /** Built-in and user-defined types */
    private TypeCollection types;

    /** All functions and procedures */
    private RoutineCollection routines;

    /** Whether the compiler is currently compiling code within a procedure */
    public bool inProcedure = false;

    /** Whether the compiler is currently compiling code within a TYPE definition */
    public bool inTypeDef = false;

    /** The type being defined if currently compiling code within a TYPE definition */
    public Type currentTypeDef;

    /** If inProcedure == true, this variable holds the current procedure name */
    public string currentProcName = "";

    /** If inProcedure == true, this is a reference to the Routine being compiled */
    public Routine currentProc;

    /** Whether the compiler is currently compiling code within a method */
    public bool inMethod = false;

    /** Stack area for code blocks */
    public Stack blockStack = Stack();

    /** Accumulate labels in this array */
    private string[] currentLabels;

    /** Whether the compiler is currently compiling user code, i.e not standard header files */
    public bool compilingUserCode = false;

    /** Class constructor */
    this()
    {
        // Initialize code
        this.imCode = new IntermediateCode(this);

        // Initialize labels
        this.labels = new LabelCollection(this);

        // Initialize variables
        this.vars = new VariableCollection(this);

        // Initialite types
        this.types = new TypeCollection();

        // Initialize routines
        this.routines = new RoutineCollection(this);
    }

     /** Set current procedure */
    public void setProc(string procName)
    {
        this.inProcedure = true;
        this.currentProcName = procName;
        if(this.inTypeDef) {
            this.inMethod = true;
        }
    }

    /** Unset current procedure */
    public void clearProc()
    {
        this.inProcedure = false;
        this.currentProcName = "";
        this.inMethod = false;
    }

    /** Outputs error message and halts compilation if necessary */
    // TODO: provide column number
    public void displayError(string msg, bool isRecoverable = false, string msgType = "ERROR")
    {
        size_t charPos = this.currentNode.begin;
        SourceFile file = SourceFile.findInContainer(this.currentFileName);
        immutable ulong lineNo = count(file.getSourceCode()[0..charPos], newline) + 1;
        stderr.writeln(this.currentFileName ~ ":" ~ to!string(lineNo) ~ ".0: " ~ msgType ~ ": " ~ msg
        );
        if(!isRecoverable) {
            exit(1);
        }
    }

    /** Outputs warning level message and continues compilation */
    public void displayWarning(string msg)
    {
        if(this.verbosity >= VERBOSITY_WARNING) {
            this.displayError(msg, true, "WARNING");
        }
    }

    /** Outputs a notice level message and continues compilation */
    public void displayNotice(string msg)
    {
        if(this.verbosity >= VERBOSITY_NOTICE) {
            this.displayError(msg, true, "NOTICE");
        }
    }

    /** Processes one line of code */
    private void processLine(ParseTree line, int pass)
    {
        ParseTree lineId = line.children[0];
        ParseTree statements;
        bool hasStatement = false;

        if(line.children.length > 1 && line.children[0].name == "XCBASIC.Asmline") {
            writeln("--ASM--");
            writeln(line);
            writeln("--/ASM--");
            return;
        }

        if(line.children.length > 1) {
            statements = line.children[1];
            hasStatement = true;
        }

        switch(pass) {
            case PASS_PRECOMPILE:
                if(hasStatement) {
                    foreach (ref child; statements.children) {
                        auto statement = child.children[0];
                        immutable string nodeName = statement.name;
                        switch(nodeName) {
                            case "XCBASIC.Proc_stmt":
                            case "XCBASIC.Fun_stmt":
                                this.setProc(join(statement.children[0].matches));
                                break;

                            case "XCBASIC.Endproc_stmt":
                            case "XCBASIC.Endfun_stmt":
                                this.clearProc();
                                break;

                            default:
                                break;
                        }
                    }
                }
                return;
                //break;

            case PASS_COMPILE:
                immutable string labelType = lineId.children.length == 0 ? "XCBASIC.none" : lineId.children[0].name;
                bool hasLabel = false;
                string labelString;
                if(labelType == "XCBASIC.Label") {
                    labelString = join(lineId.children[0].matches[0..$-1]);
                    hasLabel = true;
                }
                else if(labelType == "XCBASIC.Unsigned") {
                    labelString = join(lineId.children[0].matches[0..$]);
                    hasLabel = true;
                }
                if(hasLabel) {
                    // Don't put label now, just remember to put it before next statement
                    this.currentLabels ~= this.labels.toAsmLabel(labelString) ~ ":";
                }

                // line has statement(s) excluding an INCLUDE directive
                if(hasStatement) {
                    // process all statements in line
                    foreach(ref child; statements.children) {
                        if(child.children[0].name == "XCBASIC.Include_stmt") {
                            if(this.inProcedure) {
                                this.displayError("INCLUDE is not allowed inside a SUB or FUNCTION");
                            }
                            // save current filename & id
                            immutable string savedFileName = this.currentFileName;
                            immutable string savedFileId = this.currentFileId;
                            // parse included file
                            string fileName = join(child.children[0].children[0].matches)[1..$-1];
                            SourceFile file = SourceFile.get(fileName);
                            this.compileSourceFile(file);
                            // restore current filename & id
                            this.currentFileName = savedFileName;
                            this.currentFileId = savedFileId;
                        }
                        else {
                            Statement stmt = stmtFactory(child, this);
                            if(this.inTypeDef && !this.inMethod
                                && stmt.classinfo.name != "statement.rem_stmt.Rem_stmt"
                                && stmt.classinfo.name != "statement.type_stmt.Field_def"
                                && stmt.classinfo.name != "statement.fun_stmt.Fun_stmt"
                                && stmt.classinfo.name != "statement.type_stmt.Field_def"
                                && stmt.classinfo.name != "statement.type_stmt.Endtype_stmt") {
                                this.displayError("TYPE blocks can only contain field or method definitions");
                            }
                            stmt.process();
                        }
                        
                        if(compilingUserCode && !canFind(["XCBASIC.Rem_stmt", "XCBASIC.Option_stmt"], child.children[0].name)) {
                            statementsBegan = true;
                        }
                    }
                   
                }
                break;
            
            default:
                assert(0);
        }
    }

    /** Walks through the source code and collects all labels */
    private void fetchLabels(ParseTree ast)
    {
        this.clearProc();

        foreach(ref child; ast.children[0].children) {
            // empty line
            if(child.name != "XCBASIC.Line" || child.children.length == 0) {
                continue;
            }

            // line starts with a line number or label
            auto lineLabel = child.children[0];
            immutable string labelType = lineLabel.children.length == 0 ? "XCBASIC.none" : lineLabel.children[0].name;
            if(labelType == "XCBASIC.Label") {
                this.labels.add(join(lineLabel.children[0].matches[0..$-1]));
            }
            else if(labelType == "XCBASIC.Unsigned") {
                this.labels.add(join(lineLabel.children[0].matches[0..$]));
            }

            // line has statement(s)
            if(child.children.length > 1) {
                auto stmt = child.children[1].children[0].children[0];
                switch(stmt.name) {
                    case "XCBASIC.Proc_stmt":
                    case "XCBASIC.Fun_stmt":
                        if(toLower(stmt.matches.join())[0..3] != "dec" ) { // "declare"
                            this.inProcedure = true;
                            string pName = fixSymbol(stmt.children[0].matches[0]) ~ "_";
                            string[] argTypes;
                            if(stmt.children.length > 1) {
                                if(stmt.children[1].name == "XCBASIC.VarList") {
                                    foreach (ref arg; stmt.children[1].children) {
                                        argTypes ~= toLower(arg.children[1].matches.join());
                                    }
                                    pName ~= argTypes.join("_");
                                }
                            }
                            this.currentProcName = pName;
                        }
                        break;

                    case "XCBASIC.Endproc_stmt":
                    case "XCBASIC.Endfun_stmt":
                        this.clearProc();
                        break;

                    default:
                        break;
                }
            }
        }
    }

    /** Performs compilation of a source file */
    public void compileSourceFile(SourceFile file)
    {
        this.currentFileName = file.getFileName();
        this.currentFileId = file.getFileId();
        this.processAst(file.getAst());
        // Check for unclosed blocks
        if(!blockStack.isEmpty()) {
            this.displayError("Premature end of file (unclosed " ~ blockStack.top().getTypeString() ~ " block)");
        }
    }

    /** Recursively walks through the AST and passes each line for further processing */
    private void walkAst(ParseTree ast, int pass)
    {
        this.currentNode = ast;
        switch(ast.name) {
            case "XCBASIC.Line":
                this.processLine(ast, pass);
                break;

            default:
                foreach(ref child; ast.children) {
                    walkAst(child, pass);
                }
            break;
        }
    }

    /** Calls all compilation passes on an AST */
    private void processAst(ParseTree ast)
    {
        // Pass 1: find labels
        this.fetchLabels(ast);
        
        // Pass 2:
        this.clearProc();
        walkAst(ast, PASS_PRECOMPILE);

        // Pass 3:
        this.clearProc();
        walkAst(ast, PASS_COMPILE);
    }

    /** Getter method that provides access to compiler.types */
    public TypeCollection getTypes()
    {
        return this.types;
    }

    /** Getter method that provides access to compiler.labels */
    public LabelCollection getLabels()
    {
        return this.labels;
    }

    /** Getter method that provides access to compiler.vars */
    public VariableCollection getVars()
    {
        return this.vars;
    }

    /** Getter method that provides access to compiler.routines */
    public RoutineCollection getRoutines()
    {
        return this.routines;
    }

    /** Getter method that provides access to compiler.imCode */
    public IntermediateCode getImCode()
    {
        return this.imCode;
    }

    /** Getter method that provides access to compiler.currentNode */
    public ParseTree getCurrentNode()
    {
        return this.currentNode;
    }

    /** Getter method to provide read access to compiler.statementsBegan */
    public bool getStatementsBegan()
    {
        return this.statementsBegan;
    }

    /** Returns the joint labels and empties current labels */
    public string getAndClearCurrentLabels()
    {
        string lbls = currentLabels.join("\n") ~ "\n";
        currentLabels = [];
        return lbls;
    }

    /** Turn on inline assembly */
    public void startInlineAssembly()
    {
        this.inlineAssembly = true;
    }

    /** Turn off inline assembly */
    public void endInlineAssembly()
    {
        this.inlineAssembly = false;
    }

    /** Check if everything went right */
    public void doPostChecks()
    {
        // 1. Check for routines not implemented
        routines.postCheck();
        dumpLabels();
    }
    
    /** Dump any labels accumulated */
    public void dumpLabels()
    {
        const string labels = getAndClearCurrentLabels();
        if(labels != "\n") {
            getImCode().appendProgramSegment(labels);    
        }
    }
}

/** Find a node in parent */
int findChild(ParseTree node, string childName, int start = 0)
{
    for(int i = start; i < node.children.length; i++) {
        if(node.children[i]. name == childName) {
            return i;
        }
    }
    return -1;
}

/** Common methods that must be implemented by an accessor type of expression (e. g Variable access, Fn call, etc) */
interface AccessorInterface
{
    /** Get the type of the expression */
    public Type getType();
    /** Assembly code that pushes the evaluated value on stack */
    public string getPushCode();
    /** Assembly code that pushes the address on stack */
    public string getPushAddressCode();
    /** Is it a constant expression */
    public bool isConstant();
    /** Returns the value if it's a constant */
    public float getConstVal();
    /** Get routine or null if it's not a routine call */
    public Routine getRoutine();
    /** Returns whether this is a sub, function or method call rather than a var access */
    public bool isFunctionCall() const;
}
