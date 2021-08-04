	PROCESSOR 6502
	
	; Push a long int onto the stack
	MAC plong
	IF !FPUSH
	lda #<{1}
	pha
	lda #>{1}
	pha
	lda #[{1} >> 16]
	pha
	ELSE
	lda #<{1}
	ldy #>{1}
	ldx #[{1} >> 16]
	ENDIF
	ENDM
	
	; Push a long int variable on the stack
	MAC plongvar
	IF !FPUSH
	lda {1}
	pha
	lda {1}
	pha
	lda {1}+2
	pha
	ELSE
	lda {1}
	ldy {1}+1
	ldx {1}+2
	ENDIF
	ENDM
	
	; Push one dynamic long variable onto stack
	MAC pdynlongvar
	ldy #[{1} + 2]
	lda (RC),y
	pha
	dey
	lda (RC),y
	pha
	dey
	lda (RC),y
	pha
	ENDM
	
	; Pull dynamic long on stack to variable
	MAC pldynlongvar
	ldy #{1}
	pla
	sta (RC),y
	pla
	iny
	sta (RC),y
	pla
	iny
	sta (RC),y
	ENDM
	
	; Pull long int to variable
	MAC pllongvar
	IF !FPULL
	pla
	sta {1}+2
	pla
	sta {1}+1
	pla
	sta {1}
	ELSE
	sta {1}
	sty {1}+1
	stx {1}+2
	ENDIF
	ENDM
	
	; Push longint of an array onto stack
	; (indexed by a word)
	MAC plongarray
	getaddr {1}
	; Load and push
	ldy #0
	lda (R0),y
	pha
	iny
	lda (R0),y
	pha
	iny
	lda (R0),y
	pha
	ENDM
	
	; Push long int of an array onto stack
	; (indexed by a byte)
	MAC plongarrayfast
	IF !FPULL
	pla
	ENDIF
	tax
	lda {1},x
	pha
	lda [{1} + 1],x
	pha
	lda [{1} + 2],x
	pha
	ENDM
	
	; Pull long int off of stack and store in array
	; (indexed by a word)
	MAC pllongarray
	getaddr {1}
	ldy #2
	pla
	sta (R0),y
	dey
	pla
	sta (R0),y
	dey
	pla
	sta (R0),y
	ENDM
	
	; Pull long int off of stack and store in array
	; (indexed by a byte)
	MAC pllongarrayfast
	IF !FPULL
	pla
	ENDIF
	tax
	pla
	sta [{1} + 2],x
	pla
	sta [{1} + 1],x
	pla
	sta {1},x
	ENDM