ERR_DIVZERO	 EQU 17
ERR_OVERFLOW EQU 18
ERR_ILQTY	 EQU 19
ERR_STRLONG	 EQU 20
SCINIT		 EQU $ff81	

	; Default error handler
	; redirect to custor handling routine if set
	; or
	; display error message and end program
	IFCONST I_RUNTIME_ERROR_IMPORTED
RUNTIME_ERROR SUBROUTINE
	ldy ERR_VECTOR + 1
	bne .custom
	; No custom error handler, do default
	pha
	jsr SCINIT
	pla
	tax
	lda .errmsg_hi,x
	tay
	lda .errmsg_lo,x	 
	brk	; TODO brk should return to system
		; Maybe better restore SP and rts
.custom
	jmp (ERR_VECTOR)

	; TODO KERNAL ERRORS
.err0 DC.B 16 
      DC.B "division by zero"
.err1 DC.B 8 
      DC.B "overflow"
.err2 DC.B "illegal quantity"
	  DC.B 0
.err3 DC.B "string stack overflow"
	
.errmsg_lo DC.B #<.err0, #<.err1, #<.err2, #<.err3 
.errmsg_hi DC.B #>.err0, #>.err1, #>.err2, #>.err3
	ENDIF
	
	; Error redirection vector
	; If HB = 0 errors won't be redirected
ERR_VECTOR HEX 00 00