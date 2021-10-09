	PROCESSOR 6502
	
	; Compare two bytes on stack for less than
	MAC cmpbytelt
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
	MAC cmpbytelte
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
	MAC cmpbytegte
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
	MAC cmpbyteeq
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
	MAC cmpbyteneq
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
	MAC cmpbytegt
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