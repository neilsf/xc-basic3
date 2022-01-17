	; XC-BASIC numeric functions
	
	; DECLARE FUNCTION ABS AS BYTE (num AS BYTE) SHARED STATIC INLINE
	MAC F_abs_byte
	ENDM
	
	; DECLARE FUNCTION ABS AS INT (num AS INT) SHARED STATIC INLINE
	MAC F_abs_int
	tsx
	lda.wx stack+1
	bpl .skip
	eor #$ff
	sta.wx stack+1
	lda.wx stack+2
	eor #$ff
	clc
	adc #$01
	sta.wx stack+2
	bne .skip
	inc.wx stack+1
.skip
	ENDM
	
	; DECLARE FUNCTION ABS AS WORD (num AS WORD) SHARED STATIC INLINE
	MAC F_abs_word
	ENDM
	
	; DECLARE FUNCTION ABS AS LONG (num AS LONG) SHARED STATIC INLINE
	MAC F_abs_long
	tsx
	lda.wx stack + 1
	bpl .skip
	eor #$ff
	sta.wx stack + 1
	lda.wx stack + 2
	eor #$ff
	sta.wx stack + 2
	lda.wx stack + 3
	eor #$ff
	clc
	adc #$01
	sta.wx stack + 3
	bne .skip
	inc.wx stack + 2
	bne .skip
	inc.wx stack + 1
.skip
	ENDM
	
	; DECLARE FUNCTION ABS AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
	MAC F_abs_float
	tsx
	lda.wx stack + 2
	and #%01111111
	sta.wx stack + 2
	ENDM
	
	; DECLARE FUNCTION SGN AS INT (num AS BYTE) SHARED STATIC INLINE
	MAC F_sgn_byte ; @pull @push
	IF !FPULL
	pla
	ENDIF
	beq .z
	lda #$01
.z
	IF !FPUSH
	pha
	lda #$00
	pha
	ELSE
	ldy #$00
	ENDIF
	ENDM
	
	; DECLARE FUNCTION SGN AS INT (num AS INT) SHARED STATIC INLINE
	MAC F_sgn_int ; @push
	pla
	bmi .neg
	beq .plz
	pla
.pos
	pint 1
	beq .end
.plz
	pla
	bne .pos
	pint 0
	beq .end
.neg
	pla
	pint -1
.end
	ENDM
	
	; DECLARE FUNCTION SGN AS INT (num AS WORD) SHARED STATIC INLINE
	MAC F_sgn_word ; @push
	pla
	beq .plz
	pla
.pos
	pint 1
	beq .end
.plz
	pla
	bne .pos
	pint 0
.end
	ENDM
	
	; DECLARE FUNCTION SGN AS INTEGER (num AS LONG) SHARED STATIC INLINE
	MAC F_sgn_long ; @push
	pla
	bmi .neg
	pla	
	bne .pos	
	pla	
	bne .pos + 1	
	pint 0
	beq .end	
.pos
	pla
	pint 1
	beq .end
.neg
	pla
	pla
	pint -1
.end
	ENDM
	
	; DECLARE FUNCTION SGN AS INTEGER (num AS FLOAT) SHARED STATIC INLINE
	MAC F_sgn_float ; @pull @push
	IF !FPULL
	pla
	sta R0
	pla
	sta R1
	pla
	pla
	ELSE
	pla
	stx R0
	sty R1
	ENDIF
	lda R0
	beq .q
    lda R1
    bmi .neg
    lda #$01
    bne .q
.neg
	pint -1
	bmi .end
.q
	IF !FPUSH
	pha
	lda #0
	pha
	ELSE
	ldy #0
	ENDIF
.end
	ENDM
	
	; DECLARE FUNCTION POW AS LONG (base AS WORD, exp AS BYTE) SHARED STATIC INLINE
	MAC F_pow_word_byte ; @pull @push
	IF !FPULL
	pla
	ENDIF
	tax
	pla
	sta FAC + 1
	pla
	sta FAC
	txa
	import I_EXP
	jsr I_EXP
	IF !FPUSH
	lda R0
	pha
	lda R0 + 1
	pha
	lda R0 + 2
	pha
	ELSE
	lda R0
	ldy R0 + 1
	ldx R0 + 2
	ENDIF
	ENDM
	
	; DECLARE FUNCTION POW AS LONG (base AS INT, exp AS BYTE) OVERRIDE SHARED STATIC INLINE
	; TODO FIND BUG
	MAC F_pow_int_byte  ; @pull @push
.SIGN EQU ARG
.EXP  EQU ARG + 1
	IF !FPULL
	pla
	ENDIF
	sta .EXP
	pla
	sta FAC + 1
	pla
	sta FAC
	lda #0
	sta .SIGN
	lda FAC + 1
	bpl .pos
	twoscplint FAC
	inc .SIGN
.pos
	lda .EXP
	import I_EXP
	jsr I_EXP
	lda .SIGN
	beq .q
	lda .EXP
	and #%00000001
	beq .q
	twoscpllong R0
.q
	IF !FPUSH
	lda R0
	pha
	lda R0 + 1
	pha
	lda R0 + 2
	pha
	ELSE
	lda R0
	ldy R0 + 1
	ldx R0 + 2
	ENDIF
	ENDM
	
	; Exponentiation
	; taken from https://codebase64.org/doku.php?id=base:exponentiation
	IFCONST I_EXP_IMPORTED
I_EXP SUBROUTINE
; input:  B value to be raised
;         A exponent
;
; algo:  if .A=0 res=1
;        if .A=1 res=B
;            _
;           | B if E=1
; Exp(B,E)= | B*Exp(B,E-1) if E is odd
;           |_Exp(B,E/2)*Exp(B,E/2) if E is even
; 
 
P EQU R0
M EQU R4
N EQU R8
; No more pseudo-regs, use FAC
B EQU FAC

    tax
    beq .res1       ; is E==0 ?
    lda B
    lsr
    ora B + 1
    beq .resB       ; if B==0 or B==1 then result=B
    txa
    cmp #1
    bne .ExpSub
.resB
 	lda #0          ; E==1 | B==1 | B==0, result=B
    sta P + 2
    sta P + 3
    lda B
    sta P
    lda B + 1
    sta P + 1
    rts
.res1
    sta P + 1       ; E=0, result=1
    sta P + 2
    sta P + 3
    lda #1
    sta P
    rts
.ExpSub
    lsr             ; E = int(E/2)
    beq .resB       ; E is 1
    bcs .ExpOdd     ; E is Odd
.ExpEven
    jsr .ExpSub     ; E is Even
    ldx #$3
.ldP
	lda P,x         ; multiply P by itself
    sta M,x         ; P is the result of a previous mult
    sta N,x         ; copy P in M and N
    dex
    bpl .ldP
    bmi .Mult32      
 
.ExpOdd
	asl             ; E = 2*int(E/2) (=E-1)
    jsr .ExpSub
    ldx #$4
.ldD
	lda <P-1,x      ; multiply P by B
    sta <M-1,x      ; P is the result of a previous mult
    dex             ; copy P in M
    bne .ldD
    lda B           ; copy B in N
    sta N
    lda B + 1
    sta N + 1
    ;lda #0
    stx N + 2
    stx N + 3
    ;jmp Mult32
 
.Mult32          ; 32=32*32
    lda #0
    sta P
    sta P+1
    sta P+2
    sta P+3
    ldy #$20
.loop
	asl P
    rol P+1
    rol P+2
    rol P+3
    asl N
    rol N+1
    rol N+2
    rol N+3
    bcc .skip
    clc
    ldx #$fc
.add
	lda.zx P-252
    adc.zx M-252
    sta.zx P-252
    inx
    bne .add
.skip
	dey 
    bne .loop
    rts
	ENDIF
	
	; DECLARE FUNCTION POW AS FLOAT (base AS FLOAT, exp AS FLOAT) SHARED STATIC INLINE
	MAC F_pow_float_float ; @pull @push
	plfloattofac
	plfloattoarg
	import I_FPLIB
	jsr FPWRT
	pfac
	ENDM
	
	; DECLARE FUNCTION EXP AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
	MAC F_exp_float ; @pull @push
	plfloattofac
	import I_FPLIB
	jsr EXP
	pfac
	ENDM
	
	; DECLARE FUNCTION LOG AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
	MAC F_log_float ; @pull @push
	plfloattofac
	import I_FPLIB
	jsr LOG
	pfac
	ENDM
	
	; DECLARE FUNCTION INT AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
	MAC F_int_float ; @pull @push
	plfloattofac
	import I_FPLIB
	jsr INT
	pfac
	ENDM
	
	; DECLARE FUNCTION SQR AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
	MAC F_sqr_float ; @pull @push
	plfloattofac
	import I_FPLIB
	jsr SQR
	pfac
	ENDM
	
	; DECLARE FUNCTION SQR AS BYTE (num AS WORD) SHARED STATIC INLINE
	MAC F_sqr_word ; @pull @push
	IF !FPULL
	pla
	sta R0 + 1
	pla
	sta R0
	ELSE
	sta R0
	sty R0 + 1
	ENDIF
	import I_SQRW
	jsr SQRW
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; DECLARE FUNCTION SQR AS BYTE (num AS INT) SHARED STATIC INLINE
	MAC F_sqr_int ; @pull @push
	IF !FPULL
	pla
	sta R0 + 1
	pla
	sta R0
	ELSE
	sta R0
	sty R0 + 1
	ENDIF
	lda R0 + 1 
	bpl .ok
	import I_RUNTIME_ERROR
	lda #ERR_ILQTY
	jmp RUNTIME_ERROR
.ok
	import I_SQRW
	jsr SQRW
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; Square root of a word in R0-R1
	; Returns value in A
	; Remainder in X
	; https://codebase64.org/doku.php?id=base:16bit_and_24bit_sqrt
	IFCONST I_SQRW_IMPORTED
SQRW SUBROUTINE
	ldy #$01
	sty R2
	dey
	sty R3
.do
	sec
	lda R0
	tax 
	sbc R2
	sta R0
	lda R1
	sbc R3
	sta R1
	bcc .nomore
	iny
	lda R2
	adc #$01
	sta R2
	bcc .do
	inc R3
	bcs .do
.nomore
	tya
	rts
	ENDIF
	
	; DECLARE FUNCTION SQR AS WORD (num AS LONG) OVERRIDE SHARED STATIC INLINE 
	MAC F_sqr_long ; @pull @push
	pllongvar R0
	lda R0 + 2
	bpl .pos
	import I_RUNTIME_ERROR
	lda #ERR_ILQTY
	jmp RUNTIME_ERROR
.pos
	import I_SQRL
	jsr SQRL
	pwordvar R8
	ENDM
	
	; Square Root of a 24bit number
	; by Verz - Jul2019
	; Input in R0
	; Result in AY
	IFCONST I_SQRL_IMPORTED
SQRL SUBROUTINE
	ldy #1
	sty R4
	dey
	sty R4 + 1
	sty R4 + 2
	sty R8
	sty R8 + 1
.do
	sec
	lda R0
	sta RA
	sbc R4
	sta R0
	lda R0 + 1
	sta RA + 1
	sbc R4 + 1
	sta R0 + 1
	lda R0 + 2
	sbc R4 + 2
	sta R0 + 2
	bcc .nomore
	inc R8
	bne .1
	inc R8 + 1
.1
	lda R4
	adc #1
	sta R4
	bcc .do
	lda R4 + 1
	adc #0
	sta R4 + 1
	bcc .do
	inc R4 + 2
	bcs .do
.nomore
	lda R8
	ldy R8 + 1
	rts
	ENDIF
	
	
	IFCONST I_RANDOMIZE_IMPORTED || I_RND_IMPORTED || I_RNDL_IMPORTED
MATH_RND_EXP HEX 80
MATH_RND HEX 00 00 00
	ENDIF
	
	; DECLARE FUNCTION RND AS FLOAT () SHARED STATIC INLINE
	MAC F_rnd ; @push
	import I_RND
	jsr I_RND
	pfloatvar MATH_RND_EXP
	ENDM
	
	; DECLARE FUNCTION RNDL AS LONG () SHARED STATIC INLINE
	MAC F_rndl
	import I_RNDL
	REPEAT 3
	jsr I_RNDL
	lda MATH_RND
	pha
	REPEND
	ENDM
	
	; DECLARE FUNCTION RNDI AS INT () SHARED STATIC INLINE
	MAC F_rndi
	import I_RNDL
	REPEAT 2
	jsr I_RNDL
	lda MATH_RND
	pha
	REPEND
	ENDM
	
	; DECLARE FUNCTION RNDW AS INT () SHARED STATIC INLINE
	MAC F_rndw
	F_rndi
	ENDM
	
	; DECLARE FUNCTION RNDB AS BYTE () SHARED STATIC INLINE
	MAC F_rndb ; @ push
	import I_RNDL
	jsr I_RNDL
	lda MATH_RND
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; 6502 LFSR PRNG - 24-bit
	; Brad Smith, 2019
	; http://rainwarrior.ca
	IFCONST I_RNDL_IMPORTED
I_RNDL SUBROUTINE
	; rotate the middle byte left
	ldy MATH_RND + 1 ; will move to seed + 2 at the end
	; compute seed + 1 ($1B>>1 = %1101)
	lda MATH_RND + 2
	lsr
	lsr
	lsr
	lsr
	sta MATH_RND + 1 ; reverse: %1011
	lsr
	lsr
	eor MATH_RND + 1
	lsr
	eor MATH_RND + 1
	eor MATH_RND + 0
	sta MATH_RND + 1
	; compute seed+0 ($1B = %00011011)
	lda MATH_RND + 2
	asl
	eor MATH_RND + 2
	asl
	asl
	eor MATH_RND + 2
	asl
	eor MATH_RND + 2
	sty MATH_RND + 2 ; finish rotating byte 1 into 2
	sta MATH_RND
	rts
	ENDIF
	
	IFCONST I_RND_IMPORTED
I_RND SUBROUTINE
	import I_FPLIB
	lda #<MATH_RND_EXP
	ldy #>MATH_RND_EXP
	jsr LOAD_FAC_FROM_YA
	lda #<.C1
	ldy #>.C1
	jsr FMULT
	lda #<.C2
	ldy #>.C2
	jsr FADD
	lda FAC + 1
	ldx FAC + 3
	sta FAC + 3
	stx FAC + 1
	lda #0
	sta FACSIGN
	lda FAC
	sta FACEXTENSION
	lda #$80
	sta FAC
	sec
	jsr NORMALIZE_FAC1
	ldx #<MATH_RND_EXP
	ldy #>MATH_RND_EXP
	jmp STORE_FAC_AT_YX_ROUNDED
	
.C1 HEX 98 35 44 7A
.C2 HEX 68 28 B1 46
	ENDIF

	MAC F_shl_byte_byte ; @pull @push
	lshiftbyte
	ENDM
	
	MAC F_shr_byte_byte ; @pull @push
	rshiftbyte
	ENDM
	
	MAC F_shl_int_byte ; @pull
	lshiftint
	ENDM
	
	MAC F_shr_int_byte ; @pull
	rshiftint
	ENDM
	
	MAC F_shl_word_byte ; @pull
	lshiftword
	ENDM
	
	MAC F_shr_word_byte ; @pull
	rshiftword
	ENDM
	
	MAC F_shl_long_byte ; @pull
	lshiftlong
	ENDM
	
	MAC F_shr_long_byte ; @pull
	rshiftlong
	ENDM
	