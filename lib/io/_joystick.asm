	
	IF TARGET & c264
	MAC F_joy_byte ; @pull @push
	ldy #$FA
	IF !FPULL
	pla
	ENDIF
	cmp #1
	beq .1
	iny
	iny
	iny
.1
	sei
.2
	sty $FF08
	lda $FF08
	sty $FF08
	cmp $FF08
	bne .2
	cli
	eor #$FF
	IF !FPUSH
	pha
	ENDIF
	ENDM
	ENDIF

	IF TARGET == c64
	MAC F_joy_byte ; @pull @push
JOYPORT2 EQU $DC00
JOYPORT1 EQU $DC01
	IF !FPULL
	pla
	ENDIF
	cmp #1
	beq .1
	lda JOYPORT2
	jmp .2
.1
	lda JOYPORT1
.2
	eor #$FF
	and #%00011111
	IF !FPUSH
	pha
	ENDIF
	ENDM
	ENDIF
	
	IF TARGET & vic20
	MAC F_joy_byte ; @pull @push
VIA1DDR EQU $9113
VIA2DDR EQU $9122
OUTPUTA EQU $9111
OUTPUTB EQU $9120
	IF !FPULL
	pla
	ENDIF
	lda #0
	sta VIA1DDR
	lda #$7F
	sta VIA2DDR
	lda OUTPUTB
	ora #%01111111
	and OUTPUTA
	eor #$ff
	IF !FPUSH
	pha
	ENDIF
	ldx #$ff
	stx VIA2DDR
	ENDM
	ENDIF
	