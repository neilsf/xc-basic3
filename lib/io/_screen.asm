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
	F_str@_int
	printstring
	ENDM
	
	; Print word on stack as PETSCII string
	MAC printword
	F_str@_word
	printstring
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
	F_str@_long
	printstring
	ENDM
	
	MAC printfloat
	import I_FPLIB
	import I_FOUT
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
	kerncall KERNAL_CHROUT
	ENDM

; Move cursor to next tab
	IFCONST I_STDLIB_TAB_IMPORTED
STDLIB_TAB SUBROUTINE
	sec
	kerncall KERNAL_PLOT
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
	kerncall KERNAL_PLOT
	rts

.tabs HEX 0A 14 1E 28 00
	ENDIF

; print petscii string
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
    kerncall KERNAL_CHROUT
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
	kerncall KERNAL_CHROUT
	inc R0
.skip
	txa
	cmp #$30
	bne .printit
	ldy R0
	beq .skip2
.printit	
	kerncall KERNAL_CHROUT
.skip2
	pla
	kerncall KERNAL_CHROUT
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
	kerncall KERNAL_CHROUT
	lda R2,x
	and #%00001111
	adc #$30
	kerncall KERNAL_CHROUT
	dex
	bpl .1
	rts
	ENDIF
	
	MAC locate
	IF !FPULL
	pla
	ENDIF
	tax
	pla
	tay
	clc
	kerncall KERNAL_PLOT
	ENDM
	
	; DECLARE FUNCTION CSRLIN AS BYTE () SHARED STATIC INLINE
	MAC F_csrlin
	sec
	kerncall KERNAL_PLOT
	txa
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	;DECLARE FUNCTION POS AS BYTE () SHARED STATIC INLINE
	MAC F_pos
	sec
	kerncall KERNAL_PLOT
	tya
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC charat
	nop
	ENDM
	
	MAC textat
	nop
	ENDM
	
	IFCONST I_SCRPOINTERS_IMPORTED
I_SCRPOINTERS
COL EQU $0400
	REPEAT SCREEN_ROWS
	DC.B <COL, >COL
COL SET COL + 40
	REPEND
	ENDIF