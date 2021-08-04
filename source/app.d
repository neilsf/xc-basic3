/**
 * XC=BASIC
 *
 * A BASIC cross compiler for MOS 6502-based machines
 *
 * Author: Csaba Fekete <feketecsaba@gmail.com>
 */

import std.stdio, std.string, std.getopt, std.file, std.path,
        std.conv, std.random, std.process;
import core.stdc.stdlib;

import pegged.grammar;
import language.grammar;

import compiler.compiler, compiler.library, compiler.sourcefile;

// Program version
const string APP_VERSION = "v3.0.0-alpha";

// Command line options
private bool noopt = false;
private string outputFormat = "prg";
version(Windows) {
	private string dasm = "dasm.exe";
}
else {
	private string dasm = "dasm";
}
private string symbolfile="";
private string listfile="";
private bool dumpast = false;
private int verbosity = VERBOSITY_INFO;

/**
 * Application entry point
 */
void main(string[] args)
{ 
    checkLibrary();
    
    // Read and validate command line options
    GetoptResult helpInformation;
    try {
        helpInformation = getopt(args,
            "dasm|d", &dasm,
            "symbol|s", &symbolfile,
            "list|l", &listfile,
            "noopt|n", &noopt,
            "format|f", &outputFormat,
            "dump-ast|a", &dumpast,
            "verbosity|v", &verbosity
        );
    }
	catch(Exception e) {
        stderr.writeln(e.msg);
        exit(1);
    }

    if(helpInformation.helpWanted) {
        displayHelp(0);
    }

	validateOptions(args);
    
    const string fileName = args[1];
    const string outName = args[2];

    // Compile the program
    Compiler compiler = new Compiler();
    immutable string currentDir = getcwd();
    chdir(dirName(fileName));
    SourceFile source = SourceFile.get(baseName(fileName));
    compiler.compileSourceFile(source);
    chdir(currentDir);
        
     // Write intermediate code to temp file
    auto rnd = Random(unpredictableSeed);
    auto u = uniform!uint(rnd);

    version(Windows) {
        const string tmpdir = tempDir();
    }
    else {
        const string tmpdir = tempDir() ~ dirSeparator;
    }

    string asmFilename = tmpdir ~ "xcbtmp_" ~ to!string(u, 16) ~ ".asm";
    File outfile = File(asmFilename, "w");
    outfile.write(compiler.getImCode().getCode());
    outfile.close();

    // Call DASM to compile intermediate code to exacutable
    version(Windows) {
        dasm = `"` ~ dasm ~ `"`;
        asmFilename = `"` ~ asmFilename ~ `"`;
        outname = `"` ~ outname ~ `"`;
        if(symbolfile != "") {
            symbolfile = `"` ~ symbolfile ~ `"`;
        }
        if(listfile != "") {
            listfile = `"` ~ listfile ~ `"`;
        }
    }

    string cmd = dasm ~ " " ~ asmFilename ~ " -o" ~ outName;
    if(symbolfile != "") {
        cmd ~= " -s" ~ symbolfile;
    }
    if(listfile != "") {
        cmd ~= " -l" ~ listfile;
    }
    auto dasm_cmd = executeShell(cmd);
    //remove(asmFilename);
    if(dasm_cmd.status != 0) {
        stderr.writeln("** ERROR ** There has been an error while trying to execute DASM, please see the bellow message.");
        stderr.writeln("Tried to execute: " ~ cmd);
        stderr.writeln(dasm_cmd.output);
        exit(1);
    }
    else {
        stdout.write(dasm_cmd.output);
        exit(0);
    }
}

/**
 * Checks if provided options are valid
 */
private void validateOptions(string[] args)
{
	if(outputFormat != "prg" && outputFormat != "asm") {
        stderr.writeln("Invalid value for option -o. Use --help for more information.");
        exit(1);
    }

    if(args.length < 3) {
        stderr.writeln("Too few command line options. Use --help for more information.");
        exit(1);
    }
}

/**
 * Display help message and exit
 */
private void displayHelp(int exitCode, string errorMsg = "")
{
    stdout.writeln(errorMsg ~
`
XC=BASIC compiler version ` ~ APP_VERSION ~ `
Copyright (c) 2019-2021 by Csaba Fekete
Usage: xcbasic3 [options] <inputfile> <outputfile> [options]
Options:
   -f
  --format=     Output format: "prg" (default, will call DASM) or "asm"

   -d
  --dasm=       Path to the DASM executable.
                Not required if DASM is in your PATH or in the working dir.

   -s
  --symbol=     Symbol dump file name. This is passed to DASM as it is.

   -l
  --list=       List file name. This is passed to DASM as it is.

   -n
  --noopt       Do NOT run the optimizer

   -a
  --dump-ast    Do not compile, just dump the Abstract Syntax Tree

   -h
  --help        Show this help
`
    );
    exit(exitCode);
}

/**
 * Check if XC=BASIC library exists, display error message if it doesn't
 */
private void checkLibrary()
{   
    if(!exists(getLibraryPath())) {
        stderr.writeln("XC=BASIC library was not found in \"" ~ getLibraryDir() ~ "\". Please make sure the directory exists and contains the library files.");
        exit(1);
    }
}