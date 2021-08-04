	; Add top 2 bytes on stack
	MAC addbyte
	IF !FPULL
	pla
	ENDIF
	sta R0
	pla
	clc
	adc R0
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Substract top 2 bytes on stack
	MAC subbyte
	IF !FPULL
	pla
	ENDIF
	sta R0
	pla
	sec
	sbc R0
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Perform OR on top 2 bytes of stack
    MAC orbyte
    IF !FPULL
    pla
    ENDIF
    sta R0
    pla
    ora R0
    IF !FPUSH
    pha
    ENDIF
    ENDM

    ; Perform AND on top 2 bytes of stack
    MAC andbyte
    IF !FPULL
    pla
    ENDIF
    sta R0
    pla
    and R0
    IF !FPUSH
    pha
    ENDIF
    ENDM

    ; Perform XOR on top 2 bytes of stack
    MAC xorbyte
    IF !FPULL
    pla
    ENDIF
    sta R0
    pla
    eor R0
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    ; Perform NOT on byte on stack
	MAC notbyte
	IF !FPULL
	pla
	ENDIF
	eor #$FF
	IF !FPUSH
	pha
	ENDIF		
	ENDM
	
	; Multiply top 2 bytes on stack
	MAC mulbyte
	IF !FPULL
	pla
	ENDIF
	sta R0
	pla
	sta R1
	import I_NUCLEUS_MULBYTE
	jsr NUCLEUS_MULBYTE	
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Divide two bytes on stack
	MAC divbyte
	IF !FPULL
	pla
	ENDIF
	sta R1
	pla
	sta R0
	import I_NUCLEUS_DIVBYTE
	jsr NUCLEUS_DIVBYTE
	lda R0
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Shift left with const number of binary places
	MAC lshiftbytewconst
	IF !FPULL
	pla
	ENDIF
	REPEAT {1}
	asl
	REPEND
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Shift right with const number of binary places
	MAC rshiftbytewconst
	IF !FPULL
	pla
	ENDIF
	REPEAT {1}
	lsr
	REPEND
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Shift left with number of binary places
	; stored in a byte on top of stack
	MAC lshiftbyte
	IF !FPULL
	pla
	ENDIF
	tay
	pla
.loop
	cpy #$00
	beq .endloop
	asl
	dey
	bpl .loop ; = branch always
.endloop
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Shift right with number of binary places
	; stored in a byte on top of stack
	MAC rshiftbyte
	IF !FPULL
	pla
	ENDIF
	tay
	pla
.loop
	cpy #$00
	beq .endloop
	lsr
	dey
	bpl .loop ; = branch always
.endloop
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
; Multiply bytes
; by White Flame 20030207
; Factors in R0 and R1
; Result in A
	IFCONST I_NUCLEUS_MULBYTE_IMPORTED
NUCLEUS_MULBYTE SUBROUTINE
	lda #$00
	beq .enterLoop		
.doAdd:
	clc
	adc R0	
.loop:		
	asl R0
.enterLoop:
	lsr R1
	bcs .doAdd
	bne .loop
.end:
	rts
	ENDIF
	
; Divide bytes
; submitted by Graham at CSDb forum
; Dividend in R0
; Divisor in R1
; Result in R0
	IFCONST I_NUCLEUS_DIVBYTE_IMPORTED
NUCLEUS_DIVBYTE SUBROUTINE
	asl R0
	lda #$00
	rol
	ldx #$08
.loop1
	cmp R1
	bcc *+4
	sbc R1
	rol R0
	rol
	dex
	bne .loop1
	ldx #$08
.loop2
   	cmp R1
	bcc *+4
	sbc R1
	rol R2
	asl
	dex
	bne .loop2
	rts
	ENDIF