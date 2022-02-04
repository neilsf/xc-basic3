module optimizer;

import std.string, std.array, std.uni, std.regex, std.stdio, std.file, std.path;
import std.algorithm;

import compiler.library;

/** An optimiter pass */
abstract class OptimizerPass
{
    /** The original code */
    private string inCode;
    /** The optimized code */
    private string outCode;

    /** Input raw code */
    public void setInCode(string inCode)
    {
        this.inCode = inCode;
    }

    /** Run pass */
    abstract void run();

    /** Output optimized code */    
    public string getOutCode()
    {
        return this.outCode;
    }
}

/** The optimizer that runs multiple passes */
final class Optimizer: OptimizerPass
{
    private OptimizerPass[] passes;

    /** Class ctor */
    this()
    {
        this.passes = [
            new ReplaceSequences(),
            new RemoveStackOps()
        ];
    }

    override void run()
    {
        string code = this.inCode;
        foreach (OptimizerPass pass; passes) {
            pass.setInCode(code);
            pass.run();
            code = pass.getOutCode();
        }
        this.outCode = code;
    }
}

/**
 * This pass replaces sequences of pseudo-ops with
 * equivalent but faster ones
 */
class ReplaceSequences: OptimizerPass
{
    private string[] sequences;

    private struct opCode {
        string op;
        string arg;
    }

    private void fetchSequences()
    {
        immutable string libDir = getLibraryDir();
        auto pusherR = ctRegex!(`MAC\s+([a-zA-Z0-9_@]+)\s+.+`);
        immutable string contents = readText(buildNormalizedPath(libDir ~ "/opt/opt.asm"));
        foreach (c; matchAll(contents, pusherR)) {
            this.sequences ~= c[1];
        }
    }

    private bool matchSequences(string candidate)
    {
        uint len = cast(uint)candidate.length;
        foreach(item; this.sequences) {
            if(len <= item.length && item[0..len] == candidate) {
                return true;
            }
        }
        return false;
    }

    private bool fullMatch(string candidate)
    {
        return canFind(this.sequences, candidate);
    }

    private string stringifySequence(opCode[] sequence)
    {
        return sequence.map!(op => op.op).join("_");
    }

    private string stringifyArgs(opCode[] sequence)
    {
        return sequence.filter!(op => op.arg != "").map!(op => op.arg).join(", ");
    }

    private int replaceSequences()
    {
        bool optEnabled = false;
        int replacementsMade = false;
        string[] lines = splitLines(this.inCode);
        opCode[] accumulatedSequence;
        string[] accumulatedCode;

        this.outCode = "";
        for(int i = 0; i < lines.length; i++) {
            string line = lines[i];
            if(line == "    ; !!opt_start!!") {
                optEnabled = true;
                this.outCode ~= line ~ "\n";
                continue;
            }
            else if(line == "    ; !!opt_end!!") {
                optEnabled = false;
                this.outCode ~= join(accumulatedCode, "\n") ~ "\n" ~ line ~ "\n";
                accumulatedSequence = [];
                accumulatedCode = [];
                this.outCode ~= line ~ "\n";
                continue;
            }

            if(!optEnabled || indexOf(line, "@opt_ignore") != -1) {
                this.outCode ~= line ~ "\n";
                continue;
            }

            auto expr = regex(r"\s+([a-zA-Z0-9_@]+)(\s.+)?");
            auto match = matchFirst(line, expr);
            if(match && !this.fullMatch(match[1])) {
                accumulatedCode ~= line;
                string opcodeStr = match[1];
                string arg = "";
                if(match.length > 2) {
                    arg = match[2];
                }

                opCode op = {opcodeStr, arg};
                accumulatedSequence ~= op;
                string seqString = this.stringifySequence(accumulatedSequence);

                if(this.matchSequences(seqString)) {
                    //stderr.writeln("match: " ~ seqString);
                    if(this.fullMatch(seqString)) {
                        //stderr.writeln("replace: " ~ seqString);
                        this.outCode ~= "    " ~ seqString ~ " " ~ this.stringifyArgs(accumulatedSequence) ~ "\n";
                        accumulatedSequence = [];
                        accumulatedCode = [];
                        replacementsMade++;
                    }
                }
                else {
                    //stderr.writeln("no match: " ~ seqString);
                    this.outCode ~= accumulatedCode[0] ~ "\n";
                    accumulatedSequence = accumulatedSequence.remove(0);
                    accumulatedCode = accumulatedCode.remove(0);
                }
            }
            else {
                //stderr.writeln("break: " ~ line);
                this.outCode ~= join(accumulatedCode, "\n") ~ "\n" ~ line ~ "\n";
                accumulatedSequence = [];
                accumulatedCode = [];
            }
        }

        return replacementsMade;
    }

    override void run()
    {
        this.fetchSequences();
        int replacementsMade;
        int i = 0;
        do {
            i++;
            replacementsMade = this.replaceSequences();
            import std.conv;
            //stderr.writeln("Pass " ~ to!string(i) ~ ": " ~ to!string(replacementsMade));
            if(replacementsMade) {
                this.inCode = this.outCode;
            }
        }
        while(replacementsMade > 0);
    }
}

/**
 * Removes unnecessary push and pull operations
 * where possible
 */
class RemoveStackOps: OptimizerPass
{
    private string[] pushers;
    private string[] pullers;

    /** Class ctor */
    this()
    {
        this.findPseudoOps();
    }

    /** Find all pseudo-ops that use the stack */
    private void findPseudoOps()
    {
        immutable string libDir = getLibraryDir();
        auto pusherR = ctRegex!(`MAC\s+([a-zA-Z0-9_@]+)\s+.+@push`);
        auto pullerR = ctRegex!(`MAC\s+([a-zA-Z0-9_@]+)\s+.+@pull`);
        foreach (string fileName; dirEntries(libDir, "*.asm", SpanMode.depth)) {
            immutable string contents = readText(fileName);
            foreach (c; matchAll(contents, pusherR)) {
                this.pushers ~= c[1];
            }
            foreach (c; matchAll(contents, pullerR)) {
                this.pullers ~= c[1];
            }
        }
    }

    override void run()
    {
        this.outCode = "";
        string[] lines = splitLines(this.inCode);
        bool opt_enabled = false;
        bool pushf = false;
        bool pullf = false;
        for(int i = 0; i < lines.length; i++) {
            string line = lines[i];
            if(line == "    ; !!opt_start!!") {
                opt_enabled = true;
                continue;
            }
            else if(line == "    ; !!opt_end!!") {
                opt_enabled = false;
                this.outCode ~= "FPUSH\tSET 0\n";
                this.outCode ~= "FPULL\tSET 0\n";
                continue;
            }

            if(!opt_enabled || indexOf(line, "@opt_ignore") != -1) {
                this.outCode ~= line ~ "\n";
                continue;
            }

            string opc = this.getOpcode(line);
            if(opc == "") {
                this.outCode ~= line ~ "\n";
                continue;
            }

            string next_opc = "";
            string next_line = "";
            if(i + 1 < lines.length) {
                int j = i + 1;
                do {
                    next_line = lines[j];
                    next_opc = this.getOpcode(next_line);
                    j++;
                }
                while(next_line == "");

                if(this.isPuller(opc) && pushf) {
                    if(!pullf) {
                        this.outCode ~= "FPULL\tSET 1\n";
                        pullf = true;
                    }

                }
                else {
                    if(pullf) {
                        this.outCode ~= "FPULL\tSET 0\n";
                        pullf = false;
                    }
                }

                if(this.isPusher(opc) && this.isPuller(next_opc)) {
                    if(!pushf) {
                        this.outCode ~= "FPUSH\tSET 1\n";
                        pushf = true;
                    }
                }
                else {
                    if(pushf) {
                        this.outCode ~= "FPUSH\tSET 0\n";
                        pushf = false;
                    }
                }
            }

            this.outCode ~= line ~ "\n";
        }
    }

    private string getOpcode(string line)
    {
        if(line == "") {
            return "";
        }
        string[] parts = line.strip.split!isWhite;
        if(parts.length == 0) {
            return "";
        }
        if(this.isPuller(parts[0]) || this.isPusher(parts[0])) {
            return parts[0];
        }
        else if(parts.length > 1 && (this.isPuller(parts[1]) || this.isPusher(parts[1]))) {
            return parts[1];
        }
        else {
            return "";
        }
    }

    private bool isPuller(string opc)
    {
        return canFind(this.pullers, opc);
    }

    private bool isPusher(string opc)
    {
        return canFind(this.pushers, opc);
    }
}
