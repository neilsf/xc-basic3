	PROCESSOR 6502
	
	IF TARGET == c64 || TARGET == c128
	INCLUDE "sfx/_sid.asm"
	ENDIF
	
	IF TARGET & vic20
	INCLUDE "sfx/_vic.asm"
	ENDIF
	
	IF TARGET & c264
	INCLUDE "sfx/_ted.asm"
	ENDIF
	
	