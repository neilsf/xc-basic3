	INCLUDE "io/_kernal.asm"
	IF TARGET == x16
	  INCLUDE "io/_vera.asm"
	ENDIF
	INCLUDE "io/_screen.asm"
	IF TARGET == pet2001
	  INCLUDE "io/_file_pet1.asm"
	ENDIF
	IF TARGET & pet3
	  INCLUDE "io/_file_pet2.asm"
	ENDIF
	IF TARGET & (pet4 | pet8032) 
	  INCLUDE "io/_file_pet4.asm"
	ENDIF
	IF TARGET & pet == 0
		INCLUDE "io/_file.asm"
	ENDIF
	INCLUDE "io/_keyboard.asm"s
	INCLUDE "io/_joystick.asm"
	INCLUDE "io/_error.asm"