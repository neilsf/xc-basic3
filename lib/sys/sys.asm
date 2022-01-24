	; XC=BASIC system functions
SAREG EQU $030C
SXREG EQU $030D 
SYREG EQU $030E 
SPREG EQU $030F

	; Initial code that runs when the program is started
	MAC xbegin
	spreset
	framereset
	IF TARGET == c64
	; Bank out BASIC ROM
	lda $01
	and #%11111110
	sta $01
	ENDIF
	ENDM
	
	; Final code that runs when the program is terminated
	MAC xend
	IF TARGET == c64
	; Bank in BASIC ROM
	lda $01
	ora #%00000001         
	sta $01
	ENDIF
	; Do BASIC cold start
	IF TARGET & vic20
	jmp ($C002)
	ENDIF
	IF TARGET == cplus4 || TARGET == c16
	jmp $8003
	ENDIF
	IF TARGET == c64
	jmp ($A002)
	ENDIF
	ENDM
	
	; DECLARE FUNCTION TI AS LONG () SHARED STATIC INLINE
	MAC F_ti ; @push
	sei
	lda $a2
	IF !FPUSH
	pha
	lda $a1
	pha
	lda $a0
	pha
	ELSE
	ldy $a1
	ldx $a0
	ENDIF
	cli
	ENDM
	
	; SYS Command
	; Use SYS 1 for fast call, SYS 0 for regular call
	MAC sys ; @pull
	IF !FPULL
	pla
	sta .jsr + 2
	pla
	sta .jsr + 1
	ELSE
	sta .jsr + 1
	sty .jsr + 2
	ENDIF
	IF {1} == 0
	lda SPREG
	pha
	lda SAREG
	ldx SXREG
	ldy SYREG
	plp
	ENDIF
.jsr	
	jsr $FFFF
	IF {1} == 0
	php
	sta SAREG
	stx SXREG
	sty SYREG
	pla
	sta SPREG
	ENDIF
	ENDM
	
	; SYS Command with constant address
	; Use SYS <addr>, 1 for fast call, SYS <addr>, 0 for regular call
	MAC sys_constaddr
	IF {2} == 0
	lda SPREG
	pha
	lda SAREG
	ldx SXREG
	ldy SYREG
	plp
	ENDIF
.jsr	
	jsr {1}
	IF {2} == 0
	php
	sta SAREG
	stx SXREG
	sty SYREG
	pla
	sta SPREG
	ENDIF
	ENDM
	
	MAC wait ; @pull
.MASK EQU R2
.TRIG EQU R3
	IF !FPULL
	pla
	sta .loop + 2
	pla
	sta .loop + 1
	ELSE
	sta .loop + 1
	sty .loop + 2
	ENDIF
	pla
	sta .MASK
	pla
	sta .TRIG
.loop
	lda.w $0000
	eor .TRIG
	and .MASK
	beq .loop
	ENDM