	PROCESSOR 6502
	
	; Add top 2 floats on stack
	MAC addfloat
	plfloattofac
	plfloattoarg
	import I_FPLIB
	jsr FADDT
	pfac
	ENDM
	
	; Subtract top 2 floats on stack
	MAC subfloat
	plfloattofac
	plfloattoarg
	import I_FPLIB
	jsr FSUBT
	pfac
	ENDM
	
	; Multiply top 2 floats on stack
	MAC mulfloat
	plfloattofac
	plfloattoarg
	import I_FPLIB
	jsr FMULTT
	pfac
	ENDM
	
	; Divide top 2 floats on stack
	MAC divfloat
	plfloattofac
	plfloattoarg
	import I_FPLIB
	jsr FDIVT
	pfac
	ENDM
	
	; Modulo of top 2 floats on stack
	MAC modfloat
	plfloattofac
	plfloattoarg
	import I_FMOD
	jsr I_FMOD
	pfac
	ENDM
	
	; Negate float on stack
	MAC negfloat
	tsx
	lda stack + 2,x
	eor #%10000000
	sta stack + 2,x
	ENDM
	
	; Discard top float on stack
	MAC discardfloat
	tsx
	inx
	inx
	inx
	inx
	txs
	ENDM
	
	IFCONST I_FMOD_IMPORTED
I_FMOD SUBROUTINE
	ldx #<.tmp
	ldy #>.tmp
	import I_FPLIB
	jsr STORE_FAC_AT_YX_ROUNDED
	jsr FDIVT
	jsr COPY_FAC_TO_ARG_ROUNDED
	import I_INT
	jsr INT
	jsr FSUBT
	lda #<.tmp
	ldy #>.tmp
	jmp FMULT
.tmp HEX 00 00 00 00
	ENDIF