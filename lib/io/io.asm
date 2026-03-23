	INCLUDE "io/_kernal.asm"
	IF TARGET == x16
	  INCLUDE "io/_vera.asm"
	ENDIF
	INCLUDE "io/_screen.asm"
	INCLUDE "io/_file.asm"
	INCLUDE "io/_keyboard.asm"
	INCLUDE "io/_joystick.asm"
	INCLUDE "io/_error.asm"