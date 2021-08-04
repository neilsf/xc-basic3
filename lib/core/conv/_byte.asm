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
	MAC F_cfloat_byte
	; TODO
	ENDM