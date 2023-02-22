module statement.sound_stmt;

import std.string, std.conv;

import pegged.grammar;

import compiler.compiler, compiler.type, compiler.number;
import language.statement, language.expression;

import globals;

template Sound_stmtCtor()
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
        useSound = true;
	}
}

class Voice_stmt : Statement
{
    mixin Sound_stmtCtor;

    void process()
    {
        ParseTree stmtNode = node.children[0];
        ParseTree valueNode = stmtNode.children[0];
        Number n = new Number(valueNode, this.compiler);
        if(n.type.name != Type.UINT8 || n.intVal > 4) {
            compiler.displayError("Invalid voice number: " ~ valueNode.matches.join());
        }
        ParseTree[] voiceSubCmdNodes = stmtNode.children[1..$];
        foreach(ref subCmd; voiceSubCmdNodes) {
            ParseTree node = subCmd.children[0];
            immutable string voiceNo = to!string(n.intVal);
            final switch(node.name) {
                case "XCBASIC.VoiceSubCmdOnOff":
                case "XCBASIC.VoiceSubCmdFilterOnOff":
                    appendCode("    voice_" ~ toLower(node.matches.join()) ~ " " ~ voiceNo ~ "\n"); 
                    break;

                case "XCBASIC.VoiceSubCmdADSR":
                    if(node.children[0].children.length != 4) {
                        compiler.displayError("VOICE ADSR expects exactly 4 parameters, got " ~ to!string(node.children[0].children.length));
                    }
                    Expression val;
                    for(int i = 0; i < 4; i++) {
                        val = new Expression(node.children[0].children[i], compiler);
                        val.setExpectedType(compiler.getTypes().get(Type.UINT8));
                        val.eval();
                        appendCode(val.toString());
                    }
                    appendCode("    voice_adsr " ~ voiceNo ~ "\n");
                    break;

                case "XCBASIC.VoiceSubCmdTone":
                    Expression tone = new Expression(node.children[0], compiler);
                    tone.setExpectedType(compiler.getTypes().get(Type.UINT16));
                    tone.eval();
                    appendCode(tone.toString());
                    appendCode("    voice_tone " ~ voiceNo ~ "\n");
                    break;

                case "XCBASIC.VoiceSubCmdPulse":
                    Expression pulse = new Expression(node.children[0], compiler);
                    pulse.setExpectedType(compiler.getTypes().get(Type.UINT16));
                    pulse.eval();
                    appendCode(pulse.toString());
                    appendCode("    voice_pulse " ~ voiceNo ~ "\n");
                    break;

                case "XCBASIC.VoiceSubCmdWave":
                    immutable string wave = toUpper(node.matches[1]);
                    appendCode("    voice_wave " ~ voiceNo ~ "," ~ wave ~ "\n");
                    break;
            }
         }
    }
}

class Filter_stmt : Statement
{
    mixin Sound_stmtCtor;

    void process()
    {
        ParseTree stmtNode = node.children[0];
        ParseTree[] voiceSubCmdNodes = stmtNode.children[0..$];
        foreach(ref subCmd; voiceSubCmdNodes) {
            ParseTree node = subCmd.children[0];
            string[] filters;
            final switch(node.name) {
                case "XCBASIC.FilterSubCmdCutoff":
                    Expression cutoff = new Expression(node.children[0], compiler);
                    cutoff.setExpectedType(compiler.getTypes().get(Type.UINT16));
                    cutoff.eval();
                    appendCode(cutoff.toString());
                    appendCode("    filter_cutoff\n");
                    break;
                case "XCBASIC.FilterSubCmdResonance":
                    Expression resonance = new Expression(node.children[0], compiler);
                    resonance.setExpectedType(compiler.getTypes().get(Type.UINT8));
                    resonance.eval();
                    appendCode(resonance.toString());
                    appendCode("    filter_resonance\n");
                    break;
                case "XCBASIC.FilterSubCmdPass":
                    uint value = 0;
                    import std.stdio;
                    immutable string pass = toUpper(node.matches[0]);
                    filters ~= "FILT" ~ pass;
                    break;
            }
            if(filters.length > 0) {
                appendCode("    filter " ~ filters.join(" | ") ~ "\n");
            }
        }
    }
}

class Volume_stmt : Statement
{
    mixin Sound_stmtCtor;

    void process()
    {
        ParseTree stmtNode = node.children[0];
        ParseTree valueNode = stmtNode.children[0];
        Expression e = new Expression(valueNode, this.compiler);
        e.setExpectedType(this.compiler.getTypes.get(Type.UINT8));
        e.eval();
        this.appendCode(e.toString() ~ "    volume\n");
    }
}

class Sound_clear_stmt : Statement
{
    mixin Sound_stmtCtor;

    void process()
    {
        this.appendCode("    sound_clear\n");
    }
}