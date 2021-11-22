	; Push immediate int onto stack
	MAC pint ; @push
	pword {1}
	ENDM
			
	; Push one int variable onto stack
	MAC pintvar ; @push
	pwordvar {1}
	ENDM
	
	; Pull int on stack to variable
	MAC plintvar ; @pull
	plwordvar {1}
	ENDM
	
	; Push int of an array onto stack
	; (indexed by a word)
	MAC pintarray ; @pull
	pwordarray {1}
	ENDM
		
	; Push int of an array onto stack
	; (indexed by a byte)
	MAC pintarrayfast ; @pull @push
	pwordarrayfast {1}
	ENDM
	
	; Pull int off of stack and store in array
	; (indexed by a word)
	MAC plintarray ; @pull
	plwordarray {1}
	ENDM
	
	; Pull int off of stack and store in array
	; (indexed by a byte)
	MAC plintarrayfast ; @pull
	plwordarrayfast {1}
	ENDM
	
	; Pull dynamic int on stack to variable
	MAC pldynintvar ; @pull
	pldynwordvar {1}
	ENDM
	
	; Push one dynamic word variable onto stack
	MAC pdynintvar ; @push
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