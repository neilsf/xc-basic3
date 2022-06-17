
    ; GET
	MAC get ; @push
	kerncall KERNAL_GETIN
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
	; turn on cursor
	IF TARGET == c64 || (TARGET & vic20)
	lda #0
	sta $CC
	ENDIF
	IF TARGET == c128
	lda #0
	sta $A27
	ENDIF
	IF TARGET & c264
	IMPORT I_C264_ENABLE_CRSR
	jsr C264_ENABLE_CRSR
	ENDIF
	ldy #0
.loop
	tya
	pha
    kerncall KERNAL_GETIN
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
    kerncall KERNAL_CHROUT
    IF TARGET & c264
    ; Cursor left
    dec TED_CRSR_LO
    lda #$ff
	cmp TED_CRSR_LO
	bne .skip1
	dec TED_CRSR_HI
.skip1
    ENDIF
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
    kerncall KERNAL_CHROUT
    IF TARGET & c264
    ; Cursor right
    inc TED_CRSR_LO
	bne .skip2
	inc TED_CRSR_HI
.skip2
    ENDIF
    iny
    jmp .loop
.q
	sty STRING_BUFFER1
	; turn off cursor
	IF TARGET == c64 || (TARGET & vic20)
	sei
	ldy $d3 ; y pos of cursor
	lda $ce ; character under cursor
	and #%01111111
	sta ($D1),y
	lda #$FF
	sta $CC
	cli
	ENDIF
	IF TARGET == c128
	lda #$FF
	sta $0A27
	ENDIF
	IF TARGET & c264
	IMPORT I_C264_DISABLE_CRSR
	jsr C264_DISABLE_CRSR
	ENDIF
	rts
	ENDIF
	
	; Enable hardware cursor on C264 
	IFCONST I_C264_ENABLE_CRSR_IMPORTED
C264_ENABLE_CRSR SUBROUTINE
    sec
	kerncall KERNAL_PLOT
	txa
	REPEAT 3
	asl
	REPEND
	pha		; A * 8
	sta R0
	lda #0
	sta R0 + 1
	REPEAT 2
	asl R0
	rol R0 + 1
	REPEND	; A * 32
	pla
	; A * 32 + A * 8 = A * 40
	clc
	adc R0
	sta R0
	bcc .1
	inc R0 + 1
.1
	clc
	tya
	adc R0
	sta R0
	bcc .2
	inc R0 + 1
.2
	sta TED_CRSR_LO
	lda R0 + 1
	sta TED_CRSR_HI
	rts
    ENDIF
    
    ; Disable hardware cursor on C264 
	IFCONST I_C264_DISABLE_CRSR_IMPORTED
C264_DISABLE_CRSR SUBROUTINE
	lda #$FF
	sta TED_CRSR_LO
	sta TED_CRSR_HI
	rts
	ENDIF