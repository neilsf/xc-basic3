	; Routines specific to the VERA chip
	; ==================================

VERA_CTRL EQU $9F25
VERA_ADDR EQU $9F20
VERA_DATA0 EQU $9F23
VERA_VRAM EQU $B000

	; Set address registers
	; Character coordinates in X, Y
	; Carry set   = color position
	; Carry clear = char position
	; Alo sets increment value to 2
	IFCONST I_VERA_SETADDR_IMPORTED
VERA_SETADDR SUBROUTINE
	txa
	asl
	sta VERA_ADDR
	tya
	adc #>VERA_VRAM
	sta VERA_ADDR + 1
	lda #%00010001
	sta VERA_ADDR + 2
	rts	
	ENDIF
	
	; Moves PETSCII string from string buffer
	; to the screen (addres previously
	; set using VERA_SETADDR)
	; String length remains in R0
	IFCONST I_VERA_MOV_STRING_IMPORTED
VERA_MOV_STRING
	ldx SP
	inx
	lda STRING_WORKAREA,x ; string length
	beq .q
	sta R0
	ldy #0
.loop
	inx
	lda STRING_WORKAREA,x
	import I_PET2SC
	jsr PET2SC
	sta VERA_DATA0	
	iny
	cpy R0
	bne .loop
.end
	stx SP
.q
	rts
	ENDIF