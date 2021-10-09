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
        rules["Data_stmt"] = toDelegate(&Data_stmt);
        rules["Charat_stmt"] = toDelegate(&Charat_stmt);
        rules["Textat_stmt"] = toDelegate(&Textat_stmt);
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
        rules["Watch_stmt"] = toDelegate(&Watch_stmt);
        rules["Pragma_stmt"] = toDelegate(&Pragma_stmt);
        rules["Memset_stmt"] = toDelegate(&Memset_stmt);
        rules["Memcpy_stmt"] = toDelegate(&Memcpy_stmt);
        rules["Memshift_stmt"] = toDelegate(&Memshift_stmt);
        rules["Disableirq_stmt"] = toDelegate(&Disableirq_stmt);
        rules["Enableirq_stmt"] = toDelegate(&Enableirq_stmt);
        rules["Randomize_stmt"] = toDelegate(&Randomize_stmt);
        rules["Open_stmt"] = toDelegate(&Open_stmt);
        rules["Get_stmt"] = toDelegate(&Get_stmt);
        rules["Close_stmt"] = toDelegate(&Close_stmt);
        rules["Type_stmt"] = toDelegate(&Type_stmt);
        rules["Field_def"] = toDelegate(&Field_def);
        rules["Endtype_stmt"] = toDelegate(&Endtype_stmt);
        rules["End_stmt"] = toDelegate(&End_stmt);
        rules["ExprList"] = toDelegate(&ExprList);
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
        rules["NL"] = toDelegate(&NL);
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
            return         pegged.peg.defined!(pegged.peg.and!(Line, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.oneOrMore!(NL), Line)), EOI), "XCBASIC.Program")(p);
        }
        else
        {
            if (auto m = tuple(`Program`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(Line, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.oneOrMore!(NL), Line)), EOI), "XCBASIC.Program"), "Program")(p);
                memo[tuple(`Program`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Program(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(Line, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.oneOrMore!(NL), Line)), EOI), "XCBASIC.Program")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(Line, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.oneOrMore!(NL), Line)), EOI), "XCBASIC.Program"), "Program")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Line_id, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Statements, Spacing))), "XCBASIC.Line")(p);
        }
        else
        {
            if (auto m = tuple(`Line`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Line_id, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Statements, Spacing))), "XCBASIC.Line"), "Line")(p);
                memo[tuple(`Line`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Line(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Line_id, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Statements, Spacing))), "XCBASIC.Line")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Line_id, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Statements, Spacing))), "XCBASIC.Line"), "Line")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Statement, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Statement, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Statements")(p);
        }
        else
        {
            if (auto m = tuple(`Statements`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Statement, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Statement, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Statements"), "Statements")(p);
                memo[tuple(`Statements`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Statements(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Statement, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Statement, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Statements")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Statement, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Statement, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Statements"), "Statements")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Let_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Print_stmt, Spacing), pegged.peg.wrapAround!(Spacing, If_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Goto_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Input_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Gosub_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Call_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Rem_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Poke_stmt, Spacing), pegged.peg.wrapAround!(Spacing, For_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Next_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Dim_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Charat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Data_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Textat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Incbin_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Include_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Sys_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Load_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Save_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Randomize_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Origin_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Swap_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Locate_stmt, Spacing), pegged.peg.wrapAround!(Spacing, On_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Error_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Wait_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Watch_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Pragma_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memset_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memcpy_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memshift_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Open_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Close_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Get_stmt, Spacing), pegged.peg.wrapAround!(Spacing, If_sa_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Else_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endif_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Disableirq_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Enableirq_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Fun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endfun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Return_fn_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Return_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Exitfun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Do_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Loop_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Asm_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endasm_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Cont_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Exit_do_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Type_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Field_def, Spacing), pegged.peg.wrapAround!(Spacing, Endtype_stmt, Spacing), pegged.peg.wrapAround!(Spacing, End_stmt, Spacing)), "XCBASIC.Statement")(p);
        }
        else
        {
            if (auto m = tuple(`Statement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Let_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Print_stmt, Spacing), pegged.peg.wrapAround!(Spacing, If_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Goto_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Input_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Gosub_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Call_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Rem_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Poke_stmt, Spacing), pegged.peg.wrapAround!(Spacing, For_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Next_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Dim_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Charat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Data_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Textat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Incbin_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Include_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Sys_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Load_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Save_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Randomize_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Origin_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Swap_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Locate_stmt, Spacing), pegged.peg.wrapAround!(Spacing, On_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Error_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Wait_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Watch_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Pragma_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memset_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memcpy_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memshift_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Open_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Close_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Get_stmt, Spacing), pegged.peg.wrapAround!(Spacing, If_sa_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Else_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endif_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Disableirq_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Enableirq_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Fun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endfun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Return_fn_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Return_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Exitfun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Do_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Loop_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Asm_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endasm_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Cont_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Exit_do_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Type_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Field_def, Spacing), pegged.peg.wrapAround!(Spacing, Endtype_stmt, Spacing), pegged.peg.wrapAround!(Spacing, End_stmt, Spacing)), "XCBASIC.Statement"), "Statement")(p);
                memo[tuple(`Statement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Statement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Let_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Print_stmt, Spacing), pegged.peg.wrapAround!(Spacing, If_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Goto_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Input_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Gosub_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Call_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Rem_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Poke_stmt, Spacing), pegged.peg.wrapAround!(Spacing, For_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Next_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Dim_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Charat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Data_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Textat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Incbin_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Include_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Sys_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Load_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Save_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Randomize_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Origin_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Swap_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Locate_stmt, Spacing), pegged.peg.wrapAround!(Spacing, On_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Error_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Wait_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Watch_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Pragma_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memset_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memcpy_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memshift_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Open_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Close_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Get_stmt, Spacing), pegged.peg.wrapAround!(Spacing, If_sa_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Else_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endif_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Disableirq_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Enableirq_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Fun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endfun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Return_fn_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Return_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Exitfun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Do_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Loop_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Asm_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endasm_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Cont_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Exit_do_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Type_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Field_def, Spacing), pegged.peg.wrapAround!(Spacing, Endtype_stmt, Spacing), pegged.peg.wrapAround!(Spacing, End_stmt, Spacing)), "XCBASIC.Statement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Let_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Print_stmt, Spacing), pegged.peg.wrapAround!(Spacing, If_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Goto_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Input_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Gosub_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Call_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Rem_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Poke_stmt, Spacing), pegged.peg.wrapAround!(Spacing, For_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Next_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Dim_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Charat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Data_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Textat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Incbin_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Include_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Sys_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Load_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Save_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Randomize_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Origin_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Swap_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Locate_stmt, Spacing), pegged.peg.wrapAround!(Spacing, On_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Error_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Wait_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Watch_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Pragma_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memset_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memcpy_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Memshift_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Open_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Close_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Get_stmt, Spacing), pegged.peg.wrapAround!(Spacing, If_sa_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Else_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endif_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Disableirq_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Enableirq_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Fun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endfun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Return_fn_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Return_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Exitfun_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Do_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Loop_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Asm_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Endasm_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Cont_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Exit_do_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Type_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Field_def, Spacing), pegged.peg.wrapAround!(Spacing, Endtype_stmt, Spacing), pegged.peg.wrapAround!(Spacing, End_stmt, Spacing)), "XCBASIC.Statement"), "Statement")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("const"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Const_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Const_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("const"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Const_stmt"), "Const_stmt")(p);
                memo[tuple(`Const_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Const_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("const"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Const_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("const"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Const_stmt"), "Const_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("let"), Spacing), pegged.peg.wrapAround!(Spacing, eps, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Let_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Let_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("let"), Spacing), pegged.peg.wrapAround!(Spacing, eps, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Let_stmt"), "Let_stmt")(p);
                memo[tuple(`Let_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Let_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("let"), Spacing), pegged.peg.wrapAround!(Spacing, eps, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Let_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("let"), Spacing), pegged.peg.wrapAround!(Spacing, eps, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Let_stmt"), "Let_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("print"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, PrintableList, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "XCBASIC.Print_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Print_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("print"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, PrintableList, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "XCBASIC.Print_stmt"), "Print_stmt")(p);
                memo[tuple(`Print_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Print_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("print"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, PrintableList, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "XCBASIC.Print_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("print"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, PrintableList, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "XCBASIC.Print_stmt"), "Print_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Print_stmt(GetName g)
    {
        return "XCBASIC.Print_stmt";
    }

    static TParseTree If_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("else"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing)), Spacing))), "XCBASIC.If_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`If_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("else"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing)), Spacing))), "XCBASIC.If_stmt"), "If_stmt")(p);
                memo[tuple(`If_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree If_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("else"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing)), Spacing))), "XCBASIC.If_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("else"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Statements, Spacing)), Spacing))), "XCBASIC.If_stmt"), "If_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing)), "XCBASIC.If_sa_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`If_sa_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing)), "XCBASIC.If_sa_stmt"), "If_sa_stmt")(p);
                memo[tuple(`If_sa_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree If_sa_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing)), "XCBASIC.If_sa_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing)), "XCBASIC.If_sa_stmt"), "If_sa_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("else"), Spacing), "XCBASIC.Else_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Else_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("else"), Spacing), "XCBASIC.Else_stmt"), "Else_stmt")(p);
                memo[tuple(`Else_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Else_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("else"), Spacing), "XCBASIC.Else_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("else"), Spacing), "XCBASIC.Else_stmt"), "Else_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end if"), Spacing), "XCBASIC.Endif_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Endif_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end if"), Spacing), "XCBASIC.Endif_stmt"), "Endif_stmt")(p);
                memo[tuple(`Endif_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Endif_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end if"), Spacing), "XCBASIC.Endif_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end if"), Spacing), "XCBASIC.Endif_stmt"), "Endif_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), Spacing)), "XCBASIC.Goto_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Goto_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), Spacing)), "XCBASIC.Goto_stmt"), "Goto_stmt")(p);
                memo[tuple(`Goto_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Goto_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), Spacing)), "XCBASIC.Goto_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), Spacing)), "XCBASIC.Goto_stmt"), "Goto_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Error_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Error_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Error_stmt"), "Error_stmt")(p);
                memo[tuple(`Error_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Error_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Error_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Error_stmt"), "Error_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("swap"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Swap_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Swap_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("swap"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Swap_stmt"), "Swap_stmt")(p);
                memo[tuple(`Swap_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Swap_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("swap"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Swap_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("swap"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Swap_stmt"), "Swap_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("input"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("#"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "XCBASIC.Input_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Input_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("input"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("#"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "XCBASIC.Input_stmt"), "Input_stmt")(p);
                memo[tuple(`Input_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Input_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("input"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("#"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "XCBASIC.Input_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("input"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("#"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing)), Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing))), "XCBASIC.Input_stmt"), "Input_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), Spacing)), "XCBASIC.Gosub_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Gosub_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), Spacing)), "XCBASIC.Gosub_stmt"), "Gosub_stmt")(p);
                memo[tuple(`Gosub_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Gosub_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), Spacing)), "XCBASIC.Gosub_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), Spacing)), "XCBASIC.Gosub_stmt"), "Gosub_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("call"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Call_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Call_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("call"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Call_stmt"), "Call_stmt")(p);
                memo[tuple(`Call_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Call_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("call"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Call_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("call"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Call_stmt"), "Call_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), "XCBASIC.Return_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Return_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), "XCBASIC.Return_stmt"), "Return_stmt")(p);
                memo[tuple(`Return_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Return_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), "XCBASIC.Return_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), "XCBASIC.Return_stmt"), "Return_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Return_fn_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Return_fn_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Return_fn_stmt"), "Return_fn_stmt")(p);
                memo[tuple(`Return_fn_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Return_fn_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Return_fn_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Return_fn_stmt"), "Return_fn_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("poke"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Poke_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Poke_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("poke"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Poke_stmt"), "Poke_stmt")(p);
                memo[tuple(`Poke_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Poke_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("poke"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Poke_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("poke"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Poke_stmt"), "Poke_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("do"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Do_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Do_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("do"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Do_stmt"), "Do_stmt")(p);
                memo[tuple(`Do_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Do_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("do"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Do_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("do"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Do_stmt"), "Do_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("loop"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Loop_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Loop_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("loop"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Loop_stmt"), "Loop_stmt")(p);
                memo[tuple(`Loop_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Loop_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("loop"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Loop_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("loop"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Loop_stmt"), "Loop_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("continue"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("do"), Spacing)), Spacing))), "XCBASIC.Cont_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Cont_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("continue"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("do"), Spacing)), Spacing))), "XCBASIC.Cont_stmt"), "Cont_stmt")(p);
                memo[tuple(`Cont_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Cont_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("continue"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("do"), Spacing)), Spacing))), "XCBASIC.Cont_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("continue"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("do"), Spacing)), Spacing))), "XCBASIC.Cont_stmt"), "Cont_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit do"), Spacing), "XCBASIC.Exit_do_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Exit_do_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit do"), Spacing), "XCBASIC.Exit_do_stmt"), "Exit_do_stmt")(p);
                memo[tuple(`Exit_do_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Exit_do_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit do"), Spacing), "XCBASIC.Exit_do_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit do"), Spacing), "XCBASIC.Exit_do_stmt"), "Exit_do_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rem"), Spacing)), Spacing), pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, eol, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), Spacing)), Spacing))), "XCBASIC.Rem_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Rem_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rem"), Spacing)), Spacing), pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, eol, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), Spacing)), Spacing))), "XCBASIC.Rem_stmt"), "Rem_stmt")(p);
                memo[tuple(`Rem_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Rem_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rem"), Spacing)), Spacing), pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, eol, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), Spacing)), Spacing))), "XCBASIC.Rem_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rem"), Spacing)), Spacing), pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, eol, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), Spacing)), Spacing))), "XCBASIC.Rem_stmt"), "Rem_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Varnosubscript, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("to"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("step"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.For_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`For_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Varnosubscript, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("to"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("step"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.For_stmt"), "For_stmt")(p);
                memo[tuple(`For_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree For_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Varnosubscript, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("to"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("step"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.For_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Varnosubscript, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("to"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("step"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.For_stmt"), "For_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("next"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Varname, Spacing))), "XCBASIC.Next_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Next_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("next"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Varname, Spacing))), "XCBASIC.Next_stmt"), "Next_stmt")(p);
                memo[tuple(`Next_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Next_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("next"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Varname, Spacing))), "XCBASIC.Next_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("next"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Varname, Spacing))), "XCBASIC.Next_stmt"), "Next_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit for"), Spacing), "XCBASIC.Exit_for_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Exit_for_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit for"), Spacing), "XCBASIC.Exit_for_stmt"), "Exit_for_stmt")(p);
                memo[tuple(`Exit_for_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Exit_for_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit for"), Spacing), "XCBASIC.Exit_for_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit for"), Spacing), "XCBASIC.Exit_for_stmt"), "Exit_for_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("dim"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("static"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varattrib, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@"), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing)), Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Varattrib, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing))), "XCBASIC.Dim_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Dim_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("dim"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("static"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varattrib, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@"), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing)), Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Varattrib, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing))), "XCBASIC.Dim_stmt"), "Dim_stmt")(p);
                memo[tuple(`Dim_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Dim_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("dim"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("static"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varattrib, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@"), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing)), Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Varattrib, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing))), "XCBASIC.Dim_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("dim"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("static"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varattrib, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@"), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing)), Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Varattrib, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing))), "XCBASIC.Dim_stmt"), "Dim_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("fast"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing)), "XCBASIC.Varattrib")(p);
        }
        else
        {
            if (auto m = tuple(`Varattrib`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("fast"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing)), "XCBASIC.Varattrib"), "Varattrib")(p);
                memo[tuple(`Varattrib`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Varattrib(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("fast"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing)), "XCBASIC.Varattrib")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("fast"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing)), "XCBASIC.Varattrib"), "Varattrib")(TParseTree("", false,[], s));
        }
    }
    static string Varattrib(GetName g)
    {
        return "XCBASIC.Varattrib";
    }

    static TParseTree Data_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("data"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Datalist, Spacing)), "XCBASIC.Data_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Data_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("data"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Datalist, Spacing)), "XCBASIC.Data_stmt"), "Data_stmt")(p);
                memo[tuple(`Data_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Data_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("data"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Datalist, Spacing)), "XCBASIC.Data_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("data"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Datalist, Spacing)), "XCBASIC.Data_stmt"), "Data_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("charat"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Charat_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Charat_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("charat"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Charat_stmt"), "Charat_stmt")(p);
                memo[tuple(`Charat_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Charat_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("charat"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Charat_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("charat"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Charat_stmt"), "Charat_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("textat"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), "XCBASIC.Textat_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Textat_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("textat"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), "XCBASIC.Textat_stmt"), "Textat_stmt")(p);
                memo[tuple(`Textat_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Textat_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("textat"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), "XCBASIC.Textat_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("textat"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), "XCBASIC.Textat_stmt"), "Textat_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Textat_stmt(GetName g)
    {
        return "XCBASIC.Textat_stmt";
    }

    static TParseTree Asm_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("asm"), Spacing), "XCBASIC.Asm_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Asm_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("asm"), Spacing), "XCBASIC.Asm_stmt"), "Asm_stmt")(p);
                memo[tuple(`Asm_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Asm_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("asm"), Spacing), "XCBASIC.Asm_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("asm"), Spacing), "XCBASIC.Asm_stmt"), "Asm_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end asm"), Spacing), "XCBASIC.Endasm_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Endasm_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end asm"), Spacing), "XCBASIC.Endasm_stmt"), "Endasm_stmt")(p);
                memo[tuple(`Endasm_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Endasm_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end asm"), Spacing), "XCBASIC.Endasm_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end asm"), Spacing), "XCBASIC.Endasm_stmt"), "Endasm_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("incbin"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, String, Spacing)), "XCBASIC.Incbin_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Incbin_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("incbin"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, String, Spacing)), "XCBASIC.Incbin_stmt"), "Incbin_stmt")(p);
                memo[tuple(`Incbin_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Incbin_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("incbin"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, String, Spacing)), "XCBASIC.Incbin_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("incbin"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, String, Spacing)), "XCBASIC.Incbin_stmt"), "Incbin_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("include"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, String, Spacing)), "XCBASIC.Include_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Include_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("include"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, String, Spacing)), "XCBASIC.Include_stmt"), "Include_stmt")(p);
                memo[tuple(`Include_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Include_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("include"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, String, Spacing)), "XCBASIC.Include_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("include"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, String, Spacing)), "XCBASIC.Include_stmt"), "Include_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit sub"), Spacing)), "XCBASIC.Exitfun_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Exitfun_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit sub"), Spacing)), "XCBASIC.Exitfun_stmt"), "Exitfun_stmt")(p);
                memo[tuple(`Exitfun_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Exitfun_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit sub"), Spacing)), "XCBASIC.Exitfun_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("exit sub"), Spacing)), "XCBASIC.Exitfun_stmt"), "Exitfun_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end sub"), Spacing)), "XCBASIC.Endfun_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Endfun_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end sub"), Spacing)), "XCBASIC.Endfun_stmt"), "Endfun_stmt")(p);
                memo[tuple(`Endfun_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Endfun_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end sub"), Spacing)), "XCBASIC.Endfun_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end sub"), Spacing)), "XCBASIC.Endfun_stmt"), "Endfun_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("declare"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sub"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Varnosubscript, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, VarList, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Funcattrib, Spacing)), Spacing))), "XCBASIC.Fun_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Fun_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("declare"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sub"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Varnosubscript, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, VarList, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Funcattrib, Spacing)), Spacing))), "XCBASIC.Fun_stmt"), "Fun_stmt")(p);
                memo[tuple(`Fun_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Fun_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("declare"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sub"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Varnosubscript, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, VarList, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Funcattrib, Spacing)), Spacing))), "XCBASIC.Fun_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("declare"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sub"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Varnosubscript, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, VarList, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Funcattrib, Spacing)), Spacing))), "XCBASIC.Fun_stmt"), "Fun_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("private"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("static"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("override"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("inline"), Spacing)), "XCBASIC.Funcattrib")(p);
        }
        else
        {
            if (auto m = tuple(`Funcattrib`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("private"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("static"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("override"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("inline"), Spacing)), "XCBASIC.Funcattrib"), "Funcattrib")(p);
                memo[tuple(`Funcattrib`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Funcattrib(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("private"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("static"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("override"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("inline"), Spacing)), "XCBASIC.Funcattrib")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("private"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("shared"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("static"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("override"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("inline"), Spacing)), "XCBASIC.Funcattrib"), "Funcattrib")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sys"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Sys_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Sys_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sys"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Sys_stmt"), "Sys_stmt")(p);
                memo[tuple(`Sys_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sys_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sys"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Sys_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sys"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Sys_stmt"), "Sys_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("load"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Load_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Load_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("load"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Load_stmt"), "Load_stmt")(p);
                memo[tuple(`Load_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Load_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("load"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Load_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("load"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Load_stmt"), "Load_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("save"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Save_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Save_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("save"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Save_stmt"), "Save_stmt")(p);
                memo[tuple(`Save_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Save_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("save"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Save_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("save"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Save_stmt"), "Save_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("origin"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Origin_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Origin_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("origin"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Origin_stmt"), "Origin_stmt")(p);
                memo[tuple(`Origin_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Origin_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("origin"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Origin_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("origin"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Origin_stmt"), "Origin_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("locate"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Locate_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Locate_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("locate"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Locate_stmt"), "Locate_stmt")(p);
                memo[tuple(`Locate_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Locate_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("locate"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Locate_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("locate"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Locate_stmt"), "Locate_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("on"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Branch_type, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing)), Spacing))), "XCBASIC.On_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`On_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("on"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Branch_type, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing)), Spacing))), "XCBASIC.On_stmt"), "On_stmt")(p);
                memo[tuple(`On_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree On_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("on"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Branch_type, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing)), Spacing))), "XCBASIC.On_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("on"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Branch_type, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Label_ref, Spacing)), Spacing))), "XCBASIC.On_stmt"), "On_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing)), "XCBASIC.Branch_type")(p);
        }
        else
        {
            if (auto m = tuple(`Branch_type`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing)), "XCBASIC.Branch_type"), "Branch_type")(p);
                memo[tuple(`Branch_type`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Branch_type(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing)), "XCBASIC.Branch_type")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing)), "XCBASIC.Branch_type"), "Branch_type")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("wait"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Wait_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Wait_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("wait"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Wait_stmt"), "Wait_stmt")(p);
                memo[tuple(`Wait_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Wait_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("wait"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Wait_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("wait"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.Wait_stmt"), "Wait_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Wait_stmt(GetName g)
    {
        return "XCBASIC.Wait_stmt";
    }

    static TParseTree Watch_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("watch"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Watch_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Watch_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("watch"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Watch_stmt"), "Watch_stmt")(p);
                memo[tuple(`Watch_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Watch_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("watch"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Watch_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("watch"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Watch_stmt"), "Watch_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Watch_stmt(GetName g)
    {
        return "XCBASIC.Watch_stmt";
    }

    static TParseTree Pragma_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("pragma"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Id, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Pragma_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Pragma_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("pragma"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Id, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Pragma_stmt"), "Pragma_stmt")(p);
                memo[tuple(`Pragma_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Pragma_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("pragma"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Id, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Pragma_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("pragma"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Id, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "XCBASIC.Pragma_stmt"), "Pragma_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Pragma_stmt(GetName g)
    {
        return "XCBASIC.Pragma_stmt";
    }

    static TParseTree Memset_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memset"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memset_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Memset_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memset"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memset_stmt"), "Memset_stmt")(p);
                memo[tuple(`Memset_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Memset_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memset"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memset_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memset"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memset_stmt"), "Memset_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memcpy"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memcpy_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Memcpy_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memcpy"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memcpy_stmt"), "Memcpy_stmt")(p);
                memo[tuple(`Memcpy_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Memcpy_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memcpy"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memcpy_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memcpy"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memcpy_stmt"), "Memcpy_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memshift"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memshift_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Memshift_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memshift"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memshift_stmt"), "Memshift_stmt")(p);
                memo[tuple(`Memshift_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Memshift_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memshift"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memshift_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memshift"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Memshift_stmt"), "Memshift_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Memshift_stmt(GetName g)
    {
        return "XCBASIC.Memshift_stmt";
    }

    static TParseTree Disableirq_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("disableirq"), Spacing), "XCBASIC.Disableirq_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Disableirq_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("disableirq"), Spacing), "XCBASIC.Disableirq_stmt"), "Disableirq_stmt")(p);
                memo[tuple(`Disableirq_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Disableirq_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("disableirq"), Spacing), "XCBASIC.Disableirq_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("disableirq"), Spacing), "XCBASIC.Disableirq_stmt"), "Disableirq_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Disableirq_stmt(GetName g)
    {
        return "XCBASIC.Disableirq_stmt";
    }

    static TParseTree Enableirq_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("enableirq"), Spacing), "XCBASIC.Enableirq_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Enableirq_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("enableirq"), Spacing), "XCBASIC.Enableirq_stmt"), "Enableirq_stmt")(p);
                memo[tuple(`Enableirq_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Enableirq_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("enableirq"), Spacing), "XCBASIC.Enableirq_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("enableirq"), Spacing), "XCBASIC.Enableirq_stmt"), "Enableirq_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Enableirq_stmt(GetName g)
    {
        return "XCBASIC.Enableirq_stmt";
    }

    static TParseTree Randomize_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("randomize"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Randomize_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Randomize_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("randomize"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Randomize_stmt"), "Randomize_stmt")(p);
                memo[tuple(`Randomize_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Randomize_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("randomize"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Randomize_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("randomize"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Randomize_stmt"), "Randomize_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("open"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Open_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Open_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("open"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Open_stmt"), "Open_stmt")(p);
                memo[tuple(`Open_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Open_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("open"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Open_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("open"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, ExprList, Spacing)), "XCBASIC.Open_stmt"), "Open_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("get"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("#"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing)), "XCBASIC.Get_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Get_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("get"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("#"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing)), "XCBASIC.Get_stmt"), "Get_stmt")(p);
                memo[tuple(`Get_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Get_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("get"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("#"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing)), "XCBASIC.Get_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("get"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("#"), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing)), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing)), "XCBASIC.Get_stmt"), "Get_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("close"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Close_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Close_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("close"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Close_stmt"), "Close_stmt")(p);
                memo[tuple(`Close_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Close_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("close"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Close_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("close"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), "XCBASIC.Close_stmt"), "Close_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("type"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Id, Spacing)), "XCBASIC.Type_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Type_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("type"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Id, Spacing)), "XCBASIC.Type_stmt"), "Type_stmt")(p);
                memo[tuple(`Type_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Type_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("type"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Id, Spacing)), "XCBASIC.Type_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("type"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Id, Spacing)), "XCBASIC.Type_stmt"), "Type_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, Var, Spacing), "XCBASIC.Field_def")(p);
        }
        else
        {
            if (auto m = tuple(`Field_def`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, Var, Spacing), "XCBASIC.Field_def"), "Field_def")(p);
                memo[tuple(`Field_def`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Field_def(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, Var, Spacing), "XCBASIC.Field_def")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, Var, Spacing), "XCBASIC.Field_def"), "Field_def")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end type"), Spacing), "XCBASIC.Endtype_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Endtype_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end type"), Spacing), "XCBASIC.Endtype_stmt"), "Endtype_stmt")(p);
                memo[tuple(`Endtype_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Endtype_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end type"), Spacing), "XCBASIC.Endtype_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end type"), Spacing), "XCBASIC.Endtype_stmt"), "Endtype_stmt")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end"), Spacing), "XCBASIC.End_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`End_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end"), Spacing), "XCBASIC.End_stmt"), "End_stmt")(p);
                memo[tuple(`End_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree End_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end"), Spacing), "XCBASIC.End_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end"), Spacing), "XCBASIC.End_stmt"), "End_stmt")(TParseTree("", false,[], s));
        }
    }
    static string End_stmt(GetName g)
    {
        return "XCBASIC.End_stmt";
    }

    static TParseTree ExprList(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.ExprList")(p);
        }
        else
        {
            if (auto m = tuple(`ExprList`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.ExprList"), "ExprList")(p);
                memo[tuple(`ExprList`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree ExprList(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.ExprList")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing))), "XCBASIC.ExprList"), "ExprList")(TParseTree("", false,[], s));
        }
    }
    static string ExprList(GetName g)
    {
        return "XCBASIC.ExprList";
    }

    static TParseTree PrintableList(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, TabSep, Spacing), pegged.peg.wrapAround!(Spacing, NlSupp, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, NlSupp, Spacing))), "XCBASIC.PrintableList")(p);
        }
        else
        {
            if (auto m = tuple(`PrintableList`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, TabSep, Spacing), pegged.peg.wrapAround!(Spacing, NlSupp, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, NlSupp, Spacing))), "XCBASIC.PrintableList"), "PrintableList")(p);
                memo[tuple(`PrintableList`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree PrintableList(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, TabSep, Spacing), pegged.peg.wrapAround!(Spacing, NlSupp, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, NlSupp, Spacing))), "XCBASIC.PrintableList")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, TabSep, Spacing), pegged.peg.wrapAround!(Spacing, NlSupp, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, NlSupp, Spacing))), "XCBASIC.PrintableList"), "PrintableList")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), "XCBASIC.TabSep")(p);
        }
        else
        {
            if (auto m = tuple(`TabSep`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), "XCBASIC.TabSep"), "TabSep")(p);
                memo[tuple(`TabSep`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree TabSep(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), "XCBASIC.TabSep")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), "XCBASIC.TabSep"), "TabSep")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing), "XCBASIC.NlSupp")(p);
        }
        else
        {
            if (auto m = tuple(`NlSupp`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing), "XCBASIC.NlSupp"), "NlSupp")(p);
                memo[tuple(`NlSupp`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree NlSupp(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing), "XCBASIC.NlSupp")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(";"), Spacing), "XCBASIC.NlSupp"), "NlSupp")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing)), Spacing))), "XCBASIC.VarList")(p);
        }
        else
        {
            if (auto m = tuple(`VarList`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing)), Spacing))), "XCBASIC.VarList"), "VarList")(p);
                memo[tuple(`VarList`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree VarList(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing)), Spacing))), "XCBASIC.VarList")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Var, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Var, Spacing)), Spacing))), "XCBASIC.VarList"), "VarList")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Datalist")(p);
        }
        else
        {
            if (auto m = tuple(`Datalist`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Datalist"), "Datalist")(p);
                memo[tuple(`Datalist`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Datalist(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Datalist")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing)), Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Datalist"), "Datalist")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, BW_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Expression")(p);
        }
        else
        {
            if (blockMemoAtPos.canFind(p.end))
                return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, BW_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Expression"), "Expression")(p);
            if (auto m = tuple(`Expression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, BW_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Expression"), "Expression")(p);
                memo[tuple(`Expression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Expression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, BW_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Expression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, BW_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Expression"), "Expression")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, REL_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Relation")(p);
        }
        else
        {
            if (blockMemoAtPos.canFind(p.end))
                return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, REL_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Relation"), "Relation")(p);
            if (auto m = tuple(`Relation`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, REL_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Relation"), "Relation")(p);
                memo[tuple(`Relation`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Relation(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, REL_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Relation")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, REL_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Relation"), "Relation")(TParseTree("", false,[], s));
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
                auto result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Term, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, E_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Term, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Simplexp"), "Simplexp")(p);
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Term, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, E_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Term, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Simplexp")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Term, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, E_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Term, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Simplexp"), "Simplexp")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, T_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Term")(p);
        }
        else
        {
            if (blockMemoAtPos.canFind(p.end))
                return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, T_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Term"), "Term")(p);
            if (auto m = tuple(`Term`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, T_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Term"), "Term")(p);
                memo[tuple(`Term`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Term(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, T_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Term")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, T_OP, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)))), Spacing))), "XCBASIC.Term"), "Term")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Parenthesis, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Address, Spacing)), Spacing)), "XCBASIC.Factor")(p);
        }
        else
        {
            if (blockMemoAtPos.canFind(p.end))
                return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Parenthesis, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Address, Spacing)), Spacing)), "XCBASIC.Factor"), "Factor")(p);
            if (auto m = tuple(`Factor`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Parenthesis, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Address, Spacing)), Spacing)), "XCBASIC.Factor"), "Factor")(p);
                memo[tuple(`Factor`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Factor(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Parenthesis, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Address, Spacing)), Spacing)), "XCBASIC.Factor")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Parenthesis, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, UN_OP, Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Address, Spacing)), Spacing)), "XCBASIC.Factor"), "Factor")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("not"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), Spacing), "XCBASIC.UN_OP")(p);
        }
        else
        {
            if (auto m = tuple(`UN_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("not"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), Spacing), "XCBASIC.UN_OP"), "UN_OP")(p);
                memo[tuple(`UN_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree UN_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("not"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), Spacing), "XCBASIC.UN_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("not"), Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), Spacing), "XCBASIC.UN_OP"), "UN_OP")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("*"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("/"), Spacing)), Spacing), "XCBASIC.T_OP")(p);
        }
        else
        {
            if (auto m = tuple(`T_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("*"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("/"), Spacing)), Spacing), "XCBASIC.T_OP"), "T_OP")(p);
                memo[tuple(`T_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree T_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("*"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("/"), Spacing)), Spacing), "XCBASIC.T_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("*"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("/"), Spacing)), Spacing), "XCBASIC.T_OP"), "T_OP")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), Spacing), "XCBASIC.E_OP")(p);
        }
        else
        {
            if (auto m = tuple(`E_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), Spacing), "XCBASIC.E_OP"), "E_OP")(p);
                memo[tuple(`E_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree E_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), Spacing), "XCBASIC.E_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), Spacing), "XCBASIC.E_OP"), "E_OP")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("and"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("or"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("xor"), Spacing)), Spacing), "XCBASIC.BW_OP")(p);
        }
        else
        {
            if (auto m = tuple(`BW_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("and"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("or"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("xor"), Spacing)), Spacing), "XCBASIC.BW_OP"), "BW_OP")(p);
                memo[tuple(`BW_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree BW_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("and"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("or"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("xor"), Spacing)), Spacing), "XCBASIC.BW_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("and"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("or"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("xor"), Spacing)), Spacing), "XCBASIC.BW_OP"), "BW_OP")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.longest_match!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<>"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing)), "XCBASIC.REL_OP")(p);
        }
        else
        {
            if (auto m = tuple(`REL_OP`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.longest_match!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<>"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing)), "XCBASIC.REL_OP"), "REL_OP")(p);
                memo[tuple(`REL_OP`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree REL_OP(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.longest_match!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<>"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing)), "XCBASIC.REL_OP")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.longest_match!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<>"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing)), "XCBASIC.REL_OP"), "REL_OP")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "XCBASIC.Parenthesis")(p);
        }
        else
        {
            if (auto m = tuple(`Parenthesis`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "XCBASIC.Parenthesis"), "Parenthesis")(p);
                memo[tuple(`Parenthesis`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Parenthesis(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "XCBASIC.Parenthesis")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing)), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.discard!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing))), "XCBASIC.Parenthesis"), "Parenthesis")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing))), "XCBASIC.Varnosubscript")(p);
        }
        else
        {
            if (auto m = tuple(`Varnosubscript`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing))), "XCBASIC.Varnosubscript"), "Varnosubscript")(p);
                memo[tuple(`Varnosubscript`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Varnosubscript(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing))), "XCBASIC.Varnosubscript")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing))), "XCBASIC.Varnosubscript"), "Varnosubscript")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing))), "XCBASIC.Var")(p);
        }
        else
        {
            if (auto m = tuple(`Var`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing))), "XCBASIC.Var"), "Var")(p);
                memo[tuple(`Var`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Var(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing))), "XCBASIC.Var")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing))), "XCBASIC.Var"), "Var")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@"), Spacing), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Address")(p);
        }
        else
        {
            if (auto m = tuple(`Address`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@"), Spacing), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Address"), "Address")(p);
                memo[tuple(`Address`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Address(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@"), Spacing), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Address")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@"), Spacing), pegged.peg.wrapAround!(Spacing, Accessor, Spacing)), "XCBASIC.Address"), "Address")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing)), pegged.peg.wrapAround!(Spacing, Varname, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing))), "XCBASIC.Accessor")(p);
        }
        else
        {
            if (auto m = tuple(`Accessor`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing)), pegged.peg.wrapAround!(Spacing, Varname, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing))), "XCBASIC.Accessor"), "Accessor")(p);
                memo[tuple(`Accessor`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Accessor(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing)), pegged.peg.wrapAround!(Spacing, Varname, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing))), "XCBASIC.Accessor")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Varname, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing)), pegged.peg.wrapAround!(Spacing, Varname, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Subscript, Spacing))), "XCBASIC.Accessor"), "Accessor")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("*"), pegged.peg.discard!(pegged.peg.option!(WS)), Number), "XCBASIC.Str_typeLen")(p);
        }
        else
        {
            if (auto m = tuple(`Str_typeLen`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("*"), pegged.peg.discard!(pegged.peg.option!(WS)), Number), "XCBASIC.Str_typeLen"), "Str_typeLen")(p);
                memo[tuple(`Str_typeLen`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Str_typeLen(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("*"), pegged.peg.discard!(pegged.peg.option!(WS)), Number), "XCBASIC.Str_typeLen")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("*"), pegged.peg.discard!(pegged.peg.option!(WS)), Number), "XCBASIC.Str_typeLen"), "Str_typeLen")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, doublequote, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, doublequote, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), pegged.peg.keep!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(" "), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, doublequote, Spacing)), "XCBASIC.String")(p);
        }
        else
        {
            if (auto m = tuple(`String`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, doublequote, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, doublequote, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), pegged.peg.keep!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(" "), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, doublequote, Spacing)), "XCBASIC.String"), "String")(p);
                memo[tuple(`String`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree String(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, doublequote, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, doublequote, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), pegged.peg.keep!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(" "), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, doublequote, Spacing)), "XCBASIC.String")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, doublequote, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, doublequote, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), pegged.peg.keep!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(" "), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, doublequote, Spacing)), "XCBASIC.String"), "String")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing)), "XCBASIC.Unsigned")(p);
        }
        else
        {
            if (auto m = tuple(`Unsigned`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing)), "XCBASIC.Unsigned"), "Unsigned")(p);
                memo[tuple(`Unsigned`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Unsigned(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing)), "XCBASIC.Unsigned")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing)), "XCBASIC.Unsigned"), "Unsigned")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("d"), Spacing)), "XCBASIC.Decimal")(p);
        }
        else
        {
            if (auto m = tuple(`Decimal`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("d"), Spacing)), "XCBASIC.Decimal"), "Decimal")(p);
                memo[tuple(`Decimal`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Decimal(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("d"), Spacing)), "XCBASIC.Decimal")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("d"), Spacing)), "XCBASIC.Decimal"), "Decimal")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), "XCBASIC.Integer")(p);
        }
        else
        {
            if (auto m = tuple(`Integer`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), "XCBASIC.Integer"), "Integer")(p);
                memo[tuple(`Integer`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Integer(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), "XCBASIC.Integer")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), "XCBASIC.Integer"), "Integer")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("$"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), Spacing))), "XCBASIC.Hexa")(p);
        }
        else
        {
            if (auto m = tuple(`Hexa`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("$"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), Spacing))), "XCBASIC.Hexa"), "Hexa")(p);
                memo[tuple(`Hexa`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Hexa(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("$"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), Spacing))), "XCBASIC.Hexa")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("$"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), Spacing))), "XCBASIC.Hexa"), "Hexa")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("%"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("0"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("1"), Spacing)), Spacing))), "XCBASIC.Binary")(p);
        }
        else
        {
            if (auto m = tuple(`Binary`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("%"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("0"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("1"), Spacing)), Spacing))), "XCBASIC.Binary"), "Binary")(p);
                memo[tuple(`Binary`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Binary(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("%"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("0"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("1"), Spacing)), Spacing))), "XCBASIC.Binary")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("%"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("0"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("1"), Spacing)), Spacing))), "XCBASIC.Binary"), "Binary")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Floating, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("e"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("E"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Integer, Spacing)), "XCBASIC.Scientific")(p);
        }
        else
        {
            if (auto m = tuple(`Scientific`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Floating, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("e"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("E"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Integer, Spacing)), "XCBASIC.Scientific"), "Scientific")(p);
                memo[tuple(`Scientific`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Scientific(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Floating, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("e"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("E"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Integer, Spacing)), "XCBASIC.Scientific")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Floating, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("e"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("E"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Integer, Spacing)), "XCBASIC.Scientific"), "Scientific")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), "XCBASIC.Floating")(p);
        }
        else
        {
            if (auto m = tuple(`Floating`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), "XCBASIC.Floating"), "Floating")(p);
                memo[tuple(`Floating`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Floating(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), "XCBASIC.Floating")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing)), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing)), "XCBASIC.Floating"), "Floating")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'{"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}'"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing)), Spacing)), "XCBASIC.Charlit")(p);
        }
        else
        {
            if (auto m = tuple(`Charlit`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'{"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}'"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing)), Spacing)), "XCBASIC.Charlit"), "Charlit")(p);
                memo[tuple(`Charlit`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Charlit(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'{"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}'"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing)), Spacing)), "XCBASIC.Charlit")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'{"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}'"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing)), Spacing)), "XCBASIC.Charlit"), "Charlit")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Decimal, Spacing), pegged.peg.wrapAround!(Spacing, Scientific, Spacing), pegged.peg.wrapAround!(Spacing, Floating, Spacing), pegged.peg.wrapAround!(Spacing, Integer, Spacing), pegged.peg.wrapAround!(Spacing, Hexa, Spacing), pegged.peg.wrapAround!(Spacing, Binary, Spacing), pegged.peg.wrapAround!(Spacing, Charlit, Spacing)), Spacing), "XCBASIC.Number")(p);
        }
        else
        {
            if (auto m = tuple(`Number`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Decimal, Spacing), pegged.peg.wrapAround!(Spacing, Scientific, Spacing), pegged.peg.wrapAround!(Spacing, Floating, Spacing), pegged.peg.wrapAround!(Spacing, Integer, Spacing), pegged.peg.wrapAround!(Spacing, Hexa, Spacing), pegged.peg.wrapAround!(Spacing, Binary, Spacing), pegged.peg.wrapAround!(Spacing, Charlit, Spacing)), Spacing), "XCBASIC.Number"), "Number")(p);
                memo[tuple(`Number`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Number(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Decimal, Spacing), pegged.peg.wrapAround!(Spacing, Scientific, Spacing), pegged.peg.wrapAround!(Spacing, Floating, Spacing), pegged.peg.wrapAround!(Spacing, Integer, Spacing), pegged.peg.wrapAround!(Spacing, Hexa, Spacing), pegged.peg.wrapAround!(Spacing, Binary, Spacing), pegged.peg.wrapAround!(Spacing, Charlit, Spacing)), Spacing), "XCBASIC.Number")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Decimal, Spacing), pegged.peg.wrapAround!(Spacing, Scientific, Spacing), pegged.peg.wrapAround!(Spacing, Floating, Spacing), pegged.peg.wrapAround!(Spacing, Integer, Spacing), pegged.peg.wrapAround!(Spacing, Hexa, Spacing), pegged.peg.wrapAround!(Spacing, Binary, Spacing), pegged.peg.wrapAround!(Spacing, Charlit, Spacing)), Spacing), "XCBASIC.Number"), "Number")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), "XCBASIC.Label")(p);
        }
        else
        {
            if (auto m = tuple(`Label`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), "XCBASIC.Label"), "Label")(p);
                memo[tuple(`Label`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Label(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), "XCBASIC.Label")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing)), "XCBASIC.Label"), "Label")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing))), "XCBASIC.Label_ref")(p);
        }
        else
        {
            if (auto m = tuple(`Label_ref`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing))), "XCBASIC.Label_ref"), "Label_ref")(p);
                memo[tuple(`Label_ref`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Label_ref(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing))), "XCBASIC.Label_ref")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9')), Spacing))), "XCBASIC.Label_ref"), "Label_ref")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, eps, Spacing)), Spacing), "XCBASIC.Line_id")(p);
        }
        else
        {
            if (auto m = tuple(`Line_id`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, eps, Spacing)), Spacing), "XCBASIC.Line_id"), "Line_id")(p);
                memo[tuple(`Line_id`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Line_id(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, eps, Spacing)), Spacing), "XCBASIC.Line_id")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Label, Spacing), pegged.peg.wrapAround!(Spacing, Unsigned, Spacing), pegged.peg.wrapAround!(Spacing, eps, Spacing)), Spacing), "XCBASIC.Line_id"), "Line_id")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("const"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("let"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("print"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("input"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("call"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rem"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("to"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("next"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("dim"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("data"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("charat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("textat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("incbin"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sys"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("and"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("origin"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("or"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("load"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("save"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("ferr"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sub"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("asm"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("endasm"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("locate"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("wait"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("watch"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("pragma"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memset"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memcpy"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("endwhile"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("repeat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("lshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("disableirq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("enableirq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("step"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("randomize"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("open"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("close"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("get"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing)), Spacing), "XCBASIC.Reserved")(p);
        }
        else
        {
            if (auto m = tuple(`Reserved`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("const"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("let"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("print"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("input"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("call"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rem"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("to"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("next"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("dim"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("data"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("charat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("textat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("incbin"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sys"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("and"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("origin"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("or"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("load"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("save"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("ferr"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sub"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("asm"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("endasm"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("locate"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("wait"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("watch"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("pragma"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memset"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memcpy"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("endwhile"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("repeat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("lshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("disableirq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("enableirq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("step"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("randomize"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("open"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("close"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("get"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing)), Spacing), "XCBASIC.Reserved"), "Reserved")(p);
                memo[tuple(`Reserved`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Reserved(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("const"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("let"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("print"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("input"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("call"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rem"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("to"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("next"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("dim"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("data"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("charat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("textat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("incbin"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sys"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("and"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("origin"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("or"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("load"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("save"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("ferr"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sub"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("asm"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("endasm"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("locate"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("wait"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("watch"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("pragma"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memset"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memcpy"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("endwhile"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("repeat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("lshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("disableirq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("enableirq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("step"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("randomize"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("open"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("close"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("get"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing)), Spacing), "XCBASIC.Reserved")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("const"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("let"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("print"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("if"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("then"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("goto"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("input"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("gosub"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("return"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("call"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("end"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rem"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("for"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("to"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("next"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("dim"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("data"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("charat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("textat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("incbin"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sys"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("and"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("origin"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("or"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("load"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("save"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("ferr"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("sub"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("function"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("asm"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("endasm"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("locate"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("wait"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("watch"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("pragma"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memset"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memcpy"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("memshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("while"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("endwhile"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("repeat"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("until"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("lshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("rshift"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("disableirq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("enableirq"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("step"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("randomize"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("open"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("close"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("get"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.caseInsensitiveLiteral!("error"), Spacing)), Spacing), "XCBASIC.Reserved"), "Reserved")(TParseTree("", false,[], s));
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
            return         pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, space, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("~"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\r"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\n"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\r\n"), Spacing)), Spacing)))), Spacing)), "XCBASIC.WS")(p);
        }
        else
        {
            if (auto m = tuple(`WS`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, space, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("~"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\r"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\n"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\r\n"), Spacing)), Spacing)))), Spacing)), "XCBASIC.WS"), "WS")(p);
                memo[tuple(`WS`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree WS(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, space, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("~"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\r"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\n"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\r\n"), Spacing)), Spacing)))), Spacing)), "XCBASIC.WS")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, space, Spacing), pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("~"), Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\r"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\n"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("\r\n"), Spacing)), Spacing)))), Spacing)), "XCBASIC.WS"), "WS")(TParseTree("", false,[], s));
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

    static TParseTree NL(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.literal!("~")), pegged.peg.oneOrMore!(pegged.peg.keywords!("\r", "\n", "\r\n"))), "XCBASIC.NL")(p);
        }
        else
        {
            if (auto m = tuple(`NL`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.literal!("~")), pegged.peg.oneOrMore!(pegged.peg.keywords!("\r", "\n", "\r\n"))), "XCBASIC.NL"), "NL")(p);
                memo[tuple(`NL`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree NL(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.literal!("~")), pegged.peg.oneOrMore!(pegged.peg.keywords!("\r", "\n", "\r\n"))), "XCBASIC.NL")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.literal!("~")), pegged.peg.oneOrMore!(pegged.peg.keywords!("\r", "\n", "\r\n"))), "XCBASIC.NL"), "NL")(TParseTree("", false,[], s));
        }
    }
    static string NL(GetName g)
    {
        return "XCBASIC.NL";
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


