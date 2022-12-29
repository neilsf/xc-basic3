module language.grammar;

import pegged.grammar;

/** Left-recursive cycles:
Simplexp <- Term <- Factor <- Expression <- Relation
*/

/** Rules that stop left-recursive cycles, followed by rules for which
 *  memoization is blocked during recursion:
Simplexp: Simplexp, Term, Factor, Expression, Relation
*/

struct GenericXCBASIC(TParseTree)
{
    import std.functional : toDelegate;
    import pegged.dynamic.grammar;
    static import pegged.peg;
    struct XCBASIC
    {
    enum name = "XCBASIC";
    static ParseTree delegate(ParseTree)[string] before;
    static ParseTree delegate(ParseTree)[string] after;
    static ParseTree delegate(ParseTree)[string] rules;
    import std.typecons:Tuple, tuple;
    static TParseTree[Tuple!(string, size_t)] memo;
    import std.algorithm: canFind, countUntil, remove;
    static size_t[] blockMemoAtPos;
    static this()
    {
        rules["Program"] = toDelegate(&Program);
        rules["Line"] = toDelegate(&Line);
        rules["Statements"] = toDelegate(&Statements);
        rules["Statement"] = toDelegate(&Statement);
        rules["Const_stmt"] = toDelegate(&Const_stmt);
        rules["Let_stmt"] = toDelegate(&Let_stmt);
        rules["Print_stmt"] = toDelegate(&Print_stmt);
        rules["Print_hash_stmt"] = toDelegate(&Print_hash_stmt);
        rules["Write_stmt"] = toDelegate(&Write_stmt);
        rules["Read_stmt"] = toDelegate(&Read_stmt);
        rules["If_stmt"] = toDelegate(&If_stmt);
        rules["If_sa_stmt"] = toDelegate(&If_sa_stmt);
        rules["Else_stmt"] = toDelegate(&Else_stmt);
        rules["Endif_stmt"] = toDelegate(&Endif_stmt);
        rules["Goto_stmt"] = toDelegate(&Goto_stmt);
        rules["Error_stmt"] = toDelegate(&Error_stmt);
        rules["Swap_stmt"] = toDelegate(&Swap_stmt);
        rules["Input_stmt"] = toDelegate(&Input_stmt);
        rules["Gosub_stmt"] = toDelegate(&Gosub_stmt);
        rules["Call_stmt"] = toDelegate(&Call_stmt);
        rules["Return_stmt"] = toDelegate(&Return_stmt);
        rules["Return_fn_stmt"] = toDelegate(&Return_fn_stmt);
        rules["Poke_stmt"] = toDelegate(&Poke_stmt);
        rules["Do_stmt"] = toDelegate(&Do_stmt);
        rules["Loop_stmt"] = toDelegate(&Loop_stmt);
        rules["Cont_stmt"] = toDelegate(&Cont_stmt);
        rules["Exit_do_stmt"] = toDelegate(&Exit_do_stmt);
        rules["Rem_stmt"] = toDelegate(&Rem_stmt);
        rules["For_stmt"] = toDelegate(&For_stmt);
        rules["Next_stmt"] = toDelegate(&Next_stmt);
        rules["Exit_for_stmt"] = toDelegate(&Exit_for_stmt);
        rules["Dim_stmt"] = toDelegate(&Dim_stmt);
        rules["Varattrib"] = toDelegate(&Varattrib);
        rules["Vardef"] = toDelegate(&Vardef);
        rules["Data_stmt"] = toDelegate(&Data_stmt);
        rules["Charat_stmt"] = toDelegate(&Charat_stmt);
        rules["Textat_stmt"] = toDelegate(&Textat_stmt);
        rules["Screen_stmt"] = toDelegate(&Screen_stmt);
        rules["Asm_stmt"] = toDelegate(&Asm_stmt);
        rules["Endasm_stmt"] = toDelegate(&Endasm_stmt);
        rules["Incbin_stmt"] = toDelegate(&Incbin_stmt);
        rules["Include_stmt"] = toDelegate(&Include_stmt);
        rules["Exitfun_stmt"] = toDelegate(&Exitfun_stmt);
        rules["Endfun_stmt"] = toDelegate(&Endfun_stmt);
        rules["Fun_stmt"] = toDelegate(&Fun_stmt);
        rules["Funcattrib"] = toDelegate(&Funcattrib);
        rules["Sys_stmt"] = toDelegate(&Sys_stmt);
        rules["Load_stmt"] = toDelegate(&Load_stmt);
        rules["Save_stmt"] = toDelegate(&Save_stmt);
        rules["Origin_stmt"] = toDelegate(&Origin_stmt);
        rules["Locate_stmt"] = toDelegate(&Locate_stmt);
        rules["On_stmt"] = toDelegate(&On_stmt);
        rules["Branch_type"] = toDelegate(&Branch_type);
        rules["Wait_stmt"] = toDelegate(&Wait_stmt);
        rules["Memset_stmt"] = toDelegate(&Memset_stmt);
        rules["Memcpy_stmt"] = toDelegate(&Memcpy_stmt);
        rules["Memshift_stmt"] = toDelegate(&Memshift_stmt);
        rules["Randomize_stmt"] = toDelegate(&Randomize_stmt);
        rules["Open_stmt"] = toDelegate(&Open_stmt);
        rules["Get_stmt"] = toDelegate(&Get_stmt);
        rules["Close_stmt"] = toDelegate(&Close_stmt);
        rules["Type_stmt"] = toDelegate(&Type_stmt);
        rules["Field_def"] = toDelegate(&Field_def);
        rules["Endtype_stmt"] = toDelegate(&Endtype_stmt);
        rules["End_stmt"] = toDelegate(&End_stmt);
        rules["Option_stmt"] = toDelegate(&Option_stmt);
        rules["Select_stmt"] = toDelegate(&Select_stmt);
        rules["Case_stmt"] = toDelegate(&Case_stmt);
        rules["Case_is_stmt"] = toDelegate(&Case_is_stmt);
        rules["Case_range_stmt"] = toDelegate(&Case_range_stmt);
        rules["Case_set_stmt"] = toDelegate(&Case_set_stmt);
        rules["Case_else_stmt"] = toDelegate(&Case_else_stmt);
        rules["Endselect_stmt"] = toDelegate(&Endselect_stmt);
        rules["Irq_stmt"] = toDelegate(&Irq_stmt);
        rules["Sprite_stmt"] = toDelegate(&Sprite_stmt);
        rules["SprSubCmd"] = toDelegate(&SprSubCmd);
        rules["SprSubCmdOnOff"] = toDelegate(&SprSubCmdOnOff);
        rules["SprSubCmdAt"] = toDelegate(&SprSubCmdAt);
        rules["SprSubCmdColor"] = toDelegate(&SprSubCmdColor);
        rules["SprSubCmdHiresMulti"] = toDelegate(&SprSubCmdHiresMulti);
        rules["SprSubCmdOnUnderBg"] = toDelegate(&SprSubCmdOnUnderBg);
        rules["SprSubCmdZDepth"] = toDelegate(&SprSubCmdZDepth);
        rules["SprSubCmdShape"] = toDelegate(&SprSubCmdShape);
        rules["SprSubCmdXYSize"] = toDelegate(&SprSubCmdXYSize);
        rules["SprSubCmdZYFlip"] = toDelegate(&SprSubCmdZYFlip);
        rules["Sprite_clear_stmt"] = toDelegate(&Sprite_clear_stmt);
        rules["Sprite_clearhit_stmt"] = toDelegate(&Sprite_clearhit_stmt);
        rules["Sprite_multicolor_stmt"] = toDelegate(&Sprite_multicolor_stmt);
        rules["Border_stmt"] = toDelegate(&Border_stmt);
        rules["Background_stmt"] = toDelegate(&Background_stmt);
        rules["Sound_clear_stmt"] = toDelegate(&Sound_clear_stmt);
        rules["Volume_stmt"] = toDelegate(&Volume_stmt);
        rules["Voice_stmt"] = toDelegate(&Voice_stmt);
        rules["VoiceSubCmd"] = toDelegate(&VoiceSubCmd);
        rules["VoiceSubCmdOnOff"] = toDelegate(&VoiceSubCmdOnOff);
        rules["VoiceSubCmdADSR"] = toDelegate(&VoiceSubCmdADSR);
        rules["VoiceSubCmdTone"] = toDelegate(&VoiceSubCmdTone);
        rules["VoiceSubCmdWave"] = toDelegate(&VoiceSubCmdWave);
        rules["VoiceSubCmdPulse"] = toDelegate(&VoiceSubCmdPulse);
        rules["VoiceSubCmdVolume"] = toDelegate(&VoiceSubCmdVolume);
        rules["VoiceSubCmdFilterOnOff"] = toDelegate(&VoiceSubCmdFilterOnOff);
        rules["Filter_stmt"] = toDelegate(&Filter_stmt);
        rules["FilterSubCmd"] = toDelegate(&FilterSubCmd);
        rules["FilterSubCmdCutoff"] = toDelegate(&FilterSubCmdCutoff);
        rules["FilterSubCmdResonance"] = toDelegate(&FilterSubCmdResonance);
        rules["FilterSubCmdPass"] = toDelegate(&FilterSubCmdPass);
        rules["Charset_stmt"] = toDelegate(&Charset_stmt);
        rules["Scroll_stmt"] = toDelegate(&Scroll_stmt);
        rules["VMode_stmt"] = toDelegate(&VMode_stmt);
        rules["VModeSubCmd"] = toDelegate(&VModeSubCmd);
        rules["VModeSubCmdExpression"] = toDelegate(&VModeSubCmdExpression);
        rules["VModeSubCmdTextBitmap"] = toDelegate(&VModeSubCmdTextBitmap);
        rules["VModeSubCmdColor"] = toDelegate(&VModeSubCmdColor);
        rules["VModeSubCmdRsel"] = toDelegate(&VModeSubCmdRsel);
        rules["VModeSubCmdCsel"] = toDelegate(&VModeSubCmdCsel);
        rules["ExprList"] = toDelegate(&ExprList);
        rules["AccessorList"] = toDelegate(&AccessorList);
        rules["PrintableList"] = toDelegate(&PrintableList);
        rules["TabSep"] = toDelegate(&TabSep);
        rules["NlSupp"] = toDelegate(&NlSupp);
        rules["VarList"] = toDelegate(&VarList);
        rules["Datalist"] = toDelegate(&Datalist);
        rules["Expression"] = toDelegate(&Expression);
        rules["Relation"] = toDelegate(&Relation);
        rules["Simplexp"] = toDelegate(&Simplexp);
        rules["Term"] = toDelegate(&Term);
        rules["Factor"] = toDelegate(&Factor);
        rules["UN_OP"] = toDelegate(&UN_OP);
        rules["T_OP"] = toDelegate(&T_OP);
        rules["E_OP"] = toDelegate(&E_OP);
        rules["BW_OP"] = toDelegate(&BW_OP);
        rules["REL_OP"] = toDelegate(&REL_OP);
        rules["Parenthesis"] = toDelegate(&Parenthesis);
        rules["Varnosubscript"] = toDelegate(&Varnosubscript);
        rules["Var"] = toDelegate(&Var);
        rules["VarnamePattern"] = toDelegate(&VarnamePattern);
        rules["Varname"] = toDelegate(&Varname);
        rules["Address"] = toDelegate(&Address);
        rules["Accessor"] = toDelegate(&Accessor);
        rules["Id"] = toDelegate(&Id);
        rules["Str_typeLen"] = toDelegate(&Str_typeLen);
        rules["Vartype"] = toDelegate(&Vartype);
        rules["Subscript"] = toDelegate(&Subscript);
        rules["String"] = toDelegate(&String);
        rules["Unsigned"] = toDelegate(&Unsigned);
        rules["Decimal"] = toDelegate(&Decimal);
        rules["Integer"] = toDelegate(&Integer);
        rules["Hexa"] = toDelegate(&Hexa);
        rules["Binary"] = toDelegate(&Binary);
        rules["Scientific"] = toDelegate(&Scientific);
        rules["Floating"] = toDelegate(&Floating);
        rules["Charlit"] = toDelegate(&Charlit);
        rules["Number"] = toDelegate(&Number);
        rules["Label"] = toDelegate(&Label);
        rules["Label_ref"] = toDelegate(&Label_ref);
        rules["Line_id"] = toDelegate(&Line_id);
        rules["Reserved"] = toDelegate(&Reserved);
        rules["WS"] = toDelegate(&WS);
        rules["EOI"] = toDelegate(&EOI);
        rules["Spacing"] = toDelegate(&Spacing);
    }

    template hooked(alias r, string name)
    {
        static ParseTree hooked(ParseTree p)
        {
            ParseTree result;

            if (name in before)
            {
                result = before[name](p);
                if (result.successful)
                    return result;
            }

            result = r(p);
            if (result.successful || name !in after)
                return result;

            result = after[name](p);
            return result;
        }

        static ParseTree hooked(string input)
        {
            return hooked!(r, name)(ParseTree("",false,[],input));
        }
    }

    static void addRuleBefore(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar name
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
            if (ruleName != "Spacing") // Keep the local Spacing rule, do not overwrite it
                rules[ruleName] = rule;
        before[parentRule] = rules[dg.startingRule];
    }

    static void addRuleAfter(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar named
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(name,rule; dg.rules)
        {
            if (name != "Spacing")
                rules[name] = rule;
        }
        after[parentRule] = rules[dg.startingRule];
    }

    static bool isRule(string s)
    {
		import std.algorithm : startsWith;
        return s.startsWith("XCBASIC.");
    }
    mixin decimateTree;

    static TParseTree Program(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Line, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.oneOrMore!(endOfLine), Line)), EOI), "XCBASIC.Program")(p);
        }
        else
        {
            if (auto m = tuple(`Program`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Line, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.oneOrMore!(endOfLine), Line)), EOI), "XCBASIC.Program"), "Program")(p);
                memo[tuple(`Program`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Program(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Line, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.oneOrMore!(endOfLine), Line)), EOI), "XCBASIC.Program")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Line, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.oneOrMore!(endOfLine), Line)), EOI), "XCBASIC.Program"), "Program")(TParseTree("", false,[], s));
        }
    }
    static string Program(GetName g)
    {
        return "XCBASIC.Program";
    }

    static TParseTree Line(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Line_id, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(Statements), pegged.peg.discard!(pegged.peg.option!(WS))), "XCBASIC.Line")(p);
        }
        else
        {
            if (auto m = tuple(`Line`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Line_id, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(Statements), pegged.peg.discard!(pegged.peg.option!(WS))), "XCBASIC.Line"), "Line")(p);
                memo[tuple(`Line`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Line(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Line_id, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(Statements), pegged.peg.discard!(pegged.peg.option!(WS))), "XCBASIC.Line")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Line_id, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(Statements), pegged.peg.discard!(pegged.peg.option!(WS))), "XCBASIC.Line"), "Line")(TParseTree("", false,[], s));
        }
    }
    static string Line(GetName g)
    {
        return "XCBASIC.Line";
    }

    static TParseTree Statements(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Statement, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(":"), pegged.peg.discard!(pegged.peg.option!(WS)), Statement))), "XCBASIC.Statements")(p);
        }
        else
        {
            if (auto m = tuple(`Statements`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Statement, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(":"), pegged.peg.discard!(pegged.peg.option!(WS)), Statement))), "XCBASIC.Statements"), "Statements")(p);
                memo[tuple(`Statements`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Statements(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Statement, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(":"), pegged.peg.discard!(pegged.peg.option!(WS)), Statement))), "XCBASIC.Statements")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Statement, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(":"), pegged.peg.discard!(pegged.peg.option!(WS)), Statement))), "XCBASIC.Statements"), "Statements")(TParseTree("", false,[], s));
        }
    }
    static string Statements(GetName g)
    {
        return "XCBASIC.Statements";
    }

    static TParseTree Statement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.longest_match!(Const_stmt, Let_stmt, Print_stmt, If_stmt, Goto_stmt, Input_stmt, Gosub_stmt, Call_stmt, Rem_stmt, Poke_stmt, For_stmt, Next_stmt, Dim_stmt, Charat_stmt, Data_stmt, Textat_stmt, Incbin_stmt, Include_stmt, Load_stmt, Save_stmt, Randomize_stmt, Origin_stmt, Swap_stmt, Locate_stmt, On_stmt, Error_stmt, Wait_stmt, Memset_stmt, Memcpy_stmt, Memshift_stmt, Open_stmt, Close_stmt, Get_stmt, If_sa_stmt, Else_stmt, Endif_stmt, Fun_stmt, Endfun_stmt, Return_fn_stmt, Return_stmt, Exitfun_stmt, Do_stmt, Loop_stmt, Asm_stmt, Endasm_stmt, Print_hash_stmt, Write_stmt, Read_stmt, Cont_stmt, Exit_do_stmt, Exit_for_stmt, Type_stmt, Endtype_stmt, Endselect_stmt, End_stmt, Screen_stmt, Option_stmt, Sprite_clearhit_stmt, Sprite_multicolor_stmt, Sprite_stmt, Sound_clear_stmt, Volume_stmt, Voice_stmt, Filter_stmt, Irq_stmt, Border_stmt, Background_stmt, Sys_stmt, Charset_stmt, Scroll_stmt, VMode_stmt, Field_def, Select_stmt, Case_stmt), "XCBASIC.Statement")(p);
        }
        else
        {
            if (auto m = tuple(`Statement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.longest_match!(Const_stmt, Let_stmt, Print_stmt, If_stmt, Goto_stmt, Input_stmt, Gosub_stmt, Call_stmt, Rem_stmt, Poke_stmt, For_stmt, Next_stmt, Dim_stmt, Charat_stmt, Data_stmt, Textat_stmt, Incbin_stmt, Include_stmt, Load_stmt, Save_stmt, Randomize_stmt, Origin_stmt, Swap_stmt, Locate_stmt, On_stmt, Error_stmt, Wait_stmt, Memset_stmt, Memcpy_stmt, Memshift_stmt, Open_stmt, Close_stmt, Get_stmt, If_sa_stmt, Else_stmt, Endif_stmt, Fun_stmt, Endfun_stmt, Return_fn_stmt, Return_stmt, Exitfun_stmt, Do_stmt, Loop_stmt, Asm_stmt, Endasm_stmt, Print_hash_stmt, Write_stmt, Read_stmt, Cont_stmt, Exit_do_stmt, Exit_for_stmt, Type_stmt, Endtype_stmt, Endselect_stmt, End_stmt, Screen_stmt, Option_stmt, Sprite_clearhit_stmt, Sprite_multicolor_stmt, Sprite_stmt, Sound_clear_stmt, Volume_stmt, Voice_stmt, Filter_stmt, Irq_stmt, Border_stmt, Background_stmt, Sys_stmt, Charset_stmt, Scroll_stmt, VMode_stmt, Field_def, Select_stmt, Case_stmt), "XCBASIC.Statement"), "Statement")(p);
                memo[tuple(`Statement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Statement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.longest_match!(Const_stmt, Let_stmt, Print_stmt, If_stmt, Goto_stmt, Input_stmt, Gosub_stmt, Call_stmt, Rem_stmt, Poke_stmt, For_stmt, Next_stmt, Dim_stmt, Charat_stmt, Data_stmt, Textat_stmt, Incbin_stmt, Include_stmt, Load_stmt, Save_stmt, Randomize_stmt, Origin_stmt, Swap_stmt, Locate_stmt, On_stmt, Error_stmt, Wait_stmt, Memset_stmt, Memcpy_stmt, Memshift_stmt, Open_stmt, Close_stmt, Get_stmt, If_sa_stmt, Else_stmt, Endif_stmt, Fun_stmt, Endfun_stmt, Return_fn_stmt, Return_stmt, Exitfun_stmt, Do_stmt, Loop_stmt, Asm_stmt, Endasm_stmt, Print_hash_stmt, Write_stmt, Read_stmt, Cont_stmt, Exit_do_stmt, Exit_for_stmt, Type_stmt, Endtype_stmt, Endselect_stmt, End_stmt, Screen_stmt, Option_stmt, Sprite_clearhit_stmt, Sprite_multicolor_stmt, Sprite_stmt, Sound_clear_stmt, Volume_stmt, Voice_stmt, Filter_stmt, Irq_stmt, Border_stmt, Background_stmt, Sys_stmt, Charset_stmt, Scroll_stmt, VMode_stmt, Field_def, Select_stmt, Case_stmt), "XCBASIC.Statement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.longest_match!(Const_stmt, Let_stmt, Print_stmt, If_stmt, Goto_stmt, Input_stmt, Gosub_stmt, Call_stmt, Rem_stmt, Poke_stmt, For_stmt, Next_stmt, Dim_stmt, Charat_stmt, Data_stmt, Textat_stmt, Incbin_stmt, Include_stmt, Load_stmt, Save_stmt, Randomize_stmt, Origin_stmt, Swap_stmt, Locate_stmt, On_stmt, Error_stmt, Wait_stmt, Memset_stmt, Memcpy_stmt, Memshift_stmt, Open_stmt, Close_stmt, Get_stmt, If_sa_stmt, Else_stmt, Endif_stmt, Fun_stmt, Endfun_stmt, Return_fn_stmt, Return_stmt, Exitfun_stmt, Do_stmt, Loop_stmt, Asm_stmt, Endasm_stmt, Print_hash_stmt, Write_stmt, Read_stmt, Cont_stmt, Exit_do_stmt, Exit_for_stmt, Type_stmt, Endtype_stmt, Endselect_stmt, End_stmt, Screen_stmt, Option_stmt, Sprite_clearhit_stmt, Sprite_multicolor_stmt, Sprite_stmt, Sound_clear_stmt, Volume_stmt, Voice_stmt, Filter_stmt, Irq_stmt, Border_stmt, Background_stmt, Sys_stmt, Charset_stmt, Scroll_stmt, VMode_stmt, Field_def, Select_stmt, Case_stmt), "XCBASIC.Statement"), "Statement")(TParseTree("", false,[], s));
        }
    }
    static string Statement(GetName g)
    {
        return "XCBASIC.Statement";
    }

    static TParseTree Const_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.discard!(WS))), pegged.peg.caseInsensitiveLiteral!("const"), pegged.peg.discard!(pegged.peg.option!(WS)), Var, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Number), "XCBASIC.Const_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Const_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.discard!(WS))), pegged.peg.caseInsensitiveLiteral!("const"), pegged.peg.discard!(pegged.peg.option!(WS)), Var, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Number), "XCBASIC.Const_stmt"), "Const_stmt")(p);
                memo[tuple(`Const_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Const_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.discard!(WS))), pegged.peg.caseInsensitiveLiteral!("const"), pegged.peg.discard!(pegged.peg.option!(WS)), Var, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Number), "XCBASIC.Const_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.discard!(WS))), pegged.peg.caseInsensitiveLiteral!("const"), pegged.peg.discard!(pegged.peg.option!(WS)), Var, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Number), "XCBASIC.Const_stmt"), "Const_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Const_stmt(GetName g)
    {
        return "XCBASIC.Const_stmt";
    }

    static TParseTree Let_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("let"), eps), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Let_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Let_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("let"), eps), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Let_stmt"), "Let_stmt")(p);
                memo[tuple(`Let_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Let_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("let"), eps), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Let_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("let"), eps), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Let_stmt"), "Let_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Let_stmt(GetName g)
    {
        return "XCBASIC.Let_stmt";
    }

    static TParseTree Print_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.discard!(pegged.peg.option!(WS)), PrintableList, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Print_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Print_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.discard!(pegged.peg.option!(WS)), PrintableList, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Print_stmt"), "Print_stmt")(p);
                memo[tuple(`Print_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Print_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.discard!(pegged.peg.option!(WS)), PrintableList, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Print_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.discard!(pegged.peg.option!(WS)), PrintableList, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Print_stmt"), "Print_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Print_stmt(GetName g)
    {
        return "XCBASIC.Print_stmt";
    }

    static TParseTree Print_hash_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Print_hash_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Print_hash_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Print_hash_stmt"), "Print_hash_stmt")(p);
                memo[tuple(`Print_hash_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Print_hash_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Print_hash_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Print_hash_stmt"), "Print_hash_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Print_hash_stmt(GetName g)
    {
        return "XCBASIC.Print_hash_stmt";
    }

    static TParseTree Write_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("write"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Write_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Write_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("write"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Write_stmt"), "Write_stmt")(p);
                memo[tuple(`Write_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Write_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("write"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Write_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("write"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Write_stmt"), "Write_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Write_stmt(GetName g)
    {
        return "XCBASIC.Write_stmt";
    }

    static TParseTree Read_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("read"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), AccessorList), "XCBASIC.Read_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Read_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("read"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), AccessorList), "XCBASIC.Read_stmt"), "Read_stmt")(p);
                memo[tuple(`Read_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Read_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("read"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), AccessorList), "XCBASIC.Read_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("read"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), AccessorList), "XCBASIC.Read_stmt"), "Read_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Read_stmt(GetName g)
    {
        return "XCBASIC.Read_stmt";
    }

    static TParseTree If_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("then"), pegged.peg.discard!(WS), Statements, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("else"), pegged.peg.discard!(WS), Statements))), "XCBASIC.If_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`If_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("then"), pegged.peg.discard!(WS), Statements, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("else"), pegged.peg.discard!(WS), Statements))), "XCBASIC.If_stmt"), "If_stmt")(p);
                memo[tuple(`If_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree If_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("then"), pegged.peg.discard!(WS), Statements, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("else"), pegged.peg.discard!(WS), Statements))), "XCBASIC.If_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("then"), pegged.peg.discard!(WS), Statements, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("else"), pegged.peg.discard!(WS), Statements))), "XCBASIC.If_stmt"), "If_stmt")(TParseTree("", false,[], s));
        }
    }
    static string If_stmt(GetName g)
    {
        return "XCBASIC.If_stmt";
    }

    static TParseTree If_sa_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("then")), "XCBASIC.If_sa_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`If_sa_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("then")), "XCBASIC.If_sa_stmt"), "If_sa_stmt")(p);
                memo[tuple(`If_sa_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree If_sa_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("then")), "XCBASIC.If_sa_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("then")), "XCBASIC.If_sa_stmt"), "If_sa_stmt")(TParseTree("", false,[], s));
        }
    }
    static string If_sa_stmt(GetName g)
    {
        return "XCBASIC.If_sa_stmt";
    }

    static TParseTree Else_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("else"), "XCBASIC.Else_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Else_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("else"), "XCBASIC.Else_stmt"), "Else_stmt")(p);
                memo[tuple(`Else_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Else_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("else"), "XCBASIC.Else_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("else"), "XCBASIC.Else_stmt"), "Else_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Else_stmt(GetName g)
    {
        return "XCBASIC.Else_stmt";
    }

    static TParseTree Endif_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end if"), "XCBASIC.Endif_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Endif_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end if"), "XCBASIC.Endif_stmt"), "Endif_stmt")(p);
                memo[tuple(`Endif_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Endif_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end if"), "XCBASIC.Endif_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end if"), "XCBASIC.Endif_stmt"), "Endif_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Endif_stmt(GetName g)
    {
        return "XCBASIC.Endif_stmt";
    }

    static TParseTree Goto_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.discard!(WS), pegged.peg.or!(Label_ref, Unsigned)), "XCBASIC.Goto_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Goto_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.discard!(WS), pegged.peg.or!(Label_ref, Unsigned)), "XCBASIC.Goto_stmt"), "Goto_stmt")(p);
                memo[tuple(`Goto_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Goto_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.discard!(WS), pegged.peg.or!(Label_ref, Unsigned)), "XCBASIC.Goto_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.discard!(WS), pegged.peg.or!(Label_ref, Unsigned)), "XCBASIC.Goto_stmt"), "Goto_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Goto_stmt(GetName g)
    {
        return "XCBASIC.Goto_stmt";
    }

    static TParseTree Error_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.discard!(WS), Expression), "XCBASIC.Error_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Error_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.discard!(WS), Expression), "XCBASIC.Error_stmt"), "Error_stmt")(p);
                memo[tuple(`Error_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Error_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.discard!(WS), Expression), "XCBASIC.Error_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.discard!(WS), Expression), "XCBASIC.Error_stmt"), "Error_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Error_stmt(GetName g)
    {
        return "XCBASIC.Error_stmt";
    }

    static TParseTree Swap_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("swap"), pegged.peg.discard!(WS), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor), "XCBASIC.Swap_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Swap_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("swap"), pegged.peg.discard!(WS), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor), "XCBASIC.Swap_stmt"), "Swap_stmt")(p);
                memo[tuple(`Swap_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Swap_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("swap"), pegged.peg.discard!(WS), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor), "XCBASIC.Swap_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("swap"), pegged.peg.discard!(WS), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor), "XCBASIC.Swap_stmt"), "Swap_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Swap_stmt(GetName g)
    {
        return "XCBASIC.Swap_stmt";
    }

    static TParseTree Input_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("input"), pegged.peg.discard!(WS), pegged.peg.option!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(",")), pegged.peg.and!(String, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(";")))), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Input_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Input_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("input"), pegged.peg.discard!(WS), pegged.peg.option!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(",")), pegged.peg.and!(String, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(";")))), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Input_stmt"), "Input_stmt")(p);
                memo[tuple(`Input_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Input_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("input"), pegged.peg.discard!(WS), pegged.peg.option!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(",")), pegged.peg.and!(String, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(";")))), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Input_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("input"), pegged.peg.discard!(WS), pegged.peg.option!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(",")), pegged.peg.and!(String, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(";")))), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(pegged.peg.literal!(";"))), "XCBASIC.Input_stmt"), "Input_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Input_stmt(GetName g)
    {
        return "XCBASIC.Input_stmt";
    }

    static TParseTree Gosub_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("gosub"), pegged.peg.discard!(WS), pegged.peg.or!(Label_ref, Unsigned)), "XCBASIC.Gosub_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Gosub_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("gosub"), pegged.peg.discard!(WS), pegged.peg.or!(Label_ref, Unsigned)), "XCBASIC.Gosub_stmt"), "Gosub_stmt")(p);
                memo[tuple(`Gosub_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Gosub_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("gosub"), pegged.peg.discard!(WS), pegged.peg.or!(Label_ref, Unsigned)), "XCBASIC.Gosub_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("gosub"), pegged.peg.discard!(WS), pegged.peg.or!(Label_ref, Unsigned)), "XCBASIC.Gosub_stmt"), "Gosub_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Gosub_stmt(GetName g)
    {
        return "XCBASIC.Gosub_stmt";
    }

    static TParseTree Call_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("call"), pegged.peg.discard!(WS), Accessor), "XCBASIC.Call_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Call_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("call"), pegged.peg.discard!(WS), Accessor), "XCBASIC.Call_stmt"), "Call_stmt")(p);
                memo[tuple(`Call_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Call_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("call"), pegged.peg.discard!(WS), Accessor), "XCBASIC.Call_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("call"), pegged.peg.discard!(WS), Accessor), "XCBASIC.Call_stmt"), "Call_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Call_stmt(GetName g)
    {
        return "XCBASIC.Call_stmt";
    }

    static TParseTree Return_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("return"), "XCBASIC.Return_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Return_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("return"), "XCBASIC.Return_stmt"), "Return_stmt")(p);
                memo[tuple(`Return_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Return_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("return"), "XCBASIC.Return_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("return"), "XCBASIC.Return_stmt"), "Return_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Return_stmt(GetName g)
    {
        return "XCBASIC.Return_stmt";
    }

    static TParseTree Return_fn_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("return"), pegged.peg.discard!(WS), Expression), "XCBASIC.Return_fn_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Return_fn_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("return"), pegged.peg.discard!(WS), Expression), "XCBASIC.Return_fn_stmt"), "Return_fn_stmt")(p);
                memo[tuple(`Return_fn_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Return_fn_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("return"), pegged.peg.discard!(WS), Expression), "XCBASIC.Return_fn_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("return"), pegged.peg.discard!(WS), Expression), "XCBASIC.Return_fn_stmt"), "Return_fn_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Return_fn_stmt(GetName g)
    {
        return "XCBASIC.Return_fn_stmt";
    }

    static TParseTree Poke_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("poke"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Poke_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Poke_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("poke"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Poke_stmt"), "Poke_stmt")(p);
                memo[tuple(`Poke_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Poke_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("poke"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Poke_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("poke"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Poke_stmt"), "Poke_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Poke_stmt(GetName g)
    {
        return "XCBASIC.Poke_stmt";
    }

    static TParseTree Do_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("do"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("until")), pegged.peg.discard!(WS), Expression))), "XCBASIC.Do_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Do_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("do"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("until")), pegged.peg.discard!(WS), Expression))), "XCBASIC.Do_stmt"), "Do_stmt")(p);
                memo[tuple(`Do_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Do_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("do"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("until")), pegged.peg.discard!(WS), Expression))), "XCBASIC.Do_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("do"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("until")), pegged.peg.discard!(WS), Expression))), "XCBASIC.Do_stmt"), "Do_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Do_stmt(GetName g)
    {
        return "XCBASIC.Do_stmt";
    }

    static TParseTree Loop_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("loop"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("until")), pegged.peg.discard!(WS), Expression))), "XCBASIC.Loop_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Loop_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("loop"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("until")), pegged.peg.discard!(WS), Expression))), "XCBASIC.Loop_stmt"), "Loop_stmt")(p);
                memo[tuple(`Loop_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Loop_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("loop"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("until")), pegged.peg.discard!(WS), Expression))), "XCBASIC.Loop_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("loop"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("until")), pegged.peg.discard!(WS), Expression))), "XCBASIC.Loop_stmt"), "Loop_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Loop_stmt(GetName g)
    {
        return "XCBASIC.Loop_stmt";
    }

    static TParseTree Cont_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("continue"), pegged.peg.discard!(WS), pegged.peg.option!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.caseInsensitiveLiteral!("do")))), "XCBASIC.Cont_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Cont_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("continue"), pegged.peg.discard!(WS), pegged.peg.option!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.caseInsensitiveLiteral!("do")))), "XCBASIC.Cont_stmt"), "Cont_stmt")(p);
                memo[tuple(`Cont_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Cont_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("continue"), pegged.peg.discard!(WS), pegged.peg.option!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.caseInsensitiveLiteral!("do")))), "XCBASIC.Cont_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("continue"), pegged.peg.discard!(WS), pegged.peg.option!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.caseInsensitiveLiteral!("do")))), "XCBASIC.Cont_stmt"), "Cont_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Cont_stmt(GetName g)
    {
        return "XCBASIC.Cont_stmt";
    }

    static TParseTree Exit_do_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("exit do"), "XCBASIC.Exit_do_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Exit_do_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("exit do"), "XCBASIC.Exit_do_stmt"), "Exit_do_stmt")(p);
                memo[tuple(`Exit_do_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Exit_do_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("exit do"), "XCBASIC.Exit_do_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("exit do"), "XCBASIC.Exit_do_stmt"), "Exit_do_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Exit_do_stmt(GetName g)
    {
        return "XCBASIC.Exit_do_stmt";
    }

    static TParseTree Rem_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("rem"), pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)))), "XCBASIC.Rem_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Rem_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("rem"), pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)))), "XCBASIC.Rem_stmt"), "Rem_stmt")(p);
                memo[tuple(`Rem_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Rem_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("rem"), pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)))), "XCBASIC.Rem_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("rem"), pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)))), "XCBASIC.Rem_stmt"), "Rem_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Rem_stmt(GetName g)
    {
        return "XCBASIC.Rem_stmt";
    }

    static TParseTree For_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.discard!(WS), Varnosubscript, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("step"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.For_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`For_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.discard!(WS), Varnosubscript, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("step"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.For_stmt"), "For_stmt")(p);
                memo[tuple(`For_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree For_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.discard!(WS), Varnosubscript, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("step"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.For_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.discard!(WS), Varnosubscript, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("step"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.For_stmt"), "For_stmt")(TParseTree("", false,[], s));
        }
    }
    static string For_stmt(GetName g)
    {
        return "XCBASIC.For_stmt";
    }

    static TParseTree Next_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("next"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), Varname))), "XCBASIC.Next_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Next_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("next"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), Varname))), "XCBASIC.Next_stmt"), "Next_stmt")(p);
                memo[tuple(`Next_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Next_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("next"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), Varname))), "XCBASIC.Next_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("next"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), Varname))), "XCBASIC.Next_stmt"), "Next_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Next_stmt(GetName g)
    {
        return "XCBASIC.Next_stmt";
    }

    static TParseTree Exit_for_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("exit for"), "XCBASIC.Exit_for_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Exit_for_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("exit for"), "XCBASIC.Exit_for_stmt"), "Exit_for_stmt")(p);
                memo[tuple(`Exit_for_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Exit_for_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("exit for"), "XCBASIC.Exit_for_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("exit for"), "XCBASIC.Exit_for_stmt"), "Exit_for_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Exit_for_stmt(GetName g)
    {
        return "XCBASIC.Exit_for_stmt";
    }

    static TParseTree Dim_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("dim"), pegged.peg.caseInsensitiveLiteral!("static")), pegged.peg.discard!(WS), pegged.peg.zeroOrMore!(pegged.peg.and!(Varattrib, pegged.peg.discard!(WS))), Vardef, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Vardef)), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Varattrib))), "XCBASIC.Dim_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Dim_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("dim"), pegged.peg.caseInsensitiveLiteral!("static")), pegged.peg.discard!(WS), pegged.peg.zeroOrMore!(pegged.peg.and!(Varattrib, pegged.peg.discard!(WS))), Vardef, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Vardef)), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Varattrib))), "XCBASIC.Dim_stmt"), "Dim_stmt")(p);
                memo[tuple(`Dim_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Dim_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("dim"), pegged.peg.caseInsensitiveLiteral!("static")), pegged.peg.discard!(WS), pegged.peg.zeroOrMore!(pegged.peg.and!(Varattrib, pegged.peg.discard!(WS))), Vardef, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Vardef)), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Varattrib))), "XCBASIC.Dim_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("dim"), pegged.peg.caseInsensitiveLiteral!("static")), pegged.peg.discard!(WS), pegged.peg.zeroOrMore!(pegged.peg.and!(Varattrib, pegged.peg.discard!(WS))), Vardef, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Vardef)), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Varattrib))), "XCBASIC.Dim_stmt"), "Dim_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Dim_stmt(GetName g)
    {
        return "XCBASIC.Dim_stmt";
    }

    static TParseTree Varattrib(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("fast"), pegged.peg.caseInsensitiveLiteral!("shared")), "XCBASIC.Varattrib")(p);
        }
        else
        {
            if (auto m = tuple(`Varattrib`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("fast"), pegged.peg.caseInsensitiveLiteral!("shared")), "XCBASIC.Varattrib"), "Varattrib")(p);
                memo[tuple(`Varattrib`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Varattrib(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("fast"), pegged.peg.caseInsensitiveLiteral!("shared")), "XCBASIC.Varattrib")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("fast"), pegged.peg.caseInsensitiveLiteral!("shared")), "XCBASIC.Varattrib"), "Varattrib")(TParseTree("", false,[], s));
        }
    }
    static string Varattrib(GetName g)
    {
        return "XCBASIC.Varattrib";
    }

    static TParseTree Vardef(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Var, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!("@")), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, Label_ref)))), "XCBASIC.Vardef")(p);
        }
        else
        {
            if (auto m = tuple(`Vardef`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Var, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!("@")), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, Label_ref)))), "XCBASIC.Vardef"), "Vardef")(p);
                memo[tuple(`Vardef`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Vardef(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Var, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!("@")), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, Label_ref)))), "XCBASIC.Vardef")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Var, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!("@")), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, Label_ref)))), "XCBASIC.Vardef"), "Vardef")(TParseTree("", false,[], s));
        }
    }
    static string Vardef(GetName g)
    {
        return "XCBASIC.Vardef";
    }

    static TParseTree Data_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.discard!(WS))), pegged.peg.caseInsensitiveLiteral!("data"), Vartype, pegged.peg.discard!(WS), Datalist), "XCBASIC.Data_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Data_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.discard!(WS))), pegged.peg.caseInsensitiveLiteral!("data"), Vartype, pegged.peg.discard!(WS), Datalist), "XCBASIC.Data_stmt"), "Data_stmt")(p);
                memo[tuple(`Data_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Data_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.discard!(WS))), pegged.peg.caseInsensitiveLiteral!("data"), Vartype, pegged.peg.discard!(WS), Datalist), "XCBASIC.Data_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.discard!(WS))), pegged.peg.caseInsensitiveLiteral!("data"), Vartype, pegged.peg.discard!(WS), Datalist), "XCBASIC.Data_stmt"), "Data_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Data_stmt(GetName g)
    {
        return "XCBASIC.Data_stmt";
    }

    static TParseTree Charat_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("charat"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Charat_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Charat_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("charat"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Charat_stmt"), "Charat_stmt")(p);
                memo[tuple(`Charat_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Charat_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("charat"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Charat_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("charat"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Charat_stmt"), "Charat_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Charat_stmt(GetName g)
    {
        return "XCBASIC.Charat_stmt";
    }

    static TParseTree Textat_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("textat"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Textat_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Textat_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("textat"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Textat_stmt"), "Textat_stmt")(p);
                memo[tuple(`Textat_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Textat_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("textat"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Textat_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("textat"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Textat_stmt"), "Textat_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Textat_stmt(GetName g)
    {
        return "XCBASIC.Textat_stmt";
    }

    static TParseTree Screen_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("screen"), pegged.peg.discard!(WS), Expression), "XCBASIC.Screen_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Screen_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("screen"), pegged.peg.discard!(WS), Expression), "XCBASIC.Screen_stmt"), "Screen_stmt")(p);
                memo[tuple(`Screen_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Screen_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("screen"), pegged.peg.discard!(WS), Expression), "XCBASIC.Screen_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("screen"), pegged.peg.discard!(WS), Expression), "XCBASIC.Screen_stmt"), "Screen_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Screen_stmt(GetName g)
    {
        return "XCBASIC.Screen_stmt";
    }

    static TParseTree Asm_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("asm"), "XCBASIC.Asm_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Asm_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("asm"), "XCBASIC.Asm_stmt"), "Asm_stmt")(p);
                memo[tuple(`Asm_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Asm_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("asm"), "XCBASIC.Asm_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("asm"), "XCBASIC.Asm_stmt"), "Asm_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Asm_stmt(GetName g)
    {
        return "XCBASIC.Asm_stmt";
    }

    static TParseTree Endasm_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end asm"), "XCBASIC.Endasm_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Endasm_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end asm"), "XCBASIC.Endasm_stmt"), "Endasm_stmt")(p);
                memo[tuple(`Endasm_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Endasm_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end asm"), "XCBASIC.Endasm_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end asm"), "XCBASIC.Endasm_stmt"), "Endasm_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Endasm_stmt(GetName g)
    {
        return "XCBASIC.Endasm_stmt";
    }

    static TParseTree Incbin_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("incbin"), pegged.peg.discard!(WS), String), "XCBASIC.Incbin_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Incbin_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("incbin"), pegged.peg.discard!(WS), String), "XCBASIC.Incbin_stmt"), "Incbin_stmt")(p);
                memo[tuple(`Incbin_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Incbin_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("incbin"), pegged.peg.discard!(WS), String), "XCBASIC.Incbin_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("incbin"), pegged.peg.discard!(WS), String), "XCBASIC.Incbin_stmt"), "Incbin_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Incbin_stmt(GetName g)
    {
        return "XCBASIC.Incbin_stmt";
    }

    static TParseTree Include_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("include"), pegged.peg.discard!(WS), String), "XCBASIC.Include_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Include_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("include"), pegged.peg.discard!(WS), String), "XCBASIC.Include_stmt"), "Include_stmt")(p);
                memo[tuple(`Include_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Include_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("include"), pegged.peg.discard!(WS), String), "XCBASIC.Include_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("include"), pegged.peg.discard!(WS), String), "XCBASIC.Include_stmt"), "Include_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Include_stmt(GetName g)
    {
        return "XCBASIC.Include_stmt";
    }

    static TParseTree Exitfun_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("exit function"), pegged.peg.caseInsensitiveLiteral!("exit sub")), "XCBASIC.Exitfun_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Exitfun_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("exit function"), pegged.peg.caseInsensitiveLiteral!("exit sub")), "XCBASIC.Exitfun_stmt"), "Exitfun_stmt")(p);
                memo[tuple(`Exitfun_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Exitfun_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("exit function"), pegged.peg.caseInsensitiveLiteral!("exit sub")), "XCBASIC.Exitfun_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("exit function"), pegged.peg.caseInsensitiveLiteral!("exit sub")), "XCBASIC.Exitfun_stmt"), "Exitfun_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Exitfun_stmt(GetName g)
    {
        return "XCBASIC.Exitfun_stmt";
    }

    static TParseTree Endfun_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("end function"), pegged.peg.caseInsensitiveLiteral!("end sub")), "XCBASIC.Endfun_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Endfun_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("end function"), pegged.peg.caseInsensitiveLiteral!("end sub")), "XCBASIC.Endfun_stmt"), "Endfun_stmt")(p);
                memo[tuple(`Endfun_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Endfun_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("end function"), pegged.peg.caseInsensitiveLiteral!("end sub")), "XCBASIC.Endfun_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("end function"), pegged.peg.caseInsensitiveLiteral!("end sub")), "XCBASIC.Endfun_stmt"), "Endfun_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Endfun_stmt(GetName g)
    {
        return "XCBASIC.Endfun_stmt";
    }

    static TParseTree Fun_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("declare"), pegged.peg.discard!(WS))), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("function"), pegged.peg.caseInsensitiveLiteral!("sub")), pegged.peg.discard!(WS), Varnosubscript, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(VarList), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), Funcattrib))), "XCBASIC.Fun_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Fun_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("declare"), pegged.peg.discard!(WS))), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("function"), pegged.peg.caseInsensitiveLiteral!("sub")), pegged.peg.discard!(WS), Varnosubscript, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(VarList), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), Funcattrib))), "XCBASIC.Fun_stmt"), "Fun_stmt")(p);
                memo[tuple(`Fun_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Fun_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("declare"), pegged.peg.discard!(WS))), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("function"), pegged.peg.caseInsensitiveLiteral!("sub")), pegged.peg.discard!(WS), Varnosubscript, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(VarList), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), Funcattrib))), "XCBASIC.Fun_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("declare"), pegged.peg.discard!(WS))), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("function"), pegged.peg.caseInsensitiveLiteral!("sub")), pegged.peg.discard!(WS), Varnosubscript, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(VarList), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!(")")), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), Funcattrib))), "XCBASIC.Fun_stmt"), "Fun_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Fun_stmt(GetName g)
    {
        return "XCBASIC.Fun_stmt";
    }

    static TParseTree Funcattrib(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("private"), pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.caseInsensitiveLiteral!("static"), pegged.peg.caseInsensitiveLiteral!("overload"), pegged.peg.caseInsensitiveLiteral!("inline")), "XCBASIC.Funcattrib")(p);
        }
        else
        {
            if (auto m = tuple(`Funcattrib`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("private"), pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.caseInsensitiveLiteral!("static"), pegged.peg.caseInsensitiveLiteral!("overload"), pegged.peg.caseInsensitiveLiteral!("inline")), "XCBASIC.Funcattrib"), "Funcattrib")(p);
                memo[tuple(`Funcattrib`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Funcattrib(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("private"), pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.caseInsensitiveLiteral!("static"), pegged.peg.caseInsensitiveLiteral!("overload"), pegged.peg.caseInsensitiveLiteral!("inline")), "XCBASIC.Funcattrib")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("private"), pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.caseInsensitiveLiteral!("static"), pegged.peg.caseInsensitiveLiteral!("overload"), pegged.peg.caseInsensitiveLiteral!("inline")), "XCBASIC.Funcattrib"), "Funcattrib")(TParseTree("", false,[], s));
        }
    }
    static string Funcattrib(GetName g)
    {
        return "XCBASIC.Funcattrib";
    }

    static TParseTree Sys_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sys"), pegged.peg.discard!(WS), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("fast")))), "XCBASIC.Sys_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Sys_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sys"), pegged.peg.discard!(WS), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("fast")))), "XCBASIC.Sys_stmt"), "Sys_stmt")(p);
                memo[tuple(`Sys_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sys_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sys"), pegged.peg.discard!(WS), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("fast")))), "XCBASIC.Sys_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sys"), pegged.peg.discard!(WS), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.caseInsensitiveLiteral!("fast")))), "XCBASIC.Sys_stmt"), "Sys_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Sys_stmt(GetName g)
    {
        return "XCBASIC.Sys_stmt";
    }

    static TParseTree Load_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("load"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Load_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Load_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("load"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Load_stmt"), "Load_stmt")(p);
                memo[tuple(`Load_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Load_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("load"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Load_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("load"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Load_stmt"), "Load_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Load_stmt(GetName g)
    {
        return "XCBASIC.Load_stmt";
    }

    static TParseTree Save_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("save"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Save_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Save_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("save"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Save_stmt"), "Save_stmt")(p);
                memo[tuple(`Save_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Save_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("save"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Save_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("save"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Save_stmt"), "Save_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Save_stmt(GetName g)
    {
        return "XCBASIC.Save_stmt";
    }

    static TParseTree Origin_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("origin"), pegged.peg.discard!(WS), pegged.peg.or!(Number, Label_ref)), "XCBASIC.Origin_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Origin_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("origin"), pegged.peg.discard!(WS), pegged.peg.or!(Number, Label_ref)), "XCBASIC.Origin_stmt"), "Origin_stmt")(p);
                memo[tuple(`Origin_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Origin_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("origin"), pegged.peg.discard!(WS), pegged.peg.or!(Number, Label_ref)), "XCBASIC.Origin_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("origin"), pegged.peg.discard!(WS), pegged.peg.or!(Number, Label_ref)), "XCBASIC.Origin_stmt"), "Origin_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Origin_stmt(GetName g)
    {
        return "XCBASIC.Origin_stmt";
    }

    static TParseTree Locate_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("locate"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Locate_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Locate_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("locate"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Locate_stmt"), "Locate_stmt")(p);
                memo[tuple(`Locate_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Locate_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("locate"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Locate_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("locate"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Locate_stmt"), "Locate_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Locate_stmt(GetName g)
    {
        return "XCBASIC.Locate_stmt";
    }

    static TParseTree On_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.discard!(WS), pegged.peg.or!(Expression, pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("vblank")), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), Expression)), pegged.peg.discard!(WS), Branch_type, pegged.peg.discard!(WS), Label_ref, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Label_ref))), "XCBASIC.On_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`On_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.discard!(WS), pegged.peg.or!(Expression, pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("vblank")), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), Expression)), pegged.peg.discard!(WS), Branch_type, pegged.peg.discard!(WS), Label_ref, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Label_ref))), "XCBASIC.On_stmt"), "On_stmt")(p);
                memo[tuple(`On_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree On_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.discard!(WS), pegged.peg.or!(Expression, pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("vblank")), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), Expression)), pegged.peg.discard!(WS), Branch_type, pegged.peg.discard!(WS), Label_ref, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Label_ref))), "XCBASIC.On_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.discard!(WS), pegged.peg.or!(Expression, pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("vblank")), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), Expression)), pegged.peg.discard!(WS), Branch_type, pegged.peg.discard!(WS), Label_ref, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Label_ref))), "XCBASIC.On_stmt"), "On_stmt")(TParseTree("", false,[], s));
        }
    }
    static string On_stmt(GetName g)
    {
        return "XCBASIC.On_stmt";
    }

    static TParseTree Branch_type(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.caseInsensitiveLiteral!("gosub")), "XCBASIC.Branch_type")(p);
        }
        else
        {
            if (auto m = tuple(`Branch_type`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.caseInsensitiveLiteral!("gosub")), "XCBASIC.Branch_type"), "Branch_type")(p);
                memo[tuple(`Branch_type`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Branch_type(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.caseInsensitiveLiteral!("gosub")), "XCBASIC.Branch_type")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.caseInsensitiveLiteral!("gosub")), "XCBASIC.Branch_type"), "Branch_type")(TParseTree("", false,[], s));
        }
    }
    static string Branch_type(GetName g)
    {
        return "XCBASIC.Branch_type";
    }

    static TParseTree Wait_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("wait"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.Wait_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Wait_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("wait"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.Wait_stmt"), "Wait_stmt")(p);
                memo[tuple(`Wait_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Wait_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("wait"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.Wait_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("wait"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.Wait_stmt"), "Wait_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Wait_stmt(GetName g)
    {
        return "XCBASIC.Wait_stmt";
    }

    static TParseTree Memset_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memset"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memset_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Memset_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memset"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memset_stmt"), "Memset_stmt")(p);
                memo[tuple(`Memset_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Memset_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memset"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memset_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memset"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memset_stmt"), "Memset_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Memset_stmt(GetName g)
    {
        return "XCBASIC.Memset_stmt";
    }

    static TParseTree Memcpy_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memcpy"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memcpy_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Memcpy_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memcpy"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memcpy_stmt"), "Memcpy_stmt")(p);
                memo[tuple(`Memcpy_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Memcpy_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memcpy"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memcpy_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memcpy"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memcpy_stmt"), "Memcpy_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Memcpy_stmt(GetName g)
    {
        return "XCBASIC.Memcpy_stmt";
    }

    static TParseTree Memshift_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memshift"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memshift_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Memshift_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memshift"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memshift_stmt"), "Memshift_stmt")(p);
                memo[tuple(`Memshift_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Memshift_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memshift"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memshift_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("memshift"), pegged.peg.discard!(pegged.peg.option!(WS)), ExprList), "XCBASIC.Memshift_stmt"), "Memshift_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Memshift_stmt(GetName g)
    {
        return "XCBASIC.Memshift_stmt";
    }

    static TParseTree Randomize_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("randomize"), pegged.peg.discard!(WS), Expression), "XCBASIC.Randomize_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Randomize_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("randomize"), pegged.peg.discard!(WS), Expression), "XCBASIC.Randomize_stmt"), "Randomize_stmt")(p);
                memo[tuple(`Randomize_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Randomize_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("randomize"), pegged.peg.discard!(WS), Expression), "XCBASIC.Randomize_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("randomize"), pegged.peg.discard!(WS), Expression), "XCBASIC.Randomize_stmt"), "Randomize_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Randomize_stmt(GetName g)
    {
        return "XCBASIC.Randomize_stmt";
    }

    static TParseTree Open_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("open"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Open_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Open_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("open"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Open_stmt"), "Open_stmt")(p);
                memo[tuple(`Open_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Open_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("open"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Open_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("open"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Open_stmt"), "Open_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Open_stmt(GetName g)
    {
        return "XCBASIC.Open_stmt";
    }

    static TParseTree Get_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("get"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","))), pegged.peg.discard!(pegged.peg.option!(WS)), Var), "XCBASIC.Get_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Get_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("get"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","))), pegged.peg.discard!(pegged.peg.option!(WS)), Var), "XCBASIC.Get_stmt"), "Get_stmt")(p);
                memo[tuple(`Get_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Get_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("get"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","))), pegged.peg.discard!(pegged.peg.option!(WS)), Var), "XCBASIC.Get_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("get"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("#"), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","))), pegged.peg.discard!(pegged.peg.option!(WS)), Var), "XCBASIC.Get_stmt"), "Get_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Get_stmt(GetName g)
    {
        return "XCBASIC.Get_stmt";
    }

    static TParseTree Close_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("close"), pegged.peg.discard!(WS), Expression), "XCBASIC.Close_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Close_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("close"), pegged.peg.discard!(WS), Expression), "XCBASIC.Close_stmt"), "Close_stmt")(p);
                memo[tuple(`Close_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Close_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("close"), pegged.peg.discard!(WS), Expression), "XCBASIC.Close_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("close"), pegged.peg.discard!(WS), Expression), "XCBASIC.Close_stmt"), "Close_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Close_stmt(GetName g)
    {
        return "XCBASIC.Close_stmt";
    }

    static TParseTree Type_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("type"), pegged.peg.discard!(WS), Id), "XCBASIC.Type_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Type_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("type"), pegged.peg.discard!(WS), Id), "XCBASIC.Type_stmt"), "Type_stmt")(p);
                memo[tuple(`Type_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Type_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("type"), pegged.peg.discard!(WS), Id), "XCBASIC.Type_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("type"), pegged.peg.discard!(WS), Id), "XCBASIC.Type_stmt"), "Type_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Type_stmt(GetName g)
    {
        return "XCBASIC.Type_stmt";
    }

    static TParseTree Field_def(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(Var, "XCBASIC.Field_def")(p);
        }
        else
        {
            if (auto m = tuple(`Field_def`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(Var, "XCBASIC.Field_def"), "Field_def")(p);
                memo[tuple(`Field_def`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Field_def(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(Var, "XCBASIC.Field_def")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(Var, "XCBASIC.Field_def"), "Field_def")(TParseTree("", false,[], s));
        }
    }
    static string Field_def(GetName g)
    {
        return "XCBASIC.Field_def";
    }

    static TParseTree Endtype_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end type"), "XCBASIC.Endtype_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Endtype_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end type"), "XCBASIC.Endtype_stmt"), "Endtype_stmt")(p);
                memo[tuple(`Endtype_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Endtype_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end type"), "XCBASIC.Endtype_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end type"), "XCBASIC.Endtype_stmt"), "Endtype_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Endtype_stmt(GetName g)
    {
        return "XCBASIC.Endtype_stmt";
    }

    static TParseTree End_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end"), "XCBASIC.End_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`End_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end"), "XCBASIC.End_stmt"), "End_stmt")(p);
                memo[tuple(`End_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree End_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end"), "XCBASIC.End_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end"), "XCBASIC.End_stmt"), "End_stmt")(TParseTree("", false,[], s));
        }
    }
    static string End_stmt(GetName g)
    {
        return "XCBASIC.End_stmt";
    }

    static TParseTree Option_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("option"), pegged.peg.discard!(WS), Id, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, String)))), "XCBASIC.Option_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Option_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("option"), pegged.peg.discard!(WS), Id, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, String)))), "XCBASIC.Option_stmt"), "Option_stmt")(p);
                memo[tuple(`Option_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Option_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("option"), pegged.peg.discard!(WS), Id, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, String)))), "XCBASIC.Option_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("option"), pegged.peg.discard!(WS), Id, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!("="), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, String)))), "XCBASIC.Option_stmt"), "Option_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Option_stmt(GetName g)
    {
        return "XCBASIC.Option_stmt";
    }

    static TParseTree Select_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("select case"), pegged.peg.discard!(WS), Expression), "XCBASIC.Select_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Select_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("select case"), pegged.peg.discard!(WS), Expression), "XCBASIC.Select_stmt"), "Select_stmt")(p);
                memo[tuple(`Select_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Select_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("select case"), pegged.peg.discard!(WS), Expression), "XCBASIC.Select_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("select case"), pegged.peg.discard!(WS), Expression), "XCBASIC.Select_stmt"), "Select_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Select_stmt(GetName g)
    {
        return "XCBASIC.Select_stmt";
    }

    static TParseTree Case_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Case_else_stmt, Case_is_stmt, Case_range_stmt, Case_set_stmt), "XCBASIC.Case_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Case_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(Case_else_stmt, Case_is_stmt, Case_range_stmt, Case_set_stmt), "XCBASIC.Case_stmt"), "Case_stmt")(p);
                memo[tuple(`Case_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Case_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Case_else_stmt, Case_is_stmt, Case_range_stmt, Case_set_stmt), "XCBASIC.Case_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(Case_else_stmt, Case_is_stmt, Case_range_stmt, Case_set_stmt), "XCBASIC.Case_stmt"), "Case_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Case_stmt(GetName g)
    {
        return "XCBASIC.Case_stmt";
    }

    static TParseTree Case_is_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case is"), pegged.peg.discard!(pegged.peg.option!(WS)), REL_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Case_is_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Case_is_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case is"), pegged.peg.discard!(pegged.peg.option!(WS)), REL_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Case_is_stmt"), "Case_is_stmt")(p);
                memo[tuple(`Case_is_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Case_is_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case is"), pegged.peg.discard!(pegged.peg.option!(WS)), REL_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Case_is_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case is"), pegged.peg.discard!(pegged.peg.option!(WS)), REL_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Expression), "XCBASIC.Case_is_stmt"), "Case_is_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Case_is_stmt(GetName g)
    {
        return "XCBASIC.Case_is_stmt";
    }

    static TParseTree Case_range_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.discard!(WS), Expression), "XCBASIC.Case_range_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Case_range_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.discard!(WS), Expression), "XCBASIC.Case_range_stmt"), "Case_range_stmt")(p);
                memo[tuple(`Case_range_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Case_range_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.discard!(WS), Expression), "XCBASIC.Case_range_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.discard!(WS), Expression, pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.discard!(WS), Expression), "XCBASIC.Case_range_stmt"), "Case_range_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Case_range_stmt(GetName g)
    {
        return "XCBASIC.Case_range_stmt";
    }

    static TParseTree Case_set_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Case_set_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Case_set_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Case_set_stmt"), "Case_set_stmt")(p);
                memo[tuple(`Case_set_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Case_set_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Case_set_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Case_set_stmt"), "Case_set_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Case_set_stmt(GetName g)
    {
        return "XCBASIC.Case_set_stmt";
    }

    static TParseTree Case_else_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("case else"), "XCBASIC.Case_else_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Case_else_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("case else"), "XCBASIC.Case_else_stmt"), "Case_else_stmt")(p);
                memo[tuple(`Case_else_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Case_else_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("case else"), "XCBASIC.Case_else_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("case else"), "XCBASIC.Case_else_stmt"), "Case_else_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Case_else_stmt(GetName g)
    {
        return "XCBASIC.Case_else_stmt";
    }

    static TParseTree Endselect_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end select"), "XCBASIC.Endselect_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Endselect_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end select"), "XCBASIC.Endselect_stmt"), "Endselect_stmt")(p);
                memo[tuple(`Endselect_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Endselect_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end select"), "XCBASIC.Endselect_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("end select"), "XCBASIC.Endselect_stmt"), "Endselect_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Endselect_stmt(GetName g)
    {
        return "XCBASIC.Endselect_stmt";
    }

    static TParseTree Irq_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("system"), pegged.peg.caseInsensitiveLiteral!("vblank")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("interrupt"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"))), "XCBASIC.Irq_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Irq_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("system"), pegged.peg.caseInsensitiveLiteral!("vblank")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("interrupt"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"))), "XCBASIC.Irq_stmt"), "Irq_stmt")(p);
                memo[tuple(`Irq_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Irq_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("system"), pegged.peg.caseInsensitiveLiteral!("vblank")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("interrupt"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"))), "XCBASIC.Irq_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("system"), pegged.peg.caseInsensitiveLiteral!("vblank")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("interrupt"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"))), "XCBASIC.Irq_stmt"), "Irq_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Irq_stmt(GetName g)
    {
        return "XCBASIC.Irq_stmt";
    }

    static TParseTree Sprite_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), Expression, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), SprSubCmd))), "XCBASIC.Sprite_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Sprite_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), Expression, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), SprSubCmd))), "XCBASIC.Sprite_stmt"), "Sprite_stmt")(p);
                memo[tuple(`Sprite_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sprite_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), Expression, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), SprSubCmd))), "XCBASIC.Sprite_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), Expression, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), SprSubCmd))), "XCBASIC.Sprite_stmt"), "Sprite_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Sprite_stmt(GetName g)
    {
        return "XCBASIC.Sprite_stmt";
    }

    static TParseTree SprSubCmd(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(SprSubCmdOnOff, SprSubCmdAt, SprSubCmdColor, SprSubCmdHiresMulti, SprSubCmdOnUnderBg, SprSubCmdShape, SprSubCmdXYSize, SprSubCmdZDepth, SprSubCmdZYFlip), "XCBASIC.SprSubCmd")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmd`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(SprSubCmdOnOff, SprSubCmdAt, SprSubCmdColor, SprSubCmdHiresMulti, SprSubCmdOnUnderBg, SprSubCmdShape, SprSubCmdXYSize, SprSubCmdZDepth, SprSubCmdZYFlip), "XCBASIC.SprSubCmd"), "SprSubCmd")(p);
                memo[tuple(`SprSubCmd`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmd(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(SprSubCmdOnOff, SprSubCmdAt, SprSubCmdColor, SprSubCmdHiresMulti, SprSubCmdOnUnderBg, SprSubCmdShape, SprSubCmdXYSize, SprSubCmdZDepth, SprSubCmdZYFlip), "XCBASIC.SprSubCmd")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(SprSubCmdOnOff, SprSubCmdAt, SprSubCmdColor, SprSubCmdHiresMulti, SprSubCmdOnUnderBg, SprSubCmdShape, SprSubCmdXYSize, SprSubCmdZDepth, SprSubCmdZYFlip), "XCBASIC.SprSubCmd"), "SprSubCmd")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmd(GetName g)
    {
        return "XCBASIC.SprSubCmd";
    }

    static TParseTree SprSubCmdOnOff(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off")), "XCBASIC.SprSubCmdOnOff")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmdOnOff`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off")), "XCBASIC.SprSubCmdOnOff"), "SprSubCmdOnOff")(p);
                memo[tuple(`SprSubCmdOnOff`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmdOnOff(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off")), "XCBASIC.SprSubCmdOnOff")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off")), "XCBASIC.SprSubCmdOnOff"), "SprSubCmdOnOff")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmdOnOff(GetName g)
    {
        return "XCBASIC.SprSubCmdOnOff";
    }

    static TParseTree SprSubCmdAt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("at"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdAt")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmdAt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("at"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdAt"), "SprSubCmdAt")(p);
                memo[tuple(`SprSubCmdAt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmdAt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("at"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdAt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("at"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdAt"), "SprSubCmdAt")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmdAt(GetName g)
    {
        return "XCBASIC.SprSubCmdAt";
    }

    static TParseTree SprSubCmdColor(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("color"), pegged.peg.discard!(WS), Expression), "XCBASIC.SprSubCmdColor")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmdColor`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("color"), pegged.peg.discard!(WS), Expression), "XCBASIC.SprSubCmdColor"), "SprSubCmdColor")(p);
                memo[tuple(`SprSubCmdColor`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmdColor(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("color"), pegged.peg.discard!(WS), Expression), "XCBASIC.SprSubCmdColor")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("color"), pegged.peg.discard!(WS), Expression), "XCBASIC.SprSubCmdColor"), "SprSubCmdColor")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmdColor(GetName g)
    {
        return "XCBASIC.SprSubCmdColor";
    }

    static TParseTree SprSubCmdHiresMulti(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hires"), pegged.peg.caseInsensitiveLiteral!("multi"), pegged.peg.caseInsensitiveLiteral!("lowcol"), pegged.peg.caseInsensitiveLiteral!("hicol")), "XCBASIC.SprSubCmdHiresMulti")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmdHiresMulti`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hires"), pegged.peg.caseInsensitiveLiteral!("multi"), pegged.peg.caseInsensitiveLiteral!("lowcol"), pegged.peg.caseInsensitiveLiteral!("hicol")), "XCBASIC.SprSubCmdHiresMulti"), "SprSubCmdHiresMulti")(p);
                memo[tuple(`SprSubCmdHiresMulti`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmdHiresMulti(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hires"), pegged.peg.caseInsensitiveLiteral!("multi"), pegged.peg.caseInsensitiveLiteral!("lowcol"), pegged.peg.caseInsensitiveLiteral!("hicol")), "XCBASIC.SprSubCmdHiresMulti")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hires"), pegged.peg.caseInsensitiveLiteral!("multi"), pegged.peg.caseInsensitiveLiteral!("lowcol"), pegged.peg.caseInsensitiveLiteral!("hicol")), "XCBASIC.SprSubCmdHiresMulti"), "SprSubCmdHiresMulti")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmdHiresMulti(GetName g)
    {
        return "XCBASIC.SprSubCmdHiresMulti";
    }

    static TParseTree SprSubCmdOnUnderBg(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.longest_match!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("under")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("background")), "XCBASIC.SprSubCmdOnUnderBg")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmdOnUnderBg`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.longest_match!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("under")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("background")), "XCBASIC.SprSubCmdOnUnderBg"), "SprSubCmdOnUnderBg")(p);
                memo[tuple(`SprSubCmdOnUnderBg`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmdOnUnderBg(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.longest_match!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("under")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("background")), "XCBASIC.SprSubCmdOnUnderBg")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.longest_match!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("under")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("background")), "XCBASIC.SprSubCmdOnUnderBg"), "SprSubCmdOnUnderBg")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmdOnUnderBg(GetName g)
    {
        return "XCBASIC.SprSubCmdOnUnderBg";
    }

    static TParseTree SprSubCmdZDepth(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("zdepth"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.SprSubCmdZDepth")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmdZDepth`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("zdepth"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.SprSubCmdZDepth"), "SprSubCmdZDepth")(p);
                memo[tuple(`SprSubCmdZDepth`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmdZDepth(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("zdepth"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.SprSubCmdZDepth")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("zdepth"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.SprSubCmdZDepth"), "SprSubCmdZDepth")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmdZDepth(GetName g)
    {
        return "XCBASIC.SprSubCmdZDepth";
    }

    static TParseTree SprSubCmdShape(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shape"), pegged.peg.discard!(WS), Expression), "XCBASIC.SprSubCmdShape")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmdShape`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shape"), pegged.peg.discard!(WS), Expression), "XCBASIC.SprSubCmdShape"), "SprSubCmdShape")(p);
                memo[tuple(`SprSubCmdShape`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmdShape(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shape"), pegged.peg.discard!(WS), Expression), "XCBASIC.SprSubCmdShape")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("shape"), pegged.peg.discard!(WS), Expression), "XCBASIC.SprSubCmdShape"), "SprSubCmdShape")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmdShape(GetName g)
    {
        return "XCBASIC.SprSubCmdShape";
    }

    static TParseTree SprSubCmdXYSize(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("xysize"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdXYSize")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmdXYSize`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("xysize"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdXYSize"), "SprSubCmdXYSize")(p);
                memo[tuple(`SprSubCmdXYSize`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmdXYSize(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("xysize"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdXYSize")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("xysize"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdXYSize"), "SprSubCmdXYSize")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmdXYSize(GetName g)
    {
        return "XCBASIC.SprSubCmdXYSize";
    }

    static TParseTree SprSubCmdZYFlip(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("xyflip"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdZYFlip")(p);
        }
        else
        {
            if (auto m = tuple(`SprSubCmdZYFlip`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("xyflip"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdZYFlip"), "SprSubCmdZYFlip")(p);
                memo[tuple(`SprSubCmdZYFlip`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SprSubCmdZYFlip(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("xyflip"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdZYFlip")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("xyflip"), pegged.peg.discard!(WS), ExprList), "XCBASIC.SprSubCmdZYFlip"), "SprSubCmdZYFlip")(TParseTree("", false,[], s));
        }
    }
    static string SprSubCmdZYFlip(GetName g)
    {
        return "XCBASIC.SprSubCmdZYFlip";
    }

    static TParseTree Sprite_clear_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear")), "XCBASIC.Sprite_clear_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Sprite_clear_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear")), "XCBASIC.Sprite_clear_stmt"), "Sprite_clear_stmt")(p);
                memo[tuple(`Sprite_clear_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sprite_clear_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear")), "XCBASIC.Sprite_clear_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear")), "XCBASIC.Sprite_clear_stmt"), "Sprite_clear_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Sprite_clear_stmt(GetName g)
    {
        return "XCBASIC.Sprite_clear_stmt";
    }

    static TParseTree Sprite_clearhit_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("hit")), "XCBASIC.Sprite_clearhit_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Sprite_clearhit_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("hit")), "XCBASIC.Sprite_clearhit_stmt"), "Sprite_clearhit_stmt")(p);
                memo[tuple(`Sprite_clearhit_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sprite_clearhit_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("hit")), "XCBASIC.Sprite_clearhit_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("hit")), "XCBASIC.Sprite_clearhit_stmt"), "Sprite_clearhit_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Sprite_clearhit_stmt(GetName g)
    {
        return "XCBASIC.Sprite_clearhit_stmt";
    }

    static TParseTree Sprite_multicolor_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("multicolor"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Sprite_multicolor_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Sprite_multicolor_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("multicolor"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Sprite_multicolor_stmt"), "Sprite_multicolor_stmt")(p);
                memo[tuple(`Sprite_multicolor_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sprite_multicolor_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("multicolor"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Sprite_multicolor_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("multicolor"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Sprite_multicolor_stmt"), "Sprite_multicolor_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Sprite_multicolor_stmt(GetName g)
    {
        return "XCBASIC.Sprite_multicolor_stmt";
    }

    static TParseTree Border_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("border"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Border_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Border_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("border"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Border_stmt"), "Border_stmt")(p);
                memo[tuple(`Border_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Border_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("border"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Border_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("border"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Border_stmt"), "Border_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Border_stmt(GetName g)
    {
        return "XCBASIC.Border_stmt";
    }

    static TParseTree Background_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Background_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Background_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Background_stmt"), "Background_stmt")(p);
                memo[tuple(`Background_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Background_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Background_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Background_stmt"), "Background_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Background_stmt(GetName g)
    {
        return "XCBASIC.Background_stmt";
    }

    static TParseTree Sound_clear_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sound"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear")), "XCBASIC.Sound_clear_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Sound_clear_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sound"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear")), "XCBASIC.Sound_clear_stmt"), "Sound_clear_stmt")(p);
                memo[tuple(`Sound_clear_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sound_clear_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sound"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear")), "XCBASIC.Sound_clear_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("sound"), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("clear")), "XCBASIC.Sound_clear_stmt"), "Sound_clear_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Sound_clear_stmt(GetName g)
    {
        return "XCBASIC.Sound_clear_stmt";
    }

    static TParseTree Volume_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.discard!(WS), Expression), "XCBASIC.Volume_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Volume_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.discard!(WS), Expression), "XCBASIC.Volume_stmt"), "Volume_stmt")(p);
                memo[tuple(`Volume_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Volume_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.discard!(WS), Expression), "XCBASIC.Volume_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.discard!(WS), Expression), "XCBASIC.Volume_stmt"), "Volume_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Volume_stmt(GetName g)
    {
        return "XCBASIC.Volume_stmt";
    }

    static TParseTree Voice_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("voice"), pegged.peg.discard!(WS), Expression, pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), VoiceSubCmd))), "XCBASIC.Voice_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Voice_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("voice"), pegged.peg.discard!(WS), Expression, pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), VoiceSubCmd))), "XCBASIC.Voice_stmt"), "Voice_stmt")(p);
                memo[tuple(`Voice_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Voice_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("voice"), pegged.peg.discard!(WS), Expression, pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), VoiceSubCmd))), "XCBASIC.Voice_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("voice"), pegged.peg.discard!(WS), Expression, pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), VoiceSubCmd))), "XCBASIC.Voice_stmt"), "Voice_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Voice_stmt(GetName g)
    {
        return "XCBASIC.Voice_stmt";
    }

    static TParseTree VoiceSubCmd(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(VoiceSubCmdOnOff, VoiceSubCmdADSR, VoiceSubCmdTone, VoiceSubCmdWave, VoiceSubCmdPulse, VoiceSubCmdFilterOnOff, VoiceSubCmdVolume), "XCBASIC.VoiceSubCmd")(p);
        }
        else
        {
            if (auto m = tuple(`VoiceSubCmd`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(VoiceSubCmdOnOff, VoiceSubCmdADSR, VoiceSubCmdTone, VoiceSubCmdWave, VoiceSubCmdPulse, VoiceSubCmdFilterOnOff, VoiceSubCmdVolume), "XCBASIC.VoiceSubCmd"), "VoiceSubCmd")(p);
                memo[tuple(`VoiceSubCmd`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VoiceSubCmd(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(VoiceSubCmdOnOff, VoiceSubCmdADSR, VoiceSubCmdTone, VoiceSubCmdWave, VoiceSubCmdPulse, VoiceSubCmdFilterOnOff, VoiceSubCmdVolume), "XCBASIC.VoiceSubCmd")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(VoiceSubCmdOnOff, VoiceSubCmdADSR, VoiceSubCmdTone, VoiceSubCmdWave, VoiceSubCmdPulse, VoiceSubCmdFilterOnOff, VoiceSubCmdVolume), "XCBASIC.VoiceSubCmd"), "VoiceSubCmd")(TParseTree("", false,[], s));
        }
    }
    static string VoiceSubCmd(GetName g)
    {
        return "XCBASIC.VoiceSubCmd";
    }

    static TParseTree VoiceSubCmdOnOff(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"), pegged.peg.caseInsensitiveLiteral!("left"), pegged.peg.caseInsensitiveLiteral!("right")), "XCBASIC.VoiceSubCmdOnOff")(p);
        }
        else
        {
            if (auto m = tuple(`VoiceSubCmdOnOff`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"), pegged.peg.caseInsensitiveLiteral!("left"), pegged.peg.caseInsensitiveLiteral!("right")), "XCBASIC.VoiceSubCmdOnOff"), "VoiceSubCmdOnOff")(p);
                memo[tuple(`VoiceSubCmdOnOff`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VoiceSubCmdOnOff(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"), pegged.peg.caseInsensitiveLiteral!("left"), pegged.peg.caseInsensitiveLiteral!("right")), "XCBASIC.VoiceSubCmdOnOff")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"), pegged.peg.caseInsensitiveLiteral!("left"), pegged.peg.caseInsensitiveLiteral!("right")), "XCBASIC.VoiceSubCmdOnOff"), "VoiceSubCmdOnOff")(TParseTree("", false,[], s));
        }
    }
    static string VoiceSubCmdOnOff(GetName g)
    {
        return "XCBASIC.VoiceSubCmdOnOff";
    }

    static TParseTree VoiceSubCmdADSR(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("adsr"), pegged.peg.discard!(WS), ExprList), "XCBASIC.VoiceSubCmdADSR")(p);
        }
        else
        {
            if (auto m = tuple(`VoiceSubCmdADSR`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("adsr"), pegged.peg.discard!(WS), ExprList), "XCBASIC.VoiceSubCmdADSR"), "VoiceSubCmdADSR")(p);
                memo[tuple(`VoiceSubCmdADSR`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VoiceSubCmdADSR(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("adsr"), pegged.peg.discard!(WS), ExprList), "XCBASIC.VoiceSubCmdADSR")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("adsr"), pegged.peg.discard!(WS), ExprList), "XCBASIC.VoiceSubCmdADSR"), "VoiceSubCmdADSR")(TParseTree("", false,[], s));
        }
    }
    static string VoiceSubCmdADSR(GetName g)
    {
        return "XCBASIC.VoiceSubCmdADSR";
    }

    static TParseTree VoiceSubCmdTone(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("tone"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdTone")(p);
        }
        else
        {
            if (auto m = tuple(`VoiceSubCmdTone`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("tone"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdTone"), "VoiceSubCmdTone")(p);
                memo[tuple(`VoiceSubCmdTone`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VoiceSubCmdTone(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("tone"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdTone")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("tone"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdTone"), "VoiceSubCmdTone")(TParseTree("", false,[], s));
        }
    }
    static string VoiceSubCmdTone(GetName g)
    {
        return "XCBASIC.VoiceSubCmdTone";
    }

    static TParseTree VoiceSubCmdWave(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("wave"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("saw"), pegged.peg.caseInsensitiveLiteral!("tri"), pegged.peg.caseInsensitiveLiteral!("pulse"), pegged.peg.caseInsensitiveLiteral!("noise"))), "XCBASIC.VoiceSubCmdWave")(p);
        }
        else
        {
            if (auto m = tuple(`VoiceSubCmdWave`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("wave"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("saw"), pegged.peg.caseInsensitiveLiteral!("tri"), pegged.peg.caseInsensitiveLiteral!("pulse"), pegged.peg.caseInsensitiveLiteral!("noise"))), "XCBASIC.VoiceSubCmdWave"), "VoiceSubCmdWave")(p);
                memo[tuple(`VoiceSubCmdWave`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VoiceSubCmdWave(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("wave"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("saw"), pegged.peg.caseInsensitiveLiteral!("tri"), pegged.peg.caseInsensitiveLiteral!("pulse"), pegged.peg.caseInsensitiveLiteral!("noise"))), "XCBASIC.VoiceSubCmdWave")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("wave"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("saw"), pegged.peg.caseInsensitiveLiteral!("tri"), pegged.peg.caseInsensitiveLiteral!("pulse"), pegged.peg.caseInsensitiveLiteral!("noise"))), "XCBASIC.VoiceSubCmdWave"), "VoiceSubCmdWave")(TParseTree("", false,[], s));
        }
    }
    static string VoiceSubCmdWave(GetName g)
    {
        return "XCBASIC.VoiceSubCmdWave";
    }

    static TParseTree VoiceSubCmdPulse(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("pulse"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdPulse")(p);
        }
        else
        {
            if (auto m = tuple(`VoiceSubCmdPulse`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("pulse"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdPulse"), "VoiceSubCmdPulse")(p);
                memo[tuple(`VoiceSubCmdPulse`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VoiceSubCmdPulse(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("pulse"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdPulse")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("pulse"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdPulse"), "VoiceSubCmdPulse")(TParseTree("", false,[], s));
        }
    }
    static string VoiceSubCmdPulse(GetName g)
    {
        return "XCBASIC.VoiceSubCmdPulse";
    }

    static TParseTree VoiceSubCmdVolume(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdVolume")(p);
        }
        else
        {
            if (auto m = tuple(`VoiceSubCmdVolume`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdVolume"), "VoiceSubCmdVolume")(p);
                memo[tuple(`VoiceSubCmdVolume`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VoiceSubCmdVolume(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdVolume")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.discard!(WS), Expression), "XCBASIC.VoiceSubCmdVolume"), "VoiceSubCmdVolume")(TParseTree("", false,[], s));
        }
    }
    static string VoiceSubCmdVolume(GetName g)
    {
        return "XCBASIC.VoiceSubCmdVolume";
    }

    static TParseTree VoiceSubCmdFilterOnOff(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"))), "XCBASIC.VoiceSubCmdFilterOnOff")(p);
        }
        else
        {
            if (auto m = tuple(`VoiceSubCmdFilterOnOff`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"))), "XCBASIC.VoiceSubCmdFilterOnOff"), "VoiceSubCmdFilterOnOff")(p);
                memo[tuple(`VoiceSubCmdFilterOnOff`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VoiceSubCmdFilterOnOff(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"))), "XCBASIC.VoiceSubCmdFilterOnOff")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("off"))), "XCBASIC.VoiceSubCmdFilterOnOff"), "VoiceSubCmdFilterOnOff")(TParseTree("", false,[], s));
        }
    }
    static string VoiceSubCmdFilterOnOff(GetName g)
    {
        return "XCBASIC.VoiceSubCmdFilterOnOff";
    }

    static TParseTree Filter_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), FilterSubCmd))), "XCBASIC.Filter_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Filter_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), FilterSubCmd))), "XCBASIC.Filter_stmt"), "Filter_stmt")(p);
                memo[tuple(`Filter_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Filter_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), FilterSubCmd))), "XCBASIC.Filter_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), FilterSubCmd))), "XCBASIC.Filter_stmt"), "Filter_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Filter_stmt(GetName g)
    {
        return "XCBASIC.Filter_stmt";
    }

    static TParseTree FilterSubCmd(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(FilterSubCmdCutoff, FilterSubCmdResonance, FilterSubCmdPass), "XCBASIC.FilterSubCmd")(p);
        }
        else
        {
            if (auto m = tuple(`FilterSubCmd`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(FilterSubCmdCutoff, FilterSubCmdResonance, FilterSubCmdPass), "XCBASIC.FilterSubCmd"), "FilterSubCmd")(p);
                memo[tuple(`FilterSubCmd`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FilterSubCmd(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(FilterSubCmdCutoff, FilterSubCmdResonance, FilterSubCmdPass), "XCBASIC.FilterSubCmd")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(FilterSubCmdCutoff, FilterSubCmdResonance, FilterSubCmdPass), "XCBASIC.FilterSubCmd"), "FilterSubCmd")(TParseTree("", false,[], s));
        }
    }
    static string FilterSubCmd(GetName g)
    {
        return "XCBASIC.FilterSubCmd";
    }

    static TParseTree FilterSubCmdCutoff(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("cutoff"), pegged.peg.discard!(WS), Expression), "XCBASIC.FilterSubCmdCutoff")(p);
        }
        else
        {
            if (auto m = tuple(`FilterSubCmdCutoff`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("cutoff"), pegged.peg.discard!(WS), Expression), "XCBASIC.FilterSubCmdCutoff"), "FilterSubCmdCutoff")(p);
                memo[tuple(`FilterSubCmdCutoff`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FilterSubCmdCutoff(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("cutoff"), pegged.peg.discard!(WS), Expression), "XCBASIC.FilterSubCmdCutoff")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("cutoff"), pegged.peg.discard!(WS), Expression), "XCBASIC.FilterSubCmdCutoff"), "FilterSubCmdCutoff")(TParseTree("", false,[], s));
        }
    }
    static string FilterSubCmdCutoff(GetName g)
    {
        return "XCBASIC.FilterSubCmdCutoff";
    }

    static TParseTree FilterSubCmdResonance(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("resonance"), pegged.peg.discard!(WS), Expression), "XCBASIC.FilterSubCmdResonance")(p);
        }
        else
        {
            if (auto m = tuple(`FilterSubCmdResonance`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("resonance"), pegged.peg.discard!(WS), Expression), "XCBASIC.FilterSubCmdResonance"), "FilterSubCmdResonance")(p);
                memo[tuple(`FilterSubCmdResonance`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FilterSubCmdResonance(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("resonance"), pegged.peg.discard!(WS), Expression), "XCBASIC.FilterSubCmdResonance")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("resonance"), pegged.peg.discard!(WS), Expression), "XCBASIC.FilterSubCmdResonance"), "FilterSubCmdResonance")(TParseTree("", false,[], s));
        }
    }
    static string FilterSubCmdResonance(GetName g)
    {
        return "XCBASIC.FilterSubCmdResonance";
    }

    static TParseTree FilterSubCmdPass(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("low"), pegged.peg.caseInsensitiveLiteral!("band"), pegged.peg.caseInsensitiveLiteral!("high")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("pass")), "XCBASIC.FilterSubCmdPass")(p);
        }
        else
        {
            if (auto m = tuple(`FilterSubCmdPass`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("low"), pegged.peg.caseInsensitiveLiteral!("band"), pegged.peg.caseInsensitiveLiteral!("high")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("pass")), "XCBASIC.FilterSubCmdPass"), "FilterSubCmdPass")(p);
                memo[tuple(`FilterSubCmdPass`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FilterSubCmdPass(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("low"), pegged.peg.caseInsensitiveLiteral!("band"), pegged.peg.caseInsensitiveLiteral!("high")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("pass")), "XCBASIC.FilterSubCmdPass")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("low"), pegged.peg.caseInsensitiveLiteral!("band"), pegged.peg.caseInsensitiveLiteral!("high")), pegged.peg.discard!(WS), pegged.peg.caseInsensitiveLiteral!("pass")), "XCBASIC.FilterSubCmdPass"), "FilterSubCmdPass")(TParseTree("", false,[], s));
        }
    }
    static string FilterSubCmdPass(GetName g)
    {
        return "XCBASIC.FilterSubCmdPass";
    }

    static TParseTree Charset_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("charset"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("rom"), pegged.peg.caseInsensitiveLiteral!("ram")))), pegged.peg.discard!(WS), Expression), "XCBASIC.Charset_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Charset_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("charset"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("rom"), pegged.peg.caseInsensitiveLiteral!("ram")))), pegged.peg.discard!(WS), Expression), "XCBASIC.Charset_stmt"), "Charset_stmt")(p);
                memo[tuple(`Charset_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Charset_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("charset"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("rom"), pegged.peg.caseInsensitiveLiteral!("ram")))), pegged.peg.discard!(WS), Expression), "XCBASIC.Charset_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("charset"), pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("rom"), pegged.peg.caseInsensitiveLiteral!("ram")))), pegged.peg.discard!(WS), Expression), "XCBASIC.Charset_stmt"), "Charset_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Charset_stmt(GetName g)
    {
        return "XCBASIC.Charset_stmt";
    }

    static TParseTree Scroll_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("h"), pegged.peg.caseInsensitiveLiteral!("v")), pegged.peg.caseInsensitiveLiteral!("scroll"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Scroll_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Scroll_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("h"), pegged.peg.caseInsensitiveLiteral!("v")), pegged.peg.caseInsensitiveLiteral!("scroll"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Scroll_stmt"), "Scroll_stmt")(p);
                memo[tuple(`Scroll_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Scroll_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("h"), pegged.peg.caseInsensitiveLiteral!("v")), pegged.peg.caseInsensitiveLiteral!("scroll"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Scroll_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("h"), pegged.peg.caseInsensitiveLiteral!("v")), pegged.peg.caseInsensitiveLiteral!("scroll"), pegged.peg.discard!(WS), ExprList), "XCBASIC.Scroll_stmt"), "Scroll_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Scroll_stmt(GetName g)
    {
        return "XCBASIC.Scroll_stmt";
    }

    static TParseTree VMode_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("vmode"), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), VModeSubCmd))), "XCBASIC.VMode_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`VMode_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("vmode"), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), VModeSubCmd))), "XCBASIC.VMode_stmt"), "VMode_stmt")(p);
                memo[tuple(`VMode_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VMode_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("vmode"), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), VModeSubCmd))), "XCBASIC.VMode_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("vmode"), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.discard!(WS), VModeSubCmd))), "XCBASIC.VMode_stmt"), "VMode_stmt")(TParseTree("", false,[], s));
        }
    }
    static string VMode_stmt(GetName g)
    {
        return "XCBASIC.VMode_stmt";
    }

    static TParseTree VModeSubCmd(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(VModeSubCmdTextBitmap, VModeSubCmdColor, VModeSubCmdRsel, VModeSubCmdCsel, VModeSubCmdExpression), "XCBASIC.VModeSubCmd")(p);
        }
        else
        {
            if (auto m = tuple(`VModeSubCmd`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(VModeSubCmdTextBitmap, VModeSubCmdColor, VModeSubCmdRsel, VModeSubCmdCsel, VModeSubCmdExpression), "XCBASIC.VModeSubCmd"), "VModeSubCmd")(p);
                memo[tuple(`VModeSubCmd`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VModeSubCmd(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(VModeSubCmdTextBitmap, VModeSubCmdColor, VModeSubCmdRsel, VModeSubCmdCsel, VModeSubCmdExpression), "XCBASIC.VModeSubCmd")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(VModeSubCmdTextBitmap, VModeSubCmdColor, VModeSubCmdRsel, VModeSubCmdCsel, VModeSubCmdExpression), "XCBASIC.VModeSubCmd"), "VModeSubCmd")(TParseTree("", false,[], s));
        }
    }
    static string VModeSubCmd(GetName g)
    {
        return "XCBASIC.VModeSubCmd";
    }

    static TParseTree VModeSubCmdExpression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(Expression, "XCBASIC.VModeSubCmdExpression")(p);
        }
        else
        {
            if (auto m = tuple(`VModeSubCmdExpression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(Expression, "XCBASIC.VModeSubCmdExpression"), "VModeSubCmdExpression")(p);
                memo[tuple(`VModeSubCmdExpression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VModeSubCmdExpression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(Expression, "XCBASIC.VModeSubCmdExpression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(Expression, "XCBASIC.VModeSubCmdExpression"), "VModeSubCmdExpression")(TParseTree("", false,[], s));
        }
    }
    static string VModeSubCmdExpression(GetName g)
    {
        return "XCBASIC.VModeSubCmdExpression";
    }

    static TParseTree VModeSubCmdTextBitmap(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("text"), pegged.peg.caseInsensitiveLiteral!("bitmap"), pegged.peg.caseInsensitiveLiteral!("ext")), "XCBASIC.VModeSubCmdTextBitmap")(p);
        }
        else
        {
            if (auto m = tuple(`VModeSubCmdTextBitmap`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("text"), pegged.peg.caseInsensitiveLiteral!("bitmap"), pegged.peg.caseInsensitiveLiteral!("ext")), "XCBASIC.VModeSubCmdTextBitmap"), "VModeSubCmdTextBitmap")(p);
                memo[tuple(`VModeSubCmdTextBitmap`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VModeSubCmdTextBitmap(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("text"), pegged.peg.caseInsensitiveLiteral!("bitmap"), pegged.peg.caseInsensitiveLiteral!("ext")), "XCBASIC.VModeSubCmdTextBitmap")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("text"), pegged.peg.caseInsensitiveLiteral!("bitmap"), pegged.peg.caseInsensitiveLiteral!("ext")), "XCBASIC.VModeSubCmdTextBitmap"), "VModeSubCmdTextBitmap")(TParseTree("", false,[], s));
        }
    }
    static string VModeSubCmdTextBitmap(GetName g)
    {
        return "XCBASIC.VModeSubCmdTextBitmap";
    }

    static TParseTree VModeSubCmdColor(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hires"), pegged.peg.caseInsensitiveLiteral!("multi")), "XCBASIC.VModeSubCmdColor")(p);
        }
        else
        {
            if (auto m = tuple(`VModeSubCmdColor`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hires"), pegged.peg.caseInsensitiveLiteral!("multi")), "XCBASIC.VModeSubCmdColor"), "VModeSubCmdColor")(p);
                memo[tuple(`VModeSubCmdColor`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VModeSubCmdColor(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hires"), pegged.peg.caseInsensitiveLiteral!("multi")), "XCBASIC.VModeSubCmdColor")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hires"), pegged.peg.caseInsensitiveLiteral!("multi")), "XCBASIC.VModeSubCmdColor"), "VModeSubCmdColor")(TParseTree("", false,[], s));
        }
    }
    static string VModeSubCmdColor(GetName g)
    {
        return "XCBASIC.VModeSubCmdColor";
    }

    static TParseTree VModeSubCmdRsel(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("rows"), pegged.peg.discard!(WS), Expression), "XCBASIC.VModeSubCmdRsel")(p);
        }
        else
        {
            if (auto m = tuple(`VModeSubCmdRsel`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("rows"), pegged.peg.discard!(WS), Expression), "XCBASIC.VModeSubCmdRsel"), "VModeSubCmdRsel")(p);
                memo[tuple(`VModeSubCmdRsel`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VModeSubCmdRsel(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("rows"), pegged.peg.discard!(WS), Expression), "XCBASIC.VModeSubCmdRsel")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("rows"), pegged.peg.discard!(WS), Expression), "XCBASIC.VModeSubCmdRsel"), "VModeSubCmdRsel")(TParseTree("", false,[], s));
        }
    }
    static string VModeSubCmdRsel(GetName g)
    {
        return "XCBASIC.VModeSubCmdRsel";
    }

    static TParseTree VModeSubCmdCsel(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("cols"), pegged.peg.discard!(WS), Expression), "XCBASIC.VModeSubCmdCsel")(p);
        }
        else
        {
            if (auto m = tuple(`VModeSubCmdCsel`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("cols"), pegged.peg.discard!(WS), Expression), "XCBASIC.VModeSubCmdCsel"), "VModeSubCmdCsel")(p);
                memo[tuple(`VModeSubCmdCsel`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VModeSubCmdCsel(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("cols"), pegged.peg.discard!(WS), Expression), "XCBASIC.VModeSubCmdCsel")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("cols"), pegged.peg.discard!(WS), Expression), "XCBASIC.VModeSubCmdCsel"), "VModeSubCmdCsel")(TParseTree("", false,[], s));
        }
    }
    static string VModeSubCmdCsel(GetName g)
    {
        return "XCBASIC.VModeSubCmdCsel";
    }

    static TParseTree ExprList(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Expression, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.ExprList")(p);
        }
        else
        {
            if (auto m = tuple(`ExprList`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Expression, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.ExprList"), "ExprList")(p);
                memo[tuple(`ExprList`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree ExprList(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Expression, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.ExprList")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Expression, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression))), "XCBASIC.ExprList"), "ExprList")(TParseTree("", false,[], s));
        }
    }
    static string ExprList(GetName g)
    {
        return "XCBASIC.ExprList";
    }

    static TParseTree AccessorList(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Accessor, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor))), "XCBASIC.AccessorList")(p);
        }
        else
        {
            if (auto m = tuple(`AccessorList`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Accessor, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor))), "XCBASIC.AccessorList"), "AccessorList")(p);
                memo[tuple(`AccessorList`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree AccessorList(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Accessor, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor))), "XCBASIC.AccessorList")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Accessor, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor))), "XCBASIC.AccessorList"), "AccessorList")(TParseTree("", false,[], s));
        }
    }
    static string AccessorList(GetName g)
    {
        return "XCBASIC.AccessorList";
    }

    static TParseTree PrintableList(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(TabSep, NlSupp), pegged.peg.discard!(pegged.peg.option!(WS)), Expression)), pegged.peg.option!(NlSupp)), "XCBASIC.PrintableList")(p);
        }
        else
        {
            if (auto m = tuple(`PrintableList`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(TabSep, NlSupp), pegged.peg.discard!(pegged.peg.option!(WS)), Expression)), pegged.peg.option!(NlSupp)), "XCBASIC.PrintableList"), "PrintableList")(p);
                memo[tuple(`PrintableList`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree PrintableList(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(TabSep, NlSupp), pegged.peg.discard!(pegged.peg.option!(WS)), Expression)), pegged.peg.option!(NlSupp)), "XCBASIC.PrintableList")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(TabSep, NlSupp), pegged.peg.discard!(pegged.peg.option!(WS)), Expression)), pegged.peg.option!(NlSupp)), "XCBASIC.PrintableList"), "PrintableList")(TParseTree("", false,[], s));
        }
    }
    static string PrintableList(GetName g)
    {
        return "XCBASIC.PrintableList";
    }

    static TParseTree TabSep(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!(","), "XCBASIC.TabSep")(p);
        }
        else
        {
            if (auto m = tuple(`TabSep`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!(","), "XCBASIC.TabSep"), "TabSep")(p);
                memo[tuple(`TabSep`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree TabSep(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!(","), "XCBASIC.TabSep")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!(","), "XCBASIC.TabSep"), "TabSep")(TParseTree("", false,[], s));
        }
    }
    static string TabSep(GetName g)
    {
        return "XCBASIC.TabSep";
    }

    static TParseTree NlSupp(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!(";"), "XCBASIC.NlSupp")(p);
        }
        else
        {
            if (auto m = tuple(`NlSupp`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!(";"), "XCBASIC.NlSupp"), "NlSupp")(p);
                memo[tuple(`NlSupp`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree NlSupp(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!(";"), "XCBASIC.NlSupp")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!(";"), "XCBASIC.NlSupp"), "NlSupp")(TParseTree("", false,[], s));
        }
    }
    static string NlSupp(GetName g)
    {
        return "XCBASIC.NlSupp";
    }

    static TParseTree VarList(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Var, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Var))), "XCBASIC.VarList")(p);
        }
        else
        {
            if (auto m = tuple(`VarList`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Var, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Var))), "XCBASIC.VarList"), "VarList")(p);
                memo[tuple(`VarList`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VarList(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Var, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Var))), "XCBASIC.VarList")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Var, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Var))), "XCBASIC.VarList"), "VarList")(TParseTree("", false,[], s));
        }
    }
    static string VarList(GetName g)
    {
        return "XCBASIC.VarList";
    }

    static TParseTree Datalist(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(Number, String, Label_ref), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, String, Label_ref), pegged.peg.discard!(pegged.peg.option!(WS))))), "XCBASIC.Datalist")(p);
        }
        else
        {
            if (auto m = tuple(`Datalist`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(Number, String, Label_ref), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, String, Label_ref), pegged.peg.discard!(pegged.peg.option!(WS))))), "XCBASIC.Datalist"), "Datalist")(p);
                memo[tuple(`Datalist`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Datalist(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(Number, String, Label_ref), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, String, Label_ref), pegged.peg.discard!(pegged.peg.option!(WS))))), "XCBASIC.Datalist")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(Number, String, Label_ref), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, String, Label_ref), pegged.peg.discard!(pegged.peg.option!(WS))))), "XCBASIC.Datalist"), "Datalist")(TParseTree("", false,[], s));
        }
    }
    static string Datalist(GetName g)
    {
        return "XCBASIC.Datalist";
    }

    static TParseTree Expression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Relation, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), BW_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Relation))), "XCBASIC.Expression")(p);
        }
        else
        {
            if (blockMemoAtPos.canFind(p.end))
                return hooked!(pegged.peg.defined!(pegged.peg.and!(Relation, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), BW_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Relation))), "XCBASIC.Expression"), "Expression")(p);
            if (auto m = tuple(`Expression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Relation, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), BW_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Relation))), "XCBASIC.Expression"), "Expression")(p);
                memo[tuple(`Expression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Expression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Relation, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), BW_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Relation))), "XCBASIC.Expression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Relation, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), BW_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Relation))), "XCBASIC.Expression"), "Expression")(TParseTree("", false,[], s));
        }
    }
    static string Expression(GetName g)
    {
        return "XCBASIC.Expression";
    }

    static TParseTree Relation(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Simplexp, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), REL_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Simplexp))), "XCBASIC.Relation")(p);
        }
        else
        {
            if (blockMemoAtPos.canFind(p.end))
                return hooked!(pegged.peg.defined!(pegged.peg.and!(Simplexp, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), REL_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Simplexp))), "XCBASIC.Relation"), "Relation")(p);
            if (auto m = tuple(`Relation`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Simplexp, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), REL_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Simplexp))), "XCBASIC.Relation"), "Relation")(p);
                memo[tuple(`Relation`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Relation(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Simplexp, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), REL_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Simplexp))), "XCBASIC.Relation")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Simplexp, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), REL_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Simplexp))), "XCBASIC.Relation"), "Relation")(TParseTree("", false,[], s));
        }
    }
    static string Relation(GetName g)
    {
        return "XCBASIC.Relation";
    }

    static TParseTree Simplexp(TParseTree p)
    {
        if(__ctfe)
        {
            assert(false, "Simplexp is left-recursive, which is not supported at compile-time. Consider using asModule().");
        }
        else
        {
            static TParseTree[size_t /*position*/] seed;
            if (auto s = p.end in seed)
                return *s;
            if (!blockMemoAtPos.canFind(p.end))
                if (auto m = tuple(`Simplexp`, p.end) in memo)
                    return *m;
            auto current = fail(p);
            seed[p.end] = current;
            blockMemoAtPos ~= p.end;
            while (true)
            {
                auto result = hooked!(pegged.peg.defined!(pegged.peg.and!(Term, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), E_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Term))), "XCBASIC.Simplexp"), "Simplexp")(p);
                if (result.end > current.end ||
                    (!current.successful && result.successful) /* null-match */)
                {
                    current = result;
                    seed[p.end] = current;
                } else {
                    seed.remove(p.end);
                    assert(blockMemoAtPos.canFind(p.end));
                    blockMemoAtPos = blockMemoAtPos.remove(countUntil(blockMemoAtPos, p.end));
                    memo[tuple(`Simplexp`, p.end)] = current;
                    return current;
                }
            }
        }
    }

    static TParseTree Simplexp(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Term, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), E_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Term))), "XCBASIC.Simplexp")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Term, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), E_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Term))), "XCBASIC.Simplexp"), "Simplexp")(TParseTree("", false,[], s));
        }
    }
    static string Simplexp(GetName g)
    {
        return "XCBASIC.Simplexp";
    }

    static TParseTree Term(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Factor, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), T_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Factor))), "XCBASIC.Term")(p);
        }
        else
        {
            if (blockMemoAtPos.canFind(p.end))
                return hooked!(pegged.peg.defined!(pegged.peg.and!(Factor, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), T_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Factor))), "XCBASIC.Term"), "Term")(p);
            if (auto m = tuple(`Term`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Factor, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), T_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Factor))), "XCBASIC.Term"), "Term")(p);
                memo[tuple(`Term`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Term(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Factor, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), T_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Factor))), "XCBASIC.Term")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Factor, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), T_OP, pegged.peg.discard!(pegged.peg.option!(WS)), Factor))), "XCBASIC.Term"), "Term")(TParseTree("", false,[], s));
        }
    }
    static string Term(GetName g)
    {
        return "XCBASIC.Term";
    }

    static TParseTree Factor(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor), Number, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Parenthesis), String, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Address)), "XCBASIC.Factor")(p);
        }
        else
        {
            if (blockMemoAtPos.canFind(p.end))
                return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor), Number, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Parenthesis), String, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Address)), "XCBASIC.Factor"), "Factor")(p);
            if (auto m = tuple(`Factor`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor), Number, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Parenthesis), String, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Address)), "XCBASIC.Factor"), "Factor")(p);
                memo[tuple(`Factor`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Factor(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor), Number, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Parenthesis), String, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Address)), "XCBASIC.Factor")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Accessor), Number, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Parenthesis), String, pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Expression), pegged.peg.and!(pegged.peg.option!(UN_OP), pegged.peg.discard!(pegged.peg.option!(WS)), Address)), "XCBASIC.Factor"), "Factor")(TParseTree("", false,[], s));
        }
    }
    static string Factor(GetName g)
    {
        return "XCBASIC.Factor";
    }

    static TParseTree UN_OP(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("not"), pegged.peg.discard!(WS))), "XCBASIC.UN_OP")(p);
        }
        else
        {
            if (auto m = tuple(`UN_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("not"), pegged.peg.discard!(WS))), "XCBASIC.UN_OP"), "UN_OP")(p);
                memo[tuple(`UN_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree UN_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("not"), pegged.peg.discard!(WS))), "XCBASIC.UN_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("-"), pegged.peg.and!(pegged.peg.caseInsensitiveLiteral!("not"), pegged.peg.discard!(WS))), "XCBASIC.UN_OP"), "UN_OP")(TParseTree("", false,[], s));
        }
    }
    static string UN_OP(GetName g)
    {
        return "XCBASIC.UN_OP";
    }

    static TParseTree T_OP(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("*"), pegged.peg.literal!("/"), pegged.peg.caseInsensitiveLiteral!("mod")), "XCBASIC.T_OP")(p);
        }
        else
        {
            if (auto m = tuple(`T_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("*"), pegged.peg.literal!("/"), pegged.peg.caseInsensitiveLiteral!("mod")), "XCBASIC.T_OP"), "T_OP")(p);
                memo[tuple(`T_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree T_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("*"), pegged.peg.literal!("/"), pegged.peg.caseInsensitiveLiteral!("mod")), "XCBASIC.T_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.literal!("*"), pegged.peg.literal!("/"), pegged.peg.caseInsensitiveLiteral!("mod")), "XCBASIC.T_OP"), "T_OP")(TParseTree("", false,[], s));
        }
    }
    static string T_OP(GetName g)
    {
        return "XCBASIC.T_OP";
    }

    static TParseTree E_OP(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("+", "-"), "XCBASIC.E_OP")(p);
        }
        else
        {
            if (auto m = tuple(`E_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("+", "-"), "XCBASIC.E_OP"), "E_OP")(p);
                memo[tuple(`E_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree E_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("+", "-"), "XCBASIC.E_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("+", "-"), "XCBASIC.E_OP"), "E_OP")(TParseTree("", false,[], s));
        }
    }
    static string E_OP(GetName g)
    {
        return "XCBASIC.E_OP";
    }

    static TParseTree BW_OP(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("and"), pegged.peg.caseInsensitiveLiteral!("or"), pegged.peg.caseInsensitiveLiteral!("xor")), "XCBASIC.BW_OP")(p);
        }
        else
        {
            if (auto m = tuple(`BW_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("and"), pegged.peg.caseInsensitiveLiteral!("or"), pegged.peg.caseInsensitiveLiteral!("xor")), "XCBASIC.BW_OP"), "BW_OP")(p);
                memo[tuple(`BW_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree BW_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("and"), pegged.peg.caseInsensitiveLiteral!("or"), pegged.peg.caseInsensitiveLiteral!("xor")), "XCBASIC.BW_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("and"), pegged.peg.caseInsensitiveLiteral!("or"), pegged.peg.caseInsensitiveLiteral!("xor")), "XCBASIC.BW_OP"), "BW_OP")(TParseTree("", false,[], s));
        }
    }
    static string BW_OP(GetName g)
    {
        return "XCBASIC.BW_OP";
    }

    static TParseTree REL_OP(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("<=", "<>", "<", "=", ">=", ">"), "XCBASIC.REL_OP")(p);
        }
        else
        {
            if (auto m = tuple(`REL_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("<=", "<>", "<", "=", ">=", ">"), "XCBASIC.REL_OP"), "REL_OP")(p);
                memo[tuple(`REL_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree REL_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("<=", "<>", "<", "=", ">=", ">"), "XCBASIC.REL_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("<=", "<>", "<", "=", ">=", ">"), "XCBASIC.REL_OP"), "REL_OP")(TParseTree("", false,[], s));
        }
    }
    static string REL_OP(GetName g)
    {
        return "XCBASIC.REL_OP";
    }

    static TParseTree Parenthesis(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!(")"))), "XCBASIC.Parenthesis")(p);
        }
        else
        {
            if (auto m = tuple(`Parenthesis`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!(")"))), "XCBASIC.Parenthesis"), "Parenthesis")(p);
                memo[tuple(`Parenthesis`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Parenthesis(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!(")"))), "XCBASIC.Parenthesis")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.option!(WS)), Expression, pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.discard!(pegged.peg.literal!(")"))), "XCBASIC.Parenthesis"), "Parenthesis")(TParseTree("", false,[], s));
        }
    }
    static string Parenthesis(GetName g)
    {
        return "XCBASIC.Parenthesis";
    }

    static TParseTree Varnosubscript(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Vartype)), "XCBASIC.Varnosubscript")(p);
        }
        else
        {
            if (auto m = tuple(`Varnosubscript`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Vartype)), "XCBASIC.Varnosubscript"), "Varnosubscript")(p);
                memo[tuple(`Varnosubscript`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Varnosubscript(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Vartype)), "XCBASIC.Varnosubscript")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Vartype)), "XCBASIC.Varnosubscript"), "Varnosubscript")(TParseTree("", false,[], s));
        }
    }
    static string Varnosubscript(GetName g)
    {
        return "XCBASIC.Varnosubscript";
    }

    static TParseTree Var(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Subscript), pegged.peg.option!(Vartype)), "XCBASIC.Var")(p);
        }
        else
        {
            if (auto m = tuple(`Var`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Subscript), pegged.peg.option!(Vartype)), "XCBASIC.Var"), "Var")(p);
                memo[tuple(`Var`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Var(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Subscript), pegged.peg.option!(Vartype)), "XCBASIC.Var")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Subscript), pegged.peg.option!(Vartype)), "XCBASIC.Var"), "Var")(TParseTree("", false,[], s));
        }
    }
    static string Var(GetName g)
    {
        return "XCBASIC.Var";
    }

    static TParseTree VarnamePattern(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_"))), pegged.peg.option!(pegged.peg.literal!("$")))), "XCBASIC.VarnamePattern")(p);
        }
        else
        {
            if (auto m = tuple(`VarnamePattern`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_"))), pegged.peg.option!(pegged.peg.literal!("$")))), "XCBASIC.VarnamePattern"), "VarnamePattern")(p);
                memo[tuple(`VarnamePattern`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VarnamePattern(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_"))), pegged.peg.option!(pegged.peg.literal!("$")))), "XCBASIC.VarnamePattern")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_"))), pegged.peg.option!(pegged.peg.literal!("$")))), "XCBASIC.VarnamePattern"), "VarnamePattern")(TParseTree("", false,[], s));
        }
    }
    static string VarnamePattern(GetName g)
    {
        return "XCBASIC.VarnamePattern";
    }

    static TParseTree Varname(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.and!(Reserved, pegged.peg.negLookahead!(VarnamePattern))), VarnamePattern), "XCBASIC.Varname")(p);
        }
        else
        {
            if (auto m = tuple(`Varname`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.and!(Reserved, pegged.peg.negLookahead!(VarnamePattern))), VarnamePattern), "XCBASIC.Varname"), "Varname")(p);
                memo[tuple(`Varname`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Varname(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.and!(Reserved, pegged.peg.negLookahead!(VarnamePattern))), VarnamePattern), "XCBASIC.Varname")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.and!(Reserved, pegged.peg.negLookahead!(VarnamePattern))), VarnamePattern), "XCBASIC.Varname"), "Varname")(TParseTree("", false,[], s));
        }
    }
    static string Varname(GetName g)
    {
        return "XCBASIC.Varname";
    }

    static TParseTree Address(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("@"), Accessor), "XCBASIC.Address")(p);
        }
        else
        {
            if (auto m = tuple(`Address`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("@"), Accessor), "XCBASIC.Address"), "Address")(p);
                memo[tuple(`Address`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Address(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("@"), Accessor), "XCBASIC.Address")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("@"), Accessor), "XCBASIC.Address"), "Address")(TParseTree("", false,[], s));
        }
    }
    static string Address(GetName g)
    {
        return "XCBASIC.Address";
    }

    static TParseTree Accessor(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Subscript), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), Varname)), pegged.peg.option!(Subscript)), "XCBASIC.Accessor")(p);
        }
        else
        {
            if (auto m = tuple(`Accessor`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Subscript), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), Varname)), pegged.peg.option!(Subscript)), "XCBASIC.Accessor"), "Accessor")(p);
                memo[tuple(`Accessor`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Accessor(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Subscript), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), Varname)), pegged.peg.option!(Subscript)), "XCBASIC.Accessor")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Varname, pegged.peg.option!(Subscript), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), Varname)), pegged.peg.option!(Subscript)), "XCBASIC.Accessor"), "Accessor")(TParseTree("", false,[], s));
        }
    }
    static string Accessor(GetName g)
    {
        return "XCBASIC.Accessor";
    }

    static TParseTree Id(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')))), "XCBASIC.Id")(p);
        }
        else
        {
            if (auto m = tuple(`Id`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')))), "XCBASIC.Id"), "Id")(p);
                memo[tuple(`Id`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Id(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')))), "XCBASIC.Id")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')))), "XCBASIC.Id"), "Id")(TParseTree("", false,[], s));
        }
    }
    static string Id(GetName g)
    {
        return "XCBASIC.Id";
    }

    static TParseTree Str_typeLen(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("*"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, Label_ref)), "XCBASIC.Str_typeLen")(p);
        }
        else
        {
            if (auto m = tuple(`Str_typeLen`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("*"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, Label_ref)), "XCBASIC.Str_typeLen"), "Str_typeLen")(p);
                memo[tuple(`Str_typeLen`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Str_typeLen(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("*"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, Label_ref)), "XCBASIC.Str_typeLen")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("*"), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.or!(Number, Label_ref)), "XCBASIC.Str_typeLen"), "Str_typeLen")(TParseTree("", false,[], s));
        }
    }
    static string Str_typeLen(GetName g)
    {
        return "XCBASIC.Str_typeLen";
    }

    static TParseTree Vartype(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.discard!(pegged.peg.caseInsensitiveLiteral!("as")), pegged.peg.discard!(WS), Id, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Str_typeLen))), eps), "XCBASIC.Vartype")(p);
        }
        else
        {
            if (auto m = tuple(`Vartype`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.discard!(pegged.peg.caseInsensitiveLiteral!("as")), pegged.peg.discard!(WS), Id, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Str_typeLen))), eps), "XCBASIC.Vartype"), "Vartype")(p);
                memo[tuple(`Vartype`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Vartype(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.discard!(pegged.peg.caseInsensitiveLiteral!("as")), pegged.peg.discard!(WS), Id, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Str_typeLen))), eps), "XCBASIC.Vartype")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.discard!(WS), pegged.peg.discard!(pegged.peg.caseInsensitiveLiteral!("as")), pegged.peg.discard!(WS), Id, pegged.peg.option!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), Str_typeLen))), eps), "XCBASIC.Vartype"), "Vartype")(TParseTree("", false,[], s));
        }
    }
    static string Vartype(GetName g)
    {
        return "XCBASIC.Vartype";
    }

    static TParseTree Subscript(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("("), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(Expression), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression)), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(")")), "XCBASIC.Subscript")(p);
        }
        else
        {
            if (auto m = tuple(`Subscript`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("("), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(Expression), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression)), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(")")), "XCBASIC.Subscript"), "Subscript")(p);
                memo[tuple(`Subscript`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Subscript(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("("), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(Expression), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression)), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(")")), "XCBASIC.Subscript")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("("), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.option!(Expression), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(","), pegged.peg.discard!(pegged.peg.option!(WS)), Expression)), pegged.peg.discard!(pegged.peg.option!(WS)), pegged.peg.literal!(")")), "XCBASIC.Subscript"), "Subscript")(TParseTree("", false,[], s));
        }
    }
    static string Subscript(GetName g)
    {
        return "XCBASIC.Subscript";
    }

    static TParseTree String(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), pegged.peg.any), pegged.peg.keep!(pegged.peg.literal!(" ")))), doublequote), "XCBASIC.String")(p);
        }
        else
        {
            if (auto m = tuple(`String`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), pegged.peg.any), pegged.peg.keep!(pegged.peg.literal!(" ")))), doublequote), "XCBASIC.String"), "String")(p);
                memo[tuple(`String`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree String(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), pegged.peg.any), pegged.peg.keep!(pegged.peg.literal!(" ")))), doublequote), "XCBASIC.String")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), pegged.peg.any), pegged.peg.keep!(pegged.peg.literal!(" ")))), doublequote), "XCBASIC.String"), "String")(TParseTree("", false,[], s));
        }
    }
    static string String(GetName g)
    {
        return "XCBASIC.String";
    }

    static TParseTree Unsigned(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')), "XCBASIC.Unsigned")(p);
        }
        else
        {
            if (auto m = tuple(`Unsigned`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')), "XCBASIC.Unsigned"), "Unsigned")(p);
                memo[tuple(`Unsigned`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Unsigned(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')), "XCBASIC.Unsigned")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')), "XCBASIC.Unsigned"), "Unsigned")(TParseTree("", false,[], s));
        }
    }
    static string Unsigned(GetName g)
    {
        return "XCBASIC.Unsigned";
    }

    static TParseTree Decimal(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Unsigned, pegged.peg.literal!("d")), "XCBASIC.Decimal")(p);
        }
        else
        {
            if (auto m = tuple(`Decimal`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Unsigned, pegged.peg.literal!("d")), "XCBASIC.Decimal"), "Decimal")(p);
                memo[tuple(`Decimal`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Decimal(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Unsigned, pegged.peg.literal!("d")), "XCBASIC.Decimal")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Unsigned, pegged.peg.literal!("d")), "XCBASIC.Decimal"), "Decimal")(TParseTree("", false,[], s));
        }
    }
    static string Decimal(GetName g)
    {
        return "XCBASIC.Decimal";
    }

    static TParseTree Integer(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), Unsigned), "XCBASIC.Integer")(p);
        }
        else
        {
            if (auto m = tuple(`Integer`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), Unsigned), "XCBASIC.Integer"), "Integer")(p);
                memo[tuple(`Integer`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Integer(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), Unsigned), "XCBASIC.Integer")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), Unsigned), "XCBASIC.Integer"), "Integer")(TParseTree("", false,[], s));
        }
    }
    static string Integer(GetName g)
    {
        return "XCBASIC.Integer";
    }

    static TParseTree Hexa(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("$"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')))), "XCBASIC.Hexa")(p);
        }
        else
        {
            if (auto m = tuple(`Hexa`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("$"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')))), "XCBASIC.Hexa"), "Hexa")(p);
                memo[tuple(`Hexa`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Hexa(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("$"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')))), "XCBASIC.Hexa")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("$"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')))), "XCBASIC.Hexa"), "Hexa")(TParseTree("", false,[], s));
        }
    }
    static string Hexa(GetName g)
    {
        return "XCBASIC.Hexa";
    }

    static TParseTree Binary(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("%"), pegged.peg.oneOrMore!(pegged.peg.keywords!("0", "1"))), "XCBASIC.Binary")(p);
        }
        else
        {
            if (auto m = tuple(`Binary`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("%"), pegged.peg.oneOrMore!(pegged.peg.keywords!("0", "1"))), "XCBASIC.Binary"), "Binary")(p);
                memo[tuple(`Binary`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Binary(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("%"), pegged.peg.oneOrMore!(pegged.peg.keywords!("0", "1"))), "XCBASIC.Binary")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("%"), pegged.peg.oneOrMore!(pegged.peg.keywords!("0", "1"))), "XCBASIC.Binary"), "Binary")(TParseTree("", false,[], s));
        }
    }
    static string Binary(GetName g)
    {
        return "XCBASIC.Binary";
    }

    static TParseTree Scientific(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Floating, pegged.peg.keywords!("e", "E"), Integer), "XCBASIC.Scientific")(p);
        }
        else
        {
            if (auto m = tuple(`Scientific`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Floating, pegged.peg.keywords!("e", "E"), Integer), "XCBASIC.Scientific"), "Scientific")(p);
                memo[tuple(`Scientific`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Scientific(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Floating, pegged.peg.keywords!("e", "E"), Integer), "XCBASIC.Scientific")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Floating, pegged.peg.keywords!("e", "E"), Integer), "XCBASIC.Scientific"), "Scientific")(TParseTree("", false,[], s));
        }
    }
    static string Scientific(GetName g)
    {
        return "XCBASIC.Scientific";
    }

    static TParseTree Floating(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), Unsigned, pegged.peg.literal!("."), Unsigned), "XCBASIC.Floating")(p);
        }
        else
        {
            if (auto m = tuple(`Floating`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), Unsigned, pegged.peg.literal!("."), Unsigned), "XCBASIC.Floating"), "Floating")(p);
                memo[tuple(`Floating`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Floating(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), Unsigned, pegged.peg.literal!("."), Unsigned), "XCBASIC.Floating")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), Unsigned, pegged.peg.literal!("."), Unsigned), "XCBASIC.Floating"), "Floating")(TParseTree("", false,[], s));
        }
    }
    static string Floating(GetName g)
    {
        return "XCBASIC.Floating";
    }

    static TParseTree Charlit(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("'{"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))), pegged.peg.literal!("}'")), pegged.peg.and!(pegged.peg.literal!("'"), pegged.peg.any, pegged.peg.literal!("'"))), "XCBASIC.Charlit")(p);
        }
        else
        {
            if (auto m = tuple(`Charlit`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("'{"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))), pegged.peg.literal!("}'")), pegged.peg.and!(pegged.peg.literal!("'"), pegged.peg.any, pegged.peg.literal!("'"))), "XCBASIC.Charlit"), "Charlit")(p);
                memo[tuple(`Charlit`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Charlit(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("'{"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))), pegged.peg.literal!("}'")), pegged.peg.and!(pegged.peg.literal!("'"), pegged.peg.any, pegged.peg.literal!("'"))), "XCBASIC.Charlit")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("'{"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))), pegged.peg.literal!("}'")), pegged.peg.and!(pegged.peg.literal!("'"), pegged.peg.any, pegged.peg.literal!("'"))), "XCBASIC.Charlit"), "Charlit")(TParseTree("", false,[], s));
        }
    }
    static string Charlit(GetName g)
    {
        return "XCBASIC.Charlit";
    }

    static TParseTree Number(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Decimal, Scientific, Floating, Integer, Hexa, Binary, Charlit), "XCBASIC.Number")(p);
        }
        else
        {
            if (auto m = tuple(`Number`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(Decimal, Scientific, Floating, Integer, Hexa, Binary, Charlit), "XCBASIC.Number"), "Number")(p);
                memo[tuple(`Number`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Number(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Decimal, Scientific, Floating, Integer, Hexa, Binary, Charlit), "XCBASIC.Number")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(Decimal, Scientific, Floating, Integer, Hexa, Binary, Charlit), "XCBASIC.Number"), "Number")(TParseTree("", false,[], s));
        }
    }
    static string Number(GetName g)
    {
        return "XCBASIC.Number";
    }

    static TParseTree Label(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))), pegged.peg.literal!(":")), "XCBASIC.Label")(p);
        }
        else
        {
            if (auto m = tuple(`Label`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))), pegged.peg.literal!(":")), "XCBASIC.Label"), "Label")(p);
                memo[tuple(`Label`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Label(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))), pegged.peg.literal!(":")), "XCBASIC.Label")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))), pegged.peg.literal!(":")), "XCBASIC.Label"), "Label")(TParseTree("", false,[], s));
        }
    }
    static string Label(GetName g)
    {
        return "XCBASIC.Label";
    }

    static TParseTree Label_ref(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')))), "XCBASIC.Label_ref")(p);
        }
        else
        {
            if (auto m = tuple(`Label_ref`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')))), "XCBASIC.Label_ref"), "Label_ref")(p);
                memo[tuple(`Label_ref`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Label_ref(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')))), "XCBASIC.Label_ref")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')))), "XCBASIC.Label_ref"), "Label_ref")(TParseTree("", false,[], s));
        }
    }
    static string Label_ref(GetName g)
    {
        return "XCBASIC.Label_ref";
    }

    static TParseTree Line_id(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Label, Unsigned, eps), "XCBASIC.Line_id")(p);
        }
        else
        {
            if (auto m = tuple(`Line_id`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(Label, Unsigned, eps), "XCBASIC.Line_id"), "Line_id")(p);
                memo[tuple(`Line_id`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Line_id(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Label, Unsigned, eps), "XCBASIC.Line_id")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(Label, Unsigned, eps), "XCBASIC.Line_id"), "Line_id")(TParseTree("", false,[], s));
        }
    }
    static string Line_id(GetName g)
    {
        return "XCBASIC.Line_id";
    }

    static TParseTree Reserved(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("and"), pegged.peg.caseInsensitiveLiteral!("as"), pegged.peg.caseInsensitiveLiteral!("asm"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("border"), pegged.peg.caseInsensitiveLiteral!("byte"), pegged.peg.caseInsensitiveLiteral!("call"), pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.caseInsensitiveLiteral!("charat"), pegged.peg.caseInsensitiveLiteral!("close"), pegged.peg.caseInsensitiveLiteral!("const"), pegged.peg.caseInsensitiveLiteral!("continue"), pegged.peg.caseInsensitiveLiteral!("data"), pegged.peg.caseInsensitiveLiteral!("decimal"), pegged.peg.caseInsensitiveLiteral!("declare"), pegged.peg.caseInsensitiveLiteral!("dim"), pegged.peg.caseInsensitiveLiteral!("do"), pegged.peg.caseInsensitiveLiteral!("else"), pegged.peg.caseInsensitiveLiteral!("end"), pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.caseInsensitiveLiteral!("exit"), pegged.peg.caseInsensitiveLiteral!("fast"), pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.caseInsensitiveLiteral!("float"), pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.caseInsensitiveLiteral!("function"), pegged.peg.caseInsensitiveLiteral!("get"), pegged.peg.caseInsensitiveLiteral!("gosub"), pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.caseInsensitiveLiteral!("hscroll"), pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.caseInsensitiveLiteral!("incbin"), pegged.peg.caseInsensitiveLiteral!("include"), pegged.peg.caseInsensitiveLiteral!("inline"), pegged.peg.caseInsensitiveLiteral!("input"), pegged.peg.caseInsensitiveLiteral!("int"), pegged.peg.caseInsensitiveLiteral!("interrupt"), pegged.peg.caseInsensitiveLiteral!("let"), pegged.peg.caseInsensitiveLiteral!("load"), pegged.peg.caseInsensitiveLiteral!("locate"), pegged.peg.caseInsensitiveLiteral!("long"), pegged.peg.caseInsensitiveLiteral!("loop"), pegged.peg.caseInsensitiveLiteral!("memcpy"), pegged.peg.caseInsensitiveLiteral!("memset"), pegged.peg.caseInsensitiveLiteral!("memshift"), pegged.peg.caseInsensitiveLiteral!("mod"), pegged.peg.caseInsensitiveLiteral!("next"), pegged.peg.caseInsensitiveLiteral!("not"), pegged.peg.caseInsensitiveLiteral!("off"), pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("open"), pegged.peg.caseInsensitiveLiteral!("option"), pegged.peg.caseInsensitiveLiteral!("or"), pegged.peg.caseInsensitiveLiteral!("origin"), pegged.peg.caseInsensitiveLiteral!("overload"), pegged.peg.caseInsensitiveLiteral!("poke"), pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.caseInsensitiveLiteral!("private"), pegged.peg.caseInsensitiveLiteral!("randomize"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("read"), pegged.peg.caseInsensitiveLiteral!("rem"), pegged.peg.caseInsensitiveLiteral!("return"), pegged.peg.caseInsensitiveLiteral!("save"), pegged.peg.caseInsensitiveLiteral!("screen"), pegged.peg.caseInsensitiveLiteral!("select"), pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.caseInsensitiveLiteral!("sound"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("static"), pegged.peg.caseInsensitiveLiteral!("step"), pegged.peg.caseInsensitiveLiteral!("string"), pegged.peg.caseInsensitiveLiteral!("sub"), pegged.peg.caseInsensitiveLiteral!("swap"), pegged.peg.caseInsensitiveLiteral!("sys"), pegged.peg.caseInsensitiveLiteral!("system"), pegged.peg.caseInsensitiveLiteral!("textat"), pegged.peg.caseInsensitiveLiteral!("then"), pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.caseInsensitiveLiteral!("type"), pegged.peg.caseInsensitiveLiteral!("until"), pegged.peg.caseInsensitiveLiteral!("vmode"), pegged.peg.caseInsensitiveLiteral!("voice"), pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.caseInsensitiveLiteral!("vscroll"), pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("word"), pegged.peg.caseInsensitiveLiteral!("write"), pegged.peg.caseInsensitiveLiteral!("xor"), pegged.peg.caseInsensitiveLiteral!("vblank")), "XCBASIC.Reserved")(p);
        }
        else
        {
            if (auto m = tuple(`Reserved`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("and"), pegged.peg.caseInsensitiveLiteral!("as"), pegged.peg.caseInsensitiveLiteral!("asm"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("border"), pegged.peg.caseInsensitiveLiteral!("byte"), pegged.peg.caseInsensitiveLiteral!("call"), pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.caseInsensitiveLiteral!("charat"), pegged.peg.caseInsensitiveLiteral!("close"), pegged.peg.caseInsensitiveLiteral!("const"), pegged.peg.caseInsensitiveLiteral!("continue"), pegged.peg.caseInsensitiveLiteral!("data"), pegged.peg.caseInsensitiveLiteral!("decimal"), pegged.peg.caseInsensitiveLiteral!("declare"), pegged.peg.caseInsensitiveLiteral!("dim"), pegged.peg.caseInsensitiveLiteral!("do"), pegged.peg.caseInsensitiveLiteral!("else"), pegged.peg.caseInsensitiveLiteral!("end"), pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.caseInsensitiveLiteral!("exit"), pegged.peg.caseInsensitiveLiteral!("fast"), pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.caseInsensitiveLiteral!("float"), pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.caseInsensitiveLiteral!("function"), pegged.peg.caseInsensitiveLiteral!("get"), pegged.peg.caseInsensitiveLiteral!("gosub"), pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.caseInsensitiveLiteral!("hscroll"), pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.caseInsensitiveLiteral!("incbin"), pegged.peg.caseInsensitiveLiteral!("include"), pegged.peg.caseInsensitiveLiteral!("inline"), pegged.peg.caseInsensitiveLiteral!("input"), pegged.peg.caseInsensitiveLiteral!("int"), pegged.peg.caseInsensitiveLiteral!("interrupt"), pegged.peg.caseInsensitiveLiteral!("let"), pegged.peg.caseInsensitiveLiteral!("load"), pegged.peg.caseInsensitiveLiteral!("locate"), pegged.peg.caseInsensitiveLiteral!("long"), pegged.peg.caseInsensitiveLiteral!("loop"), pegged.peg.caseInsensitiveLiteral!("memcpy"), pegged.peg.caseInsensitiveLiteral!("memset"), pegged.peg.caseInsensitiveLiteral!("memshift"), pegged.peg.caseInsensitiveLiteral!("mod"), pegged.peg.caseInsensitiveLiteral!("next"), pegged.peg.caseInsensitiveLiteral!("not"), pegged.peg.caseInsensitiveLiteral!("off"), pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("open"), pegged.peg.caseInsensitiveLiteral!("option"), pegged.peg.caseInsensitiveLiteral!("or"), pegged.peg.caseInsensitiveLiteral!("origin"), pegged.peg.caseInsensitiveLiteral!("overload"), pegged.peg.caseInsensitiveLiteral!("poke"), pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.caseInsensitiveLiteral!("private"), pegged.peg.caseInsensitiveLiteral!("randomize"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("read"), pegged.peg.caseInsensitiveLiteral!("rem"), pegged.peg.caseInsensitiveLiteral!("return"), pegged.peg.caseInsensitiveLiteral!("save"), pegged.peg.caseInsensitiveLiteral!("screen"), pegged.peg.caseInsensitiveLiteral!("select"), pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.caseInsensitiveLiteral!("sound"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("static"), pegged.peg.caseInsensitiveLiteral!("step"), pegged.peg.caseInsensitiveLiteral!("string"), pegged.peg.caseInsensitiveLiteral!("sub"), pegged.peg.caseInsensitiveLiteral!("swap"), pegged.peg.caseInsensitiveLiteral!("sys"), pegged.peg.caseInsensitiveLiteral!("system"), pegged.peg.caseInsensitiveLiteral!("textat"), pegged.peg.caseInsensitiveLiteral!("then"), pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.caseInsensitiveLiteral!("type"), pegged.peg.caseInsensitiveLiteral!("until"), pegged.peg.caseInsensitiveLiteral!("vmode"), pegged.peg.caseInsensitiveLiteral!("voice"), pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.caseInsensitiveLiteral!("vscroll"), pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("word"), pegged.peg.caseInsensitiveLiteral!("write"), pegged.peg.caseInsensitiveLiteral!("xor"), pegged.peg.caseInsensitiveLiteral!("vblank")), "XCBASIC.Reserved"), "Reserved")(p);
                memo[tuple(`Reserved`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Reserved(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("and"), pegged.peg.caseInsensitiveLiteral!("as"), pegged.peg.caseInsensitiveLiteral!("asm"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("border"), pegged.peg.caseInsensitiveLiteral!("byte"), pegged.peg.caseInsensitiveLiteral!("call"), pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.caseInsensitiveLiteral!("charat"), pegged.peg.caseInsensitiveLiteral!("close"), pegged.peg.caseInsensitiveLiteral!("const"), pegged.peg.caseInsensitiveLiteral!("continue"), pegged.peg.caseInsensitiveLiteral!("data"), pegged.peg.caseInsensitiveLiteral!("decimal"), pegged.peg.caseInsensitiveLiteral!("declare"), pegged.peg.caseInsensitiveLiteral!("dim"), pegged.peg.caseInsensitiveLiteral!("do"), pegged.peg.caseInsensitiveLiteral!("else"), pegged.peg.caseInsensitiveLiteral!("end"), pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.caseInsensitiveLiteral!("exit"), pegged.peg.caseInsensitiveLiteral!("fast"), pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.caseInsensitiveLiteral!("float"), pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.caseInsensitiveLiteral!("function"), pegged.peg.caseInsensitiveLiteral!("get"), pegged.peg.caseInsensitiveLiteral!("gosub"), pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.caseInsensitiveLiteral!("hscroll"), pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.caseInsensitiveLiteral!("incbin"), pegged.peg.caseInsensitiveLiteral!("include"), pegged.peg.caseInsensitiveLiteral!("inline"), pegged.peg.caseInsensitiveLiteral!("input"), pegged.peg.caseInsensitiveLiteral!("int"), pegged.peg.caseInsensitiveLiteral!("interrupt"), pegged.peg.caseInsensitiveLiteral!("let"), pegged.peg.caseInsensitiveLiteral!("load"), pegged.peg.caseInsensitiveLiteral!("locate"), pegged.peg.caseInsensitiveLiteral!("long"), pegged.peg.caseInsensitiveLiteral!("loop"), pegged.peg.caseInsensitiveLiteral!("memcpy"), pegged.peg.caseInsensitiveLiteral!("memset"), pegged.peg.caseInsensitiveLiteral!("memshift"), pegged.peg.caseInsensitiveLiteral!("mod"), pegged.peg.caseInsensitiveLiteral!("next"), pegged.peg.caseInsensitiveLiteral!("not"), pegged.peg.caseInsensitiveLiteral!("off"), pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("open"), pegged.peg.caseInsensitiveLiteral!("option"), pegged.peg.caseInsensitiveLiteral!("or"), pegged.peg.caseInsensitiveLiteral!("origin"), pegged.peg.caseInsensitiveLiteral!("overload"), pegged.peg.caseInsensitiveLiteral!("poke"), pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.caseInsensitiveLiteral!("private"), pegged.peg.caseInsensitiveLiteral!("randomize"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("read"), pegged.peg.caseInsensitiveLiteral!("rem"), pegged.peg.caseInsensitiveLiteral!("return"), pegged.peg.caseInsensitiveLiteral!("save"), pegged.peg.caseInsensitiveLiteral!("screen"), pegged.peg.caseInsensitiveLiteral!("select"), pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.caseInsensitiveLiteral!("sound"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("static"), pegged.peg.caseInsensitiveLiteral!("step"), pegged.peg.caseInsensitiveLiteral!("string"), pegged.peg.caseInsensitiveLiteral!("sub"), pegged.peg.caseInsensitiveLiteral!("swap"), pegged.peg.caseInsensitiveLiteral!("sys"), pegged.peg.caseInsensitiveLiteral!("system"), pegged.peg.caseInsensitiveLiteral!("textat"), pegged.peg.caseInsensitiveLiteral!("then"), pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.caseInsensitiveLiteral!("type"), pegged.peg.caseInsensitiveLiteral!("until"), pegged.peg.caseInsensitiveLiteral!("vmode"), pegged.peg.caseInsensitiveLiteral!("voice"), pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.caseInsensitiveLiteral!("vscroll"), pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("word"), pegged.peg.caseInsensitiveLiteral!("write"), pegged.peg.caseInsensitiveLiteral!("xor"), pegged.peg.caseInsensitiveLiteral!("vblank")), "XCBASIC.Reserved")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("and"), pegged.peg.caseInsensitiveLiteral!("as"), pegged.peg.caseInsensitiveLiteral!("asm"), pegged.peg.caseInsensitiveLiteral!("background"), pegged.peg.caseInsensitiveLiteral!("border"), pegged.peg.caseInsensitiveLiteral!("byte"), pegged.peg.caseInsensitiveLiteral!("call"), pegged.peg.caseInsensitiveLiteral!("case"), pegged.peg.caseInsensitiveLiteral!("charat"), pegged.peg.caseInsensitiveLiteral!("close"), pegged.peg.caseInsensitiveLiteral!("const"), pegged.peg.caseInsensitiveLiteral!("continue"), pegged.peg.caseInsensitiveLiteral!("data"), pegged.peg.caseInsensitiveLiteral!("decimal"), pegged.peg.caseInsensitiveLiteral!("declare"), pegged.peg.caseInsensitiveLiteral!("dim"), pegged.peg.caseInsensitiveLiteral!("do"), pegged.peg.caseInsensitiveLiteral!("else"), pegged.peg.caseInsensitiveLiteral!("end"), pegged.peg.caseInsensitiveLiteral!("error"), pegged.peg.caseInsensitiveLiteral!("exit"), pegged.peg.caseInsensitiveLiteral!("fast"), pegged.peg.caseInsensitiveLiteral!("filter"), pegged.peg.caseInsensitiveLiteral!("float"), pegged.peg.caseInsensitiveLiteral!("for"), pegged.peg.caseInsensitiveLiteral!("function"), pegged.peg.caseInsensitiveLiteral!("get"), pegged.peg.caseInsensitiveLiteral!("gosub"), pegged.peg.caseInsensitiveLiteral!("goto"), pegged.peg.caseInsensitiveLiteral!("hscroll"), pegged.peg.caseInsensitiveLiteral!("if"), pegged.peg.caseInsensitiveLiteral!("incbin"), pegged.peg.caseInsensitiveLiteral!("include"), pegged.peg.caseInsensitiveLiteral!("inline"), pegged.peg.caseInsensitiveLiteral!("input"), pegged.peg.caseInsensitiveLiteral!("int"), pegged.peg.caseInsensitiveLiteral!("interrupt"), pegged.peg.caseInsensitiveLiteral!("let"), pegged.peg.caseInsensitiveLiteral!("load"), pegged.peg.caseInsensitiveLiteral!("locate"), pegged.peg.caseInsensitiveLiteral!("long"), pegged.peg.caseInsensitiveLiteral!("loop"), pegged.peg.caseInsensitiveLiteral!("memcpy"), pegged.peg.caseInsensitiveLiteral!("memset"), pegged.peg.caseInsensitiveLiteral!("memshift"), pegged.peg.caseInsensitiveLiteral!("mod"), pegged.peg.caseInsensitiveLiteral!("next"), pegged.peg.caseInsensitiveLiteral!("not"), pegged.peg.caseInsensitiveLiteral!("off"), pegged.peg.caseInsensitiveLiteral!("on"), pegged.peg.caseInsensitiveLiteral!("open"), pegged.peg.caseInsensitiveLiteral!("option"), pegged.peg.caseInsensitiveLiteral!("or"), pegged.peg.caseInsensitiveLiteral!("origin"), pegged.peg.caseInsensitiveLiteral!("overload"), pegged.peg.caseInsensitiveLiteral!("poke"), pegged.peg.caseInsensitiveLiteral!("print"), pegged.peg.caseInsensitiveLiteral!("private"), pegged.peg.caseInsensitiveLiteral!("randomize"), pegged.peg.caseInsensitiveLiteral!("raster"), pegged.peg.caseInsensitiveLiteral!("read"), pegged.peg.caseInsensitiveLiteral!("rem"), pegged.peg.caseInsensitiveLiteral!("return"), pegged.peg.caseInsensitiveLiteral!("save"), pegged.peg.caseInsensitiveLiteral!("screen"), pegged.peg.caseInsensitiveLiteral!("select"), pegged.peg.caseInsensitiveLiteral!("shared"), pegged.peg.caseInsensitiveLiteral!("sound"), pegged.peg.caseInsensitiveLiteral!("sprite"), pegged.peg.caseInsensitiveLiteral!("static"), pegged.peg.caseInsensitiveLiteral!("step"), pegged.peg.caseInsensitiveLiteral!("string"), pegged.peg.caseInsensitiveLiteral!("sub"), pegged.peg.caseInsensitiveLiteral!("swap"), pegged.peg.caseInsensitiveLiteral!("sys"), pegged.peg.caseInsensitiveLiteral!("system"), pegged.peg.caseInsensitiveLiteral!("textat"), pegged.peg.caseInsensitiveLiteral!("then"), pegged.peg.caseInsensitiveLiteral!("timer"), pegged.peg.caseInsensitiveLiteral!("to"), pegged.peg.caseInsensitiveLiteral!("type"), pegged.peg.caseInsensitiveLiteral!("until"), pegged.peg.caseInsensitiveLiteral!("vmode"), pegged.peg.caseInsensitiveLiteral!("voice"), pegged.peg.caseInsensitiveLiteral!("volume"), pegged.peg.caseInsensitiveLiteral!("vscroll"), pegged.peg.caseInsensitiveLiteral!("while"), pegged.peg.caseInsensitiveLiteral!("word"), pegged.peg.caseInsensitiveLiteral!("write"), pegged.peg.caseInsensitiveLiteral!("xor"), pegged.peg.caseInsensitiveLiteral!("vblank")), "XCBASIC.Reserved"), "Reserved")(TParseTree("", false,[], s));
        }
    }
    static string Reserved(GetName g)
    {
        return "XCBASIC.Reserved";
    }

    static TParseTree WS(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(space, pegged.peg.and!(pegged.peg.literal!("_"), pegged.peg.oneOrMore!(endOfLine)), pegged.peg.and!(pegged.peg.literal!("'"), pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)))))), "XCBASIC.WS")(p);
        }
        else
        {
            if (auto m = tuple(`WS`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(space, pegged.peg.and!(pegged.peg.literal!("_"), pegged.peg.oneOrMore!(endOfLine)), pegged.peg.and!(pegged.peg.literal!("'"), pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)))))), "XCBASIC.WS"), "WS")(p);
                memo[tuple(`WS`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree WS(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(space, pegged.peg.and!(pegged.peg.literal!("_"), pegged.peg.oneOrMore!(endOfLine)), pegged.peg.and!(pegged.peg.literal!("'"), pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)))))), "XCBASIC.WS")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(space, pegged.peg.and!(pegged.peg.literal!("_"), pegged.peg.oneOrMore!(endOfLine)), pegged.peg.and!(pegged.peg.literal!("'"), pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)))))), "XCBASIC.WS"), "WS")(TParseTree("", false,[], s));
        }
    }
    static string WS(GetName g)
    {
        return "XCBASIC.WS";
    }

    static TParseTree EOI(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), "XCBASIC.EOI")(p);
        }
        else
        {
            if (auto m = tuple(`EOI`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), "XCBASIC.EOI"), "EOI")(p);
                memo[tuple(`EOI`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree EOI(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), "XCBASIC.EOI")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), "XCBASIC.EOI"), "EOI")(TParseTree("", false,[], s));
        }
    }
    static string EOI(GetName g)
    {
        return "XCBASIC.EOI";
    }

    static TParseTree Spacing(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.literal!("\t"))), "XCBASIC.Spacing")(p);
        }
        else
        {
            if (auto m = tuple(`Spacing`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.literal!("\t"))), "XCBASIC.Spacing"), "Spacing")(p);
                memo[tuple(`Spacing`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Spacing(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.literal!("\t"))), "XCBASIC.Spacing")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.literal!("\t"))), "XCBASIC.Spacing"), "Spacing")(TParseTree("", false,[], s));
        }
    }
    static string Spacing(GetName g)
    {
        return "XCBASIC.Spacing";
    }

    static TParseTree opCall(TParseTree p)
    {
        TParseTree result = decimateTree(Program(p));
        result.children = [result];
        result.name = "XCBASIC";
        return result;
    }

    static TParseTree opCall(string input)
    {
        if(__ctfe)
        {
            return XCBASIC(TParseTree(``, false, [], input, 0, 0));
        }
        else
        {
            forgetMemo();
            return XCBASIC(TParseTree(``, false, [], input, 0, 0));
        }
    }
    static string opCall(GetName g)
    {
        return "XCBASIC";
    }


    static void forgetMemo()
    {
        memo = null;
    }
    }
}

alias GenericXCBASIC!(ParseTree).XCBASIC XCBASIC;


