	PROCESSOR 6502
	
	; Perform OR on top 2 long ints of stack
	MAC orlong
    tsx
    lda.wx stack + 4
    ora.wx stack + 1
    sta.wx stack + 4
    lda.wx stack + 5
    ora.wx stack + 2
    sta.wx stack + 5
    lda.wx stack + 6
    ora.wx stack + 3
    sta.wx stack + 6
    inx
    inx
    inx
    txs
	ENDM

    ; Perform AND on top 2 long ints of stack
	MAC andlong
    tsx
    lda.wx stack + 4
    and.wx stack + 1
    sta.wx stack + 4
    lda.wx stack + 5
    and.wx stack + 2 
    sta.wx stack + 5
    lda.wx stack + 6
    and.wx stack + 3
    sta.wx stack + 6
    inx
    inx
    inx
    txs
	ENDM

    ; Perform XOR on top 2 long ints of stack
	MAC xorlong
    tsx
    lda.wx stack + 4
    eor.wx stack + 1
    sta.wx stack + 4
    lda.wx stack + 5
    eor.wx stack + 2
    sta.wx stack + 5
    lda.wx stack + 6
    eor.wx stack + 3
    sta.wx stack + 6
    inx
    inx
    inx
    txs
	ENDM

	; Add long ints on stack
	MAC addlong
	tsx
	clc
	lda.wx stack + 3
	adc.wx stack + 6
	sta.wx stack + 6
	lda.wx stack + 2
	adc.wx stack + 5
	sta.wx stack + 5
	pla
	adc.wx stack + 4
	sta.wx stack + 4
	inx
	inx
	inx
	txs
	ENDM
	
	; Substract long ints on stack
	MAC sublong
	tsx
	sec
	lda.wx stack + 6
	sbc.wx stack + 3
	sta.wx stack + 6
	lda.wx stack + 5
	sbc.wx stack + 2
	sta.wx stack + 5
	lda.wx stack + 4
	sbc.wx stack + 1
	sta.wx stack + 4
	inx
	inx
	inx
	txs
	ENDM
	
	; Switch sign of long integer
	MAC twoscpllong
	lda {1} + 2
	eor #$ff
	sta {1} + 2
	lda {1} + 1
	eor #$ff
	sta {1} + 1
	lda {1}
	eor #$ff
	clc
	adc #$01
	sta {1}
	bne .1
	inc {1} + 1
	bne .1
	inc {1} + 2
.1
	ENDM
	
	; Multiply top 2 long ints on stack
	MAC mullong ; @pull @push
	IF !FPULL
	pla
	sta R6
	pla
	sta R5
	pla
	sta R4
	ELSE
	sta R4
	sty R5
	stx R6
	ENDIF
	pla
	sta R9
	pla
	sta R8
	pla
	sta R7
	import I_NUCLEUS_MUL24
	jsr NUCLEUS_MUL24
	IF !FPUSH
	lda R0
	pha
	lda R1
	pha
	lda R2
	pha
	ELSE
	lda R0
	ldy R1
	ldx R2
	ENDIF
	ENDM
	
	; Divide top 2 long ints on stack
	MAC divlong  ; @pull @push
	IF !FPULL
	pla
	sta R7 + 2
	pla
	sta R7 + 1
	pla
	sta R7
	ELSE
	sta R7
	sty R7 + 1
	stx R7 + 2
	ENDIF
	pla
	sta R4 + 2
	pla
	sta R4 + 1
	pla
	sta R4
	import I_NUCLEUS_DIV24
	jsr NUCLEUS_DIV24
	IF !FPUSH
	lda R4
	pha
	lda R4 + 1
	pha
	lda R4 + 2
	pha
	ELSE
	lda R4
	ldy R4 + 1
	ldx R4 + 2
	ENDIF
	ENDM
	
	; Modulo of top 2 long ints on stack
	MAC modlong  ; @pull @push
	IF !FPULL
	pla
	sta R7 + 2
	pla
	sta R7 + 1
	pla
	sta R7
	ELSE
	sta R7
	sty R7 + 1
	stx R7 + 2
	ENDIF
	pla
	sta R4 + 2
	pla
	sta R4 + 1
	pla
	sta R4
	import I_NUCLEUS_DIV24
	jsr NUCLEUS_DIV24
	IF !FPUSH
	lda R0
	pha
	lda R0 + 1
	pha
	lda R0 + 2
	pha
	ELSE
	lda R0
	ldy R0 + 1
	ldx R0 + 2
	ENDIF
	ENDM
	
	; Perform NOT on long int on stack
	MAC notlong
	tsx
	lda.wx stack + 1
	eor #$ff
	sta.wx stack + 1
	lda.wx stack + 2
	eor #$ff
	sta.wx stack + 2
	lda.wx stack + 3
	eor #$ff
	sta.wx stack + 3
	ENDM
	
	; Negate long int on stack
	MAC neglong
	tsx
	lda.wx stack + 3
	eor #$ff
	sta.wx stack + 3
	lda.wx stack + 2
	eor #$ff
	sta.wx stack + 2
	lda.wx stack + 1
	eor #$ff
	clc
	adc #01
	sta.wx stack + 1
	bne .q
	inc.wx stack + 2
	bne .q
	inc.wx stack + 3
.q
	ENDM
	
	; Shift left with number of binary places
	; stored in a byte on top of stack
	MAC lshiftlong ; @pull
	IF !FPULL
	pla
	ENDIF
	tay
	tsx
.loop
	cpy #$00
	beq .endloop
	asl.wx stack + 3
	rol.wx stack + 2
	rol.wx stack + 1
	dey
	bpl .loop ; = branch always
.endloop
	ENDM
	
	; LSHIFT() function
	; with constant argument
	MAC lshiftlongwconst
	tsx
	REPEAT {1}
	asl.wx stack + 3
	rol.wx stack + 2
	rol.wx stack + 1
	REPEND
	ENDM
	
	; Shift right with number of binary places
	; stored in a byte on top of stack
	MAC rshiftlong ; @pull
	IF !FPULL
	pla
	ENDIF
	tay
	tsx
.loop
	cpy #$00
	beq .endloop
	lda.wx stack + 1
	asl
	ror.wx stack + 1
	ror.wx stack + 2
	ror.wx stack + 3
	dey
	bpl .loop ; = branch always
.endloop
	ENDM
	
	; RSHIFT() function
	; with constant argument
	MAC rshiftlongwconst
	tsx
	REPEAT {1}
	lda.wx stack + 1
	asl
	ror.wx stack + 1
	ror.wx stack + 2
	ror.wx stack + 3
	REPEND
	ENDM
	
	; Signed 24-bit multiply routine
	IFCONST I_NUCLEUS_MUL24_IMPORTED
NUCLEUS_MUL24	SUBROUTINE
.factor1 EQU R4
.factor2 EQU R7
.product EQU R0

	ldx #$00
	lda R4 + 2
	bpl .skip
	twoscpllong R4
	inx
.skip
	lda R7 + 2				
	bpl .skip2
	twoscpllong R7
	inx
.skip2
	jsr NUCLEUS_MULU24
	txa
	and #$01
	beq .q
	twoscpllong R0
.q	rts

	; Unsigned 24-bit multiply routine	
NUCLEUS_MULU24	SUBROUTINE
.factor1 EQU R4
.factor2 EQU R7
.product EQU R0

	lda #$00
	sta R0
	sta R0 + 1
	sta R0 + 2

.loop
	lda R7
	bne .nz
	lda R7 + 1
	bne .nz
	lda R7 + 2
	bne .nz
	rts
.nz
	lda R7
	and #$01
	beq .skip
	
	lda R4
	clc
	adc R0
	sta R0
	
	lda R4 + 1
	adc R0 + 1
	sta R0 + 1
	
	lda R4 + 2
	adc R0 + 2
	sta R0 + 2

.skip
	asl R4
	rol R4 + 1
	rol R4 + 2
	lsr R7 + 2
	ror R7 + 1
	ror R7

	jmp .loop
	ENDIF
	
	; Signed 24-bit multiply routine
	IFCONST I_NUCLEUS_DIV24_IMPORTED
NUCLEUS_DIV24	SUBROUTINE

.dividend EQU R4
.divisor  EQU R7

	ldx #$00
	lda R4 + 2
	bpl .skip
	twoscpllong R4
	inx
.skip
	lda R7 + 2				
	bpl .skip2
	twoscpllong R7
    inx
.skip2
    txa
    pha
	jsr NUCLEUS_DIVU24
	pla
	and #$01
	beq .q
	twoscpllong R4
.q	rts
	
; Unsigned 24 integer division
; the result goes to dividend and remainder variables
; https://codebase64.org/doku.php?id=base:24bit_division_24-bit_result
NUCLEUS_DIVU24	SUBROUTINE
.dividend 		EQU R4
.divisor 		EQU R7
.remainder 		EQU R0
.pztemp 	 	EQU R3

	lda .divisor
	bne .ok
	lda .divisor + 1
	bne .ok
	lda .divisor + 2
	bne .ok
	import I_RUNTIME_ERROR
	lda #ERR_DIVZERO
	jmp RUNTIME_ERROR
.ok
	lda #0
	sta .remainder
	sta .remainder + 1
	sta .remainder + 2
	ldx #24	        ;repeat for each bit: ...

.divloop
	asl .dividend
	rol .dividend + 1	
	rol .dividend + 2
	rol .remainder
	rol .remainder + 1
	rol .remainder + 2
	lda .remainder
	sec
	sbc .divisor
	tay
	lda .remainder + 1
	sbc .divisor + 1
	sta .pztemp
	lda .remainder + 2
	sbc .divisor + 2
	bcc .skip

	sta .remainder + 2
	lda .pztemp
	sta .remainder + 1
	sty .remainder	
	inc .dividend

.skip
	dex
	bne .divloop	
	rts
	ENDIF