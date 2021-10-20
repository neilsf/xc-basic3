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
	lda.wx stack+4
	cmp.wx stack+1
	beq .1
	bpl .false
.1:	lda.wx stack+5
	cmp.wx stack+2
	beq .2
	bpl .false
.2:	lda.wx stack+6
	cmp.wx stack+3
	beq .3
	bpl .false
.3:	DS.B 6, $e8 ; 6x inx
	txs
	ptrue
	bne .q
.false:	
	DS.B 6, $e8 ; 6x inx	
	txs
	pfalse
.q
	ENDM
	
	; Compare two long ints on stack for greater than
	MAC cmplonggt
	tsx
	lda.wx stack+4
	cmp.wx stack+1
	beq .1
	bpl .true
.1:	lda.wx stack+5
	cmp.wx stack+2
	beq .2
	bpl .true
.2:	lda.wx stack+6
	cmp.wx stack+3
	beq .3
	bpl .true
.3:	DS.B 6, $e8 ; 6x inx
	txs
	pfalse
	beq .q
.true:	
	DS.B 6, $e8 ; 6x inx	
	txs
	ptrue
.q
	ENDM