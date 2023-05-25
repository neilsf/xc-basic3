module statement.sprite_stmt;

import std.string, std.conv;

import pegged.grammar;

import compiler.compiler, compiler.type;
import language.statement, language.expression;

import globals;

template Sprite_stmtCtor()
{
    this(ParseTree node, Compiler compiler)
	{
		super(node, compiler);
        useSprites = true;
	}
}

class Sprite_stmt : Statement
{
    mixin Sprite_stmtCtor;

    void process()
    {
        ParseTree stmtNode = node.children[0];
        ParseTree sprNoNode = stmtNode.children[0];
        ParseTree[] sprSubCmdNodes = stmtNode.children[1..$];
        Expression sprNo = new Expression(sprNoNode, compiler);
        sprNo.setExpectedType(compiler.getTypes().get(Type.UINT8));
        sprNo.eval();
        ubyte sprNoInt;
        string sprNoStr;
        if(sprNo.isConstant) {
            sprNoInt = to!ubyte(sprNo.getConstVal());
            sprNoStr = to!string(sprNoInt);
            if(sprNoInt < 0 || sprNoInt > 7) {
                compiler.displayError("Sprite number must be a number between 0 and 7");
            }
        } else {
            appendCode(sprNo.toString());
            appendCode("    sprite\n");
            sprNoStr = "255";
        }
        foreach(ref subCmd; sprSubCmdNodes) {
            ParseTree node = subCmd.children[0];
            switch(node.name) {
                case "XCBASIC.SprSubCmdOnOff":
                    appendCode("    sprite_" ~ toLower(node.matches.join()) ~ " " ~ sprNoStr ~ "\n"); 
                    break;

                case "XCBASIC.SprSubCmdAt":
                    if(node.children[0].children.length != 2) {
                        compiler.displayError("SPRITE AT expects exactly 2 parameters, got " ~ to!string(node.children[0].children.length));
                    }
                    Expression x = new Expression(node.children[0].children[0], compiler);
                    Expression y = new Expression(node.children[0].children[1], compiler);
                    x.setExpectedType(compiler.getTypes().get(Type.UINT16));
                    y.setExpectedType(compiler.getTypes().get(Type.UINT8));
                    x.eval(); y.eval();
                    appendCode(x.toString() ~ y.toString());
                    appendCode("    sprite_at " ~ sprNoStr ~ "\n");
                    break;

                case "XCBASIC.SprSubCmdColor":
                    Expression clr = new Expression(node.children[0], compiler);
                    clr.setExpectedType(compiler.getTypes().get(Type.UINT8));
                    clr.eval();
                    appendCode(clr.toString());
                    appendCode("    sprite_color " ~ sprNoStr ~ "\n");
                    break;

                case "XCBASIC.SprSubCmdHiresMulti":
                    appendCode("    sprite_" ~ toLower(node.matches.join()) ~ " " ~ sprNoStr ~ "\n"); 
                    break;

                case "XCBASIC.SprSubCmdOnUnderBg":
                    immutable string mnemonic = toLower(node.matches[0]) == "o" ? "on" : "under";
                    appendCode("    sprite_" ~ mnemonic ~ "_bg " ~ sprNoStr ~ "\n"); 
                    break;

                case "XCBASIC.SprSubCmdShape":
                    Expression shape = new Expression(node.children[0], compiler);
                    shape.setExpectedType(compiler.getTypes().get(target == "mega65" ? Type.UINT16 : Type.UINT8));
                    shape.eval();
                    appendCode(shape.toString());
                    appendCode("    sprite_shape " ~ sprNoStr ~ "\n");
                    break;

                case "XCBASIC.SprSubCmdXYSize":
                    if(node.children[0].children.length != 2) {
                        compiler.displayError("SPRITE XYSIZE expects exactly 2 parameters, got " ~ to!string(node.children[0].children.length));
                    }
                    Expression x = new Expression(node.children[0].children[0], compiler);
                    Expression y = new Expression(node.children[0].children[1], compiler);
                    x.setExpectedType(compiler.getTypes().get(Type.UINT8));
                    y.setExpectedType(compiler.getTypes().get(Type.UINT8));
                    x.eval(); y.eval();
                    appendCode(x.toString() ~ y.toString());
                    appendCode("    sprite_xysize " ~ sprNoStr ~ "\n");
                    break;

                default:
                    compiler.displayError("Unknown statement: " ~ node.name);
                    break;
            }
        }
    }
}

class Sprite_multicolor_stmt : Statement
{
    mixin Sprite_stmtCtor;

    void process()
    {
        ParseTree stmtNode = node.children[0];
        ParseTree xprListNode = stmtNode.children[0];
        if(xprListNode.children.length != 2) {
            compiler.displayError("SPRITE MULTICOLOR requires exactly 2 arguments");
        }
        Expression c1Exp = new Expression(xprListNode.children[0], compiler);
        Expression c2Exp = new Expression(xprListNode.children[1], compiler);
        c1Exp.setExpectedType(compiler.getTypes.get(Type.UINT8));
        c2Exp.setExpectedType(compiler.getTypes.get(Type.UINT8));
        c1Exp.eval(); c2Exp.eval();
        this.appendCode(
            c1Exp.toString() ~
            c2Exp.toString() ~
            "    sprite_multicolor\n"
        );
    }
}

class Sprite_clearhit_stmt : Statement
{
    mixin Sprite_stmtCtor;

    void process()
    {
        this.appendCode("    sprite_clear_hit\n");
    }
}