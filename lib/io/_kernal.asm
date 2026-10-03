KERNAL_CHROUT EQU $FFD2
	IF (TARGET & pet) == 0
KERNAL_PLOT	  EQU $FFF0
	ENDIF
KERNAL_SETNAM EQU $FFBD
KERNAL_SETLFS EQU $FFBA
KERNAL_OPEN   EQU $FFC0
KERNAL_READST EQU $FFB7
KERNAL_CLOSE  EQU $FFC3
KERNAL_GETIN  EQU $FFE4
KERNAL_CHRIN  EQU $FFCF
KERNAL_CHKIN  EQU $FFC6
KERNAL_CHKOUT EQU $FFC9
KERNAL_CLRCHN EQU $FFCC
KERNAL_LOAD	  EQU $FFD5
KERNAL_SAVE   EQU $FFD8
KERNAL_SCREENMODE EQU $FF5F ; Commander X16 only
X16_screen_set_charset EQU $FF62 ; Commander X16 only

STATUS EQU $90 ; KERNAL I/O STATUS

	; Calls a KERNAL routine
	; Routine address in {1}
	MAC kerncall
		IF TARGET & pet
			import I_{1}
		ENDIF
	jsr {1}
	ENDM

	; Re-implementation of certain KERNAL routines for PET systems
	IF TARGET & pet	
		
		IF TARGET == pet2001
SCR_LN_PTR  EQU $E0
CRS_COL		EQU $E2
CRS_ROW		EQU $F5
		ELSE
SCR_LN_PTR  EQU $C4
CRS_COL		EQU $C6
CRS_ROW		EQU $D8
SCR_LIN_ADDR_LO  EQU $E755
SCR_LIN_ADDR_HI  EQU $E76E
		ENDIF

		; PLOT. Save or restore cursor position.
		; Input:  Carry: 0 = Restore from input, 1 = Save to output
		;		  Y = Cursor column (if Carry = 0)
		;		  X = Cursor row (if Carry = 0)
		; Output: Y = Cursor column (if Carry = 1); X = Cursor row (if Carry = 1).
		IFCONST I_KERNAL_PLOT_IMPORTED
KERNAL_PLOT	  SUBROUTINE
		bcs .read
		sty CRS_COL
		stx CRS_ROW
		txa
		import I_CALC_SCRROWPTR
		jsr CALC_SCRROWPTR
		lda R0
		sta SCR_LN_PTR
		lda R0 + 1
		sta SCR_LN_PTR + 1
		rts
.read
		ldy CRS_COL
		ldx CRS_ROW
		rts
		ENDIF
	ENDIF