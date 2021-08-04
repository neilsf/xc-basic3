	PROCESSOR 6502
	
	; Compare two words on stack for equality
	MAC cmpwordeq
	IF !FPULL
	pla
	sta R2
	pla
	sta R1
	ELSE
	sta R1
	sty R2
	ENDIF
	pla
	cmp R2
	bne .phf
	pla
	cmp R1
	bne .phf+1
	ptrue
	IF !FPUSH
	bne * + 6
	ELSE
	bne * + 5
	ENDIF
.phf: 
	pla
	pfalse
	ENDM
	
	; Compare two words on stack for inequality
	MAC cmpwordneq
	IF !FPULL
	pla
	sta R2
	pla
	sta R1
	ELSE
	sta R1
	sty R2
	ENDIF
	pla
	cmp R2
	bne .pht
	pla
	cmp R1
	bne .pht+1
	pfalse
	IF !FPUSH
	beq * + 6
	ELSE
	beq * + 5
	ENDIF
.pht:
	pla
	ptrue
	ENDM
	
	; Compare two words on stack for less than
	; older < newer
	MAC cmpwordlt
	IF !FPULL
	pla
	sta R0 + 1
	pla
	sta R0
	ELSE
	sta R0
	sty R0 + 1
	ENDIF
	pla
	cmp R0 + 1
	pla
	sbc R0
	bcs .false
	ptrue
	IF !FPUSH
	beq * + 6
	ELSE
	beq * + 5
	ENDIF
.false:
	pfalse
	ENDM
	
	; Compare two words on stack for greater than or equal
	; older >= newer
	MAC cmpwordgte
	IF !FPULL
	pla
	sta R0 + 1
	pla
	sta R0
	ELSE
	sta R0
	sty R0 + 1
	ENDIF
	pla
	cmp R0 + 1
	pla
	sbc R0
	bcs .true
	pfalse
	IF !FPUSH
	beq * + 6
	ELSE
	beq * + 5
	ENDIF
.true:
	ptrue
	ENDM
	
	; Compare two words on stack for greater than
	; older > newer
	MAC cmpwordgt
	tsx
	lda.wx stack+2
	cmp.wx stack+4
	lda.wx stack+1
	sbc.wx stack+3
	bcc .true	
	inx
	inx
	inx
	inx
	txs
	pfalse
	IF !FPUSH
	beq * + 10
	ELSE
	beq * + 9
	ENDIF
.true:
	inx
	inx
	inx
	inx
	txs
	ptrue
	ENDM
	
	; Compare two words on stack for less than or equal
	; older <= newer
	MAC cmpwordlte
	IF !FPULL
	pla
	sta R0 + 1
	pla
	sta R0
	ELSE
	sta R0
	sty R0 + 1
	ENDIF
	pla
	cmp R0 + 1
	bne .1
	pla
	cmp R0
.1  bcc .true  ; lower
	bne .false ; higher
.true
	ptrue
	IF !FPUSH
	beq * + 6
	ELSE
	beq * + 5
	ENDIF
.false:
	pfalse
	ENDM