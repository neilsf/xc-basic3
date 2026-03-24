	PROCESSOR 6502
	
	; Convert float on stack to byte
	MAC F_cbyte_float ; @pull @push
	plfloattofac
	import I_FPLIB
	jsr QINT
	lda FAC + 3
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Convert float on stack to int
	MAC F_cint_float ; @pull @push
	plfloattofac
	import I_FPLIB
	jsr QINT
	IF !FPUSH
	lda FAC + 3
	pha
	lda FAC + 2
	pha
	ELSE
	lda FAC + 3
	ldy FAC + 2
	ENDIF
	ENDM
	
	; Convert float on stack to word
	MAC F_cword_float ; @pull @push
	F_cint_float
	ENDM
	
	; Convert float on stack to long
	MAC F_clong_float ; @pull @push
	plfloattofac
	import I_FPLIB
	jsr QINT
	IF !FPUSH
	lda FAC + 3
	pha
	lda FAC + 2
	pha
	lda FAC + 1
	pha
	ELSE
	lda FAC + 3
	ldy FAC + 2
	ldx FAC + 1
	ENDIF
	ENDM