
    ; GET
	MAC get
	jsr KERNAL_GETIN
	IF !FPUSH
	pha
	ENDIF
	ENDM
     
     ; Input string from keyboard
     ; Accepted chars: $20-5F and $A0-$DF
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
	sty $cc	; turn on cursor
.loop
	tya
	pha
    jsr KERNAL_GETIN
    tax
    pla
    tay
    txa
    beq .loop
    cmp #$14 ; Delete
    bne .1
    cpy #0
    beq .loop
    dey
    jsr KERNAL_PRINTCHR
    jmp .loop
.1  cmp #$0d ; Return
    beq .q
	cmp #$20 ;
	bcc .loop
	cmp #$df
	bcs .loop
	cmp #$5f
	bcc .ok
	cmp #$a0
	bcs .ok
	bcc .loop
.ok
    ; Write character
    sta.wy STRING_BUFFER1 + 1
    ; Echo it
    jsr KERNAL_PRINTCHR
    iny
    jmp .loop
.q
	sty STRING_BUFFER1
	; turn off cursor
	sei
	ldy $d3 ; y pos of cursor
	lda $ce ; character under cursor
	and #%01111111
	sta ($d1),y
	lda #$ff
	sta $cc
	cli
	rts
	ENDIF