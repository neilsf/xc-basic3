	PROCESSOR 6502
	
	; Push true onto stack
	MAC ptrue ; @push
	lda #$FF
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Push false onto stack
	MAC pfalse ; @push
	lda #$00
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Push immediate byte onto stack
	MAC pbyte ; @push
	lda #{1}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Push byte variable onto stack
	MAC pbytevar ; @push
	lda {1}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Push dynamic byte variable onto stack
	MAC pdynbytevar ; @push
	ldy #{1}
	lda (RC),y
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Pull byte on stack to variable
	MAC plbytevar ; @pull
	IF !FPULL
	pla
	ENDIF
	sta {1}
	ENDM
	
	; Pull dynamic byte on stack to variable
	MAC pldynbytevar ; @pull
	IF !FPULL
	pla
	ENDIF
	ldy #{1}
	sta (RC),y
	ENDM
	
	; Push byte of an array onto stack
	; (indexed by a word)
	MAC pbytearray ; @pull @push
	getaddr {1}
	; Load and push
	ldy #0
	lda (R0),y
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Push byte of an array onto stack
	; (indexed by a byte)
	MAC pbytearrayfast ; @pull @push
	IF !FPULL
	pla
	ENDIF
	tax
	lda {1},x
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Push byte of a dynamic array onto stack
	; (indexed by a byte)
	; Variable name (offset) in {1}
	MAC pdynbytearrayfast ; @pull @push
	getdynaddr
	ldy #{1}
	lda (R0),y
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Pull byte off of stack and store in array
	; (indexed by a word)
	MAC plbytearray ; @pull
	getaddr {1}
	pla
	ldy #0
	sta (R0),y
	ENDM
	
	; Pull byte off of stack and store in array
	; (indexed by a byte)
	MAC plbytearrayfast ; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	pla
	sta {1},x
	ENDM
	
	; Pull byte off of stack and store in dynamic array
	; (indexed by a byte)
	MAC pldynbytearrayfast ; @pull
	getdynaddr
	ldy #{1}
	pla
	sta (R0),y
	ENDM
	
	; Push relative byte variable (e.g this.something)
	MAC prelativebytevar ; @push
	ldy #{1}
	lda (TH),y
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Pull byte value and store in relative byte variable
	; (e.g this.something)
	MAC plrelativebytevar ; @pull
	IF !FPULL
	pla
	ENDIF
	ldy #{1}
	sta (TH),y
	ENDM