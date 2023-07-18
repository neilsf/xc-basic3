; ------------------------------------------
; XC=BASIC
; Pseudo-registers
;
; ZP locations reserved
; ------------------------------------------
; Arithmetic registers
R0	EQU $02
R1	EQU $03
R2	EQU $04
R3	EQU $05
R4	EQU $06
R5	EQU $07
R6	EQU $08
R7	EQU $09
R8	EQU $0A
R9	EQU $0B
RA	EQU $0C
RB	EQU $0D
; Pointer to current string in work area
SP	EQU $0E
; Pointer to current stack frame
RC  EQU $0F
RD  EQU $10
; Tmp Pointer to next stack frame
RE	EQU $11
RF	EQU $12
; Pointer to "this"
TH  EQU $13
; Current sprite number
SN  EQU $15

	; Push pseudo-registers onto stack
	MAC phsr
	IF !FASTIRQ
	ldx #SP
.l
	lda $00,x
	pha
	dex
	cpx #[R0 - 1]
	bne .l
	ENDIF
	ENDM
	
	; Pull pseudo-registers off of stack
	MAC plsr
	IF !FASTIRQ
	ldx #R0
.l
	pla
	sta $00,x
	inx
	cpx #[SP + 1]
	bne .l
	ENDIF
	ENDM

