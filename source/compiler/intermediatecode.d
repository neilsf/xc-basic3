module compiler.intermediatecode;

import std.conv;

import globals, compiler.compiler, compiler.library;

/** This class builds the intermediate assembly code */
class IntermediateCode
{
    /** Code segments */
    enum PROGRAM_SEGMENT = 0;
    enum ROUTINE_SEGMENT = 1;
    enum VAR_SEGMENT     = 2;
    enum DATA_SEGMENT    = 3;
    
    /** Code segments as strings */
    private string[int] segments;

    /** Reference to the Compiler object */
    private Compiler compiler;

    /** Class constructor */
    this(Compiler compiler)
    {
        this.compiler = compiler;
        this.segments =  [
            PROGRAM_SEGMENT : "prg_start:\n    SEG \"PROGRAM\"\n    ORG prg_start\nFPUSH EQU 0\nFPULL EQU 0\n    xbegin\n",
            ROUTINE_SEGMENT : "routines_start:\n    SEG \"LIBRARY\"\n    ORG routines_start\n" ~ getIncludes(),
            DATA_SEGMENT    : "data_start:\n",
            VAR_SEGMENT     : "vars_start:\n    SEG.U \"VARIABLES\"\n    ORG vars_start\n"
        ];
    }

    /** Appends code or data to a segment */
    public void appendSegment(int segmentId, string contents)
    {
        this.segments[segmentId] ~= contents;
    }

    /** Shortcut for appending program or routine segments */
    public void appendProgramSegment(string code)
    {
        immutable int segment = this.compiler.inProcedure ? ROUTINE_SEGMENT : PROGRAM_SEGMENT;
        this.appendSegment(segment, code);
    }

    /** Getter method to any segment */
    public string getSegment(int segmentId)
    {
        return this.segments[segmentId];
    }

    private string getStartUp()
    {
        // Target machine bits meaning
        // Bits 15-4: base machine
        // Bits 3-0: machine config 
        string startUpCode =
`    PROCESSOR 6502
c64      EQU %0000000000010000
vic20    EQU %0000000000100000
vic20_3k EQU %0000000000100001
vic20_8k EQU %0000000000100010
c264     EQU %0000000001000000
cplus4   EQU %0000000001000001
c16      EQU %0000000001000010
TARGET   EQU ` ~ target ~ `
    SEG "UPSTART"
    ORG $` ~ to!string(startAddress, 16) ~ "\n";
        if(basicLoader) {
            startUpCode ~= 
`    DC.W next_line, 2021
    DC.B $9e, [prg_start]d, 0
next_line:
    DC.W 0

`;
        }
        return startUpCode;
    }

    private string getIncludes()
    {
        return `
    INCDIR "` ~ getLibraryDir() ~ `"
    INCLUDE "` ~ LIBRARY_FILENAME ~ `"

`;
    }

    public string getCode()
    {
        return  getStartUp() ~
                getSegment(PROGRAM_SEGMENT) ~ "    xend\n\n" ~
                getSegment(ROUTINE_SEGMENT) ~
                getSegment(DATA_SEGMENT) ~
                getSegment(VAR_SEGMENT);
    }
}