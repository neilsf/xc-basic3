STATUS EQU $90 ; KERNAL I/O STATUS
KERNAL_SETNAM EQU $FFBD
KERNAL_SETLFS EQU $FFBA
KERNAL_OPEN   EQU $FFC0
KERNAL_READST EQU $FFB7
KERNAL_CLOSE  EQU $FFC3
KERNAL_GETIN  EQU $FFE4
KERNAL_CHRIN  EQU $FFCF
KERNAL_CHKIN  EQU $FFC6
KERNAL_CLRCHN EQU $FFCC
KERNAL_LOAD	  EQU $FFD5
KERNAL_SAVE   EQU $FFD8

	; Calls SETNAM with string on stack
	MAC setnam
	ldx SP
	inx
	lda STRING_WORKAREA,x
	inx
	ldy #>STRING_WORKAREA
	jsr KERNAL_SETNAM
	import I_STRSCRATCH
	jsr STRSCRATCH
	ENDM
	
	MAC setlfs
	pla
	tay
	pla
	tax
	pla
	jsr KERNAL_SETLFS
	ENDM
	
	MAC open
	jsr KERNAL_OPEN
	bcc .ok
	import I_RUNTIME_ERROR
	jmp RUNTIME_ERROR
.ok
	ENDM

	MAC close
	IF !FPULL
	pla
	ENDIF
	jsr KERNAL_CLOSE
	ENDM
	
	; GET#
	; logical file# on stack
	; returns char on stack
	MAC get_hash
	IF !FPULL
	pla
	ENDIF
	tax
	jsr KERNAL_CHKIN
	jsr KERNAL_CHRIN
	pha
	jsr KERNAL_CLRCHN
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
	jsr KERNAL_CHKIN
	ldy #0
	jsr KERNAL_READST
.loop
	tya
	pha
	jsr KERNAL_CHRIN
	tax
	jsr KERNAL_READST
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
    jmp KERNAL_CLRCHN
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
	jsr KERNAL_LOAD
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
	jsr KERNAL_SAVE
	bcc .q
	import I_RUNTIME_ERROR
	jmp RUNTIME_ERROR
.q:
	ENDM