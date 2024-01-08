; ===============================
; == XC-BASIC3 Runtime Library ==
; ===============================

	; Import a subrutine using this macro otherwise 
	; it won't get compiled into the final source
	MAC import
{1},"_IMPORTED" SET 1
	ENDM
	
	; Pseudo-registers on zeropage
	INCLUDE "core/zp/psregs.asm"
	; Basic stack operations
	INCLUDE "core/stack/stack.asm"		
	; Conversion between data types
	INCLUDE "core/conv/conv.asm"
	; Numeric comparisons
	INCLUDE "core/comp/comp.asm"
	; Basic arithmetics, boolean logic
	INCLUDE "core/arith/arith.asm"
	; Program structures
	INCLUDE "core/struct/struct.asm"
	; Math library, floating point arithmetics
	INCLUDE "math/math.asm"
	; String library
	INCLUDE "string/string.asm"
	; Input-output library
	INCLUDE "io/io.asm"
	; Memory library
	INCLUDE "mem/mem.asm"
	; System library
	INCLUDE "sys/sys.asm"
	; Interrupts
	INCLUDE "irq/irq.asm"
    ; Graphics
	INCLUDE "grx/grx.asm"
	; Sound
	IF USESFX
	  INCLUDE "sfx/sfx.asm"
	ENDIF
    ; Sprites
    INCLUDE "grx/sprite.asm"
    ; Optimizer
	INCLUDE "opt/opt.asm"