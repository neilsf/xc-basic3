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
    
    MAC sta_far
    ldx #<{1}
    stx R0
    ldx #>{1}
    stx R0 + 1
    ldx #<[{1} >> 16]
    stx R0 + 2
    ldx #>[{1} >> 16]
    stx R0 + 3
    ldz_imm #0
    sta_indz R0
    ENDM