	PROCESSOR 6502
	
	; Convert word on stack to byte
	MAC F_cbyte_word
	pla
	ENDM
	
	; Convert word on stack to integer
	MAC F_cint_word
	ENDM

	; Convert word on stack to long
	MAC F_clong_word
	lda #$00
	pha
	ENDM
	
	; Convert word on stack to float
	MAC F_cfloat_word ; @pull @push
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
	sec
	jsr FLOAT2
	pfac
	ENDM