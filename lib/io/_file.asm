	; Calls SETNAM with string on stack
	MAC setnam
	ldx SP
	inx
	lda STRING_WORKAREA,x
	inx
	ldy #>STRING_WORKAREA
	kerncall KERNAL_SETNAM
	import I_STRSCRATCH
	jsr STRSCRATCH
	ENDM
	
	MAC setlfs
	pla
	tay
	pla
	tax
	pla
	kerncall KERNAL_SETLFS
	ENDM
	
	MAC open
	kerncall KERNAL_OPEN
	bcc .ok
	import I_RUNTIME_ERROR
	jmp RUNTIME_ERROR
.ok
	ENDM

	MAC close
	IF !FPULL
	pla
	ENDIF
	kerncall KERNAL_CLOSE
	ENDM
	
	; GET#
	; logical file# on stack
	; returns char on stack
	MAC get_hash
	IF !FPULL
	pla
	ENDIF
	tax
	kerncall KERNAL_CHKIN
	kerncall KERNAL_CHRIN
	pha
	kerncall KERNAL_CLRCHN
	ENDM
	
	MAC F_st
	jsr KERNAL_READST
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; INPUT#
	; logical file# on stack
	; returns string on string stack
	MAC input_hash
	IF !FPULL
	pla
	ENDIF
	tax
	kerncall KERNAL_CHKIN
	ldy #0
.loop
	tya
	pha
	kerncall KERNAL_CHRIN
	tax
	kerncall KERNAL_READST
	bne .over
    pla
    tay
    txa
    cmp #$0d ; Return
    beq .over
    cmp #$2c ; Comma
    beq .over
    cmp #$3a ; Colon
    beq .over
    cmp #$3b ; Semicolon
    beq .over
    sta.wy STRING_BUFFER1 + 1
    iny
    cpy #80
    bne .loop
.over
	sty STRING_BUFFER1
    kerncall KERNAL_CLRCHN
    rts
	ENDM
	
	; PRINT#
	; logical file# on stack
	; string on string stack
	; {1} = 1 : this is the last string in block
	MAC print_hash
	IF !FPULL
	pla
	ENDIF
	tax
	kerncall KERNAL_CHKIN
	ldx SP
	inx
	lda STRING_WORKAREA,x
	beq .q
	sta R2
	inx
	stx R0
	lda #>STRING_WORKAREA
	sta R0 + 1
	ldy #0
.loop
	lda (R0),y
	kerncall KERNAL_CHROUT
	iny
	cpy R2
	bne .loop
.q
	IF {1} == 1
	lda #$0d ; Return
	ELSE
	lda #$2c ; Comma
	ENDIF
	kerncall KERNAL_CHROUT
	rts
	ENDM
	
	; Load routine
	; load 1: load at address stored in file
	; load 0: load at a specified address 
	MAC load
	; get address
	IF {1} == 0
	pla
	tay
	pla
	tax
	ENDIF
	lda #$00
	kerncall KERNAL_LOAD
	bcc .q
	import I_RUNTIME_ERROR
	jmp RUNTIME_ERROR
.q:
	ENDM
	
	; Save routine
	MAC save
	; get start address
	IF !FPULL
	pla
	sta R0 + 1
	pla
	sta R0
	ELSE
	sta R0
	sty R0 + 1
	ENDIF
	pla
	tay
	pla
	tax
	lda #R0
	kerncall KERNAL_SAVE
	bcc .q
	import I_RUNTIME_ERROR
	jmp RUNTIME_ERROR
.q:
	ENDM