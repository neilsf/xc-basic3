	MAC memset ; @pull
    IF !FPULL
      pla
      and #%00001111
      sta .dst + 2
      pla
      sta .dst + 1
      pla
      sta .dst
    ELSE
      sta .dst
      sty .dst + 1
      txa
      and #%00001111
      sta .dst + 2
    ENDIF
    pla
    sta .count + 1
    pla
    sta .count
    pla
    sta .value
    sta $D707
    DC.B $00   ; end of job options
    DC.B $03   ; fill
.count
    DC.W 2000  ; count
.value 
    DC.W $0000 ; value
    DC.B $00   ; src bank
.dst
    DC.W $0800 ; dst
    DC.B $00   ; dst bank
    DC.B $00   ; cmd hi
    DC.W $0000 ; modulo / ignored
	ENDM

	MAC memcpy ; @pull
    ; Source address
    IF !FPULL
      pla
      and #%00001111
      sta .src + 2
      pla
      sta .src + 1
      pla
      sta .src
    ELSE
      sta .src
      sty .src + 1
      txa
      and #%00001111
      sta .src + 2
    ENDIF
    ; Dest address
    pla
    and #%00001111
    sta .dst + 2
    pla
    sta .dst + 1
    pla
    sta .dst
    ; Length
    pla
    sta .count + 1
    pla
    sta .count
    sta $D707  ; Go!
    
    DC.B $0B   ; F018B type job
    DC.B $00   ; end of job options
    DC.B $00   ; copy
.count
    DC.W $0000 ; count
.src 
    DC.W $0000 ; value
    DC.B $00   ; src bank
.dst
    DC.W $0000 ; dst
    DC.B $00   ; dst bank
    DC.B $00   ; cmd hi
    DC.W $0000 ; modulo / ignored    
	ENDM
    
    MAC memshift ; @pull
    ; Source address
    IF !FPULL
      pla
      and #%00001111
      sta .src + 2
      pla
      sta .src + 1
      pla
      sta .src
    ELSE
      sta .src
      sty .src + 1
      txa
      and #%00001111
      sta .src + 2
    ENDIF
    ; Dest address
    pla
    and #%00001111
    sta .dst + 2
    pla
    sta .dst + 1
    pla
    sta .dst
    ; Length
    pla
    sta .count + 1
    sta R1
    pla
    sta .count
    sta R0
    dec R0
    bpl .1
    dec R1
.1
    ; Add length - 1 to source
    lda R0
    clc
    adc .src
    sta .src
    lda R1
    adc .src + 1
    sta .src + 1
    ; Add length - 1 to dst
    lda R0
    clc
    adc .dst
    sta .dst
    lda R1
    adc .dst + 1
    sta .dst + 1
    sta $D707  ; Go!
    
    DC.B $0B   ; F018B type job
    DC.B $00   ; end of job options
    DC.B %00110000   ; copy + downwards
.count
    DC.W $0000 ; count
.src 
    DC.W $0000 ; value
    DC.B $00   ; src bank
.dst
    DC.W $0000 ; dst
    DC.B $00   ; dst bank
    DC.B $00   ; cmd hi
    DC.W $0000 ; modulo / ignored    
	ENDM
	
	MAC poke ; @pull
	IF !FPULL
	pla
	sta .l + 2
	pla
	sta .l + 1
	ELSE
	sta .l + 1
	sty .l + 2
	ENDIF
	pla
.l  sta $ffff
	ENDM
    
	; usage: poke {const address}
	MAC poke_constaddr ; @pull
	IF !FPULL
	pla
	ENDIF
	sta {1}
	ENDM
    
	; POKE (long address) - 45XX CPU only
	MAC pokel ; @pull
    IF !FPULL
	pla
	sta R6
	pla
	sta R5
	pla
	sta R4
	ELSE
	sta R4
	sty R5
	stx R6
	ENDIF
    lda #0
    sta R7
    ldz_imm #0
    pla
    sta_indz R4 
    ENDM
	
	; POKE (const long address) - 45XX CPU only
	MAC pokel_constaddr ; @pull
    ldx #<{1}
	stx R4
	ldx #>{1}
	stx R5
	ldx #[{1} >> 16]
    stx R6
	ldx #0
    stx R7
    ldz_imm #0
    IF !FPULL
    pla
    ENDIF
    sta_indz R4
    ENDM
    
    ; DOKE (long address) - 45XX CPU only
	MAC dokel ; @pull
    IF !FPULL
	pla
	sta R6
	pla
	sta R5
	pla
	sta R4
	ELSE
	sta R4
	sty R5
	stx R6
	ENDIF
    lda #0
    sta R7
    ldz_imm #1
    pla
    sta_indz R4
    dez
    pla
    sta_indz R4
	ENDM
    
	; DOKE (const long address) - 45XX CPU only
	MAC dokel_constaddr ; @pull
    ldx #<{1}
	stx R4
	ldx #>{1}
	stx R5
	ldx #[{1} >> 16]
    stx R6
	ldx #0
    stx R7
    IF !FPULL
      ldz_imm #1
      pla
      sta_indz R4
      dez
      pla
      sta_indz R4
    ELSE
      ldz_imm #0
      sta_indz R4
      tya
      inz
      sta_indz R4
    ENDIF
    ENDM

	MAC doke ; @pull
	IF !FPULL
	pla
	sta R1
	pla
	sta R0
	ELSE
	sta R0
	sty R1
	ENDIF
	ldy #$01
	pla
	sta (R0),y
	dey
	pla
	sta (R0),y
	ENDM
	
	; usage: doke {const address}
	MAC doke_constaddr ; @pull
	IF !FPULL
	pla
	sta {1} + 1
	pla
	sta {1}
	ELSE
	sta {1}
	sty {1} + 1
	ENDIF
	ENDM