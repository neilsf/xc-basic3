	IF TARGET == c64 || TARGET == c128 || TARGET == mega65
	INCLUDE "grx/_vic.asm"
	ENDIF

	IF TARGET == x16
	INCLUDE "grx/_vera.asm"
	ENDIF