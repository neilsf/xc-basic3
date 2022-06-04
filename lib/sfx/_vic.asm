	PROCESSOR 6502
	
V1FREQ	EQU $900A
V2FREQ  EQU $900B
V3FREQ  EQU $900C
V4FREQ  EQU $900D
MASTVOL EQU $900E

	MAC voice_on
	lda V{1}FREQ	
	ora #%10000000
	sta V{1}FREQ	
	ENDM
	
	MAC voice_off
	lda V{1}FREQ	
	and #%01111111		
	sta V{1}FREQ	
	ENDM
	
	MAC voice_tone ; @pull
	IF !FPULL
	pla ; discard HB
	pla ; keep LB
	ENDIF
	and #%01111111
	sta R0
	lda V{1}FREQ
	and #%10000000
	ora R0
	sta V{1}FREQ
	ENDM

	MAC volume ; @pull
	IF !FPULL
	pla ; R
	ENDIF
	sta R0
	lda MASTVOL
	and #%11110000
	ora R0
	sta MASTVOL
	ENDM
	
	MAC sound_clear
	lda MASTVOL
	and #%11110000
	STA MASTVOL
	lda #0
	sta V1FREQ
	sta V2FREQ
	sta V3FREQ
	sta V4FREQ
	ENDM
	
	; Unsupported on VIC-20
	
	MAC voice_wave ; @pull
	ENDM
	
	MAC voice_pulse ; @pull
	IF !FPULL
	pla
	ENDIF
	ENDM
	
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