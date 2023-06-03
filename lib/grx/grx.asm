	IF TARGET == c64 || TARGET == c128 || TARGET == mega65
HSCR EQU $D016	
VSCR EQU $D011	
RAST EQU $D012
RAST8 EQU $D011
	ENDIF
	IF TARGET & c264
HSCR EQU $FF07	
VSCR EQU $FF06	
RAST EQU $FF0B
RAST8 EQU $FF0A
	ENDIF
	IF TARGET & vic20
RAST EQU $9004
RAST8 EQU $9003
	ENDIF

	IF TARGET == x16
RAST EQU $9F28
RAST8 EQU $9F26
	ENDIF

    IF TARGET == mega65
VIC4_CHARPTR EQU $0FFD3068
    ENDIF
	
VMODE_TEXT EQU 1	
VMODE_BITMAP EQU 2	
VMODE_EXT EQU 3	
VMODE_HIRES EQU 0
VMODE_MULTI EQU 1

VICII_BORDER	 EQU $D020
VICII_BACKGROUND EQU $D021
TED_BORDER	 	 EQU $FF19
TED_BACKGROUND   EQU $FF15
VICI_BORDER_BG	 EQU $900F
VERA_BORDER		 EQU $9F2C
VERA_L0_HSCROLL_L EQU $9F30
VERA_L0_HSCROLL_H EQU $9F31
VERA_L0_VSCROLL_L EQU $9F32
VERA_L0_VSCROLL_H EQU $9F33
VERA_L1_HSCROLL_L EQU $9F37
VERA_L1_HSCROLL_H EQU $9F38
VERA_L1_VSCROLL_L EQU $9F39
VERA_L1_VSCROLL_H EQU $9F3A

	MAC hscroll ; @pull

	IF TARGET == c64 || TARGET == c128 || TARGET & c264 || TARGET == mega65
	  IF !FPULL
	    pla
	  ENDIF
	  and #%00000111
	  sta R0
	  lda HSCR
	  and #%11111000
	  ora R0
	  sta HSCR
	ENDIF

	IF TARGET == x16
	  IF !FPULL
	    pla
		sta VERA_L{1}_HSCROLL_H
		pla
		sta VERA_L{1}_HSCROLL_L
	  ELSE
	  	sta VERA_L{1}_HSCROLL_L
		sty VERA_L{1}_HSCROLL_H
	  ENDIF
	ENDIF

	ENDM
	
	MAC vscroll ; @pull

	IF TARGET == c64 || TARGET == c128 || TARGET & c264 || TARGET == mega65
	  IF !FPULL
	    pla
	  ENDIF
	  and #%00000111
	  sta R0
	  lda VSCR
	  and #%11111000
	  ora R0
	  sta VSCR
	ENDIF

	IF TARGET == x16
	  IF !FPULL
	    pla
		sta VERA_L{1}_VSCROLL_H
		pla
		sta VERA_L{1}_VSCROLL_L
	  ELSE
	  	sta VERA_L{1}_VSCROLL_L
		sty VERA_L{1}_VSCROLL_H
	  ENDIF

	ENDM
	
	; 1 = text
	; 2 = bitmap
	; 3 = ext
	MAC vmode
	IF TARGET & vic20 || TARGET & pet
	ELSE
	lda VSCR
	IF {1} == 1
	and #%01011111
	ENDIF
	IF {1} == 2
	ora #%00100000
	ENDIF
	IF {1} == 3
	ora #%01000000
	ENDIF
	sta VSCR
	ENDIF
	ENDM
	
	; 0 = hires
	; 1 = multi
	MAC vmodecolor
	IF TARGET & vic20 || TARGET & pet
	ELSE
	lda HSCR
	IF {1} == 1
	ora #%00010000
	ELSE
	and #%11101111
	ENDIF
	sta HSCR
	ENDIF
	ENDM
	
	MAC rsel
	IF TARGET & vic20 || TARGET & pet
	ELSE
    lda VSCR
	IF {1} == 1
    ora #%00001000
	ELSE
    and #%11110111
	ENDIF
    sta VSCR
	ENDIF
	ENDM
	
	MAC csel
	IF TARGET & vic20 || TARGET & pet
	ELSE
	lda HSCR
	IF {1} == 1
    ora #%00001000
	ELSE
    and #%11110111
	ENDIF
    sta HSCR
	ENDIF
	ENDM

	; Sets screen mode for X16
	MAC vmode_x16 ; @pull
	IF !FPULL
	pla
	ENDIF
	clc
	jsr $FF5F ; screen_mode
	ENDM

CHARSETSEL SET 0    

	MAC charsetram
	IF TARGET & c264
	lda $FF12
	and #%11111011
	sta $FF12
	ENDIF
	IF TARGET & vic20
	lda $9005
	ora #%00001000
	sta $9005
	ENDIF
	IF TARGET == x16
CHARSETSEL SET 1
	ENDIF
	ENDM
	
	MAC charsetrom
	IF TARGET & c264
	lda $FF12
	ora #%00000100
	sta $FF12
	ENDIF
	IF TARGET & vic20
	lda $9005
	and #%11110111
	sta $9005
	ENDIF
	IF TARGET == x16
CHARSETSEL SET 0
	ENDIF
	ENDM
    
	MAC charset ; @pull
	IF TARGET == x16
	  IF CHARSETSEL == 0
	    IF !FPULL
		  pla ; drop HB
		  pla ; keep LB
	    ENDIF	
		and #%00000011
		jsr X16_screen_set_charset
	  ELSE
		IF !FPULL
		  HEX 7A; ply
		  HEX FA; plx
		ELSE
		  tax
	    ENDIF
		lda #0
		jsr X16_screen_set_charset
	  ENDIF
	ELSE
	IF !FPULL
      pla
    ENDIF
	ENDIF
    IF (TARGET == c64) || (TARGET == c128)
    asl
    and #%00001110
    sta R0
    lda $D018
    and #%11110001
    ora R0
    sta $D018
    ENDIF
	IF TARGET & c264
    asl
    asl
    sta R0
	lda $FF13
    and #%00000011
    ora R0
    sta $FF13
    ENDIF
    IF TARGET & vic20 
    and #%00000111
    sta R0
    lda $9005
    and #%11111000
    ora R0
    sta $9005
    ENDIF
    IF TARGET == mega65
      ldx #<VIC4_CHARPTR
      stx R0
      ldx #>VIC4_CHARPTR
      stx R0 + 1
      ldx #<[VIC4_CHARPTR >> 16]
      stx R0 + 2
      ldx #>[VIC4_CHARPTR >> 16]
      stx R0 + 3
      IF !FPULL
        ldz_imm #2
        sta_indz R0
        pla
        dez
        sta_indz R0
        pla
        dez
        sta_indz R0
      ELSE
        ldz_imm #0
        sta_indz R0
        tya
        inz
        sta_indz R0
        txa
        inz
        sta_indz R0
      ENDIF
    ENDIF
	ENDM

	MAC F_scan
	IF TARGET & vic20
	  clc
	  lda RAST8
	  asl
	  lda RAST
	  asl
	  pha
	  lda #0
	  rol
	  pha
	ELSE
	  lda RAST
	  pha
	  lda RAST8
	  IF (TARGET == c64) || (TARGET == c128) || (TARGET == x16) || (TARGET == mega65)
	  asl
	  lda #0
	  rol
	  ENDIF
	  IF TARGET & c264
	  and #%00000001
	  ENDIF
	  pha
	ENDIF
	ENDM