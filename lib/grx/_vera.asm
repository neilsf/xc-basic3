VERA_SPREG    EQU $FC00

SPR_ADDRL EQU R0
SPR_ADDRH EQU R1
SPR_XL    EQU R2
SPR_XH    EQU R3
SPR_YL    EQU R4
SPR_YH    EQU R5
SPR_PROP1 EQU R6
SPR_PROP2 EQU R7
CURR_SPR  EQU R8

    MAC sprite ; @pull
    IF !FPULL
        pla
    ENDIF
    sta CURR_SPR
    import I_VERA_CALC_SPRBASE
    jsr VERA_CALC_SPRBASE
    ldx #0
.1
    lda VERA_DATA0
    sta SPR_ADDRL,x
    inx
    cpx #8
    bne .1
    ENDM

    MAC savesprite
    lda CURR_SPR
    import I_VERA_CALC_SPRBASE
    jsr VERA_CALC_SPRBASE
    ldx #0
.1
    lda SPR_ADDRL,x
    sta VERA_DATA0
    inx
    cpx #8
    bne .1
    ENDM

    MAC sprite_on
    lda SPR_PROP1
    ora #%00001100
    sta SPR_PROP1
    ENDM

    MAC sprite_off
    lda SPR_PROP1
    and #%11110011
    sta SPR_PROP1
    ENDM

    MAC sprite_zdepth
    lda SPR_PROP1
    and #%11110011
    sta SPR_PROP1
    pla
    and #%00000011
    asl
    asl
    ora SPR_PROP1
    sta SPR_PROP1
    ENDM

    MAC sprite_at
    pla
    sta SPR_YH
    pla
    sta SPR_YL
    pla
    sta SPR_XH
    pla
    sta SPR_XL
    ENDM

    MAC sprite_color
    lda SPR_PROP2
    and #%11110000
    sta SPR_PROP2
    pla
    and #%00001111
    ora SPR_PROP2
    sta SPR_PROP2
    ENDM

    MAC sprite_lowcol
    lda SPR_XH
    and #%01111111
    sta SPR_XH
    ENDM

    MAC sprite_hicol
    lda SPR_XH
    ora #%10000000
    sta SPR_XH
    ENDM

    MAC sprite_hires
    sprite_lowcol
    ENDM

    MAC sprite_multi
    sprite_hicol
    ENDM

    MAC sprite_on_bg
	ENDM
	
	MAC sprite_under_bg
	ENDM

    MAC sprite_shape
    lda SPR_ADDRH
    and #%10000000
    sta SPR_ADDRH
    pla
    ora SPR_ADDRH
    sta SPR_ADDRH
    pla
    sta SPR_ADDRL
    ENDM

    MAC sprite_xysize
    lda SPR_PROP2
    and #%00001111
    sta SPR_PROP2
    pla
    and #%00000011
    REPEAT 4
    asl
    REPEND
    ora SPR_PROP2
    sta SPR_PROP2
    pla
    and #%00000011
    REPEAT 6
    asl
    REPEND
    ora SPR_PROP2
    sta SPR_PROP2
    ENDM

    MAC sprite_xyflip
    lda SPR_PROP1
    and #%00000011
    sta SPR_PROP1
    pla
    and #%00000001
    ora SPR_PROP1
    sta SPR_PROP1
    pla
    and #%00000001
    asl
    ora SPR_PROP1
    sta SPR_PROP1
    ENDM

    MAC sprite_multicolor ; @pull
	IF !FPULL
	pla
    ENDIF
	ENDM

    MAC sprite_clear_hit
	ENDM

    MAC sprite_clear
    lda #0
    import I_VERA_CALC_SPRBASE
    jsr VERA_CALC_SPRBASE
    lda #0
    ldy #16
.0
    ldx #64
.1
    sta VERA_DATA0
    dex
    bne .1
    dey
    bne .0
    ENDM

    ; Sets VERA address register to Sprite data
    ; With increment value 1
    ; A = Sprite No
    IF I_VERA_CALC_SPRBASE_IMPORTED
VERA_CALC_SPRBASE SUBROUTINE
    pha
    lda VERA_CTRL
    and #%11111110
    sta VERA_CTRL
    pla
    asl
    asl
    asl
    clc
    adc #<VERA_SPREG
    sta VERA_ADDR
    lda #>VERA_SPREG
    adc #0
    sta VERA_ADDR + 1
    lda #%00010001
    sta VERA_ADDR + 2
    rts
    ENDIF