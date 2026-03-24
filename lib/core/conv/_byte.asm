	PROCESSOR 6502
	
	; Convert byte on stack to word on stack
	MAC F_cword_byte
	lda #$00
	pha
	ENDM
	
	; Convert byte on stack to int on stack
	MAC F_cint_byte
	F_cword_byte
	ENDM
	
	; Convert byte on stack to long on stack
	MAC F_clong_byte
	lda #$00
	pha
	pha
	ENDM
	
	; Convert byte on stack to float on stack
	MAC F_cfloat_byte ; @pull @push
	IF !FPULL
	pla
	ENDIF
	sta FAC + 1
	lda #$00
	sta FAC + 2
	ldx #$88
	sec
	import I_FPLIB
	jsr FLOAT2
	pfac
	ENDM