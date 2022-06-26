	IF TARGET == c64
HSCR EQU $D016	
VSCR EQU $D011	
	ENDIF
	IF TARGET & c264
HSCR EQU $FF07	
VSCR EQU $FF06	
	ENDIF
	
VMODE_TEXT EQU 1	
VMODE_BITMAP EQU 2	
VMODE_EXT EQU 3	
VMODE_HIRES EQU 0
VMODE_MULTI EQU 1
	
	IF TARGET & vic20
	
	MAC hscroll
	ENDM
	MAC vscroll
	ENDM
	MAC vmode
	ENDM
	MAC vmodecolor
	ENDM
	MAC rsel
	ENDM
	MAC csel
	ENDM
	ELSE
	
	MAC hscroll ; @pull
	IF !FPULL
	pla
	ENDIF
	and #%00000111
	sta R0
	lda HSCR
	and #%11111000
	ora R0
	sta HSCR
	ENDM
	
	MAC vscroll ; @pull
	IF !FPULL
	pla
	ENDIF
	and #%00000111
	sta R0
	lda VSCR
	and #%11111000
	ora R0
	sta VSCR
	ENDM
	
	; 1 = text
	; 2 = bitmap
	; 3 = ext
	MAC vmode
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
	ENDM
	
	; 0 = hires
	; 1 = multi
	MAC vmodecolor
	lda HSCR
	IF {1} == 1
	ora #%00010000
	ELSE
	and #%11101111
	ENDIF
	sta HSCR
	ENDM
	
	MAC rsel
	IF !FPULL
	pla
	ENDIF
	and #%00000001
	asl
	asl
	asl
	asl
	sta R0
	lda VSCR
	and #%11110111
	ora R0
	sta VSCR
	ENDM
	
	MAC csel
	IF !FPULL
	pla
	ENDIF
	and #%00000001
	asl
	asl
	asl
	asl
	sta R0
	lda HSCR
	and #%11110111
	ora R0
	sta HSCR
	ENDM
	
	ENDIF