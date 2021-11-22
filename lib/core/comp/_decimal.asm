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
	MAC cmpdecimallt ; @pull @push
	cmpwordlt
	ENDM
	
	; Compare two decimals on stack for greater than or equal
	; older >= newer
	MAC cmpdecimalgte ; @pull @push
	cmpwordgte
	ENDM
	
	; Compare two decimals on stack for greater than
	; older > newer
	MAC cmpdecimalgt ; @push
	cmpwordgt
	ENDM
	
	; Compare two decimals on stack for less than or equal
	; older <= newer
	MAC cmpdecimallte ; @pull @push
	cmpwordlte	
	ENDM