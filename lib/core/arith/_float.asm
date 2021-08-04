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