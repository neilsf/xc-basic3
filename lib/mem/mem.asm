	IF TARGET == mega65
      INCLUDE "mem/45xx/_fn.asm"
	  INCLUDE "mem/45xx/_routines.asm"
	ELSE
      INCLUDE "mem/65xx/_fn.asm"
	  INCLUDE "mem/65xx/_routines.asm"
	ENDIF
    