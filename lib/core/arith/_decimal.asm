	PROCESSOR 6502
	
	; Add top 2 decimals on stack
	MAC adddecimal
	sei
	sed
	addword
	cld
	cli
	ENDM
	
	; Substract top 2 decimals on stack
	MAC subdecimal
	sei
	sed
	subword
	cld
	cli
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
    MAC notdecimal
    notword
    ENDM