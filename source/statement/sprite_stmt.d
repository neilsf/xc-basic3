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
        ParseTree[] sprSubCmdNodes = stmtNode.children[1 .. $];
        Expression sprNo = new Expression(sprNoNode, compiler);
        sprNo.setExpectedType(compiler.getTypes().get(Type.UINT8));
        sprNo.eval();
        ubyte sprNoInt;
        string sprNoStr;
        if (sprNo.isConstant)
        {
            sprNoInt = to!ubyte(sprNo.getConstVal());
            sprNoStr = to!string(sprNoInt);
            ubyte maxSprites;
            switch (target)
            {
			case "x16":
				maxSprites = 127;
				break;
			case "nes":
				maxSprites = 63;
				break;
			default:
				maxSprites = 7;
				break;
			}
            if (sprNoInt < 0 || sprNoInt > maxSprites)
            {
                compiler.displayError(
                        "Sprite number must be a number between 0 and " ~ to!string(maxSprites));
            }
            if (target == "x16" || target == "nes")
            {
                sprNo.eval();
                appendCode(sprNo.toString());
                appendCode("    sprite\n");
            }
        }
        else
        {
            appendCode(sprNo.toString());
            appendCode("    sprite\n");
            sprNoStr = "255";
        }
        foreach (ref subCmd; sprSubCmdNodes)
        {
            ParseTree node = subCmd.children[0];
            switch (node.name)
            {
            case "XCBASIC.SprSubCmdOnOff":
				if (target == "nes")
				{
					compiler.displayError("SPRITE ON/OFF not available for target " ~ target);
				}
                appendCode("    sprite_" ~ toLower(node.matches.join()) ~ " " ~ sprNoStr ~ "\n");
                break;

            case "XCBASIC.SprSubCmdAt":
                if (node.children[0].children.length != 2)
                {
                    compiler.displayError("SPRITE AT expects exactly 2 parameters, got " ~ to!string(
                            node.children[0].children.length));
                }
                Expression x = new Expression(node.children[0].children[0], compiler);
                Expression y = new Expression(node.children[0].children[1], compiler);
                const string xExpType = (target == "nes") ? Type.UINT8 : Type.UINT16;
                const string yExpType = (target == "x16") ? Type.UINT16 : Type.UINT8;
                x.setExpectedType(compiler.getTypes().get(xExpType));
                y.setExpectedType(compiler.getTypes().get(yExpType));
                x.eval();
                y.eval();
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

            case "XCBASIC.SprSubCmdZDepth":
				if (target != "x16")
				{
					compiler.displayError("SPRITE ZDEPTH not available for target " ~ target);
				}
                Expression zd = new Expression(node.children[0], compiler);
                zd.setExpectedType(compiler.getTypes().get(Type.UINT8));
                zd.eval();
                appendCode(zd.toString());
                appendCode("    sprite_zdepth " ~ sprNoStr ~ "\n");
                break;

            case "XCBASIC.SprSubCmdHiresMulti":
				if (target != "c64" || target != "c128" || target != "m65")
				{
					compiler.displayError("SPRITE HIRES/MULTI not available for target " ~ target);
				}
                string prop = toLower(node.matches.join());
                appendCode("    sprite_" ~ prop ~ " " ~ sprNoStr ~ "\n");
                break;

            case "XCBASIC.SprSubCmdOnUnderBg":
				if (target != "c64" || target != "c128" || target != "m65" || target != "nes")
				{
					compiler.displayError("SPRITE ON/UNDER BACKGROUND not available for target " ~ target);
				}
                immutable string mnemonic = toLower(node.matches[0]) == "on" ? "on" : "under";
                appendCode("    sprite_" ~ mnemonic ~ "_bg " ~ sprNoStr ~ "\n");
                break;

            case "XCBASIC.SprSubCmdShape":
                Expression shape = new Expression(node.children[0], compiler);
                const string expType = (target == "x16" || target == "mega65") ? Type.UINT16
                    : Type.UINT8;
                shape.setExpectedType(compiler.getTypes().get(expType));
                shape.eval();
                appendCode(shape.toString());
                appendCode("    sprite_shape " ~ sprNoStr ~ "\n");
                break;

            case "XCBASIC.SprSubCmdXYSize":
				if (target == "nes")
				{
					compiler.displayError("SPRITE XYSIZE not available for target " ~ target);
				}
                if (node.children[0].children.length != 2)
                {
                    compiler.displayError("SPRITE XYSIZE expects exactly 2 parameters, got " ~ to!string(
                            node.children[0].children.length));
                }
                Expression x = new Expression(node.children[0].children[0], compiler);
                Expression y = new Expression(node.children[0].children[1], compiler);
                x.setExpectedType(compiler.getTypes().get(Type.UINT8));
                y.setExpectedType(compiler.getTypes().get(Type.UINT8));
                x.eval();
                y.eval();
                appendCode(x.toString() ~ y.toString());
                appendCode("    sprite_xysize " ~ sprNoStr ~ "\n");
                break;

            case "XCBASIC.SprSubCmdXYFlip":
                if (target != "x16" || target != "nes")
				{
					compiler.displayError("SPRITE XYFLIP not available for target " ~ target);
				}
                if (node.children[0].children.length != 2)
                {
                    compiler.displayError("SPRITE XYFLIP expects exactly 2 parameters, got " ~ to!string(
                            node.children[0].children.length));
                }
                Expression x = new Expression(node.children[0].children[0], compiler);
                Expression y = new Expression(node.children[0].children[1], compiler);
                x.setExpectedType(compiler.getTypes().get(Type.UINT8));
                y.setExpectedType(compiler.getTypes().get(Type.UINT8));
                x.eval();
                y.eval();
                appendCode(x.toString() ~ y.toString());
                appendCode("    sprite_xyflip " ~ sprNoStr ~ "\n");
                break;

            default:
                compiler.displayError("Unknown statement: " ~ node.name);
                break;
            }
        }
        appendCode("    savesprite\n");
    }
}

class Sprite_multicolor_stmt : Statement
{
    mixin Sprite_stmtCtor;

    void process()
    {
        ParseTree stmtNode = node.children[0];
        ParseTree xprListNode = stmtNode.children[0];
        if (xprListNode.children.length != 2)
        {
            compiler.displayError("SPRITE MULTICOLOR requires exactly 2 arguments");
        }
        Expression c1Exp = new Expression(xprListNode.children[0], compiler);
        Expression c2Exp = new Expression(xprListNode.children[1], compiler);
        c1Exp.setExpectedType(compiler.getTypes.get(Type.UINT8));
        c2Exp.setExpectedType(compiler.getTypes.get(Type.UINT8));
        c1Exp.eval();
        c2Exp.eval();
        this.appendCode(c1Exp.toString() ~ c2Exp.toString() ~ "    sprite_multicolor\n");
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

class Sprite_clear_stmt : Statement
{
    mixin Sprite_stmtCtor;

    void process()
    {
        this.appendCode("    sprite_clear\n");
    }
}
