	PROCESSOR 6502
	
	; Compare two decimals on stack for equality
	MAC cmpdecimaleq ; @pull @push
	cmpwordeq
	ENDM
	
	; Compare two decimals on stack for inequality
	MAC cmpdecimalneq ; @pull @push
	cmpwordneq
	ENDM
	
	; Compare two decimals on stack for less than
	; older < newer
	MAC cmpdecimallt
	cmpwordlt
	ENDM
	
	; Compare two decimals on stack for greater than or equal
	; older >= newer
	MAC cmpdecimalgte
	cmpwordgte
	ENDM
	
	; Compare two decimals on stack for greater than
	; older > newer
	MAC cmpdecimalgt
	cmpwordgt
	ENDM
	
	; Compare two decimals on stack for less than or equal
	; older <= newer
	MAC cmpdecimallte
	cmpwordlte	
	ENDM