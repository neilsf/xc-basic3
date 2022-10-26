	IF TARGET == c64 || TARGET == c128
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
	
VMODE_TEXT EQU 1	
VMODE_BITMAP EQU 2	
VMODE_EXT EQU 3	
VMODE_HIRES EQU 0
VMODE_MULTI EQU 1
	
	MAC hscroll ; @pull
	IF !FPULL
	pla
	ENDIF
	IF TARGET & vic20 || TARGET & pet
	ELSE
	and #%00000111
	sta R0
	lda HSCR
	and #%11111000
	ora R0
	sta HSCR
	ENDIF
	ENDM
	
	MAC vscroll ; @pull
	IF !FPULL
	pla
	ENDIF
	IF TARGET & vic20 || TARGET & pet
	ELSE
	and #%00000111
	sta R0
	lda VSCR
	and #%11111000
	ora R0
	sta VSCR
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
	and #%11011111
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
	ENDM
    
	MAC charset ; @pull
    IF !FPULL
    pla
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
	  IF (TARGET == c64) || (TARGET == c128) 
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