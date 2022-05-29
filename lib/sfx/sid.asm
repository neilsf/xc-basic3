	PROCESSOR 6502
	
V1FREQ	EQU $D400
V1PULS	EQU $D402
V1CTRL	EQU $D404
V1AD	EQU $D405
V1SR	EQU $D406

V2FREQ	EQU $D407
V2PULS	EQU $D409
V2CTRL	EQU $D40B
V2AD	EQU $D40C
V2SR	EQU $D40D

V3FREQ	EQU $D40E
V3PULS	EQU $D410
V3CTRL	EQU $D412
V3AD	EQU $D413
V3SR	EQU $D414                             

FILTCUT	EQU $D415	
FILTRR	EQU	$D417	
FMVOL	EQU $D418

WAVETRI   EQU %00010000
WAVESAW   EQU %00100000
WAVEPULSE EQU %01000000
WAVENOISE EQU %10000000

FILTLOW	  EQU %00010000
FILTBAND  EQU %00100000
FILTHIGH  EQU %01000000

	MAC voice_on
.REG EQU V{1}FREQ	
	lda .REG	
	ora #1	
	sta .REG	
	ENDM
	
	MAC voice_off
.REG EQU V{1}FREQ	
	lda .REG	
	and #%11111110	
	sta .REG	
	ENDM
	
	MAC voice_tone ; @pull
.REG EQU V{1}FREQ
	IF !FPULL
	pla
	ENDIF	
	sta .REG + 1	
	pla	
	sta .REG	
	ENDM
	
	; e.g voice_wave 1,SAW
	; e.g voice_wave 2,PULSE
	MAC voice_wave
.REG EQU V{1}CTRL	
.VAL EQU WAVE{2}
	lda .REG
	ora .VAL
	sta .REG
	ENDM
	
	MAC voice_pulse ; @pull
.REG EQU V{1}PULS
	IF !FPULL
	pla
	ENDIF	
	sta .REG + 1	
	pla	
	sta .REG	
	ENDM
	
	; Push order: A D S R
	MAC voice_adsr ; @pull
	IF !FPULL
	pla ; R
	ENDIF	
	sta R0	
	pla ; S	
	asl	
	asl	
	asl	
	asl	
	ora	R0
	sta V{1}AD
	pla ; D
	sta R0
	pla ; A
	asl	
	asl	
	asl	
	asl	
	ora	R0
	sta V{1}SR
	ENDM
	
	MAC voice_filter_on
	lda #[1 << [{1} - 1]]
	ora FILTRR
	sta FILTRR
	ENDM
	
	MAC voice_filter_off
	lda #[[1 << [{1} - 1]] ^ $FF]
	and FILTRR
	sta FILTRR
	ENDM
	
	MAC filter
	lda FILTRR
	and #%10001111 
	ora #FILT{1}
	sta FILTRR
	ENDM
	
	MAC filter_cutoff ; @pull
	IF !FPULL
	pla
	ENDIF
	sta FILTCUT + 1
	pla
	sta FILTCUT
	ENDM
	
	MAC filter_resonance ; @pull
	IF !FPULL
	pla
	ENDIF
	asl
	asl
	asl
	asl
	sta R0
	lda FILTRR
	and #%11110000
	ora R0
	sta FILTRR
	ENDM
	
	MAC volume ; @pull
	IF !FPULL
	pla ; R
	ENDIF
	sta R0
	lda FMVOL
	and #%11110000
	ora R0
	sta FMVOL
	ENDM
	
	MAC sound_clear
	ldx #$18
	lda #0
.loop
	sta V1FREQ,x
	dex
	bpl .loop
	ENDM
	