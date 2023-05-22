	; XC=BASIC memory functions
	
	; DECLARE FUNCTION PEEK AS BYTE (address AS WORD) SHARED STATIC INLINE
	MAC F_peek_word ; @push @pull
	IF !FPULL
	pla
	sta .l + 2
	pla
	sta .l + 1
	ELSE
	sta .l + 1
	sty .l + 2
	ENDIF
.l  lda $FFFF
	IF !FPUSH
	pha
	ENDIF
	ENDM
    
	; DECLARE FUNCTION PEEK AS BYTE (address AS LONG) OVERRIDE SHARED STATIC INLINE
	MAC F_peek_long ; @push @pull
	IF !FPULL
	pla
	sta R6
	pla
	sta R5
	pla
	sta R4
	ELSE
	sta R4
	sty R5
	stx R6
	ENDIF
    lda #0
    sta R7
    ldz_imm #0
    lda_indz R4
    IF !FPUSH
	pha
	ENDIF
	ENDM

	MAC F_deek_word ; @push @pull
	IF !FPULL
	pla
	sta R1
	pla
	sta R0
	ELSE
	sta R0
	sty R1
	ENDIF
	IF !FPUSH
	ldy #$00
	lda (R0),y
	pha
	iny
	lda (R0),y
	pha
	ELSE
	ldy #$00
	lda (R0),y
	tax
	iny
	lda (R0),y
	tay
	txa
	ENDIF
	ENDM
    
	; DECLARE FUNCTION DEEK AS BYTE (address AS LONG) OVERRIDE SHARED STATIC INLINE
	MAC F_deek_long ; @push @pull
	IF !FPULL
	pla
	sta R6
	pla
	sta R5
	pla
	sta R4
	ELSE
	sta R4
	sty R5
	stx R6
	ENDIF
    lda #0
    sta R7
    IF !FPUSH
    ldz_imm #0
    lda_indz R4
	pha
    inz
    lda_indz R4
	pha
    ELSE
    ldz_imm #1
    lda_indz R4
	tay
    dez
    lda_indz R4
	ENDIF
	ENDM