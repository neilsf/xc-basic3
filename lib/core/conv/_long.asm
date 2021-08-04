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
	longtoword
	ENDM
	
	; Convert long int on stack to float
	MAC F_cfloat_long
	; TODO
	nop
	ENDM