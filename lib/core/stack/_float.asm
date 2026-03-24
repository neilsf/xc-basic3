	PROCESSOR 6502
	
	; Push immediate float on stack
	; Expects 4 bytes, e. g pfloat 01,02,FE,FF
	; TO ALLOW DIRECT COMPARISON OF NUMBERS 
	; IN FAC AND ON STACK, FLOATS ARE
	; PUSHED IN REVERSE ORDER, M3-M2-M1-E
	MAC pfloat ; @push
	lda #${4}
	pha
	IF !FPUSH
	lda #${3}
	pha
	lda #${2}
	pha
	lda #${1}
	pha
	ELSE
	lda #${3}
	ldy #${2}
	ldx #${1}
	ENDIF
	ENDM
	
	; Push float variable on stack
	MAC pfloatvar ; @push
	lda {1} + 3
	pha
	IF !FPUSH
	lda {1} + 2
	pha
	lda {1} + 1
	pha
	lda {1}
	pha
	ELSE
	lda {1} + 2
	ldy {1} + 1
	ldx {1}
	ENDIF
	ENDM
	
	; Pull float on stack to variable
	MAC plfloatvar ; @pull
	IF !FPULL
	pla
	sta {1}
	pla
	sta {1} + 1
	pla
	sta {1} + 2
	ELSE
	stx {1}
	sty {1} + 1
	sta {1} + 2
	ENDIF
	pla
	sta {1} + 3
	ENDM
	
	; Push float of an array onto stack
	; (indexed by a word)
	MAC pfloatarray ; @pull
	getaddr {1}
	; Load and push
	ldy #3
	lda (R0),y
	pha
	dey
	lda (R0),y
	pha
	dey
	lda (R0),y
	pha
	dey
	lda (R0),y
	pha
	ENDM
	
	; Push float of an array onto stack
	; (indexed by a byte)
	MAC pfloatarrayfast ; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	lda.wx {1} + 3
	pha
	lda.wx {1} + 2
	pha
	lda.wx {1} + 1
	pha
	lda {1},x
	pha
	ENDM
	
	; Pull long int off of stack and store in array
	; (indexed by a word)
	MAC plfloatarray ; @pull
	getaddr {1}
	ldy #0
	pla
	sta (R0),y
	iny
	pla
	sta (R0),y
	iny
	pla
	sta (R0),y
	iny
	pla
	sta (R0),y
	ENDM
	
	; Pull float off of stack and store in array
	; (indexed by a byte)
	MAC plfloatarrayfast ; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	pla
	sta {1},x
	pla
	sta.wx {1} + 1
	pla
	sta.wx {1} + 2
	pla
	sta.wx {1} + 3
	ENDM
	
	; Pull float off of stack into FAC
	MAC plfloattofac ; @pull
	IF !FPULL
	pla
	sta FAC
	pla
	sta FACSIGN
    ora #%10000000
    sta FAC + 1
	pla
	sta FAC + 2
	ELSE
	sta FAC + 2
	tya
	sta FACSIGN
    ora #%10000000
    sta FAC + 1
	stx FAC
	ENDIF
	pla
	sta FAC + 3
	lda #$00
	sta FACEXTENSION
	ENDM
	
	; Pull float off of stack into ARG
	MAC plfloattoarg ; @pull
	IF !FPULL
	pla
	sta ARG
	pla
	sta ARGSIGN
    eor FACSIGN
    sta SGNCPR
	lda ARGSIGN
	ora #%10000000
	sta ARG + 1
	pla
	sta ARG + 2
	ELSE
	sta ARG
	tya
	sta ARGSIGN
    eor FACSIGN
    sta SGNCPR
	lda ARGSIGN
	ora #%10000000
	sta ARG + 1
	stx ARG + 2
	ENDIF
	pla
	sta ARG + 3
	lda FAC
	ENDM
	
	; Round and push float in FAC onto stack
	MAC pfac ; @push
	import I_FPLIB
	jsr ROUND_FAC
	lda #$00
	sta FACEXTENSION
	lda FAC + 3
	pha
	IF !FPUSH
	lda FAC + 2
	pha
	lda FACSIGN
	ora #$7F
    and FAC + 1
    pha
    lda FAC
    pha
	ELSE
	lda FACSIGN
	ora #$7F
    and FAC + 1
    tay
    ldx FAC
	lda FAC + 2
	ENDIF
	ENDM
	
	; Push one dynamic float variable onto stack
	MAC pdynfloatvar
	ldy #[{1} + 3]
	lda (RC),y
	pha
	REPEAT 3
	dey
	lda (RC),y
	pha
	REPEND
	ENDM
	
	; Pull dynamic float on stack to variable
	MAC pldynfloatvar
	ldy #{1}
	pla
	sta (RC),y
	REPEAT 3
	pla
	iny
	sta (RC),y
	REPEND
	ENDM
	
	; Push relative word variable (e.g this.something)
	MAC prelativefloatvar
	ldy #[{1} + 3]
	lda (TH),y
	pha
	REPEAT 3
	dey
	lda (TH),y
	pha
	REPEND
	ENDM
	
	; Pull int value and store in relative word variable
	; (e.g this.something)
	MAC plrelativefloatvar
	ldy #{1}
	pla
	sta (TH),y
	REPEAT 3
	pla
	iny
	sta (TH),y
	REPEND
	ENDM