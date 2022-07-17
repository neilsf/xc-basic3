/**
 * XC=BASIC
 *
 * A BASIC cross compiler for MOS 6502-based machines
 *
 * Author: Csaba Fekete <feketecsaba@gmail.com>
 */

import std.stdio, std.string, std.getopt, std.file, std.path,
        std.conv, std.random, std.process, std.algorithm;
import core.stdc.stdlib;

import pegged.grammar;
import language.grammar;

import compiler.compiler, compiler.library, compiler.sourcefile;

import globals, optimizer;

// Program version
const string APP_VERSION = "v3.0.8";

/** Possible target options */
const string[] targetOpts = [
    "c64",      // Commodore-64
    "vic20",    // Commodore VIC-20 (unexpanded)
    "vic20_3k", // Commodore VIC-20 with 3k RAM expansion
    "vic20_8k", // Commodore VIC-20 with 8k RAM expansion
    "cplus4",   // Commodore Plus/4
    "c16",      // Commodore-16,
    "c128",     // Commodore-128
    "pet2001",  // Commodore PET2001
    "pet3008",  // Commodore PET3000 series (8k RAM)
    "pet3016",  // Commodore PET3000 series (16k RAM)
    "pet3032",  // Commodore PET3000 series (32k RAM)
    "pet4016",  // Commodore PET4000 series (16k RAM)
    "pet4032",  // Commodore PET4000 series (32k RAM)
    "pet8032"   // Commodore PET8000 series
];

// Command line options
private bool optimize = true;
private bool keepImCode = false;
version(Windows) {
	private string dasm = "dasm.exe";
}
else {
	private string dasm = "dasm";
}
private string symbolfile="";
private string listfile="";
private int verbosity = VERBOSITY_INFO;

private GetoptResult helpInformation;

/**
 * Application entry point
 */
void main(string[] args)
{ 
    checkLibrary();
    
    // Read and validate command line options
    try {
        helpInformation = getopt(args,
            "target|t", &target,
            "basic-loader|b", &basicLoader,
            "start-address|o", &startAddress,
            "max-address|m", &topAddress,
            "dasm|d", &dasm,
            "symbol|s", &symbolfile,
            "list|l", &listfile,
            "optimize|p", &optimize,
            "keep-imcode|k", &keepImCode,
            "verbosity|v", &verbosity,
            "inline-data|i", &inlineData
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
    setStartAddress();
    
    const string fileName = args[1];
    string outName;
    if(args.length >= 3) {
        outName = args[2];
    }
    else {
        outName = to!string(fileName.withExtension("prg"));
        if(verbosity >= VERBOSITY_NOTICE) {
            stdout.writeln("** NOTICE ** Output file not specified, defaulting to " ~ outName);
        }
    }

    Compiler compiler = new Compiler();
    // Compile standard headers
    const string stdHeadersName = getLibraryDir() ~ "/headers.bas";
    SourceFile source = SourceFile.get(stdHeadersName);
    compiler.compileSourceFile(source);
    // Compile the program
    compiler.compilingUserCode = true;
    immutable string currentDir = getcwd();
    chdir(dirName(fileName));
    source = SourceFile.get(baseName(fileName));
    compiler.compileSourceFile(source);
    compiler.doPostChecks();
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
    string tmpSymbolfile = tmpdir ~ "xcbtmp_" ~ to!string(u, 16) ~ ".sym";

    File outfile = File(asmFilename, "w");
    if(optimize) {
        OptimizerPass optimizer = new Optimizer();
        optimizer.setInCode(compiler.getImCode().getCode());
        optimizer.run();
        outfile.write(optimizer.getOutCode());
    } else {
        outfile.write(compiler.getImCode().getCode());
    }
    
    outfile.close();

    // Call DASM to compile intermediate code to exacutable
    version(Windows) {
        dasm = `"` ~ dasm ~ `"`;
        asmFilename = `"` ~ asmFilename ~ `"`;
        outName = `"` ~ outName ~ `"`;
        if(listfile != "") {
            listfile = `"` ~ listfile ~ `"`;
        }
    }

    string cmd = dasm ~ " " ~ asmFilename ~ " -o" ~ outName ~ " -s" ~ tmpSymbolfile;

    if(listfile != "") {
        cmd ~= " -l" ~ listfile;
    }
    auto dasm_cmd = executeShell(cmd);
    
    if(!keepImCode) {
        try {
            remove(asmFilename);
        }
        catch(Exception e) {
            // There has been an error while removing the file
            // it's okay, since it's in a temp dir, it'll be removed anyway
        }
        
    } else {
        stdout.writeln("File containing intermediate code kept in " ~ asmFilename);
    }
    
    if(dasm_cmd.status != 0) {
        stderr.writeln("** ERROR ** There has been an error while trying to execute DASM, please see the bellow message.");
        stderr.writeln("Tried to execute: " ~ cmd);
        stderr.writeln(dasm_cmd.output);
        stderr.writeln("Please submit this bug to https://github.com/neilsf/xc-basic3/issues");
        exit(1);
    }
    else {
        if(verbosity == VERBOSITY_INFO) {
            displayInformation(tmpSymbolfile);
        }
        if(symbolfile != "") {
            copy(tmpSymbolfile, symbolfile);
        }
        remove(tmpSymbolfile);
        exit(0);
    }
}

/**
 * Checks if provided options are valid
 */
private void validateOptions(string[] args)
{
    if(args.length < 2) {
        stderr.writeln("Too few command line options. Use --help for more information.");
        exit(1);
    }

    if(!canFind(targetOpts, target)) {
        stderr.writeln("'" ~ target ~"' is not a valid target. Possible values are: " ~ targetOpts.join(", "));
        exit(1);
    }

    if(topAddress < -1 || topAddress > 0xffff) {
        stderr.writeln("Invalid max address: " ~ to!string(topAddress));
        exit(1);
    }
}

/**
 * Set implicit start address based on other options
 */
public void setStartAddress()
{
    if(basicLoader) {
        switch(target) {
            case "vic20_3k":
                startAddress = 0x0401;
                break;
            
            case "c64":
                startAddress = 0x0801;
                break;

            case "c128":
                startAddress = 0x1c01;
                break;

            case "vic20":
            case "cplus4":
            case "c16":
                startAddress = 0x1001;
                break;

            case "pet2001":
            case "pet3008":
            case "pet3016":
            case "pet3032":
            case "pet4016":
            case "pet4032":
            case "pet8032":
                startAddress = 0x0401;
                break;

            case "vic20_8k":
            default:
                startAddress = 0x1201;
                break;
        }
    }
    else if(startAddress == -1) {
        startAddress = 0x1000;
    }

     if(startAddress < 0 || startAddress > 0xffff) {
        stderr.writeln("Invalid start address: " ~ to!string(startAddress));
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
XC=BASIC compiler version ` ~ APP_VERSION ~ " (" ~ __DATE__ ~ ")" ~ `
Copyright (c) 2019-2022 by Csaba Fekete (see LICENSE)
Usage: xcbasic3 [options] <inputfile> <outputfile> [options]
Options:
   -t
  --target=         Target machine. Possible values: ` ~ targetOpts.join(", ") ~ `.
                    Defaults to "c64".

   -b
  --basic-loader=   Include a BASIC loader. Turned on by default (true).

   -o
  --start-address=  Change the default start address. Please provide a decimal number. Has no effect if
                    --basic-loader=true.

   -m
  --max-address=    Change the default top address. The default value is the top of the
                    function stack minus 64 bytes. See https://xc-basic.net/doku.php?id=v3:memory_model
                    If the program and its data overgrow the top address, compilation will fail.
                    Please provide a decimal number.

   -k
  --keep-imcode=    By default, the intermediate assembly code will be deleted after successful
                    assembly. Set this to TRUE if you wan to keep it.

   -d
  --dasm=           Path to the DASM executable.
                    Not required if DASM is in your PATH or in the working dir.

   -s
  --symbol=         Symbol dump file name. Provide a file name if you want to generate a symbol dump.

   -l
  --list=           List file name. This is passed to DASM as it is.

   -p
  --optimize        Output optimized (faster and smaller) code. Turned on by default (true).

   -h
  --help            Show this help

   -i
  --inline-data=    If set to true, DATA statements are compiled at the current origin.
                    Otherwise, they get compiled after code. Defaults to false.
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

/**
 * Fetch symbol addresses from the symbol list provided by DASM
 * Extend the list in symbolNames to get more
 */
private int[string] getSymbols(string tmpSymbolfile)
{
    const string[] symbolNames = ["prg_start", "library_start", "data_start", "vars_start", "vars_end"];
    int[string] symbols;
    auto lines = slurp!(string, string, string)(tmpSymbolfile, "%s %s %s");
    foreach (key, value; lines) {
        if(canFind(symbolNames, value[0])) {
            symbols[value[0]] = to!int(value[1], 16);
        }
    }
    return symbols;
}

/**
 * Display information about the compiled program
 */
private void displayInformation(string tmpSymbolfile)
{
    bool hasVars = false;
    string asHex(int number) {
        return to!string(rightJustifier(to!string(number, 16), 4, '0'));
    }    

    int[string] symbols = getSymbols(tmpSymbolfile);
    
    const string separator = "+---------------+-------+-------+"; 
    stdout.writeln("Complete. (0)");
    stdout.writeln(separator ~ "\n|    Segment    | Start |  End  |\n" ~ separator);
    if(basicLoader) {
        stdout.writeln("|BASIC Loader   | $" ~ asHex(startAddress) ~ " | $" ~ asHex(symbols["prg_start"] - 1) ~ " |");
    }
    stdout.writeln("|Program code   | $" ~ asHex(symbols["prg_start"]) ~ " | $" ~ asHex(symbols["library_start"] - 1) ~ " |");
    if(symbols["data_start"] > symbols["library_start"]) {
        stdout.writeln("|Library        | $" ~ asHex(symbols["library_start"]) ~ " | $" ~ asHex(symbols["data_start"] - 1) ~ " |");
    }
    if(symbols["vars_start"] > symbols["data_start"]) {
        stdout.writeln("|Data & Strings | $" ~ asHex(symbols["data_start"]) ~ " | $" ~ asHex(symbols["vars_start"] - 1) ~ " |");
    }
    if(symbols["vars_end"] > symbols["vars_start"]) {
        stdout.writeln("|Variables*     | $" ~ asHex(symbols["vars_start"]) ~ " | $" ~ asHex(symbols["vars_end"] - 1) ~ " |");
        hasVars = true;
    }
    stdout.writeln(separator);
    if(hasVars) {
        stdout.writeln("(*) Uninitialized segment.");
    }
}