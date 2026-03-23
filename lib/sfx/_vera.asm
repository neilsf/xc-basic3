PSGREG    EQU $F9C0
WAVETRI   EQU %10000000
WAVESAW   EQU %01000000
WAVEPULSE EQU %00000000
WAVENOISE EQU %11000000

VOICE_WORKAREA
VOICE_FREQL  EQU R0
VOICE_FREQH  EQU R1
VOICE_CTRVOL EQU R2
VOICE_WAVPUL EQU R3
CURR_VOICE   EQU R4

    MAC loadvoice ; @pull
    IF !FPULL
        pla
    ENDIF
    sta CURR_VOICE
    sei
    import I_VERA_CALC_SNDBASE
    jsr VERA_CALC_SNDBASE
    lda VERA_DATA0
    sta VOICE_WORKAREA
    lda VERA_DATA0
    sta VOICE_WORKAREA + 1
    lda VERA_DATA0
    sta VOICE_WORKAREA + 2
    lda VERA_DATA0
    sta VOICE_WORKAREA + 3
    cli
    ENDM

    MAC savevoice
    lda CURR_VOICE
    sei
    import I_VERA_CALC_SNDBASE
    jsr VERA_CALC_SNDBASE
    lda VOICE_WORKAREA
    sta VERA_DATA0
    lda VOICE_WORKAREA + 1
    sta VERA_DATA0
    lda VOICE_WORKAREA + 2
    sta VERA_DATA0
    lda VOICE_WORKAREA + 3
    sta VERA_DATA0
    cli
    ENDM

    MAC voice_on
    lda VOICE_CTRVOL
    ora #%11000000
    sta VOICE_CTRVOL
	ENDM

    MAC voice_off
    lda VOICE_CTRVOL
    and #%00111111
    sta VOICE_CTRVOL
	ENDM

    MAC voice_left
    lda VOICE_CTRVOL
    and #%00111111
    ora #%01000000
    sta VOICE_CTRVOL
	ENDM

    MAC voice_right
    lda VOICE_CTRVOL
    and #%00111111
    ora #%10000000
    sta VOICE_CTRVOL
	ENDM

    MAC voice_tone ; @pull
	IF !FPULL
        pla
        sta VOICE_FREQH
        pla
        sta VOICE_FREQL
    ELSE
        sta VOICE_FREQL
        sty VOICE_FREQH
    ENDIF
	ENDM

    ; e.g voice_wave SAW
    MAC voice_wave
	lda VOICE_WAVPUL
	and #%00111111
    ora #WAVE{2}
	sta VOICE_WAVPUL
	ENDM

    MAC voice_pulse ; @pull
    IF !FPULL
        pla
    ENDIF
    and #%00111111
	sta R0
    lda VOICE_WAVPUL
	and #%11000000
    ora R0
	sta VOICE_WAVPUL
	ENDM

    MAC voice_volume ; @pull
    IF !FPULL
        pla
    ENDIF
    and #%00111111
	sta R0
    lda VOICE_CTRVOL
	and #%11000000
    ora R0
	sta VOICE_CTRVOL
	ENDM

    ; Unsupported on X16
	
	MAC voice_adsr ; @pull
	IF !FPULL
	pla
	ENDIF
	pla
	pla
	pla
	ENDM
	
	MAC voice_filteron
	ENDM
	
	MAC voice_filteroff
	ENDM
	
	MAC filter
	ENDM
	
	MAC filter_cutoff ; @pull
	IF !FPULL
	pla
	pla
	ENDIF
	ENDM
	
	MAC filter_resonance ; @pull
	IF !FPULL
	pla
	ENDIF
	ENDM

    MAC volume ; @pull
	IF !FPULL
	pla
	ENDIF
	ENDM

    ; End of unsupported macros

    MAC sound_clear
    lda #0
    import I_VERA_CALC_SNDBASE
    jsr VERA_CALC_SNDBASE
    ldx #64
    lda #0
.1
    sta VERA_DATA0
    dex
    bne .1
    ENDM

    ; Sets VERA address register to Voice data
    ; With increment value 1
    ; A = Voice No
    IF I_VERA_CALC_SNDBASE_IMPORTED
VERA_CALC_SNDBASE SUBROUTINE
    pha
    lda VERA_CTRL
    and #%11111110
    sta VERA_CTRL
    pla
    asl
    asl
    clc
    adc #<PSGREG
    sta VERA_ADDR
    lda #>PSGREG
    adc #0
    sta VERA_ADDR + 1
    lda #%00010001
    sta VERA_ADDR + 2
    rts
    ENDIF

