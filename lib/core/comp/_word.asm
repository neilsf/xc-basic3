	PROCESSOR 6502
	
	; Compare two words on stack for equality
	MAC cmpwordeq ; @pull @push
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
	bne .phf + 1
	ptrue
	bne .q
.phf: 
	pla
	pfalse
.q
	ENDM
	
	; Compare two words on stack for inequality
	MAC cmpwordneq ; @pull @push
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
	beq .q
.pht:
	pla
	ptrue
.q
	ENDM
	
	; Compare two words on stack for less than
	; older < newer
	MAC cmpwordlt ; @pull @push
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
	bne .q
.false:
	pfalse
.q
	ENDM
	
	; Compare two words on stack for greater than or equal
	; older >= newer
	MAC cmpwordgte ; @pull @push
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
	beq .q
.true:
	ptrue
.q
	ENDM
	
	; Compare two words on stack for greater than
	; older > newer
	MAC cmpwordgt ; @push
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
	beq .q
.true:
	inx
	inx
	inx
	inx
	txs
	ptrue
.q
	ENDM
	
	; Compare two words on stack for less than or equal
	; older <= newer
	MAC cmpwordlte ; @pull @push
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
	bne .q
.false:
	pfalse
.q
	ENDM