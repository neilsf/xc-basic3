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
	lda #$00
	pha
	ENDM
	
	; Convert int on stack to float
	MAC F_cfloat_int
	; TODO
	ENDM