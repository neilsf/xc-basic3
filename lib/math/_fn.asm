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
	MAC F_sgn_byte
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
	MAC F_sgn_int
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
	MAC F_sgn_word
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
	MAC F_sgn_long
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
	MAC F_sgn_float
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
	
	; DECLARE FUNCTION POW AS LONG (base AS INT, exp AS BYTE) OVERRIDE SHARED STATIC INLINE
	; TODO FIND BUG
	MAC F_pow_int_byte
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
	MAC F_pow_float_float
	plfloattofac
	plfloattoarg
	import I_FPLIB
	jsr FPWRT
	pfac
	ENDM
	
	; DECLARE FUNCTION COS AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
	MAC F_cos_float
	plfloattofac
	tsx
	dex
	dex
	dex
	dex
	txs
	plfloattoarg
	import I_COS
	jsr I_COS
	pfac
	ENDM
	
	; COS(x) function
	; x in both ARG and FAC
	; Result in FAC
	IFCONST I_COS_IMPORTED
I_COS SUBROUTINE
	import I_FPLIB
	lda FAC
	jsr FMULTT
	ldx #<.X2
	ldy #>.X2
	jsr STORE_FAC_AT_YX_ROUNDED
	lda #<.C3
	ldy #>.C3
	jsr FMULT
	lda #<.C2
	ldy #>.C2
	jsr FADD
	lda #<.X2
	ldy #>.X2
	jsr FMULT
	lda #<.C1
	ldy #>.C1
	jsr FADD
	rts
.X2 HEX 00 00 00 00 ; X**2
.C1	HEX 80 7F D8 E0 ; 0.999403
.C2 HEX 7F FD BC A9 ; -0.495580
.C3 HEX 7C 16 B3 35 ; 0.036792
	ENDIF
	
	; DECLARE FUNCTION SIN AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
	MAC F_sin_float
	plfloattofac
	import I_SIN
	jsr I_SIN
	pfac
	ENDM
	
	; SIN(x) function
	; x in FAC
	; Result in FAC
	IFCONST I_SIN_IMPORTED
I_SIN SUBROUTINE
	import I_FPLIB
	lda #<.halfpi
	ldy #>.halfpi
	jsr FSUB
	jsr COPY_FAC_TO_ARG_ROUNDED
	lda #$00
    sta SGNCPR
	import I_COS
	jmp I_COS
.halfpi HEX 81 49 0F D8
	ENDIF
	
	; DECLARE FUNCTION MOD AS FLOAT (dividend AS FLOAT, divisor AS float) SHARED STATIC INLINE
	MAC F_mod_float_float
	plfloattofac
	plfloattoarg
	import I_FMOD
	jsr I_FMOD
	pfac
	ENDM
	
	IFCONST I_FMOD_IMPORTED
I_FMOD SUBROUTINE
	ldx #<.tmp
	ldy #>.tmp
	import I_FPLIB
	jsr STORE_FAC_AT_YX_ROUNDED
	jsr FDIVT
	jsr COPY_FAC_TO_ARG_ROUNDED
	import I_INT
	jsr INT
	jsr FSUBT
	lda #<.tmp
	ldy #>.tmp
	jmp FMULT
.tmp HEX 00 00 00 00
	ENDIF
	
	IFCONST I_RANDOMIZE_IMPORTED || I_RND_IMPORTED
MATH_RNDEXP HEX 80
MATH_RND HEX 00 00 00
	ENDIF
	
	; DECLARE FUNCTION RND AS FLOAT () SHARED STATIC INLINE
	MAC F_rnd
	import I_RND
	jsr I_RND
	lda #<MATH_RNDEXP
	ldy #>MATH_RNDEXP
	jsr LOAD_FAC_FROM_YA
	sec
	jsr NORMALIZE_FAC1
	pfac
	ENDM
	
	; DECLARE FUNCTION RND AS LONG () SHARED STATIC INLINE
	MAC F_rndl
	import I_RND
	jsr I_RND
	IF !FPUSH
	lda MATH_RND
	pha
	lda MATH_RND + 1
	pha
	lda MATH_RND + 2
	pha
	ELSE
	lda MATH_RND
	ldy MATH_RND + 1
	ldx MATH_RND + 2
	ENDIF
	ENDM
	
	; 6502 LFSR PRNG - 24-bit
	; Brad Smith, 2019
	; http://rainwarrior.ca
	IFCONST I_RND_IMPORTED
I_RND SUBROUTINE
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


	