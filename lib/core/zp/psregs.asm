; ------------------------------------------
; XC=BASIC
; Pseudo-registers
;
; ZP locations reserved
; ------------------------------------------
IF TARGET == x16
  R0 EQU $22
ELSE
  R0 EQU $02
ENDIF

; Arithmetic registers
R1	EQU R0 + 1
R2	EQU R0 + 2
R3	EQU R0 + 3
R4	EQU R0 + 4
R5	EQU R0 + 5
R6	EQU R0 + 6
R7	EQU R0 + 7
R8	EQU R0 + 8
R9	EQU R0 + 9
RA	EQU R0 + 10
RB	EQU R0 + 11
; Pointer to current string in work area
SP	EQU R0 + 12
; Pointer to current stack frame
RC  EQU R0 + 13
RD  EQU R0 + 14
; Tmp Pointer to next stack frame
RE	EQU R0 + 15
RF	EQU R0 + 16
; Pointer to "this"
TH  EQU R0 + 17
; Current sprite number
SN  EQU R0 + 18

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

