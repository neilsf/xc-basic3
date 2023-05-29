	IF TARGET == c64 || TARGET == c128 || TARGET == mega65
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