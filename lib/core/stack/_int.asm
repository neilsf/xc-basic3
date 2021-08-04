	PROCESSOR 6502
	
	; Push immediate int onto stack
	MAC pint
	pword {1}
	ENDM
			
	; Push one int variable onto stack
	MAC pintvar
	pwordvar {1}
	ENDM
	
	; Pull int on stack to variable
	MAC plintvar
	plwordvar {1}
	ENDM
	
	; Push int of an array onto stack
	; (indexed by a word)
	MAC pintarray
	pwordarray {1}
	ENDM
		
	; Push int of an array onto stack
	; (indexed by a byte)
	MAC pintarrayfast
	pwordarrayfast {1}
	ENDM
	
	; Pull int off of stack and store in array
	; (indexed by a word)
	MAC plintarray
	plwordarray {1}
	ENDM
	
	; Pull int off of stack and store in array
	; (indexed by a byte)
	MAC plintarrayfast
	plwordarrayfast {1}
	ENDM
	
	; Pull dynamic int on stack to variable
	MAC pldynintvar
	pldynwordvar {1}
	ENDM
	
	; Push one dynamic word variable onto stack
	MAC pdynintvar
	pdynwordvar {1}
	ENDM
	
	; Push relative int variable (e.g this.something)
	MAC prelativeintvar
	prelativewordvar {1}
	ENDM
	
	; Pull int value and store in relative int variable
	; (e.g this.something)
	MAC plrelativeintvar
	plrelativewordvar {1}
	ENDM