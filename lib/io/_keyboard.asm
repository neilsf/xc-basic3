	
	IF TARGET == c64 || TARGET = c128
IO_KEYW		EQU $DC00 
IO_KEYR		EQU $DC01
IO_DDRA		EQU $DC02
IO_DDRB		EQU $DC03
	ENDIF 

	IF TARGET & vic20
IO_KEYW		EQU $9120 
IO_KEYR		EQU $9121 
	ENDIF
	
	IF TARGET & c264
IO_KEYW		EQU $FD30 
IO_KEYR		EQU $FF08 	
	ENDIF
	
	IF TARGET & pet
IO_KEYW		EQU $E810 
IO_KEYR		EQU $E812
	ENDIF
	
    ; GET
	MAC get ; @push
	kerncall KERNAL_GETIN
	IF !FPUSH
	pha
	ENDIF
	ENDM
     
     ; Input string from keyboard
    MAC input
    import I_IO_INPUT
    jsr IO_INPUT
    lda #<STRING_BUFFER1
    sta R0
    lda #>STRING_BUFFER1
    sta R0 + 1
    lda STRING_BUFFER1
    import I_STRMOV
    jsr STRMOV
    ENDM
    
    IFCONST I_IO_INPUT_IMPORTED
IO_INPUT SUBROUTINE
	ldy #0
.loop
	kerncall KERNAL_CHRIN
	sta.wy STRING_BUFFER1 + 1
    iny
	cmp #$0d
	bne .loop
    dey ; remove <CR> from end of input
	sty STRING_BUFFER1
	rts
	ENDIF
	
	; DECLARE FUNCTION KEY AS BYTE (scancode AS WORD) SHARED STATIC INLINE
	; HB: Keyboard write mask
	; LB: Keyboard read mask
	MAC F_key_word ; @push @pull
	IF TARGET == c64 || TARGET = c128
	ldx #%11111111 
 	stx IO_DDRA             
	ldx #%00000000
	stx IO_DDRB      
	ENDIF
	  If !FPULL
	  pla
	  sta IO_KEYW
		IF TARGET & c264
		sta IO_KEYR
	    ENDIF
	  ELSE
		sty IO_KEYW
		IF TARGET & c264
		sta IO_KEYR
	    ENDIF
	  ENDIF
	ENDIF
	If !FPULL
	pla
	ENDIF
	and IO_KEYR
	bne .f
	ptrue
	bne .q
.f
	pfalse
.q
	ENDM