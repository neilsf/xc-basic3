STRING_WORKAREA EQU $CF00
STRING_BUFFER1  EQU $033C
STRING_BUFFER2  EQU $039D

	INCLUDE "string/_fn.asm"
	
	; Reset stack pointer
	MAC spreset
	lda #$ff
	sta SP
	ENDM
	
	; Push string to stack
	; Allocating as many bytes as necessary
	MAC pstringvar
	lda #<{1}
	sta R0
	lda #>{1}
	sta R0 + 1
	lda {1}	; get string length
	import I_STRMOV
	jsr STRMOV
	ENDM
	
	; Destination pointer = Stack pointer + {offset}
	MAC stackptrtodestptr
	lda RC	   ; Copy pointer
	clc
	adc #{1}   ; Add offset to pointer
	sta R0	   
	lda RC + 1
	adc #0
	sta R0 + 1
	ENDM
	
	; Destination pointer = THIS pointer + {offset}
	MAC thisptrtodestptr
	lda TH	   ; Copy pointer
	clc
	adc #{1}   ; Add offset to pointer
	sta R0	   
	lda TH + 1
	adc #0
	sta R0 + 1
	ENDM
	
	; Push dynamic string variable onto stack
	; Var relative address in {1}
	MAC pdynstringvar
	stackptrtodestptr {1}
	ldy #{1}
	lda (RC),y ; get string length
	import I_STRMOV
	jsr STRMOV
	ENDM
	
	; Pull string off of stack to variable
	; Var address in {1}
	; Max length (excluding length indicator) in {2} - The target var might be narrower
	MAC plstringvar
	lda #<{1}
	sta R0 
	lda #>{1}
	sta R0 + 1
	lda #{2}
	import I_STRREMOV
	jsr STRREMOV
	ENDM
	
	; Pull dynamic string on stack to variable
	; Var relative address in {1}
	; Max length (excluding length indicator) in {2} - The target var might be narrower
	MAC pldynstringvar
	stackptrtodestptr {1}
	lda #{2}
	import I_STRREMOV
	jsr STRREMOV
	ENDM
	
	; Push string of an array onto stack
	; (indexed by a word)
	MAC pstringarray
	getaddr {1}
	ldy #0
	lda (R0),y	; get string length
	import I_STRMOV
	jsr STRMOV
	ENDM
	
	; Push string of an array onto stack
	; (indexed by a byte)
	MAC pstringarrayfast
	IF !FPULL
	pla
	ENDIF
	tax
	clc
	adc #<{1} ; R0 = {1} + A
	sta R0
	lda #>{1}
	adc #0
	sta R0 + 1
	lda {1},x
	import I_STRMOV
	jsr STRMOV
	ENDM
	
	; Pull string off of stack and store in array
	; (indexed by a word)
	; Max length in {2}
	MAC plstringarray
	getaddr {1}
	lda #{2}
	import I_STRREMOV
	jsr STRREMOV
	ENDM
	
	; Pull string off of stack and store in array
	; (indexed by a byte)
	; Max length in {2}
	MAC plstringarrayfast
	IF !FPULL
	pla
	ENDIF
	tax
	clc
	adc #<{1} ; R0 = {1} + A
	sta R0
	lda #>{1}
	adc #0
	sta R0 + 1
	lda #{2}
	import I_STRREMOV
	jsr STRREMOV
	ENDM
	
	; Push relative string variable (e.g this.something$)
	MAC prelativestringvar
	thisptrtodestptr {1}
	ldy #{1}
	lda (TH),y ; get string length
	import I_STRMOV
	jsr STRMOV
	ENDM
	
	; Pull byte value and store in relative string variable
	; (e.g this.something$)
	MAC plrelativestringvar
	thisptrtodestptr {1}
	lda #{2}
	import I_STRREMOV
	jsr STRREMOV
	ENDM
	
	; Move string on stack and update stack pointer
	; Length in A
	; String ptr in R0
	IFCONST I_STRMOV_IMPORTED
STRMOV SUBROUTINE
	pha		; save length
	tay
	ldx SP	; current stack pointer
.loop
	lda (R0),y
	sta STRING_WORKAREA,x
	dex
	dey
	bne .loop 
	pla		; restore length	
	sta STRING_WORKAREA,x
	dex
	stx SP	; new stack pointer
	rts
	ENDIF
	
	IFCONST I_STRREMOV_IMPORTED
	; Dest ptr to string in R0
	; Max length in A
STRREMOV SUBROUTINE
	ldx SP
	inx
	cmp STRING_WORKAREA,x ; length of string on stack
	bcc .skip
	lda STRING_WORKAREA,x
.skip
	ldy #0
	sta (R0),y
	tay
	; X = X + Y
	stx R2
	clc
	adc R2
	tax
	stx SP ; Move pointer to end of string
.loop
	lda STRING_WORKAREA,x
	sta (R0),y
	dex
	dey
	bne .loop
	rts
	ENDIF
	
	IFCONST I_STRSCRATCH_IMPORTED
	; Remove top string from stack without copying
STRSCRATCH SUBROUTINE
	ldx SP
	inx
	stx R0
	lda STRING_WORKAREA,x
	clc
	adc R0
	sta SP
	rts
	ENDIF
		
	; Concatenate top two strings on stack
	MAC addstring
	import I_STR_CONCAT
	jsr STR_CONCAT
	ENDM
	
	IFCONST I_STR_CONCAT_IMPORTED
STR_CONCAT	SUBROUTINE
	; Pull string2
	plstringvar STRING_BUFFER2, 96
	; Pull string1
	plstringvar STRING_BUFFER1, 96
	; Push string1
	pstringvar STRING_BUFFER1
	; Adjust pointer and push string2
	inc SP
	pstringvar STRING_BUFFER2
	; Calculate and write total length
	lda STRING_BUFFER1
	clc
	adc STRING_BUFFER2
	ldx SP
	inx
	sta STRING_WORKAREA,x
	ENDIF
	
	; Returns pointer (XY) and length (A) to null-terminated
	; string converted from Pascal string on stack
	MAC strtonullterm
	import I_STR_TONULLTERM
	jsr STR_TONULLTERM
	lda R1
	ldx #<STRING_BUFFER1
	ldy #>STRING_BUFFER1
	ENDM
	
	; Converts Pascal string on stack to
	; null-terminated string at STRING_BUFFER1
	; saves string length in R1
	IFCONST I_STR_TONULLTERM_IMPORTED
STR_TONULLTERM SUBROUTINE
	ldx SP
	inx
	lda STRING_WORKAREA,x
	sta R1
	tay
	lda #0
	sta STRING_BUFFER1,y
	; X = X + Y + 1
	sty R0
	txa
	clc
	adc R0
	tax
	inx
	stx SP ; point to next string
.loop
	lda STRING_WORKAREA,x
	sta [STRING_BUFFER1 - 1],y
	dex
	dey
	bne .loop
	rts
	ENDIF