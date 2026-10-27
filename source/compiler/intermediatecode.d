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
    enum DATA_SEGMENT = 3;
    enum VAR_SEGMENT = 4;

    /** Code segments as strings */
    private string[int] segments;

    /** Reference to the Compiler object */
    private Compiler compiler;

    /** Class constructor */
    this(Compiler compiler)
    {
        this.compiler = compiler;
        const string varSegmentInit = zerofillVars ? "SEG" : "SEG.U";
        this.segments = [
            PROGRAM_SEGMENT: target == "nes" ?
				"    SEG PROGRAM\n    ORG $8000\nprg_start EQU $8000\nFPUSH SET 0\nFPULL SET 0\n    xbegin\n    ; !!opt_start!!\n"
				:
				"prg_start:\n    SEG \"PROGRAM\"\n    ORG prg_start\nFPUSH SET 0\nFPULL SET 0\n    xbegin\n    ; !!opt_start!!\n",
            ROUTINE_SEGMENT: "\nroutines_start:\n",
            LIBRARY_SEGMENT: "\n    ; !!opt_end!!\nlibrary_start:\n    SEG \"LIBRARY\"\n    ORG library_start\n" ~ getIncludes() ~ "\n",
            DATA_SEGMENT: "\ndata_start:\n",
            VAR_SEGMENT: target == "nes" ?
				"    " ~ varSegmentInit ~ " \"VARIABLES\"\n    ORG $0300\nvars_start EQU $0300\n"
				:
				"vars_start:\n    " ~ varSegmentInit ~ " \"VARIABLES\"\n    ORG vars_start\n"
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
        const string processorType = target == "x16" ? "65c02" : "6502";
        
        string startUpCode = "    PROCESSOR " ~ processorType ~ "\n";
        startUpCode ~= getMainConstants();
		if (target == "nes")
		{
			startUpCode ~= getNesHeader();
		}
		else
		{
			startUpCode ~= "    SEG \"UPSTART\"\n    ORG $" ~ to!string(startAddress, 16) ~ "\n";
			startUpCode ~= getBasicStub();
		}
    
        return startUpCode;
    }

	private string getMainConstants()
	{
		// Target machine bits meaning
        // Bits 15-8: base machine
        // Bits 7-0: machine config 
		return `
c64         EQU %0000000100000000

vic20       EQU %0000001000000000
vic20_3k    EQU %0000001000000001
vic20_8k    EQU %0000001000000010
vic20_16k   EQU %0000001000000110
vic20_24k   EQU %0000001000001010

c264        EQU %0000010000000000
cplus4      EQU %0000010000000001
c16         EQU %0000010000000010

c128        EQU %0000100000000000

pet         EQU %0001000000000000
pet2001     EQU %0001000000001001
pet3        EQU %0001000000010000
pet3008     EQU %0001000000010001
pet3016     EQU %0001000000010010
pet3032     EQU %0001000000010100
pet4        EQU %0001000000100000
pet4016     EQU %0001000000100010
pet4032     EQU %0001000000100100
pet8032     EQU %0001000001000100

x16         EQU %0010000000000000
mega65      EQU %0100000000000000

nes			EQU %1000000000000000

TARGET   EQU ` ~ target ~ `
TOPADDR  EQU ` ~ to!string(topAddress) ~ `
USEIRQ   EQU ` ~ (useIrqs ? "1" : "0") ~ `
FASTIRQ  EQU ` ~ (fastIrqs ? "1" : "0") ~ `
USESPR   EQU ` ~ (useSprites ? "1" : "0") ~ `
USESFX   EQU ` ~ (useSound ? "1" : "0") ~ `
`;
	}
	
	private string getNesHeader()
	{
		return `
	SEG HEADER
	ORG $7FF0
    HEX 4E 45 53 1A 02 01 00 08 00 00 00 00 00 00 00 01
`;
	}

    private string getBasicStub()
    {
        if (basicLoader)
        {
            return `
    DC.W next_line, 2021
` ~ (target == "mega65" ? "    DC.B $fe,$02,$30,$3a" : "") ~ `    
    DC.B $9e, [prg_start]d, 0
next_line:
    DC.W 0
`;
        }
        return "";
    }

    private string getIncludes()
    {
        return `
    INCDIR "` ~ getLibraryDir() ~ `"
    INCLUDE "` ~ LIBRARY_FILENAME ~ `"

`;
    }
    
    private string getNesVectorSegment()
    {
		return `
    ORG $FFFA
    DC.W NES_NMI
	DC.W NES_RESET
    DC.W 0
`;
	}

    public string getCode()
    {
        return
			getStartUp() ~
			getSegment(PROGRAM_SEGMENT) ~
			"    xend\n\n" ~
			getSegment(ROUTINE_SEGMENT) ~
			getSegment(LIBRARY_SEGMENT) ~
			getSegment(DATA_SEGMENT) ~
			(target == "nes" ? getNesVectorSegment() : "") ~
			getSegment(VAR_SEGMENT) ~
			"vars_end:\n";
    }
}
