	; Push immediate word onto stack
	MAC pword ; @push
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
	
	; Push address to stack
	MAC paddr ; @push
	pword {1}
	ENDM
	
	; Push one word variable onto stack
	MAC pwordvar ; @push
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
	MAC pdynwordvar ; @push
	ldy #{1}
	IF !FPUSH
	lda (RC),y
	pha
	iny
	lda (RC),y
	pha
	ELSE
	lda (RC),y
	tax
	iny
	lda (RC),y
	tay
	txa
	ENDIF
	ENDM
	
	; Pull word on stack to variable
	MAC plwordvar ; @pull
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
	ldy #[{1} + 1]
	pla
	sta (RC),y
	pla
	dey
	sta (RC),y
	ENDM
	
	; Push word of an array onto stack
	; (indexed by a word)
	MAC pwordarray ; @pull
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
	MAC pwordarrayfast ; @pull @push
	IF !FPULL
	pla
	ENDIF
	tax
	IF !FPUSH
	lda	{1},x
	pha
	lda [{1} + 1],x
	pha
	ELSE
	lda {1},x
	ldy [{1} + 1],x
	ENDIF
	ENDM
	
	; Pull word off of stack and store in array
	; (indexed by a word)
	MAC plwordarray ; @pull
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
	MAC plwordarrayfast ; @pull
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
	ldy #[{1} + 1]
	sta (TH),y
	pla
	dey
	sta (TH),y
	ENDM