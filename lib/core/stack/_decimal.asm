	; Push immediate decimal onto stack
	MAC pdecimal ; @push
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
	MAC pdecimalvar ; @push
	pwordvar {1}
	ENDM
	
	; Pull decimal on stack to variable
	MAC pldecimalvar ; @pull
	plwordvar {1}
	ENDM
	
	; Push decimal of an array onto stack
	; (indexed by a word)
	MAC pdecimalarray ; @pull
	pwordarray {1}
	ENDM
	
	; Push decimal of an array onto stack
	; (indexed by a byte)
	MAC pdecimalarrayfast ; @pull @push
	pwordarrayfast {1}
	ENDM
	
	; Pull decimal off of stack and store in array
	; (indexed by a word)
	MAC pldecimalarray ; @pull
	plwordarray {1}
	ENDM
	
	; Pull decimal off of stack and store in array
	; (indexed by a byte)
	MAC pldecimalarrayfast ; @pull
	plwordarrayfast {1}
	ENDM
	
	; Pull dynamic decimal on stack to variable
	MAC pldyndecimalvar ; @pull
	pldynwordvar {1}
	ENDM
	
	; Push one dynamic decimal variable onto stack
	MAC pdyndecimalvar ; @push
	pdynwordvar {1}
	ENDM
	
	; Push relative decimal variable (e.g this.something)
	MAC prelativedecimalvar
	prelativewordvar {1}
	ENDM
	
	; Pull decimal value and store in relative decimal variable
	; (e.g this.something)
	MAC plrelativedecimalvar
	plrelativewordvar {1}
	ENDM