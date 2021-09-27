	; XC=BASIC memory functions
	
	; DECLARE FUNCTION PEEK AS BYTE (address AS WORD) SHARED STATIC INLINE
	MAC F_peek_word
	IF !FPULL
	pla
	sta .l + 2
	pla
	sta .l + 1
	ELSE
	sta .l + 1
	sty .l + 2
	ENDIF
.l  lda $0000
	IF FPUSH
	pha
	ENDIF
	ENDM 