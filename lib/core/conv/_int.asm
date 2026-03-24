	PROCESSOR 6502
	
	; Convert int on stack to byte
	MAC F_cbyte_int
	pla
	ENDM
	
	; Convert int on stack to word
	MAC F_cword_int
	ENDM

	; Convert int on stack to long
	MAC F_clong_int
	tsx
	lda stack + 1,x
	bpl .pos
	lda #$ff
	bmi .end
.pos
	lda #$00
.end
	pha
	ENDM
	
	; Convert int on stack to float
	MAC F_cfloat_int ; @pull @push
	IF !FPULL
	pla	
	sta FAC + 1
	pla
	sta FAC + 2
	ELSE	
	sta FAC + 2
	sty FAC + 1
	ENDIF
	ldx #$90
	import I_FPLIB
	jsr FLOAT1
	pfac
	ENDM