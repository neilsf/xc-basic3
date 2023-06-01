	IF TARGET == c64
	INCLUDE "irq/_c64.asm"
	ENDIF
	
	IF TARGET & vic20
	INCLUDE "irq/_vic20.asm"
	ENDIF
    
	IF TARGET & c264
    INCLUDE "irq/_c264.asm"
	ENDIF
    
	IF TARGET & pet
    INCLUDE "irq/_pet.asm"
	ENDIF
    
	IF TARGET == c128
	INCLUDE "irq/_c128.asm"
	ENDIF

	IF TARGET == x16
	INCLUDE "irq/_x16.asm"
	ENDIF