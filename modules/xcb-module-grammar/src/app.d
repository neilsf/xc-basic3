import pegged.grammar;
import std.stdio;

/**
 * This program generates pre-compiled grammar for XC=BASIC
 *
 * Usage: ./xcb-module-grammar > ../../source/language/grammar.d
 */

void main(string[] args)
{
    string s = "module language.grammar;\n\nimport pegged.grammar;\n\n";
    s ~= grammar(`
        XCBASIC:
            Program <- Line (endOfLine+ Line)* EOI
            Line <- :WS? Line_id :WS? Statements? :WS?
            
            Statements <- Statement (:WS? ":" :WS? Statement)*

            Statement <- (Const_stmt | Let_stmt | Print_stmt | If_stmt | Goto_stmt | Input_stmt | Gosub_stmt | Call_stmt |
                        Rem_stmt | Poke_stmt | For_stmt | Next_stmt | Dim_stmt | Charat_stmt | Data_stmt | Textat_stmt | Incbin_stmt |
                        Include_stmt | Load_stmt | Save_stmt | Randomize_stmt |
                        Origin_stmt | Swap_stmt | Locate_stmt | On_stmt | Error_stmt | Wait_stmt |
                         Memset_stmt | Memcpy_stmt | Memshift_stmt | Open_stmt | Close_stmt | Get_stmt |
                        If_sa_stmt | Else_stmt | Endif_stmt | Fun_stmt | Endfun_stmt | Return_fn_stmt | Return_stmt | Exitfun_stmt | Do_stmt | Loop_stmt |
                        Asm_stmt | Endasm_stmt | Print_hash_stmt | Write_stmt | Read_stmt |
                        Cont_stmt |  Exit_do_stmt | Exit_for_stmt | Type_stmt | Endtype_stmt | Endselect_stmt | End_stmt |
                        Screen_stmt | Option_stmt | Sprite_clearhit_stmt | Sprite_multicolor_stmt | Sprite_stmt |
                        Sound_clear_stmt | Volume_stmt | Voice_stmt | Filter_stmt | Irq_stmt | Border_stmt | Background_stmt | Sys_stmt |
                        Charset_stmt | Scroll_stmt | VMode_stmt | Field_def |
                        Select_stmt | Case_stmt)
            Const_stmt <-    ("shared"i :WS)? "const"i :WS Varnosubscript :WS? "=" :WS? Number
            Let_stmt <-      (("let"i :WS) / eps) Accessor :WS? "=" :WS? Expression
            Print_stmt <-    "print"i :WS? PrintableList :WS? ";"?
            Print_hash_stmt <- "print"i :WS? "#" :WS? ExprList :WS? ";"?
            Write_stmt      <- "write"i :WS? "#" :WS? ExprList
            Read_stmt       <- "read"i :WS? "#" :WS? Expression  :WS? "," :WS? AccessorList
            If_stmt <-       "if"i :WS Expression :WS "then"i :WS Statements (:WS? "else"i :WS Statements)?
            If_sa_stmt <-    "if"i :WS Expression :WS "then"i
            Else_stmt <-     "else"i
            Endif_stmt <-    "end if"i
            Goto_stmt <-     "goto"i :WS (Label_ref / Unsigned)
            Error_stmt <-    "error"i :WS Expression
            Swap_stmt <-     "swap"i :WS Accessor :WS? "," :WS? Accessor
            Input_stmt <-    "input"i :WS (("#" :WS? Expression :WS? ",")  / (String :WS? ";"))? :WS? AccessorList :WS? ";"?
            Gosub_stmt <-    "gosub"i :WS (Label_ref / Unsigned)
            Call_stmt <-     "call"i :WS Accessor
            Return_stmt <-   "return"i
            Return_fn_stmt <- "return"i :WS Expression
            Poke_stmt <-     ("poke"i / "doke"i) :WS Expression :WS? "," :WS? Expression
            Do_stmt <-       "do"i (:WS ("while"i / "until"i) :WS Expression)?
            Loop_stmt <-     "loop"i (:WS ("while"i / "until"i) :WS Expression)?
            Cont_stmt <-     "continue"i :WS ("for"i / "do"i)?
            Exit_do_stmt <-  "exit do"i
            Rem_stmt <-      "rem"i ~((!eol .)*)
            For_stmt <-      "for"i :WS Varnosubscript :WS? "=" :WS? Expression :WS? "to"i :WS? Expression (:WS? "step"i :WS? Expression)?
            Next_stmt <-     "next"i (:WS Varname)?
            Exit_for_stmt <- "exit for"i
            Dim_stmt <-      ("dim"i / "static"i) :WS (Varattrib :WS)* Vardef (:WS? "," :WS? Vardef)* (:WS? Varattrib)*
                Varattrib <- "fast"i / "shared"i
                Vardef <- Var (:WS? :"@" :WS? (Number / Label_ref))?
            Data_stmt <-     ("shared"i :WS)? "data"i Vartype :WS Datalist
            Charat_stmt <-   "charat"i :WS ExprList
            Textat_stmt <-   "textat"i :WS ExprList
            Screen_stmt <-   "screen"i :WS Expression
            Asm_stmt <-      "asm"i
            Endasm_stmt <-   "end asm"i
            Incbin_stmt <-   "incbin"i :WS String
            Include_stmt <-  "include"i :WS String
            Exitfun_stmt <-  "exit function"i  / "exit sub"i
            Endfun_stmt <-   "end function"i / "end sub"i
            Fun_stmt <-      ("declare"i :WS)? ("function"i / "sub"i) :WS Varnosubscript :WS? :"(" :WS? VarList? :WS? :")" (:WS Funcattrib)*
                Funcattrib <- "private"i / "shared"i / "static"i / "overload"i / "inline"i
            Sys_stmt <-      "sys"i :WS Expression (:WS? "fast"i)?
            Load_stmt <-     "load"i :WS ExprList
            Save_stmt <-     "save"i :WS ExprList
            Origin_stmt <-   "origin"i :WS (Number / Label_ref)
            Locate_stmt <-   "locate"i :WS Expression :WS? "," :WS? Expression
            On_stmt <-       "on"i :WS (Expression / "error"i / "timer"i / "sprite"i / "background"i / "raster"i) (:WS Expression)? :WS Branch_type :WS Label_ref (:WS? "," :WS? Label_ref)*
                Branch_type <- "goto"i / "gosub"i
            Wait_stmt <-     "wait"i :WS? Expression :WS? "," :WS? Expression (:WS? "," :WS? Expression)?
            Memset_stmt <-   "memset"i :WS? ExprList
            Memcpy_stmt <-   "memcpy"i :WS? ExprList
            Memshift_stmt <- "memshift"i :WS? ExprList
            Randomize_stmt <-  "randomize"i :WS Expression
            Open_stmt <- "open"i :WS ExprList
            Get_stmt <- "get"i (:WS? "#" :WS? Expression :WS? ",")? :WS? Var
            Close_stmt <- "close"i :WS Expression
            Type_stmt <- "type"i :WS Id
            Field_def <- Var
            Endtype_stmt <- "end type"i
            End_stmt <-      "end"i
            Option_stmt <-   "option"i :WS Id (:WS? "=" :WS? (Number / String))?

            Select_stmt <- "select case"i :WS Expression
            Case_stmt <- Case_else_stmt / Case_is_stmt / Case_range_stmt / Case_set_stmt
                Case_is_stmt <- "case is"i :WS? REL_OP :WS? Expression
                Case_range_stmt <- "case"i :WS Expression :WS "to"i :WS Expression
                Case_set_stmt <- "case"i :WS ExprList
                Case_else_stmt <- "case else"i
            Endselect_stmt <- "end select"i

            Irq_stmt <- ("timer"i / "raster"i / "sprite"i / "background"i / "system"i) :WS "interrupt"i :WS ("on"i / "off"i)
            
            Sprite_stmt <-   "sprite"i :WS Expression (:WS SprSubCmd)*
                SprSubCmd <-  SprSubCmdOnUnderBg /SprSubCmdOnOff / 
							SprSubCmdAt / SprSubCmdColor /
                             SprSubCmdHiresMulti /
                             SprSubCmdShape / SprSubCmdXYSize
                    SprSubCmdOnOff <- "on"i / "off"i
                    SprSubCmdAt <- "at"i :WS ExprList
                    SprSubCmdColor <- "color"i :WS Expression
                    SprSubCmdHiresMulti <- "hires"i / "multi"i
                    SprSubCmdOnUnderBg <- ("on"i | "under"i) :WS "background"i
                    SprSubCmdShape <- "shape"i :WS Expression
                    SprSubCmdXYSize <- "xysize"i :WS ExprList
            Sprite_clearhit_stmt <- "sprite"i :WS "clear"i :WS "hit"i
            Sprite_multicolor_stmt <- "sprite"i :WS "multicolor"i :WS ExprList
            
            Border_stmt <-  "border"i :WS ExprList
            Background_stmt <-  "background"i :WS ExprList

            Sound_clear_stmt <- "sound"i :WS "clear"i
            Volume_stmt <- "volume"i :WS Expression
            Voice_stmt <- "voice"i :WS Number (:WS VoiceSubCmd)+
                VoiceSubCmd <- VoiceSubCmdOnOff / VoiceSubCmdADSR /
                              VoiceSubCmdTone / VoiceSubCmdWave / VoiceSubCmdPulse /
                              VoiceSubCmdFilterOnOff
                    VoiceSubCmdOnOff <- "on"i / "off"i
                    VoiceSubCmdADSR <- "adsr"i :WS ExprList
                    VoiceSubCmdTone <- "tone"i :WS Expression
                    VoiceSubCmdWave <- "wave"i :WS ("saw"i / "tri"i / "pulse"i / "noise"i )
                    VoiceSubCmdPulse <- "pulse"i :WS Expression
                    VoiceSubCmdFilterOnOff <- "filter"i :WS ("on"i / "off"i)
            Filter_stmt <- "filter"i (:WS FilterSubCmd)+
                FilterSubCmd <- FilterSubCmdCutoff / FilterSubCmdResonance /
                                FilterSubCmdPass
                    FilterSubCmdCutoff <- "cutoff"i :WS Expression
                    FilterSubCmdResonance <- "resonance"i :WS Expression
                    FilterSubCmdPass <-  ("low"i / "band"i / "high"i) :WS "pass"i

            Charset_stmt <- "charset"i (:WS "rom"i / "ram"i)? :WS Expression
            Scroll_stmt <- ("h"i / "v"i) "scroll"i :WS Expression
            VMode_stmt <- "vmode"i (:WS VModeSubCmd)+
                VModeSubCmd <- VModeSubCmdTextBitmap / VModeSubCmdColor /
                                VModeSubCmdRsel / VModeSubCmdCsel
                    VModeSubCmdTextBitmap <- "text"i / "bitmap"i / "ext"i
                    VModeSubCmdColor <- "hires"i / "multi"i
                    VModeSubCmdRsel <- "rows"i :WS Expression
                    VModeSubCmdCsel <- "cols"i :WS Expression

            ExprList <- Expression (:WS? "," :WS? Expression)*
            AccessorList <- Accessor (:WS? "," :WS? Accessor)*
            PrintableList <- Expression :WS? (:WS? (TabSep / NlSupp) :WS? Expression)* NlSupp?
            TabSep <- ","
            NlSupp <- ";"
            VarList <- Var (:WS? "," :WS? Var)*
            Datalist <- (Number / String / Label_deref / Varname) (:WS? "," :WS? (Number / String / Label_deref / Varname) :WS?)*

            Expression <- Relation (:WS? BW_OP :WS? Relation)*
            Relation <- Simplexp (:WS? REL_OP :WS? Simplexp)?
            Simplexp <- Term (:WS? E_OP :WS? Term)*
            Term <- Factor (:WS? T_OP :WS? Factor)*
            Factor <- (UN_OP? :WS? Accessor) / Number / (UN_OP? :WS? Parenthesis) / String / (UN_OP? :WS? Expression) / (UN_OP? :WS? Address)
            
            UN_OP <- ("-" / ("not"i :WS))
            T_OP <- ("*" / "/" / "mod"i)
            E_OP <- ("+" / "-")
            BW_OP <- ("and"i / "or"i / "xor"i)
            REL_OP <- ("<=" / "<>" / "<" / "=" / ">=" / ">")

            Parenthesis <- :"(" :WS? Expression :WS? :")"

            Varnosubscript <- Varname Vartype?
            Var <- Varname Subscript? Vartype?
            
            IdentifierStart <~ [a-zA-Z_]
            IdentifierCont <~ [a-zA-Z0-9_]+
            Varname <~ !(Reserved !IdentifierCont) IdentifierStart IdentifierCont? "$"?

            Address <- "@" Accessor

            Accessor <- Varname Subscript? (:"." Varname)* Subscript?

            Id <- [a-zA-Z_] [a-zA-Z_0-9]*
            Str_typeLen <- "*" :WS? (Number / Label_ref)
            Vartype <- (:WS :"as"i :WS Id (:WS? Str_typeLen)?) / eps
            Subscript <- "(" :WS? Expression? (:WS? "," :WS? Expression)* :WS? ")"
            String <- doublequote (!doublequote . / ^' ')* doublequote

            Unsigned   <- [0-9]+
            Decimal    <- Unsigned "d"
            Integer    <- "-"? Unsigned
            Hexa       <- "$" [0-9a-fA-F]+
            Binary     <- "%" ("0" / "1")+
            Scientific <- Floating ('e' / 'E' ) Integer
            Floating   <- "-"? Unsigned "." Unsigned
            Charlit    <- ("'{" [a-zA-Z_0-9]+ "}'") / ("'" . "'")

            Number <- (Decimal / Scientific / Floating / Integer / Hexa / Binary / Charlit)

            Label <- [a-zA-Z_] [a-zA-Z_0-9]* ":"
            Label_ref <- [a-zA-Z_] [a-zA-Z_0-9]*
            Label_deref <- "@" Label_ref

            Line_id <- (Label / Unsigned / eps)

            Reserved <- "and"i / "as"i / "asm"i / "background"i / "border"i / "byte"i / "call"i / "case"i / "charat"i / "close"i / "const"i / "continue"i / "data"i / "decimal"i / "declare"i / "dim"i / "do"i / "else"i / "end"i / "error"i / "exit"i / "fast"i / "filter"i / "float"i / "for"i / "function"i / "get"i / "gosub"i / "goto"i / "hscroll"i / "if"i / "incbin"i / "include"i / "inline"i / "input"i / "int"i / "interrupt"i / "let"i / "load"i / "locate"i / "long"i / "loop"i / "memcpy"i / "memset"i / "memshift"i / "mod"i / "next"i / "not"i / "off"i / "on"i / "open"i / "option"i / "or"i / "origin"i / "overload"i / "poke"i / "doke"i / "print"i / "private"i / "randomize"i / "raster"i / "read"i / "rem"i / "return"i / "save"i / "screen"i / "select"i / "shared"i / "sound"i / "sprite"i / "static"i / "step"i / "string"i / "sub"i / "swap"i / "sys"i / "system"i / "textat"i / "then"i / "timer"i / "to"i / "type"i / "until"i / "vmode"i / "voice"i / "volume"i / "vscroll"i / "while"i / "word"i / "write"i / "xor"
            WS <- (space / "_" endOfLine+ / "'"  ~((!eol .)*))+
            EOI < !.
            Spacing <- :('\t')*
        `);
    writeln(s);
}

