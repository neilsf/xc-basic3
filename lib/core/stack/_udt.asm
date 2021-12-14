	PROCESSOR 6502
	
	; Push variable of user defined type onto stack
	; Variable label in {1}
	; Number of bytes in {2}
	MAC pudtvar
	ldx #0
.do
	lda.wx {1}
	pha
	inx
	cpx #{2}
	bcc .do
	ENDM
	
	; Pull value of user defined type off of stack into variable
	; Variable label in {1}
	; Number of bytes in {2}
	MAC pludtvar
	ldx #{2}
.do
	pla
	sta.wx {1} - 1
	dex
	bne .do
	ENDM
	
	; Push user defined type of an array onto stack
	; (indexed by a word)
	; Variable label in {1}
	; Number of bytes in {2}
	MAC pudtarray ; @pull
	getaddr {1}
	; Load and push
	ldy #0
.do
	lda (R0),y
	pha
	iny
	cpy #{2}
	bcc .do
	ENDM
	
	; Push byte of an array onto stack
	; (indexed by a byte)
	; Variable label in {1}
	; Number of bytes in {2}
	MAC pudtarrayfast ; @pull
	IF !FPULL
	pla
	ENDIF
	tay
	sta R0
	clc
	adc #{2}
	sta R0
.do
	lda {1},y
	pha
	iny
	cpy R0
	bcc .do
	ENDM
	
	; Pull value of user defined type off of stack
	; and store in array (indexed by a word)
	MAC pludtarray ; @pull
	getaddr [{1} - 1]
	ldy #{2}
.do
	pla
	sta (R0),y
	dey
	bne .do
	ENDM
	
	; Pull value of user defined type off of stack
	; and store in array (indexed by a byte)
	MAC pludtarrayfast ; @pull
	IF !FPULL
	pla
	ENDIF
	sta R0
	inc R0
	clc
	adc #{2}
	tay
.do
	pla
	sta.wy {1} - 1
	dey
	cpy R0
	bcs .do
	ENDM
	
	; Push one dynamic udt variable onto stack
	; Relative address of var in {1}
	; Type length in {2}
	MAC pdynudtvar
	ldy #{1}
.loop
	lda (RC),y
	pha
	iny
	cpy #[{1} + {2}]
	bcc .loop
	ENDM
	
	; Pull dynamic udt on stack to variable
	; Relative address of var in {1}
	; Type length in {2}
	MAC pldynudtvar
	ldy #[{1} + {2} - 1]
.loop
	pla
	sta (RC),y
	dey
	cpy #{1}
	bpl .loop
	ENDM
	
	; Push relative udt variable (e.g this.something)
	; Relative address of var in {1}
	; Type length in {2}
	MAC prelativeudtvar
	ldy #{1}
.loop
	lda (TH),y
	pha
	iny
	cpy #[{1} + {2}]
	bcc .loop
	ENDM
	
	; Pull udt value and store in relative udt variable
	; (e.g this.something)
	; Relative address of var in {1}
	; Type length in {2}
	MAC plrelativeudtvar
	ldy #[{1} + {2} - 1]
.loop
	pla
	sta (TH),y
	dey
	cpy #{1}
	bpl .loop
	ENDM