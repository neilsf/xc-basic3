	; This universal macro
	; can be used for if, while, until
	; usage:
	; cond_stmt <false_label> [, <else_label>]
	MAC cond_stmt
	IF !FPULL
	pla
	ENDIF
	bne * + 5
	IFCONST {2}
	jmp {2}
	ELSE
	jmp {1}
	ENDIF
	ENDM
	
	; Same as above but it enters block if
	; Contidion evals to false
	MAC neg_cond_stmt
	IF !FPULL
	pla
	ENDIF
	beq * + 5
	IFCONST {2}
	jmp {2}
	ELSE
	jmp {1}
	ENDIF
	ENDM
	
	; Entry of FOR loop (integer counter)
	; Usage: forint <block id>, <counter_var>, <limit_var>, <step_var>
	MAC forint
	IFCONST {4}
	; Check if step is negative
	lda {4} + 1
	; it is positive: do the regular comparison
	bpl .cmp
.neg
	; compare counter var to limit var (downwards)
	lda {2}
	cmp {3}
	lda {2} + 1
	sbc {3} + 1
	bpl .enter					; Enter the code block
	jmp _ENDFOR_{1}				; Exit loop
	ENDIF
.cmp
	; compare counter var to limit var (upwards)
	lda {3}
	cmp {2}
	lda {3} + 1
	sbc {2} + 1
	bpl .enter					; Enter the code block
	jmp _ENDFOR_{1}				; Exit loop
.enter
	ENDM
	
	; NEXT routine (integer index)
	; Usage: nextint <block id>, <counter_var>, <step_var>
	MAC nextint
	; increment index variable
	IFCONST {3}
	; increment with step
	clc
	lda {3}
	adc {2}
	sta {2}
	lda {3} + 1
	adc {2} + 1
	sta {2} + 1
	ELSE
	; increment with 1
	inc {2}
	bne .skip
	inc {2} + 1
	ENDIF
.skip
	; Jump back to loop entry
	jmp _FOR_{1}
	ENDM
	
	; Entry of FOR loop (long counter)
	; Usage: forint <block id>, <counter_var>, <limit_var>, <step_var>
	MAC forlong
	IFCONST {4}
	; Check if step is negative
	lda {4} + 2
	; it is positive: do the regular comparison
	bpl .cmp
.neg
	; compare counter var to limit var (downwards)
	lda {2}
	cmp {3}
	lda {2} + 1
	sbc {3} + 1
	lda {2} + 2
	sbc {3} + 2
	bpl .enter				; Enter the code block
	jmp _ENDFOR_{1}				; Exit loop
	ENDIF
.cmp
	; compare counter var to limit var (upwards)
	lda {3}
	cmp {2}
	lda {3} + 1
	sbc {2} + 1
	lda {3} + 2
	sbc {2} + 2
	bpl .enter					; Enter the code block
	jmp _ENDFOR_{1}				; Exit loop
.enter
	ENDM
	
	; NEXT routine (long counter)
	; Usage: nextint <block id>, <counter_var>, <step_var>
	MAC nextlong
	; increment index variable
	IFCONST {3}
	; increment with step
	clc
	lda {3}
	adc {2}
	sta {2}
	lda {3} + 1
	adc {2} + 1
	sta {2} + 1
	lda {3} + 2
	adc {2} + 2
	sta {2} + 2
	ELSE
	; increment with 1
	inc {2}
	bne .skip
	inc {2} + 1
	bne .skip
	inc {2} + 2
	ENDIF
.skip
	; Jump back to loop entry
	jmp _FOR_{1}
	ENDM
	
	MAC forword
	; compare index to max
	lda {3}
	cmp {2}
	lda {3} + 1
	sbc {2} + 1
	bpl .enter					; Enter the code block
	jmp _ENDFOR_{1}				; Exit loop
.enter
	ENDM
	
	; NEXT routine (word counter)
	; Usage: nextb <block id>, <counter var>, <step var>
	MAC nextword
	; increment index variable
	IFCONST {3}
	; increment with step
	clc
	lda {3}
	adc {2}
	sta {2}
	lda {3} + 1
	adc {2} + 1
	sta {2} + 1
	; don't roll over
	bcs _ENDFOR_{1}
	ELSE
	; increment with one
	inc {2}
	bne .skip
	inc {2} + 1
	; don't roll over
	beq _ENDFOR_{1}
.skip
	ENDIF
	jmp _FOR_{1}
	ENDM
	
	; Entry of FOR loop (byte index)
	; Usage: forb <block id>, <counter_var>, <limit_var>
	MAC forbyte
	; compare index to max
	lda {3}
	cmp {2}
	bcs .enter
	;index is gte, exit loop
	jmp _ENDFOR_{1}
.enter
	ENDM
	
	; NEXT routine (byte index)
	; Usage: nextb <block id>, <counter var>, <step var>
	MAC nextbyte
	; increment index variable
	IFCONST {3}
	; increment with step
	clc
	lda {3}
	adc {2}
	sta {2}
	; don't roll over
	bcs _ENDFOR_{1}
	ELSE
	; increment with one
	inc {2}
	; don't roll over
	beq _ENDFOR_{1}
	ENDIF
	jmp _FOR_{1}
	ENDM