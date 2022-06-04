	PROCESSOR 6502
	
SNDCTRL EQU $FF11
V1FREQL EQU $FF0E
V1FREQH EQU $FF10
V2FREQL EQU $FF0F
V2FREQH EQU $FF12

WAVEPULSE EQU %00100000
WAVENOISE EQU %01000000

; Voice 2 wave setting
V2WAVE DC.B WAVEPULSE

	MAC voice_on
	lda SNDCTRL
	IF {1} == 1
	ora #%00010000
	ELSE
	and #%10011111
	ora V2WAVE
	ENDIF
	sta SNDCTRL
	ENDM
	
	MAC voice_off
	lda SNDCTRL		
	IF {1} == 1		
	and #%11101111	
	ELSE
	and #%10011111
	ENDIF		
	sta SNDCTRL	
	ENDM
	
	MAC voice_tone ; @pull
	IF !FPULL
  	  pla
	  and #%00000011
	  sta R0
	  lda V{1}FREQH
	  and #%11111100
	  ora R0
	  sta V{1}FREQH
	  pla
	  sta V{1}FREQL
	ELSE
	  sta V{1}FREQL
	  tya
	  and #%00000011
	  sta R0
	  lda V{1}FREQH
	  and #%11111100
	  ora R0
	  sta V{1}FREQH
	ENDIF
	ENDM
	
	MAC voice_wave ; @pull
	IF {1} == 2
	  lda #WAVE{2}
	  sta V2WAVE
	ENDIF
	ENDM
	
	MAC volume ; @pull
	IF !FPULL
	pla ; R
	ENDIF
	sta R0
	lda SNDCTRL
	and #%11110000
	ora R0
	sta SNDCTRL
	ENDM
	
	MAC sound_clear
	lda #%00100000
	sta V2WAVE
	lda #0
	sta SNDCTRL
	ENDM
	
	; Unsupported on TED
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