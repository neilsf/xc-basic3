; --------------------------------
; XC=BASIC optimized macros
; --------------------------------
    
    ; BYTES
    
    ; Quick addition
    MAC pbytevar_pbyte_addbyte; @push
    lda {1}
    clc
    adc #{2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbyte_pbytevar_addbyte ; @push
    lda #{1}
    clc
    adc {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbytevar_pbytevar_addbyte ; @push
    lda {1}
    clc
    adc {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    ; Quick subtraction
    MAC pbytevar_pbyte_subbyte; @push
    lda {1}
    sec
    sbc #{2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbyte_pbytevar_subbyte ; @push
    lda #{1}
    sec
    sbc {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbytevar_pbytevar_subbyte ; @push
    lda {1}
    sec
    sbc {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    ; Increase instad of addition
    MAC pbytevar_pbyte_addbyte_plbytevar
    IF {1} == {3} && {2} == 1 ; Same vars and addend = 1
    inc {1}
    ELSE
    lda {1}
    clc
    adc #{2}
    sta {3}
    ENDIF
    ENDM
    
    MAC pbyte_pbytevar_addbyte_plbytevar
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
    MAC pbytevar_pbyte_subbyte_plbytevar
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
    MAC pbytevar_pbyte_orbyte ; @push
    lda {1}
    ora #{2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbyte_pbytevar_orbyte ; @push
    lda #{1}
    ora {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbytevar_pbytevar_orbyte ; @push
    lda {1}
    ora {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    ; Quick AND
    MAC pbytevar_pbyte_andbyte ; @push
    lda {1}
    and #{2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbyte_pbytevar_andbyte ; @push
    lda #{1}
    and {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbytevar_pbytevar_andbyte ; @push
    lda {1}
    and {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    ; Quick XOR
    MAC pbytevar_pbyte_xorbyte ; @push
    lda {1}
    eor #{2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbyte_pbytevar_xorbyte ; @push
    lda #{1}
    eor {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    MAC pbytevar_pbytevar_xorbyte ; @push
    lda {1}
    eor {2}
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    ; WORDS, INTS and DECIMALS
    
    ; Quick addition
    MAC pint_pintvar_addint ; @push
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
    
    MAC pbyte_F_cint_byte_pintvar_addint ; @push
    pint_pintvar_addint {1}, {2}
    ENDM
    
    MAC pword_pwordvar_addword ; @push
    pint_pintvar_addint {1}, {2}
    ENDM
    
    MAC pbyte_F_cword_byte_pwordvar_addword ; @push
    pint_pintvar_addint {1}, {2}
    ENDM
    
    MAC pdecimal_pdecimalvar_adddecimal ; @push
    IF !USEIRQ
	sei
	ENDIF
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
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pint_pintvar_addint_plintvar
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
    
    MAC pbyte_F_cint_byte_pintvar_addint_plintvar
    pint_pintvar_addint_plintvar {1}, {2}, {3}
    ENDM
    
    MAC pword_pwordvar_addword_plwordvar
    pint_pintvar_addint_plintvar {1}, {2}, {3}
    ENDM
    
    MAC pbyte_F_cword_byte_pwordvar_addword_plwordvar
    pint_pintvar_addint_plintvar {1}, {2}, {3}
    ENDM
    
    MAC pdecimal_pdecimalvar_adddecimal_pldecimalvar
    IF !USEIRQ
	sei
	ENDIF
    sed
    lda #{1}
    clc
    adc {3}
    sta {4}
    lda #{2}
    adc {3} + 1
    sta {4} + 1
    cld
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pintvar_pint_addint ; @push
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
    
    MAC pintvar_pbyte_F_cint_byte_addint ; @push
    pintvar_pint_addint {1}, {2}
    ENDM
    
    MAC pwordvar_pword_addword ; @push
    pintvar_pint_addint {1}, {2}
    ENDM
    
    MAC pwordvar_pbyte_F_cword_byte_addword ; @push
    pintvar_pint_addint {1}, {2}
    ENDM
    
    MAC pdecimalvar_pdecimal_adddecimal ; @push
    IF !USEIRQ
	sei
	ENDIF
    sed
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
    cld
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pintvar_pint_addint_plintvar
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
    
    MAC pintvar_pbyte_F_cint_byte_addint_plintvar
    pintvar_pint_addint_plintvar {1}, {2}, {3}
    ENDM
    
    MAC pwordvar_pword_addword_plwordvar
    pintvar_pint_addint_plintvar {1}, {2}, {3}
    ENDM
        
    MAC pwordvar_pbyte_F_cword_byte_addword_plwordvar
    pintvar_pint_addint_plintvar {1}, {2}, {3}
    ENDM
    
    MAC pdecimalvar_pdecimal_addecimal_pldecimalvar
    IF !USEIRQ
	sei
	ENDIF
    sed
    lda {1}
    clc
    adc #{2}
    sta {4}
    lda {1} + 1
    adc #{3}
    sta {4} + 1
    cld
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pintvar_pintvar_addint ; @push
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
    
    MAC pwordvar_pwordvar_addword ; @push
    pintvar_pintvar_addint {1}, {2}
    ENDM
    
    MAC pdecimalvar_pdecimalvar_adddecimal ; @push
    IF !USEIRQ
	sei
	ENDIF
    sed
    pintvar_pintvar_addint {1}, {2}
    cld
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pintvar_pintvar_addint_plintvar
    lda {1}
    clc
    adc {2}
    sta {3}
    lda {1} + 1
    adc {2} + 1
    sta {3} + 1
    ENDM
    
    MAC pwordvar_pwordvar_addword_plwordvar ; @push
    pintvar_pintvar_addint {1}, {2}, {3}
    ENDM
    
    MAC pdecimalvar_pdecimalvar_adddecimal_pldecimalvar; @push
    IF !USEIRQ
	sei
	ENDIF
    sed
    pintvar_pintvar_addint {1}, {2}, {3}
    cld
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    ; Quick subtraction
    
    MAC pint_pintvar_subint ; @push
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
    
    MAC pword_pwordvar_subword ; @push
    pint_pintvar_subint {1}, {2}
    ENDM
    
    MAC pdecimal_pdecimalvar_subdecimal ; @push
    IF !USEIRQ
	sei
	ENDIF
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
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pint_pintvar_subint_plintvar
    lda #<{1}
    sec
    sbc {2}
    sta {3}
    lda #>{1}
    sbc {2} + 1
    sta {3} + 1
    ENDM
    
    MAC pword_pwordvar_subword_plwordvar
    pint_pintvar_subint_plintvar {1}, {2}, {3}
    ENDM
    
    MAC pdecimal_pdecimalvar_subdecimal_pldecimalvar
    IF !USEIRQ
	sei
	ENDIF
    sed
    lda #{1}
    sec
    sbc {3}
    sta {4}
    lda #{2}
    sbc {3} + 1
    sta {4} + 1
    cld
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pintvar_pint_subint ; @push
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
    
    MAC pwordvar_pword_subword ; @push
    pintvar_pint_subint {1}, {2}
    ENDM
    
    MAC pdecimalvar_pdecimal_subdecimal ; @push
    IF !USEIRQ
	sei
	ENDIF
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
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pintvar_pint_subint_plintvar
    lda {1}
    sec
    sbc #<{2}
    sta {3}
    lda {1} + 1
    sbc #>{2}
    sta {3} + 1
    ENDM
    
    MAC pwordvar_pword_subword_plwordvar
    pintvar_pint_subint_plintvar {1}, {2}, {3}
    ENDM
    
    MAC pdecimalvar_pdecimal_subdecimal_pldecimalvar
    IF !USEIRQ
	sei
	ENDIF
    sed
    lda {1}
    sec
    sbc #{2}
    sta {4}
    lda {1} + 1
    sbc #{3}
    sta {4} + 1
    cld
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pintvar_pintvar_subint ; @push
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
    
    MAC pwordvar_pwordvar_subword ; @push
    pintvar_pintvar_subint {1}, {2}
    ENDM
    
    MAC pdecimalvar_pdecimalvar_subdecimal ; @push
    IF !USEIRQ
	sei
	ENDIF
    sed
    pintvar_pintvar_subint {1}, {2}
    cld
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    MAC pintvar_pintvar_subint_plintvar
    lda {1}
    sec
    sbc {2}
    sta {3}
    lda {1} + 1
    sbc {2} + 1
    sta {3} + 1
    ENDM
    
    MAC pwordvar_pwordvar_subword_plwordvar
    pintvar_pintvar_subint_plintvar {1}, {2}, {3}
    ENDM
    
    MAC pdecimalvar_pdecimalvar_subdecimal_pldecimalvar
    IF !USEIRQ
	sei
	ENDIF
    sed
    pintvar_pintvar_subint_plintvar {1}, {2}, {3}
    cld
    IF !USEIRQ
    cli
    ENDIF
    ENDM
    
    ; Array access
    
    MAC pbytevar_pbytearrayfast ; @push
    ldx {1}
    lda {2},x
    IF !FPUSH
    pha
    ENDIF
    ENDM
    
    ; Quick comparison of bytes
    
	MAC pbyte_pbyte_cmpbyteeq ; @push
	lda #{1}
	cmp #{2}
	beq .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbyte_cmpbyteeq ; @push
	lda {1}
	cmp #{2}
	beq .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbyte_pbytevar_cmpbyteeq ; @push
	lda #{1}
	cmp {2}
	beq .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbytevar_cmpbyteeq ; @push
	lda {1}
	cmp {2}
	beq .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbyte_pbyte_cmpytebneq ; @push
	lda #{1}
	cmp #{2}
	bne .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbyte_cmpytebneq ; @push
	lda {1}
	cmp #{2}
	bne .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbyte_pbytevar_cmpytebneq ; @push
	lda #{1}
	cmp {2}
	bne .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbytevar_cmpytebneq ; @push
	lda {1}
	cmp {2}
	bne .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM

	MAC pbyte_pbyte_cmpbytelt ; @push
	lda #{1}
	cmp #{2}
	bcs .false
	ptrue
	bne .end
.false:
	pfalse
.end
	ENDM
	
	MAC pbytevar_pbyte_cmpbytelt ; @push
	lda {1}
	cmp #{2}
	bcs .false
	ptrue
	bne .end
.false:
	pfalse
.end
	ENDM
	
	MAC pbyte_pbytevar_cmpbytelt ; @push
	lda #{1}
	cmp {2}
	bcs .false
	ptrue
	bne .end
.false:
	pfalse
.end
	ENDM
	
	MAC pbytevar_pbytevar_cmpbytelt ; @push
	lda {1}
	cmp {2}
	bcs .false
	ptrue
	bne .end
.false:
	pfalse
.end
	ENDM
	
	MAC pbyte_pbyte_cmpbytelte ; @push
	lda #{2}
	cmp #{1}
	bcs .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbyte_pbytevar_cmpbytelte ; @push
	lda {2}
	cmp #{1}
	bcs .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbyte_cmpbytelte ; @push
	lda #{2}
	cmp {1}
	bcs .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbytevar_cmpbytelte ; @push
	lda {2}
	cmp {1}
	bcs .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbyte_pbyte_cmpbbytegte ; @push
	lda #{1}
	cmp #{2}
	bcs .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbyte_cmpbbytegte ; @push
	lda {1}
	cmp #{2}
	bcs .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbyte_pbytevar_cmpbbytegte ; @push
	lda #{1}
	cmp {2}
	bcs .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbytevar_cmpbytegte ; @push
	lda {1}
	cmp {2}
	bcs .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbyte_pbyte_cmpbytegt ; @push
	lda #{2}
	cmp #{1}
	bcc .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbyte_pbytevar_cmpbytegt ; @push
	lda {2}
	cmp #{1}
	bcc .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbyte_cmpbytegt ; @push
	lda #{2}
	cmp {1}
	bcc .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	MAC pbytevar_pbytevar_cmpbytegt ; @push
	lda {2}
	cmp {1}
	bcc .true
	pfalse
	beq .end
.true:
	ptrue
.end
	ENDM
	
	 ; Quick comparison and branching
	
	MAC pbyte_pbyte_cmpbyteeq_cond_stmt
	lda #{1}
	cmp #{2}
	beq .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true:
	ENDM
	
	MAC pbytevar_pbyte_cmpbyteeq_cond_stmt
	lda {1}
	cmp #{2}
	beq .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true:
	ENDM
	
	MAC pbyte_pbytevar_cmpbyteeq_cond_stmt
	lda #{1}
	cmp {2}
	beq .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true:
	ENDM
	
	MAC pbytevar_pbytevar_cmpbyteeq_cond_stmt
	lda {1}
	cmp {2}
	beq .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true:
	ENDM
	
	MAC pbyte_pbyte_cmpytebneq_cond_stmt
	lda #{1}
	cmp #{2}
	bne .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbyte_cmpytebneq_cond_stmt
	lda {1}
	cmp #{2}
	bne .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbyte_pbytevar_cmpytebneq_cond_stmt
	lda #{1}
	cmp {2}
	bne .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbytevar_cmpytebneq_cond_stmt
	lda {1}
	cmp {2}
	bne .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM

	MAC pbyte_pbyte_cmpbytelt_cond_stmt
	lda #{1}
	cmp #{2}
	bcc .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbyte_cmpbytelt_cond_stmt
	lda {1}
	cmp #{2}
	bcc .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbyte_pbytevar_cmpbytelt_cond_stmt
	lda #{1}
	cmp {2}
	bcc .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbytevar_cmpbytelt_cond_stmt
	lda {1}
	cmp {2}
	bcc .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbyte_pbyte_cmpbytelte_cond_stmt
	lda #{2}
	cmp #{1}
	bcs .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbyte_pbytevar_cmpbytelte_cond_stmt
	lda {2}
	cmp #{1}
	bcs .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbyte_cmpbytelte_cond_stmt
	lda #{2}
	cmp {1}
	bcs .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbytevar_cmpbytelte_cond_stmt
	lda {2}
	cmp {1}
	bcs .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbyte_pbyte_cmpbbytegte_cond_stmt
	lda #{1}
	cmp #{2}
	bcs .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbyte_cmpbbytegte_cond_stmt
	lda {1}
	cmp #{2}
	bcs .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbyte_pbytevar_cmpbbytegte_cond_stmt
	lda #{1}
	cmp {2}
	bcs .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbytevar_cmpbytegte_cond_stmt
	lda {1}
	cmp {2}
	bcs .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbyte_pbyte_cmpbytegt_cond_stmt
	lda #{2}
	cmp #{1}
	bcc .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbyte_pbytevar_cmpbytegt_cond_stmt
	lda {2}
	cmp #{1}
	bcc .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbyte_cmpbytegt_cond_stmt
	lda #{2}
	cmp {1}
	bcc .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM
	
	MAC pbytevar_pbytevar_cmpbytegt_cond_stmt
	lda {2}
	cmp {1}
	bcc .true
	IF {4} > 0 && {2} < $10000
	jmp {4}
	ELSE
	jmp {3}
	ENDIF
.true
	ENDM