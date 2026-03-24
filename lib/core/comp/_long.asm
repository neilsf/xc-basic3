	PROCESSOR 6502
	
	; Compare two long ints on stack for equality
	MAC cmplongeq ; @push
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
	txa
	clc
	adc #6
	tax
	txs
	ptrue
	bne .q
.false:
	txa
	clc
	adc #6
	tax
	txs
	pfalse
.q
	ENDM
	
	; Compare two long ints on stack for inequality
	MAC cmplongneq ; @push
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
	txa
	clc
	adc #6
	tax
	txs
	pfalse
	beq .q
.true:
	txa
	clc
	adc #6
	tax
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
	MAC cmplonglt ; @push
	_lcomparison
	bmi .true
	txa
	clc
	adc #6
	tax
	txs
	pfalse
	beq .q
.true:
	txa
	clc
	adc #6
	tax	
	txs
	ptrue
.q
	ENDM
	
	; Compare two long ints on stack for greater than or equal
	MAC cmplonggte ; @push
	_lcomparison
	bpl .true
	txa
	clc
	adc #6
	tax
	txs
	pfalse
	beq .q
.true:
	txa
	clc
	adc #6
	tax	
	txs
	ptrue
.q
	ENDM

	; Compare two long ints on stack for less than or equal
	MAC cmplonglte ; @push
	tsx
	lda.wx stack+3
	cmp.wx stack+6
	lda.wx stack+2
	sbc.wx stack+5
	lda.wx stack+1
	sbc.wx stack+4
	bvc .1
	eor #$80
.1
	bmi .phf	
	txa
	clc
	adc #6
	tax
	txs
	ptrue
	bne .q
.phf:
	txa
	clc
	adc #6
	tax
	txs
	pfalse
.q
	ENDM
	
	; Compare two long ints on stack for greater than
	MAC cmplonggt ; @push
	tsx
	lda.wx stack+3
	cmp.wx stack+6
	lda.wx stack+2
	sbc.wx stack+5
	lda.wx stack+1
	sbc.wx stack+4
	bvc .1
	eor #$80
.1
	bmi .pht
	txa
	clc
	adc #6
	tax
	txs
	pfalse
	beq .q
.pht:
	txa
	clc
	adc #6
	tax
	txs
	ptrue
.q
	ENDM