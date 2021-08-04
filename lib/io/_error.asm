ERR_DIVZERO	 EQU 0
ERR_OVERFLOW EQU 1
ERR_ILQTY	 EQU 2
ERR_STRLONG	 EQU 3

; Display error message and end program
	IFCONST I_RUNTIME_ERROR_IMPORTED
RUNTIME_ERROR SUBROUTINE
	tax
	lda .errmsg_hi,x
	tay
	lda .errmsg_lo,x	 
	brk	; TODO brk should return to system
		; Maybe better restore SP and rts

.err0 DC.B "division by zero"
	  DC.B 0
.err1 DC.B "overflow"
	  DC.B 0
.err2 DC.B "illegal quantity"
	  DC.B 0
.err3 DC.B "string stack overflow"
	
.errmsg_lo DC.B #<.err0, #<.err1, #<.err2, #<.err3 
.errmsg_hi DC.B #>.err0, #>.err1, #>.err2, #>.err3
	ENDIF