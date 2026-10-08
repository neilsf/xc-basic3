	; Compare top two strings on stack for equality
	MAC cmpstringeq ; @push
	lda #0
	sta RA
	import I_STRCMP
	jsr I_STRCMP
	beq .true
	pfalse
	beq .exit
.true
	ptrue
.exit
	ENDM

	; Compare top two strings on stack for equality
	; and leave first argument on stack
	MAC cmpstringeq_lfs ; @push
	lda #1
	sta RA
	import I_STRCMP
	jsr I_STRCMP
	beq .true
	pfalse
	beq .exit
.true
	ptrue
.exit
	ENDM
	
	; Compare top two strings on stack for inequality
	MAC cmpstringneq ; @push
	lda #0
	sta RA
	import I_STRCMP
	jsr I_STRCMP
	bne .true
	pfalse
	beq .exit
.true
	ptrue
.exit
	ENDM

	; Compare top two strings on stack for inequality
	; and leave first argument on stack
	MAC cmpstringneq_lfs ; @push
	lda #1
	sta RA
	import I_STRCMP
	jsr I_STRCMP
	bne .true
	pfalse
	beq .exit
.true
	ptrue
.exit
	ENDM
	
	IFCONST I_STRCMP_IMPORTED
	; STRCMP routine
	; Compares strings on stack
	; Result in zero flag
	; RA = 0: Remove both operands from stack
	; RA > 0: Leave first operand on stack
I_STRCMP SUBROUTINE
	lda #>STRING_WORKAREA
	sta R2 + 1
	sta R0 + 1
	ldx SP
	inx
	lda STRING_WORKAREA,x
	sta RB ; LEN(str2)
	stx R2
	inx
	txa
	clc
	adc RB
	tax
	stx R0
	ldy #0
	; Compare length
	lda (R0),y
    cmp (R2),y
    beq .equ
    bne .exit
.equ:    
    tay
    beq .exit
.loop:
	lda (R2),y
    cmp (R0),y
    bne .exit
	dey
	bne .loop
.exit:
	php
	; remove strings from stack
	ldy #0
	lda SP
	clc
	adc (R2),y	; First operand length
	adc #1
	ldx RA
	bne .skip
	adc (R0),y	; Second operand length
	adc #1
.skip
	sta SP 
	plp
	rts
	ENDIF