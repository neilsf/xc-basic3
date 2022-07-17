	IF TARGET == c64
HSCR EQU $D016	
VSCR EQU $D011	
	ENDIF
	IF TARGET & c264
HSCR EQU $FF07	
VSCR EQU $FF06	
	ENDIF
	
	IF TARGET & vic20 || TARGET & pet
	
	MAC hscroll
	ENDM
	MAC vscroll
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
	
	ENDIF