	; XC-BASIC numeric functions
	
	; DECLARE FUNCTION ABS AS BYTE (num AS BYTE) SHARED STATIC INLINE
	MAC F_abs_byte
	ENDM
	
	; DECLARE FUNCTION ABS AS INT (num AS INT) SHARED STATIC INLINE
	MAC F_abs_int
	tsx
	lda.wx stack+1
	bpl .skip
	eor #$ff
	sta.wx stack+1
	lda.wx stack+2
	eor #$ff
	clc
	adc #$01
	sta.wx stack+2
	bne .skip
	inc.wx stack+1
.skip
	ENDM
	
	; DECLARE FUNCTION ABS AS WORD (num AS WORD) SHARED STATIC INLINE
	MAC F_abs_word
	ENDM
	
	; DECLARE FUNCTION ABS AS LONG (num AS LONG) SHARED STATIC INLINE
	MAC F_abs_long
	tsx
	lda.wx stack + 1
	bpl .skip
	eor #$ff
	sta.wx stack + 1
	lda.wx stack + 2
	eor #$ff
	sta.wx stack + 2
	lda.wx stack + 3
	eor #$ff
	clc
	adc #$01
	sta.wx stack + 3
	bne .skip
	inc.wx stack + 2
	bne .skip
	inc.wx stack + 1
.skip
	ENDM
	
	; DECLARE FUNCTION ABS AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
	MAC F_abs_float
	tsx
	lda.wx stack + 2
	and #%01111111
	sta.wx stack + 2
	ENDM
	
	; DECLARE FUNCTION SGN AS INT (num AS BYTE) SHARED STATIC INLINE
	MAC F_sgn_byte
	IF !FPULL
	pla
	ENDIF
	beq .z
	lda #$01
.z
	IF !FPUSH
	pha
	lda #$00
	pha
	ELSE
	ldy #$00
	ENDIF
	ENDM
	
	; DECLARE FUNCTION SGN AS INT (num AS INT) SHARED STATIC INLINE
	MAC F_sgn_int
	pla
	bmi .neg
	beq .plz
	pla
.pos
	pint 1
	beq .end
.plz
	pla
	bne .pos
	pint 0
	beq .end
.neg
	pla
	pint -1
.end
	ENDM
	
	; DECLARE FUNCTION SGN AS INT (num AS WORD) SHARED STATIC INLINE
	MAC F_sgn_word
	pla
	beq .plz
	pla
.pos
	pint 1
	beq .end
.plz
	pla
	bne .pos
	pint 0
	beq .end
.end
	ENDM
	
	; DECLARE FUNCTION SGN AS INTEGER (num AS LONG) SHARED STATIC INLINE
	MAC F_sgn_long
	
	ENDM
	
	; DECLARE FUNCTION SGN AS INTEGER (num AS FLOAT) SHARED STATIC INLINE
	MAC F_sgn_float
	IF !FPULL
	pla
	sta R0
	pla
	sta R1
	pla
	pla
	ELSE
	pla
	stx R0
	sty R1
	ENDIF
	lda R0
	beq .q
    lda R1
    bmi .neg
    lda #$01
    bne .q
.neg
	pint -1
	bmi .end
.q
	IF !FPUSH
	pha
	lda #0
	pha
	ELSE
	ldy #0
	ENDIF
.end
	ENDM