module compiler.intermediatecode;

import compiler.compiler, compiler.library;

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
            PROGRAM_SEGMENT : "prg_start:\n    SEG \"PROGRAM\"\n    ORG prg_start\nFPUSH EQU 0\nFPULL EQU 0\n    spreset\n",
            ROUTINE_SEGMENT : "routines_start:\n    SEG \"LIBRARY\"\n    ORG routines_start\n",
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
        return 
`    PROCESSOR 6502
    SEG "UPSTART"
    ORG $0801
    DC.W next_line, 2021
    DC.B $9e, [prg_start]d, 0
next_line:
    DC.W 0
`;
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
                getSegment(PROGRAM_SEGMENT) ~ "    rts\n\n" ~
                getSegment(ROUTINE_SEGMENT) ~
                getIncludes() ~
                getSegment(DATA_SEGMENT) ~
                getSegment(VAR_SEGMENT);
    }
}