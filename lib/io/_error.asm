ERR_TOO_MANY_FILES		EQU $01
ERR_FILE_OPEN 			EQU $02
ERR_FILE_NOT_OPEN 		EQU $03
ERR_FILE_NOT_FOUND 		EQU $04
ERR_DEVICE_NOT_PRESENT 	EQU $05
ERR_NOT_INPUT_FILE		EQU $06
ERR_NOT_OUTPUT_FILE		EQU $07
ERR_MISSING_FILENAME	EQU $08
ERR_ILLEGAL_DEVICE_NO	EQU $09
ERR_DEVICE_NOT_READY 	EQU $0a
ERR_READ_ERROR		 	EQU $0b
ERR_ILQTY	 			EQU $0e
ERR_OVERFLOW			EQU $0f
ERR_DIVZERO				EQU $14
ERR_ILLEGAL_DIRECT		EQU $15

SCINIT		 EQU $ff81	

	MAC seterrhandler
	lda #<{1}
	sta ERR_VECTOR
	lda #>{1}
	sta ERR_VECTOR + 1
	ENDM
	
	MAC error ; @pull
	IF !FPULL
	pla
	ENDIF
	import I_RUNTIME_ERROR
	jmp RUNTIME_ERROR
	ENDM
	
	MAC F_err ; @push
	lda ERRNO
	IF !FPUSH
	pha
	ENDIF
	ENDM

	; Return value of the ERR() function
ERRNO HEX 00

	; Default error handler
	; redirect to custor handling routine if set
	; or
	; display error message and end program
	IFCONST I_RUNTIME_ERROR_IMPORTED
RUNTIME_ERROR SUBROUTINE
	sta ERRNO
	ldy ERR_VECTOR + 1
	bne .custom
	; No custom error handler, do default
	pha
	;jsr SCINIT
	printnl
	lda #<.err
	ldy #>.err
	import I_STDLIB_PRINTSTR
	jsr STDLIB_PRINTSTR
	printbyte ; pulls error code off of stack
	xend
.custom
	jmp (ERR_VECTOR)

	; "error "
.err HEX 06 45 52 52 4f 52 20

	; Error redirection vector
	; If HB = 0 errors won't be redirected
ERR_VECTOR HEX 00 00
	ENDIF