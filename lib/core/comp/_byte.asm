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
	IF !FPUSH
	bcc * + 5
	ELSE
	bcc * + 4
	ENDIF
.phf: pfalse 
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
	IF !FPUSH
	bcs * + 5
	ELSE
	bcs * + 4
	ENDIF
.pht: ptrue
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
	IF !FPUSH
	bcc * + 5
	ELSE
	bcc * + 4
	ENDIF
.pht: ptrue
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
	IF !FPUSH
	beq * + 5
	ELSE
	beq * + 4
	ENDIF
.pht: ptrue
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
	IF !FPUSH
	jmp * + 5
	ELSE
	jmp * + 4
	ENDIF
.pht: ptrue
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
	IF !FPUSH
	bcs * + 5
	ELSE
	bcs * + 4
	ENDIF
.phf: pfalse
	ENDM