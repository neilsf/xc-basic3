	; Fills memory area
	;
	; derived from Practical Memory Move Routines
	; by Bruce Clark 
	;
	; R0: destination address
	; A: fill byte
	; R2: number of bytes to copy
	IFCONST I_MEMSET_IMPORTED	
MEMSET	SUBROUTINE
.dst	EQU R0
.siz	EQU R2
		ldy #0
        ldx .siz+1
        beq .md2
.md1    
        sta (.dst),Y
        iny
        bne .md1
        inc .dst+1
        dex
        bne .md1
.md2    ldx .siz
        beq .md4
.md3
        sta (.dst),Y
        iny
        dex
        bne .md3
.md4    rts
	ENDIF

	MAC memset ; @pull
      ;
	  ; MEGA65 Target, use DMA
	  ;
      IF TARGET == mega65
        IF !FPULL
	      pla
	      sta .dst + 2
          pla
	      sta .dst + 1
	      pla
	      sta .dst
	    ELSE
	      sta .dst
	      sty .dst + 1
          stx .dst + 2
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
.count  DC.W 2000  ; count
.value  DC.W $0000 ; value
        DC.B $00   ; src bank
.dst    DC.W $0800 ; dst
        DC.B $00   ; dst bank
        DC.B $00   ; cmd hi
        DC.W $0000 ; modulo / ignored
      ;
      ; Classic Commmodore target, use routine
      ;
      ELSE
	    IF !FPULL
	      pla
	      sta R1
	      pla
	      sta R0
	    ELSE
	      sta R0
	      sty R1
	    ENDIF
	    pla
	    sta R3
	    pla
	    sta R2
	    pla
	    import I_MEMSET
	    jsr MEMSET
      ENDIF
	ENDM
			
	; Copies memory area downwards
	; from Practical Memory Move Routines
	; by Bruce Clark
	;
	; R0: source address
	; R2: destination address
	; R4: number of bytes to copy
	;
	; overlapping safe downwards only
	
	IFCONST I_MEMCPY_IMPORTED	
MEMCPY	SUBROUTINE
.src	EQU R0
.dst	EQU R2
.siz	EQU R4
		ldy #0
        ldx .siz+1
        beq .md2
.md1    lda (.src),Y
        sta (.dst),Y
        iny
        bne .md1
        inc .src+1
        inc .dst+1
        dex
        bne .md1
.md2    ldx .siz
        beq .md4
.md3    lda (.src),Y
        sta (.dst),Y
        iny
        dex
        bne .md3
.md4    rts
	ENDIF
	
	MAC memcpy ; @pull
	IF !FPULL
	pla
	sta R1
	pla
	sta R0
	ELSE
	sta R0
	sty R1
	ENDIF
	pla
	sta R3
	pla
	sta R2
	pla
	sta R5
	pla
	sta R4
	import I_MEMCPY
	jsr MEMCPY
	ENDM
	
	; Copies memory area upwards
	;
	; from Practical Memory Move Routines
	; by Bruce Clark
	;
	; FROM = source start address
	; TO = destination start address
	; SIZE = number of bytes to move
	IFCONST I_MEMSHIFT_IMPORTED
MEMSHIFT SUBROUTINE
.FROM	EQU R0
.TO		EQU R2
.SIZE	EQU R4

	ldx .SIZE+1
    clc          ; start at the final pages of FROM and TO
 	txa
	adc .FROM+1
	sta .FROM+1
    clc
	txa
	adc .TO+1
	sta .TO+1
	inx
	ldy .SIZE
	beq .mu3
    dey
    beq .mu2
.mu1    
	lda (.FROM),y
	sta (.TO),y
	dey
	bne .mu1
.mu2      
    lda (.FROM),y
    sta (.TO),Y
.mu3     
	dey
    dec .FROM+1
    dec .TO+1
    dex
    bne .mu1
    rts
    ENDIF
    
    MAC memshift ; @pull
	IF !FPULL
	pla
	sta R1
	pla
	sta R0
	ELSE
	sta R0
	sty R1
	ENDIF
	pla
	sta R3
	pla
	sta R2
	pla
	sta R5
	pla
	sta R4
	import I_MEMSHIFT
	jsr MEMSHIFT
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