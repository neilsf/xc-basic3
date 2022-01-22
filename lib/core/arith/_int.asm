	PROCESSOR 6502
	
	; Add top 2 ints on stack
	MAC addint
	addword
	ENDM
	
	; Subtract top 2 ints on stack
	MAC subint
	subword
	ENDM
	
	; Multiply top 2 ints on stack
	MAC mulint ; @pull @push
	IF !FPULL
	pla
	sta R1
	pla
	sta R0
	ELSE
	sta R0
	sty R1
	ENDIF
	pla
	sta R3
	pla
	sta R2
	import I_NUCLEUS_MUL16
	jsr NUCLEUS_MUL16
	IF !FPUSH
	lda R0
	pha
	lda R1
	pha
	ELSE
	lda R0
	ldy R1
	ENDIF
	ENDM
	
	; Divide top 2 ints on stack
	MAC divint ; @push
	plwordvar R0
	plwordvar R2
	lda R0
	bne .ok
	lda R1
	bne .ok
	import I_RUNTIME_ERROR
	lda #ERR_DIVZERO
	jmp RUNTIME_ERROR
.ok
	import I_NUCLEUS_DIV16
	jsr NUCLEUS_DIV16
	pintvar R2
	ENDM
	
	; Modulo of top 2 ints on stack
	MAC modint ; @push
	plwordvar R0
	plwordvar R2
	lda R0
	bne .ok
	lda R1
	bne .ok
	import I_RUNTIME_ERROR
	lda #ERR_DIVZERO
	jmp RUNTIME_ERROR
.ok
	import I_NUCLEUS_DIV16
	jsr NUCLEUS_DIV16
	pintvar R4
	ENDM
	
	; Perform NOT on int on stack
	MAC notint ; @pull @push
	notword
	ENDM
	
	; Perform AND on top 2 ints on stack
	MAC andint
	andword
	ENDM
	
	; Perform OR on top 2 ints on stack
	MAC orint
	orword
	ENDM
	
	; Perform XOR on top 2 ints of stack
	MAC xorint
    xorword
	ENDM
	
	; Take two's complement of int
	MAC twoscplint
	lda {1}+1
	eor #$ff
	sta {1}+1
	lda {1}
	eor #$ff
	clc
	adc #$01
	sta {1}
	bne .skip
	inc {1}+1
.skip
	ENDM
	
	; Negate int on stack
	MAC negint ; @pull
	IF !FPULL
	pla
	tay
	pla
	ENDIF
	tax
	tya
	eor #$ff	
	tay	
	txa	
	eor #$ff	
	clc	
	adc #1	
	bne .skip	
	iny	
.skip
	IF !FPUSH	
	pha
	tya
	pha
	ENDIF
	ENDM
	
	; Shift left with number of binary places
	; stored in a byte on top of stack
	MAC lshiftint ; @pull
	lshiftword
	ENDM
	
	; LSHIFT() function
	; with constant argument
	MAC lshiftintwconst
	lshiftwordwconst {1}
	ENDM
	
	; Shift right with number of binary places
	; stored in a byte on top of stack
	MAC rshiftint ; @pull
	IF !FPULL
	pla
	ENDIF
	tay
	tsx
.loop
	cpy #$00
	beq .endloop
	; Move sign to carry
	lda.wx stack + 1
	asl
	ror.wx stack + 1
	ror.wx stack + 2
	dey
	bpl .loop ; = branch always
.endloop
	ENDM
	
	; RSHIFT() function
	; with constant argument
	MAC rshiftintwconst
	tsx
	REPEAT {1}
	lda.wx stack + 1
	asl
	ror.wx stack + 1
	ror.wx stack + 2
	REPEND
	ENDM
	
	; Signed 16-bit multiplication
	IFCONST I_NUCLEUS_MUL16_IMPORTED
	import I_NUCLEUS_MULU16
NUCLEUS_MUL16 SUBROUTINE
	ldy #$00					; .y will hold the sign of product
	lda R1
	bpl .skip					; if factor1 is negative
	twoscplint R0				; then factor1 := -factor1
	iny							; and switch sign
.skip
	lda R3				
	bpl .skip2					; if factor2 is negative
	twoscplint R2				; then factor2 := -factor2
	iny							; and switch sign
.skip2
	jsr NUCLEUS_MULU16				; do unsigned multiplication
	tya
	and #$01					; if .x is odd
	beq .q
	twoscplint R0				; then product := -product
.q	rts
	ENDIF
	
	; Signed 16-bit division	
	IFCONST I_NUCLEUS_DIV16_IMPORTED
	import I_NUCLEUS_DIVU16
NUCLEUS_DIV16 SUBROUTINE
	ldx #$00
	lda R2+1
	bpl .skip
	twoscplint R2
	inx
.skip
	lda R0+1		
	bpl .skip2
	twoscplint R0
	inx
.skip2
	txa
	pha
	jsr NUCLEUS_DIVU16
	pla
	and #$01
	beq .q
	twoscplint R2
.q	rts
	ENDIF