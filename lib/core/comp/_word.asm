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
	MAC cmpwordlt
	tsx
	lda.wx stack + 4
	cmp.wx stack + 2
	lda.wx stack + 3
	sbc.wx stack + 1
	bcc .true
	lda #0
	beq .1
.true
	lda #255
.1
	sta.wx stack + 4
	inx
	inx
	inx
	txs
	ENDM
	
	; Compare two words on stack for greater than or equal
	MAC cmpwordgte
	tsx
	lda.wx stack + 4
	cmp.wx stack + 2
	lda.wx stack + 3
	sbc.wx stack + 1
	bcs .true
	lda #0
	beq .1
.true
	lda #255
.1
	sta.wx stack + 4
	inx
	inx
	inx
	txs
	ENDM
	
	; Compare two words on stack for greater than
	MAC cmpwordgt
	tsx
	lda.wx stack + 2
	cmp.wx stack + 4
	lda.wx stack + 1
	sbc.wx stack + 3
	bcc .true
	lda #0
	beq .1
.true
	lda #255
.1
	sta.wx stack + 4
	inx
	inx
	inx
	txs
	ENDM
	
	; Compare two words on stack for less than or equal
	MAC cmpwordlte
	tsx
	lda.wx stack + 2
	cmp.wx stack + 4
	lda.wx stack + 1
	sbc.wx stack + 3
	bcs .true
	lda #0
	beq .1
.true
	lda #255
.1
	sta.wx stack + 4
	inx
	inx
	inx
	txs
	ENDM