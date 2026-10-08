	
	
	; Compare top 2 ints on stack for equality
	MAC cmpinteq ; @pull @push
	cmpwordeq
	ENDM
	
	; Compare top 2 ints on stack for inequality
	MAC cmpintneq ; @pull @push
	cmpwordneq
	ENDM

	; Compare top 2 ints on stack for equality (leave first operand on stack)
	MAC cmpinteq_lfs ; @push
	cmpwordeq_lfs
	ENDM

	; Compare top 2 ints on stack for inequality (leave first operand on stack)
	MAC cmpintneq_lfs ; @push
	cmpwordneq_lfs
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

	; Compare two ints on stack for less than
	; And leave the first argument on stack
	MAC cmpintlt_lfs ; @push
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
	txs
	pfalse
	IF !FPUSH
	beq * + 8
	ELSE
	beq * + 7
	ENDIF
.pht:
	inx
	inx
	txs
	ptrue
	ENDM
	
	; Compare two ints on stack for greater than or equal
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

	; Compare two ints on stack for greater than or equal
	; and leave the first argument on stack
	MAC cmpintgte_lfs ; @push
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
	txs
	ptrue
	IF !FPUSH
	bne * + 8
	ELSE
	bne * + 7
	ENDIF
.phf:
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

	; Compare two ints on stack for greater than
	; and leave the first argument on stack
	MAC cmpintgt_lfs ; @push
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
	txs
	pfalse
	IF !FPUSH
	beq * + 8
	ELSE
	beq * + 7
	ENDIF
.pht:
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

	; Compare two ints on stack for less than or equal
	; and leave the first argument on stack
	MAC cmpintlte_lfs ; @push
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
	txs
	ptrue
	IF !FPUSH
	bne * + 8
	ELSE
	bne * + 7
	ENDIF
.phf:
	inx
	inx
	txs
	pfalse
	ENDM