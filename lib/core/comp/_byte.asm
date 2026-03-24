	PROCESSOR 6502
	
	; Compare two bytes on stack for less than
	MAC cmpbytelt ; @pull @push
	IF !FPULL
	pla
	ENDIF
	sta R0
	pla
	cmp R0
	bcs .phf
	ptrue
	bne .q
.phf: pfalse
.q:
	ENDM
	
	; Compare two bytes on stack for less than or equal
	MAC cmpbytelte  ; @pull @push
	IF !FPULL
	pla
	ENDIF
	sta R0
	pla
	cmp R0
	bcc .pht
	beq .pht
	pfalse
	beq .q
.pht: ptrue
.q
	ENDM
	
	; Compare two bytes on stack for greater than or equal
	MAC cmpbytegte  ; @pull @push
	IF !FPULL
	pla
	ENDIF                 
	sta R0
	pla
	cmp R0
	bcs .pht
	pfalse
	beq .q
.pht: ptrue
.q:
	ENDM
	
	; Compare two bytes on stack for equality
	MAC cmpbyteeq  ; @pull @push
	IF !FPULL
	pla
	ENDIF                 
	sta R0
	pla
	cmp R0
	beq .pht
	pfalse
	beq .q
.pht: ptrue
.q:
	ENDM
	
	; Compare two bytes on stack for inequality
	MAC cmpbyteneq  ; @pull @push
	IF !FPULL
	pla
	ENDIF                 
	sta R0
	pla
	cmp R0
	bne .pht
	pfalse
	beq .q
.pht: ptrue
.q:
	ENDM
	
	; Compare two bytes on stack for greater than
	MAC cmpbytegt  ; @pull @push
	IF !FPULL
	pla
	ENDIF                 
	sta R0
	pla
	cmp R0
	bcc .phf
	beq .phf
	ptrue
	bne .q
.phf: pfalse
.q:
	ENDM