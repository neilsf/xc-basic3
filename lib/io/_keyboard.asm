
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
	sty STRING_BUFFER1
	rts
	ENDIF