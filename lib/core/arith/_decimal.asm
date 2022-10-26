	PROCESSOR 6502
	
	; Add top 2 decimals on stack
	MAC adddecimal
	IF !USEIRQ
	sei
	ENDIF
	sed
	addword
	cld
	IF !USEIRQ
	cli
	ENDIF
	ENDM
	
	; Substract top 2 decimals on stack
	MAC subdecimal
	IF !USEIRQ
	sei
	ENDIF
	sed
	subword
	cld
	IF !USEIRQ
	cli
	ENDIF
	ENDM
	
	; Perform AND on top 2 decimals on stack
	MAC anddecimal
	andword
	ENDM
	
	; Perform OR on top 2 decimals on stack
	MAC ordecimal
	orword
	ENDM
	
	; Perform XOR on top 2 decimals of stack
    MAC xordecimal
    xorword
    ENDM
    
	; Perform NOT on top 2 decimals of stack
    MAC notdecimal ; @pull
    notword
    ENDM