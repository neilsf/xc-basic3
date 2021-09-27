	; String functions
	
	; DECLARE FUNCTION LEN AS BYTE (instr$ AS STRING) SHARED STATIC INLINE
	MAC F_len_string
	ldx SP
	inx
	lda STRING_WORKAREA,x
	pha
	clc
	adc SP
	adc #1
	sta SP
	ENDM
	
	; DECLARE FUNCTION RIGHT$ AS STRING (instr$ AS STRING, length AS BYTE) SHARED STATIC INLINE
	MAC F_right@_string_byte
	IF !FPULL
	pla
	ENDIF
	import I_STR_RIGHT
	jsr STR_RIGHT
	ENDM
	
	; RIGHT$ function
	; A - length
	IFCONST I_STR_RIGHT_IMPORTED
STR_RIGHT SUBROUTINE
	ldx SP
	inx
	cmp STRING_WORKAREA,x
	bcs .exit ; length >= string length, leave string as it is
	; X = X + len - A
	sta R0
	txa
	clc
	adc STRING_WORKAREA,x
	sbc R0
 	tax
 	lda R0
 	sta STRING_WORKAREA,x
 	dex
 	sta SP
.exit
	rts
	ENDIF
	
	; DECLARE FUNCTION LEFT$ AS STRING (instr$ AS STRING, length AS BYTE) SHARED STATIC INLINE
	MAC F_left@_string_byte
	IF !FPULL
	pla
	ENDIF
	import I_STR_LEFT
	jsr STR_LEFT
	ENDM
	
	; LEFT$ function
	; A - length
	IFCONST I_STR_LEFT_IMPORTED
STR_LEFT SUBROUTINE
	ldx SP
	inx
	cmp STRING_WORKAREA,x
	bcs .end ; length >= str length, leave string as it is
 	; A = Number of bytes to write
 	sta STRING_WORKAREA,x
 	tay
 	stx .1 + 1
 	; A = X + A + 1
 	inx
 	stx R0
 	clc
 	adc R0 
 	sta .2 + 1
 	sta SP
.loop
.1	lda STRING_WORKAREA,y
.2	sta STRING_WORKAREA,y
 	dey
 	bpl .loop
	; write new pointer
 	dec SP
.end
	rts
	ENDIF
	
	; DECLARE FUNCTION MID$ AS STRING (instr$ AS STRING, pos AS BYTE, length AS BYTE) SHARED STATIC INLINE
	MAC F_mid@_string_byte_byte
	IF !FPULL
	pla
	tay
	pla
	ENDIF
	import I_STR_MID
	jsr STR_MID
	ENDM
	
	; MID$ function
	; Y - length
	; A - pos
	; uses the equivalence MID$(x$,p,n)=LEFT$(RIGTH$(x$,LEN(x$)-p),n)
	IFCONST I_STR_MID_IMPORTED
	import I_STR_LEFT
	import I_STR_RIGHT
STR_MID SUBROUTINE
	sta R0
	; LEN(x$)
	ldx SP
	inx
	lda STRING_WORKAREA,x
	sec
	sbc R0
	bpl .ok
	; P >= LEN(x$), return empty string
	; TODO
	rts
.ok
	sty R1
	jsr STR_RIGHT
	lda R1
	jsr STR_LEFT
	rts
	ENDIF
	
	; DECLARE FUNCTION CHR$ AS STRING (charcode AS BYTE) SHARED STATIC INLINE
	MAC F_chr@_byte
	IF !FPUSH
	pla
	ENDIF
	ldx SP
	sta STRING_WORKAREA,x
	dex
	lda #1
	sta STRING_WORKAREA,x
	dec SP
	dec SP
	ENDM
	
	; DECLARE FUNCTION ASC AS BYTE (char$ AS STRING) SHARED STATIC INLINE
	MAC F_asc_string
	ldx SP
	inx
	lda STRING_WORKAREA,x
	tay ; length
	bne .nonzero
	pha ; zero
	beq .q
.nonzero
	inx
	lda STRING_WORKAREA,x
	pha ; first char
	tya
	clc
	adc SP
	sta SP
.q
	ENDM
	
	; DECLARE FUNCTION LCASE$ AS STRING (instr$ AS STRING) SHARED STATIC INLINE
	MAC F_lcase@_string
	import I_STR_LCASE
	jsr STR_LCASE
	ENDM
	
	IFCONST I_STR_LCASE_IMPORTED
STR_LCASE SUBROUTINE
	ldx SP
	inx
	stx .selfmod1 + 1
	stx .selfmod2 + 1
	lda STRING_WORKAREA,x
	beq .exit
	tay
.loop
.selfmod1
	lda STRING_WORKAREA,y ; <- address self-modified
	cmp #$C1
	bcc .next
	cmp #$DB	
	bcs .next	
	and #%01111111
.selfmod2
	sta STRING_WORKAREA,y ; <- address self-modified
.next
	dey
	bne .loop
.exit
	rts
	ENDIF
	
	; DECLARE FUNCTION UCASE$ AS STRING (instr$ AS STRING) SHARED STATIC INLINE
	MAC F_ucase@_string
	import I_STR_UCASE
	jsr STR_UCASE
	ENDM
	
	IFCONST I_STR_UCASE_IMPORTED
STR_UCASE SUBROUTINE
	ldx SP
	inx
	stx .selfmod1 + 1
	stx .selfmod2 + 1
	lda STRING_WORKAREA,x
	beq .exit
	tay
.loop
.selfmod1
	lda STRING_WORKAREA,y ; <- address self-modified
	cmp #$41
	bcc .next
	cmp #$5B	
	bcs .next	
	ora #%10000000
.selfmod2
	sta STRING_WORKAREA,y ; <- address self-modified
.next
	dey
	bne .loop
.exit
	rts
	ENDIF
	
	; DECLARE FUNCTION VAL AS FLOAT (instr$ AS string) SHARED STATIC INLINE
	MAC F_val_string
	ldx SP
	inx
	stx R0
	lda #>STRING_WORKAREA
	sta R0 + 1
	lda STRING_WORKAREA,x
	sta RA
	import I_FPLIB
	import I_FIN
	jsr FIN
	pfac
	ENDM
	
	; DECLARE FUNCTION STR$ AS STRING (number AS BYTE) SHARED STATIC INLINE
	MAC F_str@_byte
	IF !FPULL
	pla
	ENDIF
	import I_STR_BTOS
	jsr STR_BTOS
	ENDM
	
	IFCONST I_STR_BTOS_IMPORTED
STR_BTOS SUBROUTINE
	ldx #0
	stx R0  ; string length
	import I_STDLIB_BYTE_TO_PETSCII
	jsr STDLIB_BYTE_TO_PETSCII
	stx R1
	ldx SP
	sta STRING_WORKAREA,x
	dex
	inc R0
	cpy #$30 ; '0'
	beq .1
	dex
	tya
	sta STRING_WORKAREA,x
	inc R0
	inx
	bne .2 ; bra
.1	lda R1
	cmp #$30 ; '0'
	beq .3
.2	lda R1
	sta STRING_WORKAREA,x
	inc R0
	lda R0
	cmp #3
	bne .3
	dex
.3	lda R0
	cmp #1
	beq .4
	dex
.4	
	sta STRING_WORKAREA,x
	dex
	stx SP
	rts
	ENDIF
	
	; DECLARE FUNCTION STR$ AS STRING (number AS DECIMAL) OVERRIDE SHARED STATIC INLINE
	MAC F_str@_decimal
	IF !FPULL
	pla
	sta R0
	pla
	sta R0 + 1
	ELSE
	sta R0 + 1
	sty R0
	ENDIF
	import I_STR_DTOS
	jsr STR_DTOS
	ENDM
	
	IFCONST I_STR_DTOS_IMPORTED
STR_DTOS:
	ldx SP
	ldy #1
.loop
	lda R0,y
	and #%00001111
	clc
	adc #$30
	sta STRING_WORKAREA,x
	dex
	lda R0,y
	lsr
	lsr
	lsr
	lsr
	adc #$30
	sta STRING_WORKAREA,x
	dex
	dey
	bpl .loop
.over
	lda #4
	sta STRING_WORKAREA,x
	dex
	stx SP
	rts
	ENDIF
	
	; DECLARE FUNCTION STR$ AS STRING (number AS WORD) OVERRIDE SHARED STATIC INLINE
	MAC F_str@_word
	IF !FPULL
	pla
	sta R2 + 1
	pla
	sta R2
	ELSE
	sta R2
	sty R2 + 1
	ENDIF
	import I_STR_WTOS
	ldx #0
	jsr STR_WTOS
	ENDM
	
	; DECLARE FUNCTION STR$ AS STRING (number AS INT) OVERRIDE SHARED STATIC INLINE
	MAC F_str@_int
	IF !FPULL
	pla
	sta R2 + 1
	pla
	sta R2
	ELSE
	sta R2
	sty R2 + 1
	ENDIF
	import I_STR_WTOS
	ldx #0
	lda R2 + 1
	bpl .pos
	twoscplint R2
	inx
.pos
	jsr STR_WTOS
	ENDM
	
	; Convert word to string
	; expects:
	; number in R2
	; X=1 if negative (but number already two's complemented)
	; X=0 otherwise
	IFCONST I_STR_WTOS_IMPORTED
STR_WTOS SUBROUTINE
	stx R0 ; Total number of chars
	txa
	beq .pos
	lda #$2d ; - sign
	pha
.pos
	ldx #00
	stx RA ; Number of digits
.do
	ldy #0
	; Check if number < 10^n
.do2
	lda R2 + 1
    cmp.wx str_pten_16 + 1
    bne .1
    lda R2
    cmp.wx str_pten_16
.1        
	bcc .next 
.sub	
	; Count how many times 10^n can be subtracted
	lda R2
	sec
	sbc.wx str_pten_16
	sta R2
	lda R2 + 1
	sbc.wx str_pten_16 + 1
	sta R2 + 1
	iny
	bne .do2
.next
	; Y now holds a decimal digit
	tya
	ora RA
	beq .2
	tya
	clc
	adc #$30
	pha
	inc R0
	inc RA
.2
	inx
	inx
	inx
	cpx #12
	bne .do
	lda R2
	clc
	adc #$30
	pha
	inc R0
	jmp STR_MOVE_REVSTR
	ENDIF
	
	; DECLARE FUNCTION STR$ AS STRING (number AS LONG) OVERRIDE SHARED STATIC INLINE
	MAC F_str@_long
	IF !FPULL
	pla
	sta R4 + 2
	pla
	sta R4 + 1
	pla
	sta R4
	ELSE
	sta R4
	sty R4 + 1
	stx R4 + 2
	ENDIF
	import I_STR_LTOS
	jsr STR_LTOS
	ENDM
	
	; Convert long to string
	; Number in R4
	IFCONST I_STR_LTOS_IMPORTED
STR_LTOS SUBROUTINE
	ldx #0
	stx R0 ; Total number of chars
	stx RA ; Number of digits
	lda R4 + 2
	bpl .do
	lda #$2d ; - sign
	pha
	inc R0
	twoscpllong R4
.do
	ldy #0
	; Check if number < 10^n
.do2
	lda R4 ; NUM1-NUM2
	cmp.wx str_pten_24
 	lda R4 + 1
  	sbc.wx str_pten_24 + 1
 	lda R4 + 2
  	sbc.wx str_pten_24 + 2
  	bcc .next
.sub	
	; Count how many times 10^n can be subtracted
	lda R4
	sec
	sbc.wx str_pten_24
	sta R4
	lda R4 + 1
	sbc.wx str_pten_24 + 1
	sta R4 + 1
	lda R4 + 2
	sbc.wx str_pten_24 + 2
	sta R4 + 2
	iny
	bne .do2
.next
	; Y now holds a decimal digit
	tya
	ora RA
	beq .2
	tya
	clc
	adc #$30
	pha
	inc R0
	inc RA
.2
	inx
	inx
	inx
	cpx #18
	bne .do
	; Print last digit
	lda R4
	clc
	adc #$30
	pha
	inc R0
	jmp STR_MOVE_REVSTR
	ENDIF

	; Powers of ten on 24 bits	
	IFCONST I_STR_WTOS_IMPORTED || I_STR_LTOS_IMPORTED	
str_pten_24
	HEX 40 42 0F	;   1000000
	HEX A0 86 01	;    100000
str_pten_16
	HEX 10 27 00	;     10000
	HEX E8 03 00	;      1000
	HEX 64 00 00	;       100
	HEX 0A 00 00	;        10
	
STR_MOVE_REVSTR SUBROUTINE
	; Move reversed string on stack to string workarea 
	; Total number of chars in R0
	lda R0
	sta R2 ; R2 reused to save no of chars
	ldx SP
	dec R0
.loop
	pla
	sta STRING_WORKAREA,x
	dex
	dec R0
	bpl .loop
	lda R2
	sta STRING_WORKAREA,x
	dex
	stx SP
	rts
	ENDIF