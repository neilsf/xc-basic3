	
	
	; Compare two bytes on stack for less than
	; (b b -> b)
	MAC cmpbytelt ; @pull @push
		IF !FPULL
			pla
		ENDIF
		sta R0
		pla
		cmp R0
		bcs .phf
		ptrue
		bne .q
.phf:
		pfalse
.q:
	ENDM

	; Compare two bytes on stack for less than
	; and leave first operand on stack
	; (b b -> b b)
	MAC cmpbytelt_lfs ; @push
		tsx
		lda stack + 2,x
		cmp stack + 1,x
		bcs .phf
		pla
		ptrue	; 9
		bne .q
.phf:
		pla
		pfalse
.q:
	ENDM
	
	; Compare two bytes on stack for less than or equal
	; (b b -> b)
	MAC cmpbytelte  ; @pull @push
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

	; Compare two bytes on stack for less than or equal
	; and leave first operand on stack
	; (b b -> b b)
	MAC cmpbytelte_lfs  ; @push
		tsx
		lda stack + 2,x
		cmp stack + 1,x
		bcc .pht
		beq .pht
		pla
		pfalse
		beq .q
.pht:
		pla
		ptrue
.q:
	ENDM
	
	; Compare two bytes on stack for greater than or equal
	; (b b -> b)
	MAC cmpbytegte  ; @pull @push
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

	; Compare two bytes on stack for greater than or equal
	; and leave first operand on stack
	; (b b -> b b)
	MAC cmpbytegte_lfs  ; @push
		tsx
		lda stack + 2,x
		cmp stack + 1,x
		bcs .pht
		pla
		pfalse
		beq .q
.pht: 	pla
		ptrue
.q:
	ENDM
	
	; Compare two bytes on stack for equality
	MAC cmpbyteeq  ; @pull @push
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

	; Compare two bytes on stack for equality
	; and leave first operand on stack
	; (b b -> b b)
	MAC cmpbyteeq_lfs  ; @push
		tsx
		lda stack + 2,x
		cmp stack + 1,x
		beq .pht
		pla
		pfalse
		beq .q
.pht: 	pla
		ptrue
.q:
	ENDM
	
	; Compare two bytes on stack for inequality
	MAC cmpbyteneq  ; @pull @push
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

	; Compare two bytes on stack for inequality
	; and leave first operand on stack
	; (b b -> b b)
	MAC cmpbyteneq_lfs  ; @push
		tsx
		lda stack + 2,x
		cmp stack + 1,x
		bne .pht
		pla
		pfalse
		beq .q
.pht: 	pla
		ptrue
.q:
	ENDM
	
	; Compare two bytes on stack for greater than
	MAC cmpbytegt  ; @pull @push
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

	; Compare two bytes on stack for greater than
	; and leave first operand on stack
	; (b b -> b b)
	MAC cmpbytegt_lfs  ; @push
		tsx
		lda stack + 2,x
		cmp stack + 1,x
		bcc .phf
		beq .phf
		pla
		ptrue
		bne .q
.phf: 	pla
		pfalse
.q:
	ENDM