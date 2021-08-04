	PROCESSOR 6502
	
	; Push immediate decimal onto stack
	MAC pdecimal
	IF !FPUSH
	lda #${1}
	pha
	lda #${2}
	pha
	ELSE
	lda #${1}
	ldy #${2}
	ENDIF
	ENDM
		
	; Push one decimal variable onto stack
	MAC pdecimalvar
	pwordvar {1}
	ENDM
	
	; Pull decimal on stack to variable
	MAC pldecimalvar
	plwordvar {1}
	ENDM
	
	; Push decimal of an array onto stack
	; (indexed by a word)
	MAC pdecimalarray
	pwordarray {1}
	ENDM
	
	; Push decimal of an array onto stack
	; (indexed by a byte)
	MAC pdecimalarrayfast
	pwordarrayfast {1}
	ENDM
	
	; Pull decimal off of stack and store in array
	; (indexed by a word)
	MAC pldecimalarray
	plwordarray {1}
	ENDM
	
	; Pull decimal off of stack and store in array
	; (indexed by a byte)
	MAC pldecimalarrayfast
	plwordarrayfast {1}
	ENDM
	
	; Pull dynamic decimal on stack to variable
	MAC pldyndecimalvar
	pldynwordvar {1}
	ENDM
	
	; Push one dynamic decimal variable onto stack
	MAC pdyndecimalvar
	pdynwordvar {1}
	ENDM