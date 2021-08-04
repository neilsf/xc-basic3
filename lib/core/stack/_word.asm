	PROCESSOR 6502
	
	; Push immediate word onto stack
	MAC pword
	IF !FPUSH
	lda #<{1}
	pha
	lda #>{1}
	pha
	ELSE
	lda #<{1}
	ldy #>{1}
	ENDIF
	ENDM
		
	; Push one word variable onto stack
	MAC pwordvar
	IF !FPUSH
	lda {1}
	pha
	lda {1}+1
	pha
	ELSE
	lda {1}
	ldy {1}+1
	ENDIF
	ENDM
		
	; Push one dynamic word variable onto stack
	MAC pdynwordvar
	ldy #[{1} + 1]
	IF !FPUSH
	lda (RC),y
	pha
	dey
	lda (RC),y
	pha
	ELSE
	lda (RC),y
	tax
	dey
	lda (RC),y
	tay
	txa
	ENDIF
	ENDM
	
	; Pull word on stack to variable
	MAC plwordvar
	IF !FPULL
	pla
	sta {1}+1
	pla
	sta {1}
	ELSE
	sta {1}
	sty {1}+1
	ENDIF
	ENDM
	
	; Pull dynamic word on stack to variable
	MAC pldynwordvar
	IF !FPULL
	ldy #{1}
	pla
	sta (RC),y
	pla
	iny
	sta (RC),y
	ELSE
	sty R0
	ldy #{1}
	sta (RC),y
	lda R0
	iny
	sta (RC),y
	ENDIF
	ENDM
	
	; Push word of an array onto stack
	; (indexed by a word)
	MAC pwordarray
	getaddr {1}
	; Load and push
	ldy #0
	lda (R0),y
	pha
	iny
	lda (R0),y
	pha
	ENDM
	
	; Push word of an array onto stack
	; (indexed by a byte)
	MAC pwordarrayfast
	IF !FPULL
	pla
	ENDIF
	tax
	lda	{1}, x
	pha
	lda [{1} + 1], x
	pha
	ENDM
	
	; Pull word off of stack and store in array
	; (indexed by a word)
	MAC plwordarray
	getaddr {1}
	pla
	ldy #1
	sta (R0),y
	dey
	pla
	sta (R0),y
	ENDM
	
	; Pull word off of stack and store in array
	; (indexed by a byte)
	MAC plwordarrayfast
	IF !FPULL
	pla
	ENDIF
	tax
	pla
	sta [{1} + 1],x
	pla
	sta {1},x
	ENDM
	
	; Push relative word variable (e.g this.something)
	MAC prelativewordvar
	ldy #{1}
	lda (TH),y
	pha
	iny
	lda (TH),y
	pha
	ENDM
	
	; Pull int value and store in relative word variable
	; (e.g this.something)
	MAC plrelativewordvar
	pla
	ldy #{1}
	sta (TH),y
	pla
	iny
	sta (TH),y
	ENDM