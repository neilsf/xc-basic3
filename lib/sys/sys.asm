	; XC=BASIC system functions
	
	MAC begin
	
	ENDM
	
	MAC end
	
	ENDM
	
	; DECLARE FUNCTION TI AS LONG () SHARED STATIC INLINE
	MAC F_ti
	php
	sei
	lda $a2
	IF !FPULL
	pha
	lda $a1
	pha
	lda $a0
	pha
	ELSE
	ldy $a1
	ldx $a0
	ENDIF
	plp
	ENDM