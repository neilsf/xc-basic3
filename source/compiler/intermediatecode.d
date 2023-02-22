module compiler.intermediatecode;

import std.conv;

import globals, compiler.compiler, compiler.library;

/** This class builds the intermediate assembly code */
class IntermediateCode
{
    /** Code segments */
    enum PROGRAM_SEGMENT = 0;
    enum ROUTINE_SEGMENT = 1;
    enum LIBRARY_SEGMENT = 2;
    enum DATA_SEGMENT    = 3;
    enum VAR_SEGMENT     = 4;
    
    /** Code segments as strings */
    private string[int] segments;

    /** Reference to the Compiler object */
    private Compiler compiler;

    /** Class constructor */
    this(Compiler compiler)
    {
        this.compiler = compiler;
        this.segments =  [
            PROGRAM_SEGMENT : "prg_start:\n    SEG \"PROGRAM\"\n    ORG prg_start\nFPUSH SET 0\nFPULL SET 0\n    xbegin\n    ; !!opt_start!!\n",
            ROUTINE_SEGMENT : "\nroutines_start:\n",
            LIBRARY_SEGMENT : "\n    ; !!opt_end!!\nlibrary_start:\n    SEG \"LIBRARY\"\n    ORG library_start\n" ~ getIncludes() ~ "\n",
            DATA_SEGMENT    : "\ndata_start:\n",
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
        // Bits 15-8: base machine
        // Bits 7-0: machine config 
        string startUpCode =
`    PROCESSOR 6502
c64      EQU %0000000100000000
vic20    EQU %0000001000000000
vic20_3k EQU %0000001000000001
vic20_8k EQU %0000001000000010
c264     EQU %0000010000000000
cplus4   EQU %0000010000000001
c16      EQU %0000010000000010
c128     EQU %0000100000000000
pet      EQU %0001000000000000
pet2001  EQU %0001000000001001
pet3     EQU %0001000000010000
pet3008  EQU %0001000000010001
pet3016  EQU %0001000000010010
pet3032  EQU %0001000000010100
pet4     EQU %0001000000100000
pet4016  EQU %0001000000100010
pet4032  EQU %0001000000100100
pet8032  EQU %0001000001000100
TARGET   EQU ` ~ target ~ `
USEIRQ   EQU ` ~ (useIrqs ? "1" : "0") ~ `
FASTIRQ  EQU ` ~ (fastIrqs ? "1" : "0") ~ `
USESPR   EQU ` ~ (useSprites ? "1" : "0") ~ `
USESFX   EQU ` ~ (useSound ? "1" : "0") ~ `
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
                getSegment(LIBRARY_SEGMENT) ~
                getSegment(DATA_SEGMENT) ~
                getSegment(VAR_SEGMENT) ~
                "vars_end:\n";
    }
}
