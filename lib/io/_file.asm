	; Calls SETNAM with string on stack
	; {1} = 0 name is empty
	; {1} = 1 name is not empty
	MAC setnam
	IF {1} == 1
	ldx SP
	inx
	lda STRING_WORKAREA,x
	inx
	ldy #>STRING_WORKAREA
	ELSE
	lda #$00 ; no filename
    tax
    tay
	ENDIF
	kerncall KERNAL_SETNAM
	IF {1} == 1
	import I_STRSCRATCH
	jsr STRSCRATCH
	ENDIF
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
	import I_RUNTIME_ERROR
	kerncall KERNAL_OPEN
	bcc .ok
	jmp RUNTIME_ERROR
.ok
	ENDM

	MAC close ; @pull
	IF !FPULL
	pla
	ENDIF
	kerncall KERNAL_CLOSE
	ENDM
	
	; GET#
	; logical file# on stack
	; returns char on stack
	MAC get_hash ; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	kerncall KERNAL_CHKIN
	kerncall KERNAL_CHRIN
	pha
	kerncall KERNAL_CLRCHN
	ENDM
	
	MAC F_st ; @push
	jsr KERNAL_READST
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; INPUT#
	; Output on string stack
	MAC input_hash
	import I_STRREAD
	jsr I_STRREAD
	ENDM
	
	; Set file as default input
	; Call before input#, read# commands
	MAC chkin
	ldx {1}
	kerncall KERNAL_CHKIN
	ENDM
	
	; Set file as default output
	; Call before print#, write# commands
	MAC chkout
	ldx {1}
	kerncall KERNAL_CHKOUT
	ENDM
	
	; Restore default input/output to keyboard/screen.
	; Call after input# and print# commands
	MAC clrchn
	kerncall KERNAL_CLRCHN
	ENDM
	
	; WRITE# (numeric or udt)
	; value on stack (pushed first)
	; logical file# in R9
	; byte length in {1}
	MAC write
	ldx #{1}
	import I_BINWRITE
	jsr I_BINWRITE
	ENDM
	
	; Writes arbitrary number of bytes to file
	; logical file # in R9
	; number of bytes in X
	; data on stack
	IFCONST I_BINWRITE_IMPORTED
I_BINWRITE SUBROUTINE
	; save return address
	pla
	sta RA
	pla
	sta RB
.loop
	pla
	kerncall KERNAL_CHROUT
	dex
	bne .loop
	; restore return address
	lda RB
	pha
	lda RA
	pha
	rts
	ENDIF
	
	; READ# (numeric or udt)
	; target address pushed on stack
	; byte length in {1}
	MAC read
	pla 
	tax
	pla
	ldy #{1}
	import I_BINREAD
	jsr I_BINREAD
	ENDM
	
	; Restores arbitrary number of bytes from file
	; Destination ptr in A/X
	; Number of bytes in Y
	IFCONST I_BINREAD_IMPORTED
I_BINREAD SUBROUTINE
	sta R0
	stx R0 + 1
.loop
	dey
	bmi .q
	kerncall KERNAL_CHRIN
	sta (R0),y
	jmp .loop
.q
	rts
	ENDIF
	
	; Output single character to opened file
	; {1} - char
	MAC chrout
	lda #{1}
	kerncall KERNAL_CHROUT
	ENDM
	
	; PRINT# (string)
	; string on string stack
	MAC print_hash
	import I_STRWRITE
	jsr I_STRWRITE
	ENDM
	
	; Load routine
	; load 1: load at address stored in file
	; load 0: load at a specified address 
	MAC load
	IF USEIRQ == 1
	jsr IRQRESET
	ENDIF
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
	IF USEIRQ == 1
	jsr IRQSETUP
	ENDIF
	ENDM
	
	; Save routine
	MAC save
	; get start address
	IF USEIRQ == 1
	jsr IRQRESET
	ENDIF
	pla
	sta R0 + 1
	pla
	sta R0
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
	IF USEIRQ == 1
	jsr IRQSETUP
	ENDIF
	ENDM
	
	; Read string from file
	; logical file no in A
	IFCONST I_STRREAD_IMPORTED
I_STRREAD SUBROUTINE
	ldx #0
	stx R0 ; Quote off
.loop
	kerncall KERNAL_CHRIN
	pha
	kerncall KERNAL_READST
	beq .ok
	pla
	jmp .over
.ok
	pla
	; Is it <EOL> ?
	cmp #$0d
	beq .over
	; Is it '"' ?
	cmp #$22
	bne .1
	lda R0
	eor #$ff
	sta R0
	jmp .loop
.1
	; Is it ',' and quote off ?
	cmp #$2c
	bne .2
	ldy R0
	beq .over
.2
	sta [STRING_BUFFER1 + 1],x
	inx
	cpx #95
	bne .loop
.over	
	stx STRING_BUFFER1
	pstringvar STRING_BUFFER1
	rts
	ENDIF
	
	; Write string to file
	; Logical file no in X
	; String on string stack
	IFCONST I_STRWRITE_IMPORTED
I_STRWRITE SUBROUTINE
	ldx SP
	inx
	lda STRING_WORKAREA,x
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
	kerncall KERNAL_CHROUT
	rts
	ENDIF
	
	; Read disk status
	; Partly taken from
	; https://codebase64.org/doku.php?id=base:reading_the_error_channel_of_a_disk_drive
	IFCONST I_IO_READST_IMPORTED
IO_READST SUBROUTINE
	lda #0      ; no filename
	tax
	tay
	sta R0		; will hold status code
	kerncall KERNAL_SETNAM
	lda #15      ; file number 15
    ldx $BA      ; last used device number
   	bne .skip
    ldx #8       ; default to device 8
.skip
	ldy #15      ; secondary address 15 (error channel)
    kerncall KERNAL_SETLFS
    kerncall KERNAL_OPEN
    bcs .error
    ldx #15      ; filenumber 15
    kerncall KERNAL_CHKIN
	kerncall KERNAL_CHRIN ; first decimal byte in A
	sec
	sbc #$30
	asl         ; multiply by 10
    sta R0
	asl
	asl
	clc
	adc R0
	sta R0
	kerncall KERNAL_CHRIN ; second decimal byte in A
	sec
	sbc #$30
	clc
	adc R0
	sta R0
	lda #15      ; filenumber 15
	kerncall KERNAL_CLOSE ; call CLOSE
    kerncall KERNAL_CLRCHN
    lda R0
    rts
.error
	import I_RUNTIME_ERROR
	jmp RUNTIME_ERROR
	ENDIF
