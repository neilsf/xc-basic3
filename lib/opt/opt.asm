; --------------------------------
; XC=BASIC optimized macros
; --------------------------------
	
	; BYTES
	
	; Quick addition
	MAC opt_pbytevar_pbyte_addbyte; @push
	lda {1}
	clc
	adc #{2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbyte_pbytevar_addbyte ; @push
	lda #{1}
	clc
	adc {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbytevar_pbytevar_addbyte ; @push
	lda {1}
	clc
	adc {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Quick subtraction
	MAC opt_pbytevar_pbyte_subbyte; @push
	lda {1}
	sec
	sbc #{2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbyte_pbytevar_subbyte ; @push
	lda #{1}
	sec
	sbc {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbytevar_pbytevar_subbyte ; @push
	lda {1}
	sec
	sbc {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Increase instad of addition
	MAC opt_pbytevar_pbyte_addbyte_plbytevar
	IF {1} == {3} && {2} == 1 ; Same vars and addend = 1
	inc {1}
	ELSE
	lda {1}
	clc
	adc #{2}
	sta {3}
	ENDIF
	ENDM
	
	MAC opt_pbyte_pbytevar_addbyte_plbytevar
	IF {2} == {3} && {1} == 1 ; Same vars and addend = 1
	inc {2}
	ELSE
	lda #{1}
	clc
	adc {2}
	sta {3}
	ENDIF
	ENDM
	
	; Decrease instad of subtraction
	MAC opt_pbytevar_pbyte_subbyte_plbytevar
	IF {1} == {3} && {2} == 1 ; Same vars and addend = 1
	dec {1}
	ELSE
	lda {1}
	sec
	sbc #{2}
	sta {3}
	ENDIF
	ENDM
	
	; Quick OR
	MAC opt_pbytevar_pbyte_orbyte ; @push
	lda {1}
	ora #{2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbyte_pbytevar_orbyte ; @push
	lda #{1}
	ora {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbytevar_pbytevar_orbyte ; @push
	lda {1}
	ora {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Quick AND
	MAC opt_pbytevar_pbyte_andbyte ; @push
	lda {1}
	and #{2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbyte_pbytevar_andbyte ; @push
	lda #{1}
	and {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbytevar_pbytevar_andbyte ; @push
	lda {1}
	and {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Quick XOR
	MAC opt_pbytevar_pbyte_xorbyte ; @push
	lda {1}
	eor #{2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbyte_pbytevar_xorbyte ; @push
	lda #{1}
	eor {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	MAC opt_pbytevar_pbytevar_xorbyte ; @push
	lda {1}
	eor {2}
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; WORDS, INTS and DECIMALS
	
	; Quick addition
	MAC opt_pint_pintvar_addint ; @push
	lda #<{1}
	clc
	adc {2}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda #>{1}
	adc {2} + 1
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	ENDM
	
	MAC opt_pword_pwordvar_addword ; @push
	opt_pint_pintvar_addint {1}, {2}
	ENDM
	
	MAC opt_pdecimal_pdecimalvar_adddecimal ; @push
	sei
	sed
	lda #{1}
	clc
	adc {3}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda #{2}
	adc {3} + 1
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	cld
	cli
	ENDM
	
	MAC opt_pint_pintvar_addint_plintvar
	IF {1} == 1 && {2} == {3}
	inc {2}
	bne .1
	inc {2} + 1
.1
	ELSE
	lda #<{1}
	clc
	adc {2}
	sta {3}
	lda #>{1}
	adc {2} + 1
	sta {3} + 1
	ENDIF
	ENDM
	
	MAC opt_pword_pwordvar_addword_plwordvar
	opt_pint_pintvar_addint_plintvar {1}, {2}, {3}
	ENDM
	
	MAC opt_pdecimal_pdecimalvar_adddecimal_pldecimalvar
	sei
	sed
	lda #{1}
	clc
	adc {3}
	sta {4}
	lda #{2}
	adc {3} + 1
	sta {4} + 1
	cld
	cli
	ENDM
	
	MAC opt_pintvar_pint_addint ; @push
	lda {1}
	clc
	adc #<{2}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda {1} + 1
	adc #>{2}
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	ENDM
	
	MAC opt_pwordvar_pword_addword ; @push
	opt_pintvar_pint_addint {1}, {2}
	ENDM
	
	MAC opt_pdecimalvar_pdecimal_adddecimal ; @push
	lda {1}
	clc
	adc #{2}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda {1} + 1
	adc #{3}
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	ENDM
	
	MAC opt_pintvar_pint_addint_plintvar
	IF {2} == 1 && {1} == {3}
	inc {1}
	bne .1
	inc {1} + 1
.1
	ELSE
	lda {1}
	clc
	adc #<{2}
	sta {3}
	lda {1} + 1
	adc #>{2}
	sta {3} + 1
	ENDIF
	ENDM
	
	MAC opt_pwordvar_pword_addword_plwordvar
	opt_pintvar_pint_addint_plintvar {1}, {2}, {3}
	ENDM
	
	MAC opt_pdecimalvar_pdecimal_addecimal_pldecimalvar
	sei
	sed
	lda {1}
	clc
	adc #{2}
	sta {4}
	lda {1} + 1
	adc #{3}
	sta {4} + 1
	cld
	cli
	ENDM
	
	MAC opt_pintvar_pintvar_addint ; @push
	lda {1}
	clc
	adc {2}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda {1} + 1
	adc {2} + 1
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	ENDM
	
	MAC opt_pwordvar_pwordvar_addword ; @push
	opt_pintvar_pintvar_addint {1}, {2}
	ENDM
	
	MAC opt_pdecimalvar_pdecimalvar_adddecimal ; @push
	opt_pintvar_pintvar_addint {1}, {2}
	ENDM
	
	MAC opt_pintvar_pintvar_addint_plintvar
	lda {1}
	clc
	adc {2}
	sta {3}
	lda {1} + 1
	adc {2} + 1
	sta {3} + 1
	ENDM
	
	MAC opt_pwordvar_pwordvar_addword_plwordvar ; @push
	opt_pintvar_pintvar_addint {1}, {2}, {3}
	ENDM
	
	MAC opt_pdecimalvar_pdecimalvar_adddecimal_pldecimalvar; @push
	sei
	sed
	opt_pintvar_pintvar_addint {1}, {2}, {3}
	cld
	cli
	ENDM
	
	; Quick subtraction
	
	MAC opt_pint_pintvar_subint ; @push
	lda #<{1}
	sec
	sbc {2}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda #>{1}
	sbc {2} + 1
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	ENDM
	
	MAC opt_pword_pwordvar_subword ; @push
	opt_pint_pintvar_subint {1}, {2}
	ENDM
	
	MAC opt_pdecimal_pdecimalvar_subdecimal ; @push
	sei
	sed
	lda #{1}
	sec
	sbc {3}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda #{2}
	sbc {3} + 1
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	cld
	cli
	ENDM
	
	MAC opt_pint_pintvar_subint_plintvar
	lda #<{1}
	sec
	sbc {2}
	sta {3}
	lda #>{1}
	sbc {2} + 1
	sta {3} + 1
	ENDM
	
	MAC opt_pword_pwordvar_subword_plwordvar
	opt_pint_pintvar_subint_plintvar {1}, {2}, {3}
	ENDM
	
	MAC opt_pdecimal_pdecimalvar_subdecimal_pldecimalvar
	sei
	sed
	lda #{1}
	sec
	sbc {3}
	sta {4}
	lda #{2}
	sbc {3} + 1
	sta {4} + 1
	cld
	cli
	ENDM
	
	MAC opt_pintvar_pint_subint ; @push
	lda {1}
	sec
	sbc #<{2}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda {1} + 1
	sbc #>{2}
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	ENDM
	
	MAC opt_pwordvar_pword_subword ; @push
	opt_pintvar_pint_subint {1}, {2}
	ENDM
	
	MAC opt_pdecimalvar_pdecimal_subdecimal ; @push
	sei
	sed
	lda {1}
	sec
	sbc #{2}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda {1} + 1
	sbc #{3}
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	cld
	cli
	ENDM
	
	MAC opt_pintvar_pint_subint_plintvar
	lda {1}
	sec
	sbc #<{2}
	sta {3}
	lda {1} + 1
	sbc #>{2}
	sta {3} + 1
	ENDM
	
	MAC opt_pwordvar_pword_subword_plwordvar
	opt_pintvar_pint_subint_plintvar
	ENDM
	
	MAC opt_pdecimalvar_pdecimal_subdecimal_pldecimalvar
	lda {1}
	sec
	sbc #{2}
	sta {4}
	lda {1} + 1
	sbc #{3}
	sta {4} + 1
	ENDM
	
	MAC opt_pintvar_pintvar_subint ; @push
	lda {1}
	sec
	sbc {2}
	IF !FPUSH
	pha
	ELSE
	tax
	ENDIF
	lda {1} + 1
	sbc {2} + 1
	IF !FPUSH
	pha
	ELSE
	tay
	txa
	ENDIF
	ENDM
	
	MAC opt_pwordvar_pwordvar_subword ; @push
	opt_pintvar_pintvar_subint
	ENDM
	
	MAC opt_pdecimalvar_pdecimalvar_subdecimal ; @push
	sei
	sed
	opt_pintvar_pintvar_subint
	cld
	cli
	ENDM
	
	MAC opt_pintvar_pintvar_subint_plintvar
	lda {1}
	sec
	sbc {2}
	sta {3}
	lda {1} + 1
	sbc {2} + 1
	sta {3} + 1
	ENDM
	
	MAC opt_pwordvar_pwordvar_subword_plwordvar
	opt_pintvar_pintvar_subint_plintvar
	ENDM
	
	MAC opt_pdecimalvar_pdecimalvar_subdecimal_pldecimalvar
	sei
	sed
	opt_pintvar_pintvar_subint_plintvar
	cld
	cli
	ENDM
	
	; Array access
	
	MAC opt_pbytevar_pbytearrayfast ; @push
	ldx {1}
	lda {2},x
	IF !FPUSH
	pha
	ENDIF
	ENDM