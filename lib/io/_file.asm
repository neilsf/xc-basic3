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
	
	; INPUT# (fixed size values)
	; Logical file# on stack
	; Number of bytes in {1}
	; Output on stack
	MAC input_hash ; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	kerncall KERNAL_CHKIN
	ldx #{1}
.loop
	kerncall KERNAL_CHRIN
	pha
	kerncall KERNAL_READST
	bne .over
	dex
	bne .loop
	kerncall KERNAL_CLRCHN
    rts
	ENDM
	
	; INPUT# (strings)
	; Logical file# on stack
	; Output on string stack
	MAC input_hash_str; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	kerncall KERNAL_CHKIN
	kerncall KERNAL_CHRIN
	sta R0 ; length
	lda SP
	sec
	sbc R0
	; a holds start
	sta R2
	inc R2
	sta SP
	dec SP
	lda #>STRING_WORKAREA
	sta R2 + 1
	; (R2) holds pointer
	ldy #0
.loop
	sty R4 ; tmp save
	kerncall KERNAL_CHRIN
	ldy R4
	sta (R2),y
	kerncall KERNAL_READST
	bne .over
	iny
	cpy R0
	bne .loop
.over
	kerncall KERNAL_CLRCHN
    rts
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
	; target address in {1}
	; byte length in {2}
	MAC read
	lda #<{1}
	ldx #>{1}
	ldy #{2}
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
	
	; PRINT# (string)
	; logical file# on stack
	; string on string stack
	; {1} = 1 : this is the last string in block
	MAC print_hash_str; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	kerncall KERNAL_CHKIN
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
	MAC save; @pull
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