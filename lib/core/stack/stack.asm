	PROCESSOR 6502
	
stack EQU $0100

	IF TARGET == c64
STACKFRAME_TOP EQU $CF00
	ENDIF
	IF TARGET == c128
STACKFRAME_TOP EQU $BF00
	ENDIf
	IF TARGET == vic20 || TARGET == vic20_3k
STACKFRAME_TOP EQU $1D00	
	ENDIF
	IF TARGET == vic20_8k || TARGET == c16
STACKFRAME_TOP EQU $3F00	
	ENDIF
	IF TARGET == cplus4 || TARGET == mega65
STACKFRAME_TOP EQU $7F00	
	ENDIF
	; PETS
	IF TARGET & pet
	  IF TARGET & 1 ; PET 8k RAM
STACKFRAME_TOP EQU $1F00
	  ENDIF
	  IF TARGET & 2  ; PET 16k RAM
STACKFRAME_TOP EQU $3F00
	  ENDIF
	  IF TARGET & 4  ; PET 32k RAM
STACKFRAME_TOP EQU $7F00
	  ENDIF
	ENDIF
	
	; (private)
	; Calculate variable address from address + index
	; Index on stack
	; Var address is {1}
	; Result in (R0)
	MAC getaddr ; @pull
	; Get index
	IF !FPULL
	pla
	sta R0+1
	pla
	sta R0
	ELSE
	sta R0
	sty R0+1
	ENDIF
	; Add address
	lda #<[{1}]
	clc
	adc R0
	sta R0
	lda #>[{1}]
	adc R0+1
	sta R0+1
	ENDM
	
	; (private)
	; Calculate dynamic variable address from frame pointer + index
	; Index on stack (one byte)
	; Result in (R0)
	MAC getdynaddr ; @pull
	IF !FPULL
	pla
	ENDIF
	clc
	adc RC
	sta R0
	lda RC + 1
	sta R0 + 1
	ENDM
	
	; Push current THIS pointer on stack
	MAC pthis ; @push
	IF !FPUSH
	lda TH
	pha
	lda TH + 1
	pha
	ELSE
	lda TH
	ldy TH + 1
	ENDIF
	ENDM
	
	; Set THIS pointer to {1} 
	MAC setthis
	lda #<{1}
	sta TH
	lda #>{1}
	sta TH + 1
	ENDM
	
	; Add {1} to THIS pointer
	MAC offsetthis
	lda TH
	clc
	adc #{1}
	sta TH
	bcc .skip
	inc TH + 1
.skip
	ENDM
	
	; Pull THIS pointer off of stack
	MAC plthis ; @pull
	IF !FPULL
	pla
	sta TH + 1
	pla
	sta TH
	ELSE
	sta TH
	sty TH + 1
	ENDIF
	ENDM
	
	MAC framereset
	lda #<STACKFRAME_TOP
	sta RC
	lda #>STACKFRAME_TOP
	sta RC + 1
	ENDM
	
	; Allocate a stack frame for a 
	; new function call
	; Number of bytes in {1}
	MAC framealloc
	IF {1} > 0
	sec
	lda RC
	sbc #{1}
	sta RC
	bcs * + 4
	dec RC + 1
	ENDIF
	ENDM
	
	; Deallocate a stack frame
	; Number of bytes in {1}
	MAC framefree
	IF {1} > 0
	clc
	lda RC
	adc #{1}
	sta RC
	bcc * + 4
	inc RC + 1
	ENDIF
	ENDM
	
	INCLUDE "core/stack/_byte.asm"
	INCLUDE "core/stack/_word.asm"
	INCLUDE "core/stack/_int.asm"
	INCLUDE "core/stack/_long.asm"
	INCLUDE "core/stack/_float.asm"
	INCLUDE "core/stack/_decimal.asm"
	INCLUDE "core/stack/_udt.asm"
	