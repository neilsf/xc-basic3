    ; 4510 instruction macros
    
    MAC inz
    DC.B $1B
    ENDM
    
    MAC dez
    DC.B $3B
    ENDM
    
    MAC lda_indz
    nop
    DC.B $B2, {1}
    ENDM
    
    MAC sta_indz
    nop
    DC.B $92, {1}
    ENDM
    
    MAC ldz_imm
    DC.B $A3, {1}
    ENDM