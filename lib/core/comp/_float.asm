	; Compare two floats on stack for equality
	MAC cmpfloateq ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	beq .true
	discardfloat
	pfalse
	IF !FPUSH
	beq * + 11
	ELSE
	beq * + 10
	ENDIF
.true
	discardfloat
	ptrue
	ENDM

	; Compare two floats on stack for equality
	; and leave the first argument on stack
	MAC cmpfloateq_lfs ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	beq .true
	pfalse
	IF !FPUSH
	beq * + 5
	ELSE
	beq * + 4
	ENDIF
.true
	ptrue
	ENDM
	
	MAC cmpfloatneq ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	bne .true
	discardfloat
	pfalse
	IF !FPUSH
	beq * + 11
	ELSE
	beq * + 10
	ENDIF
.true
	discardfloat
	ptrue
	ENDM

	; Compare two floats on stack for inequality
	; and leave first operand on stack
	; (f f -> f b)
	MAC cmpfloatneq_lfs ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	bne .true
	pfalse
	IF !FPUSH
	beq * + 5
	ELSE
	beq * + 4
	ENDIF
.true
	ptrue
	ENDM
	
	; Compare top 2 floats on stack for greater than
	MAC cmpfloatgt ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	bmi .true
	discardfloat
	pfalse
	IF !FPUSH
	beq * + 11
	ELSE
	beq * + 10
	ENDIF
.true
	discardfloat
	ptrue
	ENDM

	; Compare top 2 floats on stack for greater than
	; and leave first operand on stack
	; (f f -> f b)
	MAC cmpfloatgt_lfs ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	bmi .true
	pfalse
	IF !FPUSH
	beq * + 5
	ELSE
	beq * + 4
	ENDIF
.true
	ptrue
	ENDM
	
	; Compare top 2 floats on stack for less than
	MAC cmpfloatlt ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	cmp #$01
	beq .true
	discardfloat
	pfalse
	IF !FPUSH
	beq * + 11
	ELSE
	beq * + 10
	ENDIF
.true
	discardfloat
	ptrue
	ENDM

	; Compare top 2 floats on stack for less than
	; and leave first operand on stack
	; (f f -> f b)
	MAC cmpfloatlt_lfs ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	cmp #$01
	beq .true
	pfalse
	IF !FPUSH
	beq * + 5
	ELSE
	beq * + 4
	ENDIF
.true
	ptrue
	ENDM
	
	; Compare top 2 floats on stack for less than or equal
	MAC cmpfloatlte ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	bmi .false
	discardfloat
	ptrue
	IF !FPUSH
	bne * + 11
	ELSE
	bne * + 10
	ENDIF
.false
	discardfloat
	pfalse
	ENDM

	; Compare top 2 floats on stack for less than or equal
	; and leave first operand on stack
	; (f f -> f b)
	MAC cmpfloatlte_lfs ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	bmi .false	
	ptrue
	IF !FPUSH
	bne * + 5
	ELSE
	bne * + 4
	ENDIF
.false
	pfalse
	ENDM
	
	; Compare top 2 floats on stack for greater than or equal
	MAC cmpfloatgte ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	cmp #$01
	beq .false
	discardfloat
	ptrue
	IF !FPUSH
	bne * + 11
	ELSE
	bne * + 10
	ENDIF
.false
	discardfloat
	pfalse
	ENDM

	; Compare top 2 floats on stack for greater than or equal
	; and leave first operand on stack
	; (f f -> f b)
	MAC cmpfloatgte_lfs ; @pull @push
	plfloattofac
	tsx
	inx
	stx DEST
	ldy #$01
	import I_FPLIB
	jsr FCOMP2
	cmp #$01
	beq .false
	ptrue
	IF !FPUSH
	bne * + 5
	ELSE
	bne * + 4
	ENDIF
.false
	pfalse
	ENDM