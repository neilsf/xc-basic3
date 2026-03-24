	PROCESSOR 6502
	
	; Compare top 2 ints on stack for equality
	MAC cmpinteq ; @pull @push
	cmpwordeq
	ENDM
	
	; Compare top 2 ints on stack for inequality
	MAC cmpintneq ; @pull @push
	cmpwordneq
	ENDM
	
	; Compare two ints on stack for less than
	MAC cmpintlt ; @push
	tsx
	lda.wx stack+4
	cmp.wx stack+2
	lda.wx stack+3
	sbc.wx stack+1
	bvc .1
	eor #$80
.1
	bmi .pht	
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
.pht:
	inx
	inx
	inx
	inx
	txs
	ptrue
	ENDM
	
	; Compare two words on stack for greater than or equal
	MAC cmpintgte ; @push
	tsx
	lda.wx stack+4
	cmp.wx stack+2
	lda.wx stack+3
	sbc.wx stack+1
	bvc .1
	eor #$80
.1
	bmi .phf	
	inx
	inx
	inx
	inx
	txs
	ptrue
	IF !FPUSH
	bne * + 10
	ELSE
	bne * + 9
	ENDIF
.phf: inx
	inx
	inx
	inx
	txs
	pfalse
	ENDM
	
	; Compare two ints on stack for greater than
	MAC cmpintgt ; @push
	tsx
	lda.wx stack+2
	cmp.wx stack+4
	lda.wx stack+1
	sbc.wx stack+3
	bvc .1
	eor #$80
.1
	bmi .pht	
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
.pht: inx
	inx
	inx
	inx
	txs
	ptrue
	ENDM

	; Compare two ints on stack for less than or equal
	MAC cmpintlte ; @push
	tsx
	lda.wx stack+2
	cmp.wx stack+4
	lda.wx stack+1
	sbc.wx stack+3
	bvc .1
	eor #$80
.1
	bmi .phf	
	inx
	inx
	inx
	inx
	txs
	ptrue
	IF !FPUSH
	bne * + 10
	ELSE
	bne * + 9
	ENDIF
.phf: inx
	inx
	inx
	inx
	txs
	pfalse
	ENDM