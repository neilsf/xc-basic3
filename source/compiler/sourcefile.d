module compiler.sourcefile;

import std.conv, std.file, std.path, std.stdio, core.stdc.stdlib, pegged.grammar;
import std.string;

import language.grammar;
import compiler.library;

/** This class is responsible for reading and parsing source files */
class SourceFile
{
    /** File name, as received from user input */
    private string fileName = "";
    /** The contents of the file */
    private string sourceCode = "";
    /** The AST after parsing */
    private ParseTree ast;
    /** File counter */
    private static int fileCounter = 0;
    /** A unique identifier for this file */
    private string fileId = "";
    /** A container holding cached instances of this class */
    private static SourceFile[] container;
   
    /** Class constructor (not available for public) */
    protected this(string fileName)
    {
        this.fileName = fileName;
        readSourceFile();
        commentInlineAsm();
        parseSourceCode();

        // increment file identifier
        fileCounter += 1;
        this.fileId = "src" ~ to!string(fileCounter);
        container ~= this;
    }

    /** Factory method to find existing instance or create new one */
    public static SourceFile get(string fileName)
    {
        return SourceFile.existsInContainer(fileName) ? 
            SourceFile.findInContainer(fileName) : new SourceFile(fileName);
    }

    /** Checks if instance exists in container */
    private static bool existsInContainer(string fileName)
    {
        foreach (ref SourceFile file; container) {
            if(file.getFileName == fileName) {
                return true;
            }
        }
        return false;
    }

    /** Get an instance by fileName from container */
    public static SourceFile findInContainer(string fileName)
    {
        foreach (ref SourceFile file; container) {
            if(file.getFileName == fileName) {
                return file;
            }
        }
        assert(0);
    }

    private void readSourceFile()
    {
        immutable string currentDir = getcwd();
        immutable string dir = dirName(this.fileName);
        immutable string file = baseName(this.fileName);

        try {
            chdir(dir);
            if(!exists(file)) {
                // try in library dir
                chdir(getLibraryDir());
            }

            this.sourceCode = to!string(read(file));
        }
        catch(FileException e) {
            stderr.writeln("** ERROR ** Failed to open source file - " ~ e.msg);
            exit(1);
        }

        chdir(currentDir);
    }

    private void commentInlineAsm()
    {
        import std.stdio;
        bool inAsmBlock = false;
        bool hasAsmBlock = false;
        string[] lines = splitLines(this.sourceCode);
        for(int i = 0; i < lines.length; i++) {
            string line = lines[i];
            if(toLower(strip(line)) == "asm") {
                inAsmBlock = true;
                hasAsmBlock = true;
            }
            else if(toLower(strip(line)) == "end asm") {
                inAsmBlock = false;
            }
            else if(inAsmBlock) {
                lines[i] = "REM " ~ line;
            }
        }
        if(hasAsmBlock) {
            this.sourceCode = lines.join("\n");
        }
    }

    private void parseSourceCode()
    {
        this.ast = XCBASIC(this.sourceCode);
        // Parser error, display error msg and exit
        if(!this.ast.successful) {
            auto errorFormatter = delegate(Position pos, string left, string right, const ParseTree p) {
                string[] r_lines = right.splitLines();
                string[] l_lines = left.splitLines();
                string errorLine = r_lines.length > 0 ? r_lines[0] : l_lines[0];
                return this.fileName ~ ":" ~ to!string(pos.line + 1) ~ "." ~ to!string(pos.col) 
                ~ ": syntax error near '" ~ errorLine
                ~ "' in file " ~ this.fileName ~ " in line "
                ~ to!string(pos.line + 1);
            };
            string msg = this.ast.failMsg(errorFormatter);
            stderr.writeln(msg);
            //stderr.writeln(ast);
            exit(1);
        }
    }

    /** Getter method for fileName */
    public string getFileName()
    {
        return this.fileName;
    }

    /** Getter method for AST */
    public ParseTree getAst()
    {
        return this.ast;
    }

    /** Returns a unique identifier for this file */
    public string getFileId()
    {
        return this.fileId;
    }

    /** Getter method to access sourceCode */
    public string getSourceCode()
    {
        return this.sourceCode;
    }
}