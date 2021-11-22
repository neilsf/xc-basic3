	PROCESSOR 6502
	
	; Convert long int on stack to byte
	MAC F_cbyte_long
	pla
	pla
	ENDM
	
	; Convert long int on stack to word
	MAC F_cword_long
	pla
	ENDM
	
	; Convert long int on stack to int
	MAC F_cint_long
	pla
	ENDM
	
	; Convert long int on stack to float
	MAC F_cfloat_long ; @pull @push
	IF !FPULL
	pla
	sta FAC + 1
	eor #$FF
	rol
	pla
	sta FAC + 2
	pla	
	sta FAC + 3
	ELSE	
	sta FAC + 3
	sty FAC + 2
	stx FAC + 1
	txa
	eor #$FF
	rol
	ENDIF
	import I_LTOF
	jsr LTOF
	pfac
	ENDM
	
	IFCONST I_LTOF_IMPORTED
LTOF SUBROUTINE
	ldx #$98
    stx FAC
    lda #$00
    sta FACEXTENSION
    sta FACSIGN
    import I_FPLIB
    jmp NORMALIZE_FAC1
    ENDIF