module optimizer;

import std.string, std.array, std.uni, std.regex, std.stdio, std.file;
import std.algorithm.mutation, std.algorithm.searching;

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
            //new ReplaceSequences(),
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
    private string[string] sequences;

    private struct opcode {
        string op;
        string arg;
    }

    private void fetch_sequences()
    {
        string[] lines = splitLines(""); //TODO!!
        bool fetch = false;
        string macname;
        foreach(line; lines) {
            if(line == "\t; [OPT_MACRO]") {
                fetch = true;
                continue;
            }

            if(line == "\t; [/OPT_MACRO]") {
                fetch = false;
                continue;
            }

            if(!fetch) {
                continue;
            }

            auto expr = regex(r"\tMAC\s([a-z_]+)");
            auto match = matchFirst(line, expr);
            if(match) {
                macname = match[1];
                continue;
            }

            expr = regex(r"\t;\s\>\s([a-z0-9_\+]+)");
            match = matchFirst(line, expr);
            if(match) {
                this.sequences[match[1]] = macname;
                continue;
            }
        }
    }

    private bool match_sequences(string candidate)
    {
        uint len = cast(uint)candidate.length;
        foreach(item; this.sequences.byKey()) {
            if(len <= item.length && item[0..len] == candidate) {
                return true;
            }
        }
        return false;
    }

    private bool full_match(string candidate)
    {
        foreach(item; this.sequences.byKey()) {
            if(item == candidate) {
                return true;
            }
        }
        return false;
    }

    private string stringify_sequence(opcode[] sequence)
    {
        string retval = "";
        for(int i = 0; i < sequence.length; i++) {
            if(i > 0) {
                retval ~= "+";
            }
            retval ~= sequence[i].op;
        }
        return retval;
    }

    private string stringify_args(opcode[] sequence)
    {
        string retval = "";
        bool first = true;
        for(int i = 0; i < sequence.length; i++) {
            if(sequence[i].arg != "") {
                if(!first) {
                    retval ~= ", ";
                }
                retval ~= sequence[i].arg;
                first = false;
            }
        }
        return retval;
    }

    private bool replace_seqs()
    {
        bool opt_enabled = false;
        bool replacements_made = false;
        string[] lines = splitLines(this.inCode);
        opcode[] accumulated_sequence;
        string[] accumulated_code;

        this.outCode = "";
        for(int i=0; i<lines.length; i++) {
            string line = lines[i];
            if(line == "\t; !!opt_start!!") {
                opt_enabled = true;
                this.outCode ~= line ~ "\n";
                continue;
            }
            else if(line == "\t; !!opt_end!!") {
                opt_enabled = false;
                this.outCode ~= join(accumulated_code, "\n") ~ "\n" ~ line ~ "\n";
                accumulated_sequence = [];
                accumulated_code = [];
                this.outCode ~= line ~ "\n";
                continue;
            }

            if(!opt_enabled) {
                this.outCode ~= line ~ "\n";
                continue;
            }

            auto expr = regex(r"\t([a-z0-9_]+)(\s.+)?");
            auto match = matchFirst(line, expr);
            if(match) {
                accumulated_code ~= line;
                string opcodeStr = match[1];
                string arg = "";
                if(match.length > 2) {
                    arg = match[2];
                }

                opcode op = {opcodeStr, arg};
                accumulated_sequence ~= op;
                string seqstring = this.stringify_sequence(accumulated_sequence);

                if(this.match_sequences(seqstring)) {
                    //stderr.writeln("match: " ~ seqstring);
                    if(this.full_match(seqstring)) {
                        //stderr.writeln("full match: " ~ seqstring);
                        this.outCode ~= "\t" ~ this.sequences[seqstring] ~ " " ~ this.stringify_args(accumulated_sequence) ~ "\n";
                        accumulated_sequence = [];
                        accumulated_code = [];
                        replacements_made = true;
                    }
                }
                else {
                    //stderr.writeln("no match: " ~ seqstring);
                    this.outCode ~= accumulated_code[0] ~ "\n";
                    accumulated_sequence = accumulated_sequence.remove(0);
                    accumulated_code = accumulated_code.remove(0);
                }
            }
            else {
                this.outCode ~= join(accumulated_code, "\n") ~ "\n" ~ line ~ "\n";
                accumulated_sequence = [];
                accumulated_code = [];
            }
        }

        return replacements_made;
    }

    override void run()
    {
        this.fetch_sequences();
        bool success;
        this.replace_seqs();
        do {
            success = this.replace_seqs();
            if(success) {
                this.inCode = this.outCode;
            }
        }
        while(success);
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
        auto pusherR = ctRegex!(`MAC\s+([a-zA-Z0-9_]+)\s+.+@push`);
        auto pullerR = ctRegex!(`MAC\s+([a-zA-Z0-9_]+)\s+.+@pull`);
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
        for(int i=0; i<lines.length; i++) {
            string line = lines[i];
            if(line == "    ; !!opt_start!!") {
                opt_enabled = true;
                continue;
            }
            else if(line == "    ; !!opt_end!!") {
                opt_enabled = false;
                continue;
            }

            if(!opt_enabled) {
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
            if(i+1 < lines.length) {
                int j = i+1;
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
