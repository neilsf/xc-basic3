	PROCESSOR 6502
	
	IF TARGET == c64
	INCLUDE "sfx/_sid.asm"
	ENDIF
	
	IF TARGET & vic20
	INCLUDE "sfx/_vic.asm"
	ENDIF
	
	