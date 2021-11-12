	PROCESSOR 6502
	
	; Compare two long ints on stack for equality
	MAC cmplongeq
	tsx
	lda.wx stack+6
	cmp.wx stack+3
	bne .false
	lda.wx stack+5
	cmp.wx stack+2
	bne .false
	lda.wx stack+4
	cmp.wx stack+1
	bne .false
	DS.B 6, $e8 ; 6x inx
	txs
	ptrue
	bne .q
.false:
	DS.B 6, $e8	; 6x inx	
	txs
	pfalse
.q
	ENDM
	
	; Compare two long ints on stack for inequality
	MAC cmplongneq
	tsx
	lda.wx stack+6
	cmp.wx stack+3
	bne .true
	lda.wx stack+5
	cmp.wx stack+2
	bne .true
	lda.wx stack+4
	cmp.wx stack+1
	bne .true
	DS.B 6, $e8 ; 6x inx
	txs
	pfalse
	beq .q
.true:
	DS.B 6, $e8	; 6x inx	
	txs
	ptrue
.q
	ENDM
	
	; Helper macro for long int comparisons
	MAC _lcomparison
	tsx
	lda.wx stack+6
    cmp.wx stack+3
    lda.wx stack+5
    sbc.wx stack+2
    lda.wx stack+4
    sbc.wx stack+1
    bvc *+4
    eor #$80
	ENDM

	; Compare two long ints on stack for less than
	MAC cmplonglt
	_lcomparison
	bmi .true
	DS.B 6, $e8 ; 6x inx
	txs
	pfalse
	beq .q
.true:
	DS.B 6, $e8 ; 6x inx	
	txs
	ptrue
.q
	ENDM
	
	; Compare two long ints on stack for greater than or equal
	MAC cmplonggte
	_lcomparison
	bpl .true
	DS.B 6, $e8 ; 6x inx
	txs
	pfalse
	beq .q
.true:
	DS.B 6, $e8 ; 6x inx	
	txs
	ptrue
.q
	ENDM

	; Compare two long ints on stack for less than or equal
	MAC cmplonglte
	tsx
	lda.wx stack+3
	cmp.wx stack+6
	lda.wx stack+2
	cmp.wx stack+5
	lda.wx stack+1
	sbc.wx stack+4
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
	bne .q
.phf: inx
	inx
	inx
	inx
	txs
	pfalse
.q
	ENDM
	
	; Compare two long ints on stack for greater than
	MAC cmplonggt
	tsx
	lda.wx stack+3
	cmp.wx stack+6
	lda.wx stack+2
	cmp.wx stack+5
	lda.wx stack+1
	sbc.wx stack+4
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
	beq .q
.pht: inx
	inx
	inx
	inx
	txs
	ptrue
.q
	ENDM