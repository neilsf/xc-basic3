	PROCESSOR 6502
	
	; Add top 2 words on stack
	; 32 cycles - could it be less?
	MAC addword
	tsx
	lda.wx stack + 2
	clc
	adc.wx stack + 4
	sta.wx stack + 4
	pla
	adc.wx stack + 3
	sta.wx stack + 3
	pla
	ENDM
	
	; Substract top 2 words on stack
	MAC subword
	tsx
	lda.wx stack + 4
	sec
	sbc.wx stack + 2
	sta.wx stack + 4
	lda.wx stack + 3
	sbc.wx stack + 1
	sta.wx stack + 3
	inx
	inx
	txs
	ENDM
	
	; Multiply top 2 words on stack
	MAC mulword ; @pull @push
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
	import I_NUCLEUS_MULU16
	jsr NUCLEUS_MULU16
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
	
	; Divide top 2 words on stack
	MAC divword ; @push
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
	import I_NUCLEUS_DIVU16
	jsr NUCLEUS_DIVU16
	pwordvar R2
	ENDM
	
	; Modulo of top 2 words on stack
	MAC modword ; @push
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
	import I_NUCLEUS_DIVU16
	jsr NUCLEUS_DIVU16
	pwordvar R4
	ENDM

	; Perform NOT on word on stack
	MAC notword ; @pull @push
	IF !FPULL
	tsx
	lda.wx stack + 1
	eor #$ff
	sta.wx stack + 1
	lda.wx stack + 2
	eor #$ff
	sta.wx stack + 2
	ELSE
	tax
	tya
	eor #$ff
	tay
	txa
	eor #$ff
	IF !FPUSH
	pha
	tya
	pha
	ENDIF
	ENDIF
	ENDM
	
	; Perform AND on top 2 words on stack
	MAC andword
	pla
    tay
    pla
    tsx
    and.wx stack + 2
    sta.wx stack + 2
    tya
    and.wx stack + 1
    sta.wx stack + 1
	ENDM
	
	; Perform OR on top 2 words on stack
	MAC orword
	pla
    tay
    pla
    tsx
    ora.wx stack + 2
    sta.wx stack + 2
    tya
    ora.wx stack + 1
    sta.wx stack + 1
	ENDM
	
	; Perform XOR on top 2 words of stack
	MAC xorword
    pla
    tay
    pla
    tsx
    eor.wx stack + 2
    sta.wx stack + 2
    tya
    eor.wx stack + 1
    sta.wx stack + 1
	ENDM
    
    ; Shift left with number of binary places
	; stored in a byte on top of stack
	MAC lshiftword ; @pull
	IF !FPULL
	pla
	ENDIF
	tay
	tsx
.loop
	cpy #$00
	beq .endloop
	asl.wx stack+2
	rol.wx stack+1
	dey
	bpl .loop ; = branch always
.endloop
	ENDM
	
	; LSHIFT() function
	; with constant argument
	MAC lshiftwordwconst
	tsx
	REPEAT {1}
	asl.wx stack+2
	rol.wx stack+1
	REPEND
	ENDM
	
	; Shift right with number of binary places
	; stored in a byte on top of stack
	MAC rshiftword ; @pull
	IF !FPULL
	pla
	ENDIF
	tay
	tsx
.loop
	cpy #$00
	beq .endloop
	lsr.wx stack+1
	ror.wx stack+2
	dey
	bpl .loop ; = branch always
.endloop
	ENDM
	
	; RSHIFT() function
	; with constant argument
	MAC rshiftwordwconst
	tsx
	REPEAT {1}
	lsr.wx stack+1
	ror.wx stack+2
	REPEND
	ENDM
    
	; Multiply unsigned words in R0 and R2, with 16-bit result in R0
	; and 16-bit overflow in R5
	IFCONST I_NUCLEUS_MULU16_IMPORTED
NUCLEUS_MULU16	SUBROUTINE
	ldx #$11		
	lda #$00
	sta R5
	clc
.1:	ror
	ror R5
	ror R1
	ror R0
	dex
	beq .q
	bcc .1
	sta R6
	lda R5
	clc
	adc R2
	sta R5
	lda R6
	adc R3
	jmp .1
.q:	sta R6
	rts
	ENDIF
	
	; 16 bit unsigned division
	; Author: unknown
	; https://codebase64.org/doku.php?id=base:16bit_division_16-bit_result
	IFCONST I_NUCLEUS_DIVU16_IMPORTED
NUCLEUS_DIVU16 SUBROUTINE
.divisor 	EQU R0
.dividend 	EQU R2
.remainder 	EQU R4
.result 	EQU .dividend ; save memory by reusing divident to store the result
	lda #0	        ;preset remainder to 0
	sta .remainder
	sta .remainder+1
	ldx #16	        ;repeat for each bit: ...
.divloop:
	asl .dividend	;dividend lb & hb*2, msb -> Carry
	rol .dividend+1	
	rol .remainder	;remainder lb & hb * 2 + msb from carry
	rol .remainder+1
	lda .remainder
	sec
	sbc .divisor	;substract divisor to see if it fits in
	tay	        	;lb result -> Y, for we may need it later
	lda .remainder+1
	sbc .divisor+1
	bcc .skip		;if carry=0 then divisor didn't fit in yet

	sta .remainder+1	;else save substraction result as new remainder,
	sty .remainder	
	inc .result		;and INCrement result cause divisor fit in 1 times
.skip:
	dex
	bne .divloop		
	rts
	ENDIF