	; This universal macro
	; can be used for if, while, until
	; usage:
	; cond_stmt <false_label> [, <else_label>]
	MAC cond_stmt ; @pull
	IF !FPULL
	pla
	ENDIF
	bne * + 5
	IF {2} > 0 && {2} < $10000 ; Both values represent void
	jmp {2}
	ELSE
	jmp {1}
	ENDIF
	ENDM
	
	; Same as above but it enters block if
	; Contidion evals to false
	MAC neg_cond_stmt ; @pull
	IF !FPULL
	pla
	ENDIF
	beq * + 5
	IF {2} > 0 && {2} < $10000 ; Both values represent void
	jmp {2}
	ELSE
	jmp {1}
	ENDIF
	ENDM
	
	; Jumps to block {1} if true
	; Or to next case {2} otherwise
	MAC case ;@pull
	IF !FPULL
	pla
	ENDIF
	bne .true
	jmp {2}
.true	
	jmp {1}
	ENDIF
	ENDM
	
	; Entry of FOR loop (integer counter)
	; Usage: forint <block id>, <counter_var>, <limit>, <step_var>, <is_limit_const>
	MAC forint
	IFCONST {4}
	; Check if step is negative
	lda {4} + 1
	; it is positive: do the regular comparison
	bpl .cmp
.neg
	; compare counter var to limit (downwards)
	IF {5} == 1 ; Limit is constant
	lda {2}
	cmp #<{3}
	lda {2} + 1
	sbc #>{3}
	ELSE
	lda {2}
	cmp {3}
	lda {2} + 1
	sbc {3} + 1
	ENDIF
	bpl .enter					; Enter the code block
	jmp _ENDFOR_{1}				; Exit loop
	ENDIF
.cmp
	; compare counter var to limit var (upwards)
	IF {5} == 1 ; Limit is constant
	lda #<{3}
	cmp {2}
	lda #>{3}
	sbc {2} + 1
	ELSE
	lda {3}
	cmp {2}
	lda {3} + 1
	sbc {2} + 1
	ENDIF
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
	; Usage: forlong <block id>, <counter_var>, <limit_var>, <step_var>, <is_limit_const>
	MAC forlong
	IFCONST {4}
	; Check if step is negative
	lda {4} + 2
	; it is positive: do the regular comparison
	bpl .cmp
.neg
	; compare counter var to limit var (downwards)
	IF {5} == 1 ; Limit is constant
	lda {2}
	cmp #<{3}
	lda {2} + 1
	sbc #>{3}
	lda {2} + 2
	sbc #[{3} >> 16]
	ELSE
	lda {2}
	cmp {3}
	lda {2} + 1
	sbc {3} + 1
	lda {2} + 2
	sbc {3} + 2
	ENDIF
	bpl .enter				; Enter the code block
	jmp _ENDFOR_{1}				; Exit loop
	ENDIF
.cmp
	; compare counter var to limit var (upwards)
	IF {5} == 1 ; Limit is constant
	lda #<{3}
	cmp {2}
	lda #>{3}
	sbc {2} + 1
	lda #[{3} >> 16]
	sbc {2} + 2
	ELSE
	lda {3}
	cmp {2}
	lda {3} + 1
	sbc {2} + 1
	lda {3} + 2
	sbc {2} + 2
	ENDIF
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
	
	; Usage: forword <block id>, <counter_var>, <limit_var>, <step_var>, <is_limit_const>
	MAC forword
	; compare index to max
	IF {5} == 1 ; Constant limit
	lda #<{3}
	cmp {2}
	lda #>{3}
	sbc {2} + 1
	ELSE
	lda {3}
	cmp {2}
	lda {3} + 1
	sbc {2} + 1
	ENDIF
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
	; Usage: forbyte <block id>, <counter_var>, <limit_var>, <step_var>, <is_limit_const>
	MAC forbyte
	; compare index to max
	IF {5} == 1
	lda #{3}
	ELSE
	lda {3}
	ENDIF
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
	
	; Entry of FOR loop (float counter)
	; Usage: forfloat <block id>, <counter_var>, <limit_var>, <step_var>
	MAC forfloat
	import I_FPLIB
	lda #<{2}
	ldy #>{2}
	jsr LOAD_FAC_FROM_YA
	lda #<{3}
	ldy #>{3}
	jsr FCOMP
	; result comparison in A
	IFCONST {4}
	; Check if step is negative
	ldx {4} + 1
	bpl .upwards
	cmp #255
	bne .enter
	jmp _ENDFOR_{1}
	ENDIF
.upwards
	cmp #1
	bne .enter
	jmp _ENDFOR_{1}
.enter
	ENDM
	
	; NEXT routine (float index)
	; Usage: nextfloat <block id>, <counter_var>, <step_var>
	MAC nextfloat
	import I_FPLIB
	lda #<{2}
	ldy #>{2}
	jsr LOAD_FAC_FROM_YA
	; increment index variable
	IFCONST {3}
	; increment with step
	lda #<{3}
	ldy #>{3}
	ELSE
	; increment with 1
	lda #<CON_ONE
	ldy #>CON_ONE
	ENDIF
	jsr FADD
	ldx #<{2}
	ldy #>{2}
	jsr STORE_FAC_AT_YX_ROUNDED
.skip
	; Jump back to loop entry
	jmp _FOR_{1}
	ENDM
	
	; ON GOTO statement
	; Usage: ongoto {lowbytes of labels}, {hibytes of labels}
	MAC ongoto ; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	lda.wx {1}
	sta .jump + 1
	lda.wx {2}
	sta .jump + 2
.jump
	jmp $ffff
	ENDM
	
	; ON GOSUB statement
	; Usage: ongosub {lowbytes of labels}, {hibytes of labels}
	MAC ongosub ; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	lda.wx {1}
	sta .jump + 1
	lda.wx {2}
	sta .jump + 2
.jump
	jsr $ffff
	ENDM