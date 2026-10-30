module globals;

import core.stdc.stdlib, std.stdio, std.conv;

/** The target machine */
string target = "c64";
/** Whether to assemble a basic loader */
bool basicLoader = true;
/** Program start address */
int startAddress = -1;
/** If the program exceeds this limit, compilation will fail */
int topAddress = -1;
/** Maximum allowed string length */
const int stringMaxLength = 96;
/** Whether to compile DATA statements at the current origin */
bool inlineData = false;
/** Whether the program uses custom irq routines */
bool useIrqs = false;
/** Fast IRQ option bypasses saving virtual registers before entering the ISR */
bool fastIrqs = false;
/** Whether the program uses sprite routines */
bool useSprites = false;
/** Whether the program uses sound routines */
bool useSound = false;
/** Whether to initialize the variable segment with zeroes */
bool zerofillVars = false;
/** Whether to use ASCII mode instead of PETSCII */
bool asciiMode = false;
/** The ROM size for NES in kilobytes (16 or 32) */
ubyte nesRomSize = 16;
/** The RAM size for NES in kilobytes (1, 2, 4, 8) */
ubyte nesRamSize = 0;
/** The char ROM file to add to NES cart image */
string nesCharRomFile = "";

/**
 * Set implicit start address based on other options
 */
public void setStartAddress()
{
    if (basicLoader)
    {
        switch (target)
        {
        case "c64":
        case "x16":
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
        case "vic20_3k":
            startAddress = 0x0401;
            break;

        case "mega65":
            startAddress = 0x2001;
            break;

        case "vic20_8k":
        case "vic20_16k":
        case "vic20_24k":
        default:
            startAddress = 0x1201;
            break;
        }
    }
    else if (target == "nes")
    {
		import std.stdio; writefln("ROM size is %d", nesRomSize);
		startAddress = nesRomSize == 32 ? 0x8000 : 0xC000;
	}
    else if (startAddress == -1)
    {
        startAddress = 0x1000;
    }

    if (startAddress < 0 || startAddress > 0xffff)
    {
        stderr.writeln("Invalid start address: " ~ to!string(startAddress));
        exit(1);
    }
}

/**
 * Set implicit end address based on target setting
 */
public void setEndAddress()
{
    if (topAddress == -1)
    {
        switch (target)
        {
        case "vic20_3k":
        case "vic20":
            topAddress = 0x1e00;
            break;

        case "c64":
            topAddress = 0xd000;
            break;

        case "c128":
        case "mega65":
            topAddress = 0xc000;
            break;

        case "cplus4":
        case "pet3032":
        case "pet4032":
        case "pet8032":
        case "vic20_24k":
            topAddress = 0x8000;
            break;

        case "pet2001":
        case "pet3008":
            topAddress = 0x2000;
            break;

        case "vic20_8k":
        case "c16":
        case "pet3016":
        case "pet4016":
            topAddress = 0x4000;
            break;

        case "vic20_16k":
            topAddress = 0x6000;
            break;

        case "x16":
            topAddress = 0x9EFF;
            break;
            
        case "nes":
			topAddress = 0xFFF9;
			break;

        default:
            topAddress = 0x10000;
        }
    }

    if (topAddress < 0 || topAddress > 0xffff)
    {
        stderr.writeln("Invalid max address: " ~ to!string(topAddress));
        exit(1);
    }
}

/**
 * Returns the family of computers the target belongs to
 */
public string getTargetFamily(string target)
{
    if (target[0 .. 3] == "pet")
    {
        return "pet";
    }
    else if (target[0 .. 3] == "vic")
    {
        return "vic20";
    }
    else if (target == "c16" || target == "cplus4")
    {
        return "c264";
    }
    else
    {
        return target;
    }
}
