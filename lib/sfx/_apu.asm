APU_PULSE1_ENVLP EQU $4000
APU_PULSE1_SWEEP EQU $4001
APU_PULSE1_TIMER EQU $4002
APU_PULSE1_LENCT EQU $4003
V1FREQLO         EQU APU_PULSE1_TIMER
V1FREQHI         EQU APU_PULSE1_LENCT
V1ENVLP          EQU APU_PULSE1_ENVLP

APU_PULSE2_ENVLP EQU $4004
APU_PULSE2_SWEEP EQU $4005
APU_PULSE2_TIMER EQU $4006
APU_PULSE2_LENCT EQU $4007
V2FREQLO         EQU APU_PULSE2_TIMER
V2FREQHI         EQU APU_PULSE2_LENCT
V2ENVLP          EQU APU_PULSE2_ENVLP

APU_TRIANG_LINCT EQU $4008
APU_TRIANG_TIMER EQU $400A
APU_TRIANG_LENCT EQU $400B
V3FREQLO         EQU APU_TRIANG_TIMER
V3FREQHI         EQU APU_TRIANG_LENCT
V3ENVLP          EQU APU_NOISE_ENVEL

APU_NOISE_ENVEL  EQU $400C
APU_NOISE_MODE   EQU $400E
APU_NOISE_LENCT  EQU $400F
V4FREQLO         EQU APU_NOISE_MODE
V4FREQHI         EQU APU_NOISE_LENCT
V4ENVLP          EQU APU_NOISE_ENVEL

APU_MASTER_CTRL  EQU $4015

  MAC loadvoice
	ENDM

	MAC savevoice
	ENDM
  
  MAC voice_on
    lda #[1 << [{1} - 1]]
    ora APU_MASTER_CTRL_SHADOW
    sta APU_MASTER_CTRL_SHADOW
    sta APU_MASTER_CTRL
	ENDM
	
	MAC voice_off
    lda #[[1 << [{1} -1 ]] ^ $FF]
    and APU_MASTER_CTRL_SHADOW
    sta APU_MASTER_CTRL_SHADOW
    sta APU_MASTER_CTRL
	ENDM

  MAC voice_tone ; @pull
.LO  EQU V{1}FREQLO
.HI  EQU V{1}FREQHI
.HIS EQU V{1}FREQHI_SHADOW
    IF {1} == 4 ; Noise channel
      IF !FPULL
        pla
      ENDIF
      sta .LO
      IF !FPULL
        pla ; discard HB
      ENDIF
      lda .HIS
      sta .HI
    ELSE
      IF !FPULL
        lda .HIS
        and #%11111000
        sta .HIS
        pla
        ora .HIS
        sta .HIS
        sta .HI
        pla
        sta .LO
      ELSE	
        sta .LO
        lda .HIS
        and #%11111000
        sta .HIS
        tya
        ora .HIS
        sta .HIS
        sta .HI
      ENDIF
    ENDIF	
	ENDM
  
  MAC voice_pulse ; @pull
.REG EQU APU_PULSE{1}_ENVLP
.SRE EQU APU_PULSE{1}_ENVLP_SHADOW
    IF !FPULL
      lda .SRE
      and #%00111111
      sta .SRE
      pla
      REPEAT 6
        asl
      REPEND
      ora .SRE
      sta .SRE
      sta .REG	
    ELSE	
      tay
      lda .SRE
      and #%00111111
      sta .SRE
      tya
      pla
      REPEAT 6
        asl
      REPEND
      ora .SRE
      sta .SRE
      sta .REG	
    ENDIF
	ENDM
  
  MAC voice_duration ; @pull
.SRE EQU V{1}FREQHI_SHADOW
    IF {1} == 3 ; Triangle voice
      ldx #$7F
      stx APU_TRIANG_LINCT
    ENDIF
    IF !FPULL
      lda .SRE
      and #%00000111
      sta .SRE
      pla
      REPEAT 3
        asl
      REPEND
      ora .SRE
      sta .SRE
    ELSE	
      tay
      lda .SRE
      and #%00000111
      sta .SRE
      tya
      REPEAT 3
        asl
      REPEND
      ora .SRE
      sta .SRE
    ENDIF
	ENDM
  
  MAC voice_envelope ; @pull
.REG EQU V{1}ENVLP
.SRE EQU V{1}ENVLP_SHADOW   
    IF !FPULL
      pla
    ENDIF
    tay
    lda .SRE
    and #%00001111
    sta .SRE
    tya
    ora .SRE
    sta .SRE
    sta .REG
  ENDM

	MAC sound_clear
    lda #0
    ldx #12
.l1
    sta APU_PULSE1_ENVLP,x
    sta APU_PULSE1_ENVLP_SHADOW,x
    dex
    bpl .l1
    sta APU_NOISE_LENCT
    sta APU_MASTER_CTRL
	ENDM
  
  MAC voice_sweep ; @pull
.REG EQU APU_PULSE{2}_SWEEP
    IF !FPULL
      pla ; Clock rate
    ENDIF
    REPEAT 4
      asl
    REPEND
    IF {1} == "UP"
      ldx #%10001000
    ELSE
      ldx #%10000000
    ENDIF
    stx R0
    ora R0
    sta R0
    pla
    and #%00000111
    ora R0
    sta .REG
  ENDM
