	; Compare top two strings on stack for equality
	MAC cmpstringeq ; @push
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
	adc #2
	adc (R2),y
	adc (R0),y
	sta SP 
	plp
	rts
	ENDIF