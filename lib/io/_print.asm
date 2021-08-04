KERNAL_PRINTCHR	EQU $e716
KERNAL_PLOT		EQU $e50a

	; Print byte on stack as PETSCII string
	MAC printbyte
	import I_STDLIB_PRINT_BYTE
	IF !FPULL
	pla
	ENDIF
	jsr STDLIB_PRINT_BYTE
	ENDM
	
	; Print int on stack as PETSCII string
	MAC printint
	import I_STDLIB_PRINT_INT
	IF !FPULL
	pla
	sta R2 + 1
	pla
	sta R2
	ELSE
	sta R2
	sty R2 + 1
	ENDIF
	jsr STDLIB_PRINT_INT
	ENDM
	
	; Print word on stack as PETSCII string
	MAC printword
	import I_STDLIB_PRINT_WORD 
	IF !FPULL
	pla
	sta R2 + 1
	pla
	sta R2
	ELSE
	sta R2
	sty R2 + 1
	ENDIF
	jsr STDLIB_PRINT_WORD
	ENDM
	
	; Print word on stack as PETSCII string
	MAC printdecimal
	import I_STDLIB_PRINT_DECIMAL 
	IF !FPULL
	pla
	sta R2 + 1
	pla
	sta R2
	ELSE
	sta R2
	sty R2 + 1
	ENDIF
	jsr STDLIB_PRINT_DECIMAL
	ENDM
	
	; Print string in memory (pointer on stack)
	MAC printstaticstring
	IF !FPULL
	pla
	tay
	pla
	ENDIF
	import I_STDLIB_PRINTSTR
	jsr STDLIB_PRINTSTR
	ENDM
	
	; Print string on string stack and pull it off
	MAC printstring
	ldx SP
	inx
	txa
	ldy #>STRING_WORKAREA
	import I_STDLIB_PRINTSTR
	jsr STDLIB_PRINTSTR
	; Move stack pointer
	tya	
	clc	
	adc SP	
	sta SP
	ENDM
	
	; Print int on stack as PETSCII string
	MAC printlong
	import I_STDLIB_PRINT_LONG
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
	jsr STDLIB_PRINT_LONG
	ENDM
	
	MAC printfloat
	import I_FPLIB
	import I_STDLIB_PRINTSTR
	plfloattofac
	jsr FOUT
	jsr STDLIB_PRINTSTR
	ENDM 
	
	; Print tab character
	MAC printtab
	import I_STDLIB_TAB
	jsr STDLIB_TAB
	ENDM
	
	; Print a newline character
	MAC printnl
	lda #13
	jsr KERNAL_PRINTCHR
	ENDM

; Move cursor to next tab
	IFCONST I_STDLIB_TAB_IMPORTED
STDLIB_TAB SUBROUTINE
	sec
	jsr KERNAL_PLOT
	tya
	ldy #$ff
.1
	iny
	cmp.wy .tabs
	bcs .1
	cpy #3
	bne .2
	iny
	inx
.2	lda.wy .tabs
	tay
	clc
	jsr KERNAL_PLOT
	rts

.tabs HEX 0A 14 1E 28 00
	ENDIF

; print null-terminated petscii string
; Pointer to string in AY
; At the end Y holds chars printed + 1
	IFCONST I_STDLIB_PRINTSTR_IMPORTED
STDLIB_PRINTSTR SUBROUTINE                  
	sta R0 	        ; store string start low byte
    sty R0 + 1      ; store string start high byte
    ldy #0
    lda (R0),y		; string length
    beq .2
    sta R2
    iny
.1:
    lda (R0),y      ; get byte from string 
    jsr KERNAL_PRINTCHR
    iny
    cpy R2
    bcc .1
    beq .1
.2:
	rts
	ENDIF
	
; convert byte to decimal petscii in YXA
	IFCONST I_STDLIB_BYTE_TO_PETSCII_IMPORTED
STDLIB_BYTE_TO_PETSCII SUBROUTINE
	ldy #$2f
  	ldx #$3a
  	sec
.1: iny
  	sbc #100
  	bcs .1
.2: dex
  	adc #10
  	bmi .2
  	adc #$2f
  	rts
  	ENDIF
  	
; print byte type as decimal
	IFCONST I_STDLIB_PRINT_BYTE_IMPORTED
	import I_STDLIB_BYTE_TO_PETSCII
STDLIB_PRINT_BYTE SUBROUTINE
	ldy #$00
	sty R0 ; has a digit been printed?
	jsr STDLIB_BYTE_TO_PETSCII
	pha
	tya
	cmp #$30
	beq .skip                                      
	jsr KERNAL_PRINTCHR
	inc R0
.skip
	txa
	cmp #$30
	bne .printit
	ldy R0
	beq .skip2
.printit	
	jsr KERNAL_PRINTCHR
.skip2
	pla
	jsr KERNAL_PRINTCHR
	rts
	ENDIF
	
; print int as petscii decimal
; expects number in R2
	IFCONST I_STDLIB_PRINT_INT_IMPORTED
	import I_STDLIB_PRINT_WORD
STDLIB_PRINT_INT SUBROUTINE
	lda R2 + 1
	bpl .1
	lda #$2d ; - sign
	jsr KERNAL_PRINTCHR
	twoscplint R2
.1
	jsr STDLIB_PRINT_WORD
	rts
	ENDIF
	
	IFCONST I_STDLIB_PRINT_DECIMAL_IMPORTED
STDLIB_PRINT_DECIMAL SUBROUTINE
	ldx #1
.1
	lda R2,x
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$30
	jsr KERNAL_PRINTCHR
	lda R2,x
	and #%00001111
	adc #$30
	jsr KERNAL_PRINTCHR
	dex
	bpl .1
	rts
	ENDIF
	
; print word as petscii decimal
; expects number in R2
	IFCONST I_STDLIB_PRINT_WORD_IMPORTED
STDLIB_PRINT_WORD SUBROUTINE
	ldx #0
	stx R0 ; if any digit has been printed
.do
	ldy #0
	; Check if number < 10^n
.do2
	lda R2 + 1
    cmp.wx stdlib_pten_16 + 1
    bne .1
    lda R2
    cmp.wx stdlib_pten_16
.1        
	bcc .next 
.sub	
	; Count how many times 10^n can be subtracted
	lda R2
	sec
	sbc.wx stdlib_pten_16
	sta R2
	lda R2 + 1
	sbc.wx stdlib_pten_16 + 1
	sta R2 + 1
	iny
	bne .do2
.next
	; Y now holds a decimal digit
	tya
	ora R0
	beq .2
	tya
	clc
	adc #$30
	jsr KERNAL_PRINTCHR
	inc R0
.2
	inx
	inx
	inx
	cpx #12
	bne .do
	; Print last digit
	lda R2
	clc
	adc #$30
	jsr KERNAL_PRINTCHR
	rts
	ENDIF

; Powers of ten on 24 bits	
	IFCONST I_STDLIB_PRINT_WORD_IMPORTED || I_STDLIB_PRINT_LONG_IMPORTED	
stdlib_pten_24
	HEX 40 42 0F	;   1000000
	HEX A0 86 01	;    100000
stdlib_pten_16
	HEX 10 27 00	;     10000
	HEX E8 03 00	;      1000
	HEX 64 00 00	;       100
	HEX 0A 00 00	;        10
	ENDIF
	
	IFCONST I_STDLIB_PRINT_LONG_IMPORTED
STDLIB_PRINT_LONG SUBROUTINE
	lda R4 + 2
	bpl .pos
	lda #$2d ; - sign
	jsr KERNAL_PRINTCHR
	twoscpllong R4
.pos
	ldx #0
	stx R0 ; if any digit has been printed
.do
	ldy #0
	; Check if number < 10^n
.do2
	lda R4 ; NUM1-NUM2
	cmp.wx stdlib_pten_24
 	lda R4 + 1
  	sbc.wx stdlib_pten_24 + 1
 	lda R4 + 2
  	sbc.wx stdlib_pten_24 + 2
  	bcc .next
.sub	
	; Count how many times 10^n can be subtracted
	lda R4
	sec
	sbc.wx stdlib_pten_24
	sta R4
	lda R4 + 1
	sbc.wx stdlib_pten_24 + 1
	sta R4 + 1
	lda R4 + 2
	sbc.wx stdlib_pten_24 + 2
	sta R4 + 2
	iny
	bne .do2
.next
	; Y now holds a decimal digit
	tya
	ora R0
	beq .2
	tya
	clc
	adc #$30
	jsr KERNAL_PRINTCHR
	inc R0
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
	jsr KERNAL_PRINTCHR
	rts
	ENDIF
