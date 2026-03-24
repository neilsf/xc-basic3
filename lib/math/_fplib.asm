; ======================================================
; MS BASIC FLOATING POINT ROUTINES
; https://github.com/mist64/msbasic
; License: 2-clause BSD
; ======================================================

CONFIG_CBM_ALL EQU 1
CONFIG_2B	 EQU 0
CONFIG_2A	 EQU 1
CONFIG_2	 EQU 0
CONFIG_11	 EQU 0
CONFIG_10A	 EQU 0
CONFIG_SMALL EQU 1
CONFIG_ROR_WORKAROUND EQU 0
BYTES_FP	 EQU 4
MANTISSA_BYTES EQU 3
AIM65		 EQU 0
KBD			 EQU 0
MAX_EXPON	 EQU 10
APPLE_BAD_BYTE EQU 0
		
		SEG.U ZP
		ORG $16
CHARAC:
		DS.B 1
INDEX:
		DS.B 2
DEST:
RESULT:
		DS.B BYTES_FP
		DS.B 2
ARGEXTENSION:
        IF CONFIG_SMALL == 0
		DS.B 1
        ENDIF
TEMP1:
		DS.B 1
HIGHDS:
		DS.B 2
HIGHTR:
		DS.B 2
        IF CONFIG_SMALL == 0
TEMP2:
		DS.B 1
        ENDIF
INDX:
TMPEXP:
        IF CONFIG_SMALL
TEMP2:
        ENDIF
		DS.B 1
EXPON:
		DS.B 1
LOWTR:
        IFNCONST LOWTRX ; allow override
LOWTRX:
        ENDIF
		DS.B 1
EXPSGN:
		DS.B 1
FAC:
		DS.B 4
FACSIGN:
		DS.B 1
SERLEN:
		DS.B 1
SHIFTSIGNEXT:
		DS.B 1
ARG:
		DS.B BYTES_FP
ARGSIGN:
		DS.B 1
STRNG1:
		DS.B 2
STRNG2:
		DS.B 2
        IF AIM65
ATN:
		DS.B 3
ZBE:
		DS.B 1
        ENDIF
VARPNT:
		DS.B 2
TEMP3:
		DS.B 2			
		
TEMP1X = TEMP1+(5-BYTES_FP)
FAC_LAST = FAC + BYTES_FP-1
ARG_LAST = ARG + BYTES_FP-1
SGNCPR = STRNG1
FACEXTENSION = STRNG1+1
RESULT_LAST = RESULT + BYTES_FP-1

	SEG "LIBRARY"
	IFCONST I_FPLIB_IMPORTED
; ----------------------------------------------------------------------------
; ADD 0.5 TO FAC
; ----------------------------------------------------------------------------
FADDH:
        lda     #<CON_HALF
        ldy     #>CON_HALF
        jmp     FADD
		
; ----------------------------------------------------------------------------
; FAC = (Y,A) - FAC
; ----------------------------------------------------------------------------
FSUB:
        jsr     LOAD_ARG_FROM_YA
        
; ----------------------------------------------------------------------------
; FAC = ARG - FAC
; ----------------------------------------------------------------------------
FSUBT:
        lda     FACSIGN
        eor     #$FF
        sta     FACSIGN
        eor     ARGSIGN
        sta     SGNCPR
        lda     FAC
        jmp     FADDT
       
; ----------------------------------------------------------------------------
; SHIFT SMALLER ARGUMENT MORE THAN 7 BITS
; ----------------------------------------------------------------------------
FADD1:
        jsr     SHIFT_RIGHT
        bcc     FADD3

; ----------------------------------------------------------------------------
; FAC = (Y,A) + FAC
; ----------------------------------------------------------------------------
FADD:
        jsr     LOAD_ARG_FROM_YA

; ----------------------------------------------------------------------------
; FAC = ARG + FAC
; ----------------------------------------------------------------------------
FADDT:
        bne     L365B
        jmp     COPY_ARG_TO_FAC
L365B:
        ldx     FACEXTENSION
        stx     ARGEXTENSION
        ldx     #ARG
        lda     ARG
FADD2:
        tay
        beq     RTS3
        sec
        sbc     FAC
        beq     FADD3
        bcc     L367F
        sty     FAC
        ldy     ARGSIGN
        sty     FACSIGN
        eor     #$FF
        adc     #$00
        ldy     #$00
        sty     ARGEXTENSION
        ldx     #FAC
        bne     L3683
L367F:
        ldy     #$00
        sty     FACEXTENSION
L3683:
        cmp     #$F9
        bmi     FADD1
        tay
        lda     FACEXTENSION
        lsr     1,x
        jsr     SHIFT_RIGHT4
FADD3:
        bit     SGNCPR
        bpl     FADD4
        ldy     #FAC
        cpx     #ARG
        beq     L369B
        ldy     #ARG
L369B:
        sec
        eor     #$FF
        adc     ARGEXTENSION
        sta     FACEXTENSION
        IF CONFIG_SMALL == 0
        lda     4,y
        sbc     4,x
        sta     FAC+4
        ENDIF
        lda     3,y
        sbc     3,x
        sta     FAC+3
        lda     2,y
        sbc     2,x
        sta     FAC+2
        lda     1,y
        sbc     1,x
        sta     FAC+1

; ----------------------------------------------------------------------------
; NORMALIZE VALUE IN FAC
; ----------------------------------------------------------------------------
NORMALIZE_FAC1:
        bcs     NORMALIZE_FAC2
        jsr     COMPLEMENT_FAC
NORMALIZE_FAC2:
        ldy     #$00
        tya
        clc
L36C7:
        ldx     FAC+1
        bne     NORMALIZE_FAC4
        ldx     FAC+2
        stx     FAC+1
        ldx     FAC+3
        stx     FAC+2
        IF CONFIG_SMALL
        ldx     FACEXTENSION
        stx     FAC+3
        ELSE
        ldx     FAC+4
        stx     FAC+3
        ldx     FACEXTENSION
        stx     FAC+4
        ENDIF
        sty     FACEXTENSION
        adc     #$08
        IF CONFIG_2B
; bugfix?
; fix does not exist on AppleSoft 2
        cmp     #(MANTISSA_BYTES+1)*8
        ELSE
        cmp     #MANTISSA_BYTES*8
        ENDIF
        bne     L36C7

; ----------------------------------------------------------------------------
; SET FAC = 0
; (ONLY NECESSARY TO ZERO EXPONENT AND SIGN CELLS)
; ----------------------------------------------------------------------------
ZERO_FAC:
        lda     #$00
STA_IN_FAC_SIGN_AND_EXP:
        sta     FAC
STA_IN_FAC_SIGN:
        sta     FACSIGN
RTS3:
        rts

; ----------------------------------------------------------------------------
; ADD MANTISSAS OF FAC AND ARG INTO FAC
; ----------------------------------------------------------------------------
FADD4:
        adc     ARGEXTENSION
        sta     FACEXTENSION
        IF CONFIG_SMALL == 0
        lda     FAC+4
        adc     ARG+4
        sta     FAC+4
        ENDIF
        lda     FAC+3
        adc     ARG+3
        sta     FAC+3
        lda     FAC+2
        adc     ARG+2
        sta     FAC+2
        lda     FAC+1
        adc     ARG+1
        sta     FAC+1
        jmp     NORMALIZE_FAC5

; ----------------------------------------------------------------------------
; FINISH NORMALIZING FAC
; ----------------------------------------------------------------------------
NORMALIZE_FAC3:
        adc     #$01
        asl     FACEXTENSION
        IF CONFIG_SMALL == 0
        rol     FAC+4
        ENDIF
        rol     FAC+3
        rol     FAC+2
        rol     FAC+1
NORMALIZE_FAC4:
        bpl     NORMALIZE_FAC3
        sec
        sbc     FAC
        bcs     ZERO_FAC
        eor     #$FF
        adc     #$01
        sta     FAC
NORMALIZE_FAC5:
        bcc     L3764
NORMALIZE_FAC6:
        inc     FAC
        beq     OVERFLOW
        IF CONFIG_ROR_WORKAROUND == 0
        ror     FAC+1
        ror     FAC+2
        ror     FAC+3
		  IF CONFIG_SMALL == 0
		  ror     FAC+4
		  ENDIF
        ror     FACEXTENSION
        ELSE
        lda     #$00
        bcc     L372E
        lda     #$80
L372E:
        lsr     FAC+1
        ora     FAC+1
        sta     FAC+1
        lda     #$00
        bcc     L373A
        lda     #$80
L373A:
        lsr     FAC+2
        ora     FAC+2
        sta     FAC+2
        lda     #$00
        bcc     L3746
        lda     #$80
L3746:
        lsr     FAC+3
        ora     FAC+3
        sta     FAC+3
        lda     #$00
        bcc     L3752
        lda     #$80
L3752:
        lsr     FAC+4
        ora     FAC+4
        sta     FAC+4
        lda     #$00
        bcc     L375E
        lda     #$80
L375E:
        lsr     FACEXTENSION
        ora     FACEXTENSION
        sta     FACEXTENSION
        ENDIF
L3764:
        rts

; ----------------------------------------------------------------------------
; 2'S COMPLEMENT OF FAC
; ----------------------------------------------------------------------------
COMPLEMENT_FAC:
        lda     FACSIGN
        eor     #$FF
        sta     FACSIGN

; ----------------------------------------------------------------------------
; 2'S COMPLEMENT OF FAC MANTISSA ONLY
; ----------------------------------------------------------------------------
COMPLEMENT_FAC_MANTISSA:
        lda     FAC+1
        eor     #$FF
        sta     FAC+1
        lda     FAC+2
        eor     #$FF
        sta     FAC+2
        lda     FAC+3
        eor     #$FF
        sta     FAC+3
        IF CONFIG_SMALL == 0
        lda     FAC+4
        eor     #$FF
        sta     FAC+4
        ENDIF
        lda     FACEXTENSION
        eor     #$FF
        sta     FACEXTENSION
        inc     FACEXTENSION
        bne     RTS12

; ----------------------------------------------------------------------------
; INCREMENT FAC MANTISSA
; ----------------------------------------------------------------------------
INCREMENT_FAC_MANTISSA:
        IF CONFIG_SMALL == 0
        inc     FAC+4
        bne     RTS12
        ENDIF
        inc     FAC+3
        bne     RTS12
        inc     FAC+2
        bne     RTS12
        inc     FAC+1
RTS12:
        rts
OVERFLOW:
		import  I_RUNTIME_ERROR
        lda     #ERR_OVERFLOW
        jmp     RUNTIME_ERROR

; ----------------------------------------------------------------------------
; SHIFT 1,X THRU 5,X RIGHT
; (A) = NEGATIVE OF SHIFT COUNT
; (X) = POINTER TO BYTES TO BE SHIFTED
;
; RETURN WITH (Y)=0, CARRY=0, EXTENSION BITS IN A-REG
; ----------------------------------------------------------------------------
SHIFT_RIGHT1:
        ldx     #RESULT-1
SHIFT_RIGHT2:
        IF CONFIG_SMALL
        ldy     3,x
        ELSE
        ldy     4,x
        ENDIF
        sty     FACEXTENSION
        IF CONFIG_SMALL == 0
        ldy     3,x
        sty     4,x
        ENDIF
        ldy     2,x
        sty     3,x
        ldy     1,x
        sty     2,x
        ldy     SHIFTSIGNEXT
        sty     1,x

; ----------------------------------------------------------------------------
; MAIN ENTRY TO RIGHT SHIFT SUBROUTINE
; ----------------------------------------------------------------------------
SHIFT_RIGHT:
        adc     #$08
        bmi     SHIFT_RIGHT2
        beq     SHIFT_RIGHT2
        sbc     #$08
        tay
        lda     FACEXTENSION
        bcs     SHIFT_RIGHT5
        IF CONFIG_ROR_WORKAROUND == 0
LB588:
        asl     1,x
        bcc     LB58E
        inc     1,x
LB58E:
        ror     1,x
        ror     1,x

; ----------------------------------------------------------------------------
; ENTER HERE FOR SHORT SHIFTS WITH NO SIGN EXTENSION
; ----------------------------------------------------------------------------
SHIFT_RIGHT4:
        ror     2,x
        ror     3,x
          IF CONFIG_SMALL == 0
        ror     4,x
          ENDIF
        ror
        iny
        bne     LB588
        ELSE
L37C4:
        pha
        lda     1,x
        and     #$80
        lsr     1,x
        ora     1,x
        sta     1,x
        .byte   $24
SHIFT_RIGHT4:
        pha
        lda     #$00
        bcc     L37D7
        lda     #$80
L37D7:
        lsr     2,x
        ora     2,x
        sta     2,x
        lda     #$00
        bcc     L37E3
        lda     #$80
L37E3:
        lsr     3,x
        ora     3,x
        sta     3,x
        lda     #$00
        bcc     L37EF
        lda     #$80
L37EF:
        lsr     4,x
        ora     4,x
        sta     4,x
        pla
        php
        lsr
        plp
        bcc     L37FD
        ora     #$80
L37FD:
        iny
        bne     L37C4
        ENDIF
SHIFT_RIGHT5:
        clc
        rts

; ----------------------------------------------------------------------------
        IF CONFIG_SMALL
CON_ONE:
        .byte   $81,$00,$00,$00
POLY_LOG:
		.byte	$02
		.byte   $80,$19,$56,$62
		.byte   $80,$76,$22,$F3
		.byte   $82,$38,$AA,$40
CON_SQR_HALF:
		.byte   $80,$35,$04,$F3
CON_SQR_TWO:
		.byte   $81,$35,$04,$F3
CON_NEG_HALF:
		.byte   $80,$80,$00,$00
CON_LOG_TWO:
		.byte   $80,$31,$72,$18
        ELSE
CON_ONE:
        .byte   $81,$00,$00,$00,$00
POLY_LOG:
        .byte   $03
		.byte   $7F,$5E,$56,$CB,$79
		.byte   $80,$13,$9B,$0B,$64
		.byte   $80,$76,$38,$93,$16
        .byte   $82,$38,$AA,$3B,$20
CON_SQR_HALF:
        .byte   $80,$35,$04,$F3,$34
CON_SQR_TWO:
        .byte   $81,$35,$04,$F3,$34
CON_NEG_HALF:
        .byte   $80,$80,$00,$00,$00
CON_LOG_TWO:
        .byte   $80,$31,$72,$17,$F8
        ENDIF

; ----------------------------------------------------------------------------
; "LOG" FUNCTION
; ----------------------------------------------------------------------------
LOG:
        jsr     SIGN
        beq     GIQ
        bpl     LOG2
GIQ:
		import  I_RUNTIME_ERROR
        lda     #ERR_ILQTY
        jmp     RUNTIME_ERROR
LOG2:
        lda     FAC
        sbc     #$7F
        pha
        lda     #$80
        sta     FAC
        lda     #<CON_SQR_HALF
        ldy     #>CON_SQR_HALF
        jsr     FADD
        lda     #<CON_SQR_TWO
        ldy     #>CON_SQR_TWO
        jsr     FDIV
        lda     #<CON_ONE
        ldy     #>CON_ONE
        jsr     FSUB
        lda     #<POLY_LOG
        ldy     #>POLY_LOG
        jsr     POLYNOMIAL_ODD
        lda     #<CON_NEG_HALF
        ldy     #>CON_NEG_HALF
        jsr     FADD
        pla
        jsr     ADDACC
        lda     #<CON_LOG_TWO
        ldy     #>CON_LOG_TWO

; ----------------------------------------------------------------------------
; FAC = (Y,A) * FAC
; ----------------------------------------------------------------------------
FMULT:
        jsr     LOAD_ARG_FROM_YA

; ----------------------------------------------------------------------------
; FAC = ARG * FAC
; ----------------------------------------------------------------------------
FMULTT:
        bne     FMULTT1
        jmp		L3903
FMULTT1:
        jsr     ADD_EXPONENTS
        lda     #$00
        sta     RESULT
        sta     RESULT+1
        sta     RESULT+2
        IF CONFIG_SMALL == 0
        sta     RESULT+3
        ENDIF
        lda     FACEXTENSION
        jsr     MULTIPLY1
        IF CONFIG_SMALL == 0
        lda     FAC+4
        jsr     MULTIPLY1
        ENDIF
        lda     FAC+3
        jsr     MULTIPLY1
        lda     FAC+2
        jsr     MULTIPLY1
        lda     FAC+1
        jsr     MULTIPLY2
        jmp     COPY_RESULT_INTO_FAC

; ----------------------------------------------------------------------------
; MULTIPLY ARG BY (A) INTO RESULT
; ----------------------------------------------------------------------------
MULTIPLY1:
        bne     MULTIPLY2
        jmp     SHIFT_RIGHT1
MULTIPLY2:
        lsr
        ora     #$80
L38A7:
        tay
        bcc     L38C3
        clc
        IF CONFIG_SMALL == 0
        lda     RESULT+3
        adc     ARG+4
        sta     RESULT+3
        ENDIF
        lda     RESULT+2
        adc     ARG+3
        sta     RESULT+2
        lda     RESULT+1
        adc     ARG+2
        sta     RESULT+1
        lda     RESULT
        adc     ARG+1
        sta     RESULT
L38C3:
        IF CONFIG_ROR_WORKAROUND == 0
        ror     RESULT
        ror     RESULT+1
        	IF APPLE_BAD_BYTE
			; this seems to be a bad byte in the dump
		.byte	RESULT+2,RESULT+2 ; XXX BUG!
        	ELSE
        ror     RESULT+2
        	ENDIF
        	IF CONFIG_SMALL == 0
        ror     RESULT+3
        	ENDIF
        ror     FACEXTENSION
        ELSE
        lda     #$00
        bcc     L38C9
        lda     #$80
L38C9:
        lsr     RESULT
        ora     RESULT
        sta     RESULT
        lda     #$00
        bcc     L38D5
        lda     #$80
L38D5:
        lsr     RESULT+1
        ora     RESULT+1
        sta     RESULT+1
        lda     #$00
        bcc     L38E1
        lda     #$80
L38E1:
        lsr     RESULT+2
        ora     RESULT+2
        sta     RESULT+2
        lda     #$00
        bcc     L38ED
        lda     #$80
L38ED:
        lsr     RESULT+3
        ora     RESULT+3
        sta     RESULT+3
        lda     #$00
        bcc     L38F9
        lda     #$80
L38F9:
        lsr     FACEXTENSION
        ora     FACEXTENSION
        sta     FACEXTENSION
        ENDIF
        tya
        lsr
        bne     L38A7
L3903:
        rts

; ----------------------------------------------------------------------------
; UNPACK NUMBER AT (Y,A) INTO ARG
; ----------------------------------------------------------------------------
LOAD_ARG_FROM_YA:
        sta     INDEX
        sty     INDEX+1
        ldy     #BYTES_FP-1
        IF CONFIG_SMALL == 0
        lda     (INDEX),y
        sta     ARG+4
        dey
        ENDIF
        lda     (INDEX),y
        sta     ARG+3
        dey
        lda     (INDEX),y
        sta     ARG+2
        dey
        lda     (INDEX),y
        sta     ARGSIGN
        eor     FACSIGN
        sta     SGNCPR
        lda     ARGSIGN
        ora     #$80
        sta     ARG+1
        dey
        lda     (INDEX),y
        sta     ARG
        lda     FAC
        rts

; ----------------------------------------------------------------------------
; ADD EXPONENTS OF ARG AND FAC
; (CALLED BY FMULT AND FDIV)
;
; ALSO CHECK FOR OVERFLOW, AND SET RESULT SIGN
; ----------------------------------------------------------------------------
ADD_EXPONENTS:
        lda     ARG
ADD_EXPONENTS1:
        beq     ZERO
        clc
        adc     FAC
        bcc     L393C
        bmi     JOV
        clc
        .byte   $2C
L393C:
        bpl     ZERO
        adc     #$80
        sta     FAC
        bne     L3947
        jmp     STA_IN_FAC_SIGN
L3947:
        lda     SGNCPR
        sta     FACSIGN
        rts

; ----------------------------------------------------------------------------
; IF (FAC) IS POSITIVE, GIVE "OVERFLOW" ERROR
; IF (FAC) IS NEGATIVE, SET FAC=0, POP ONE RETURN, AND RTS
; CALLED FROM "EXP" FUNCTION
; ----------------------------------------------------------------------------
OUTOFRNG:
        lda     FACSIGN
        eor     #$FF
        bmi     JOV

; ----------------------------------------------------------------------------
; POP RETURN ADDRESS AND SET FAC=0
; ----------------------------------------------------------------------------
ZERO:
        pla
        pla
        jmp     ZERO_FAC
JOV:
        jmp     OVERFLOW

; ----------------------------------------------------------------------------
; MULTIPLY FAC BY 10
; ----------------------------------------------------------------------------
MUL10:
        jsr     COPY_FAC_TO_ARG_ROUNDED
        tax
        beq     L3970
        clc
        adc     #$02
        bcs     JOV
LD9BF:
        ldx     #$00
        stx     SGNCPR
        jsr     FADD2
        inc     FAC
        beq     JOV
L3970:
        rts

; ----------------------------------------------------------------------------
CONTEN:
        IF CONFIG_SMALL
        .byte   $84,$20,$00,$00
        ELSE
        .byte   $84,$20,$00,$00,$00
        ENDIF

; ----------------------------------------------------------------------------
; DIVIDE FAC BY 10
; ----------------------------------------------------------------------------
DIV10:
        jsr     COPY_FAC_TO_ARG_ROUNDED
        lda     #<CONTEN
        ldy     #>CONTEN
        ldx     #$00

; ----------------------------------------------------------------------------
; FAC = ARG / (Y,A)
; ----------------------------------------------------------------------------
DIV:
        stx     SGNCPR
        jsr     LOAD_FAC_FROM_YA
        jmp     FDIVT

; ----------------------------------------------------------------------------
; FAC = (Y,A) / FAC
; ----------------------------------------------------------------------------
FDIV:
        jsr     LOAD_ARG_FROM_YA

; ----------------------------------------------------------------------------
; FAC = ARG / FAC
; ----------------------------------------------------------------------------
FDIVT:
        bne     FDIVT1
        import  I_RUNTIME_ERROR
        lda     #ERR_DIVZERO
        jmp     RUNTIME_ERROR
FDIVT1:
        jsr     ROUND_FAC
        lda     #$00
        sec
        sbc     FAC
        sta     FAC
        jsr     ADD_EXPONENTS
        inc     FAC
        beq     JOV
        ldx     #-MANTISSA_BYTES
        lda     #$01
L39A1:
        ldy     ARG+1
        cpy     FAC+1
        bne     L39B7
        ldy     ARG+2
        cpy     FAC+2
        bne     L39B7
        ldy     ARG+3
        cpy     FAC+3
        IF CONFIG_SMALL == 0
        bne     L39B7
        ldy     ARG+4
        cpy     FAC+4
        ENDIF
L39B7:
        php
        rol
        bcc     L39C4
        inx
        sta     RESULT_LAST-1,x
        beq     L39F2
        bpl     L39F6
        lda     #$01
L39C4:
        plp
        bcs     L39D5
L39C7:
        asl     ARG_LAST
        IF CONFIG_SMALL == 0
        rol     ARG+3
        ENDIF
        rol     ARG+2
        rol     ARG+1
        bcs     L39B7
        bmi     L39A1
        bpl     L39B7
L39D5:
        tay
        IF CONFIG_SMALL == 0
        lda     ARG+4
        sbc     FAC+4
        sta     ARG+4
        ENDIF
        lda     ARG+3
        sbc     FAC+3
        sta     ARG+3
        lda     ARG+2
        sbc     FAC+2
        sta     ARG+2
        lda     ARG+1
        sbc     FAC+1
        sta     ARG+1
        tya
        jmp     L39C7
L39F2:
        lda     #$40
        bne     L39C4
L39F6:
        asl
        asl
        asl
        asl
        asl
        asl
        sta     FACEXTENSION
        plp
        jmp     COPY_RESULT_INTO_FAC

; ----------------------------------------------------------------------------
; COPY RESULT INTO FAC MANTISSA, AND NORMALIZE
; ----------------------------------------------------------------------------
COPY_RESULT_INTO_FAC:
        lda     RESULT
        sta     FAC+1
        lda     RESULT+1
        sta     FAC+2
        lda     RESULT+2
        sta     FAC+3
        IF CONFIG_SMALL == 0
        lda     RESULT+3
        sta     FAC+4
        ENDIF
        jmp     NORMALIZE_FAC2

; ----------------------------------------------------------------------------
; UNPACK (Y,A) INTO FAC
; ----------------------------------------------------------------------------
LOAD_FAC_FROM_YA:
        sta     INDEX
        sty     INDEX+1
        ldy     #MANTISSA_BYTES
        IF CONFIG_SMALL == 0
        lda     (INDEX),y
        sta     FAC+4
        dey
        ENDIF
        lda     (INDEX),y
        sta     FAC+3
        dey
        lda     (INDEX),y
        sta     FAC+2
        dey
        lda     (INDEX),y
        sta     FACSIGN
        ora     #$80
        sta     FAC+1
        dey
        lda     (INDEX),y
        sta     FAC
        sty     FACEXTENSION
        rts

; ----------------------------------------------------------------------------
; ROUND FAC, STORE IN TEMP2
; ----------------------------------------------------------------------------
STORE_FAC_IN_TEMP2_ROUNDED:
        ldx     #TEMP2
        .byte   $2C

; ----------------------------------------------------------------------------
; ROUND FAC, STORE IN TEMP1
; ----------------------------------------------------------------------------
STORE_FAC_IN_TEMP1_ROUNDED:
        ldx     #TEMP1X
        ldy     #$00
        beq     STORE_FAC_AT_YX_ROUNDED

; ----------------------------------------------------------------------------
; ROUND FAC, AND STORE AT (Y,X)
; ----------------------------------------------------------------------------
STORE_FAC_AT_YX_ROUNDED:
        jsr     ROUND_FAC
        stx     INDEX
        sty     INDEX+1
        ldy     #MANTISSA_BYTES
        IF CONFIG_SMALL == 0
        lda     FAC+4
        sta     (INDEX),y
        dey
        ENDIF
        lda     FAC+3
        sta     (INDEX),y
        dey
        lda     FAC+2
        sta     (INDEX),y
        dey
        lda     FACSIGN
        ora     #$7F
        and     FAC+1
        sta     (INDEX),y
        dey
        lda     FAC
        sta     (INDEX),y
        sty     FACEXTENSION
        rts

; ----------------------------------------------------------------------------
; COPY ARG INTO FAC
; ----------------------------------------------------------------------------
COPY_ARG_TO_FAC:
        lda     ARGSIGN
MFA:
        sta     FACSIGN
        ldx     #BYTES_FP
L3A7A:
        lda     SHIFTSIGNEXT,x
        sta     EXPSGN,x
        dex
        bne     L3A7A
        stx     FACEXTENSION
        rts

; ----------------------------------------------------------------------------
; ROUND FAC AND COPY TO ARG
; ----------------------------------------------------------------------------
COPY_FAC_TO_ARG_ROUNDED:
        jsr     ROUND_FAC
MAF:
        ldx     #BYTES_FP+1
L3A89:
        lda     EXPSGN,x
        sta     SHIFTSIGNEXT,x
        dex
        bne     L3A89
        stx     FACEXTENSION
RTS14:
        rts

; ----------------------------------------------------------------------------
; ROUND FAC USING EXTENSION BYTE
; ----------------------------------------------------------------------------
ROUND_FAC:
        lda     FAC
        beq     RTS14
        asl     FACEXTENSION
        bcc     RTS14

; ----------------------------------------------------------------------------
; INCREMENT MANTISSA AND RE-NORMALIZE IF CARRY
; ----------------------------------------------------------------------------
INCREMENT_MANTISSA:
        jsr     INCREMENT_FAC_MANTISSA
        bne     RTS14
        jmp     NORMALIZE_FAC6

; ----------------------------------------------------------------------------
; TEST FAC FOR ZERO AND SIGN
;
; FAC > 0, RETURN +1
; FAC = 0, RETURN  0
; FAC < 0, RETURN -1
; ----------------------------------------------------------------------------
SIGN:
        lda     FAC
        beq     RTS15
L3AA7:
        lda     FACSIGN
SIGN2:
        rol
        lda     #$FF
        bcs     RTS15
        lda     #$01
RTS15:
        rts

; ----------------------------------------------------------------------------
; "SGN" FUNCTION
; ----------------------------------------------------------------------------
SGN:
        jsr     SIGN

; ----------------------------------------------------------------------------
; CONVERT (A) INTO FAC, AS SIGNED VALUE -128 TO +127
; ----------------------------------------------------------------------------
FLOAT:
        sta     FAC+1
        lda     #$00
        sta     FAC+2
        ldx     #$88

; ----------------------------------------------------------------------------
; FLOAT UNSIGNED VALUE IN FAC+1,2 (HB-LB)
; (X) = EXPONENT
; ----------------------------------------------------------------------------
FLOAT1:
        lda     FAC+1
        eor     #$FF
        rol

; ----------------------------------------------------------------------------
; FLOAT UNSIGNED VALUE IN FAC+1,2 (HB-LB)
; (X) = EXPONENT
; C=0 TO MAKE VALUE NEGATIVE
; C=1 TO MAKE VALUE POSITIVE
; ----------------------------------------------------------------------------
FLOAT2:
 		lda     #$00
		IFNCONST CONFIG_SMALL
        sta     FAC+4
		ENDIF
        sta     FAC+3
LDB21:
        stx     FAC
        sta     FACEXTENSION
        sta     FACSIGN
        jmp     NORMALIZE_FAC1

; ----------------------------------------------------------------------------
; "ABS" FUNCTION
; ----------------------------------------------------------------------------
ABS:
        lsr     FACSIGN
        rts

; ----------------------------------------------------------------------------
; COMPARE FAC WITH PACKED # AT (Y,A)
; RETURN A=1,0,-1 AS (Y,A) IS <,=,> FAC
; ----------------------------------------------------------------------------
FCOMP:
        sta     DEST

; ----------------------------------------------------------------------------
; SPECIAL ENTRY FROM "NEXT" PROCESSOR
; "DEST" ALREADY SET UP
; ----------------------------------------------------------------------------
FCOMP2:
        sty     DEST+1
        ldy     #$00
        lda     (DEST),y
        iny
        tax
        beq     SIGN
        lda     (DEST),y
        eor     FACSIGN
        bmi     L3AA7
        cpx     FAC
        bne     L3B0A
        lda     (DEST),y
        ora     #$80
        cmp     FAC+1
        bne     L3B0A
        iny
        lda     (DEST),y
        cmp     FAC+2
        bne     L3B0A
        iny
        IF CONFIG_SMALL == 0
        lda     (DEST),y
        cmp     FAC+3
        bne     L3B0A
        iny
        ENDIF
        lda     #$7F
        cmp     FACEXTENSION
        lda     (DEST),y
        sbc     FAC_LAST
        beq     FCOMPEND
L3B0A:
        lda     FACSIGN
        bcc     L3B10
        eor     #$FF
L3B10:
        jmp     SIGN2
FCOMPEND
		rts

; ----------------------------------------------------------------------------
; QUICK INTEGER FUNCTION
;
; CONVERTS FP VALUE IN FAC TO INTEGER VALUE
; IN FAC+1...FAC+4, BY SHIFTING RIGHT WITH SIGN
; EXTENSION UNTIL FRACTIONAL BITS ARE OUT.
;
; THIS SUBROUTINE ASSUMES THE EXPONENT < 32.
; ----------------------------------------------------------------------------
QINT:
        lda     FAC
        beq     QINT3
        sec
        sbc     #120+8*BYTES_FP
        bit     FACSIGN
        bpl     L3B27
        tax
        lda     #$FF
        sta     SHIFTSIGNEXT
        jsr     COMPLEMENT_FAC_MANTISSA
        txa
L3B27:
        ldx     #FAC
        cmp     #$F9
        bpl     QINT2
        jsr     SHIFT_RIGHT
        sty     SHIFTSIGNEXT
L3B32:
        rts
QINT2:
        tay
        lda     FACSIGN
        and     #$80
        lsr     FAC+1
        ora     FAC+1
        sta     FAC+1
        jsr     SHIFT_RIGHT4
        sty     SHIFTSIGNEXT
        rts
		
; ----------------------------------------------------------------------------
; "INT" FUNCTION
;
; USES QINT TO CONVERT (FAC) TO INTEGER FORM,
; AND THEN REFLOATS THE INTEGER.
; ----------------------------------------------------------------------------
INT:
        lda     FAC
        cmp     #120+8*BYTES_FP
        bcs     RTS17
        jsr     QINT
        sty     FACEXTENSION
        lda     FACSIGN
        sty     FACSIGN
        eor     #$80
        rol
        lda     #120+8*BYTES_FP
        sta     FAC
        lda     FAC_LAST
        sta     CHARAC
        jmp     NORMALIZE_FAC1
QINT3:
        sta     FAC+1
        sta     FAC+2
        sta     FAC+3
        IF CONFIG_SMALL == 0
        sta     FAC+4
        ENDIF
        tay
RTS17:
        rts
        
; ----------------------------------------------------------------------------
; ADD (A) TO FAC
; ----------------------------------------------------------------------------
ADDACC:
        pha
        jsr     COPY_FAC_TO_ARG_ROUNDED
        pla
        jsr     FLOAT
        lda     ARGSIGN
        eor     FACSIGN
        sta     SGNCPR
        ldx     FAC
        jmp     FADDT

		IFCONST I_FIN_IMPORTED
; ----------------------------------------------------------------------------
; CONVERT STRING TO FP VALUE IN FAC
;
; STRING POINTER IN R0
; STRING LENGTH IN RA
; ----------------------------------------------------------------------------
		
FIN:
        ldy     #$00
        sty		RB
        ldx     #SERLEN-TMPEXP
L3B6F:
        sty     TMPEXP,x
        dex
        bpl     L3B6F
        jsr		CHRGET
        bcc     FIN2
        cmp     #$2D		; '-'
        bne     L3B7E
        stx     SERLEN
        beq     FIN1
L3B7E:
        cmp     #$2B		; '+'
        bne     FIN3
FIN1:
        jsr     CHRGET
FIN2:
        bcc     FIN9
FIN3:
        cmp     #$2E		; '.'
        beq     FIN10
        cmp     #$45		; 'e'
        bne     FIN7
        jsr     CHRGET
        bcc     FIN5
        cmp     #$2D		; '-'
        beq     L3BA6
        cmp     #$2D		; '-'
        beq     L3BA6
        cmp     #$2B		; '+'
        beq     FIN4
        cmp     #$2B		; '+'
        beq     FIN4
        bne     FIN6
L3BA6:
        IFNCONST CONFIG_ROR_WORKAROUND
        ror     EXPSGN
        ELSE
        lda     #$00
        bcc     L3BAC
        lda     #$80
L3BAC:
        lsr     EXPSGN
        ora     EXPSGN
        sta     EXPSGN
        ENDIF
FIN4:
        jsr     CHRGET
FIN5:
        bcc     GETEXP
FIN6:
        bit     EXPSGN
        bpl     FIN7
        lda     #$00
        sec
        sbc     EXPON
        jmp     FIN8
; ----------------------------------------------------------------------------
; FOUND A DECIMAL POINT
; ----------------------------------------------------------------------------
FIN10:
        IFNCONST CONFIG_ROR_WORKAROUND
        ror     LOWTR
        ELSE
        lda     #$00
        bcc     L3BC9
        lda     #$80
L3BC9:
        lsr     LOWTR
        ora     LOWTR
        sta     LOWTR
        ENDIF
        bit     LOWTR
        bvc     FIN1
; ----------------------------------------------------------------------------
; NUMBER TERMINATED, ADJUST EXPONENT NOW
; ----------------------------------------------------------------------------
FIN7:
        lda     EXPON
FIN8:
        sec
        sbc     INDX
        sta     EXPON
        beq     L3BEE
        bpl     L3BE7
L3BDE:
        jsr     DIV10
        inc     EXPON
        bne     L3BDE
        beq     L3BEE
L3BE7:
        jsr     MUL10
        dec     EXPON
        bne     L3BE7
L3BEE:
        lda     SERLEN
        bmi     L3BF3
        rts
L3BF3:
        jmp     NEGOP
; ----------------------------------------------------------------------------
; ACCUMULATE A DIGIT INTO FAC
; ----------------------------------------------------------------------------
FIN9:
        pha
        bit     LOWTR
        bpl     L3BFD
        inc     INDX
L3BFD:
        jsr     MUL10
        pla
        sec
        sbc     #$30
        jsr     ADDACC
        jmp     FIN1

; ----------------------------------------------------------------------------
; ACCUMULATE DIGIT OF EXPONENT
; ----------------------------------------------------------------------------
GETEXP:
        lda     EXPON
        cmp     #MAX_EXPON
        bcc     L3C2C
        IF CONFIG_10A
        lda     #$64
        ENDIF
        bit     EXPSGN
        IF CONFIG_10A
        bmi     L3C3A
        ELSE
        bmi     LDC70
        ENDIF
        jmp     OVERFLOW
LDC70:
        IFNCONST CONFIG_10A
        lda     #$0B
        ENDIF
L3C2C:
        asl
        asl
        clc
        adc     EXPON
        asl
        clc
        adc     (R0),y
        sec
        sbc     #$30
L3C3A:
        sta     EXPON
        jmp     FIN4

		; Custom chrget function		
		; String pointer already stored in (R0)		
		; String length in RA
		; Temp index RB must be set to 0 before first invocation
CHRGET	SUBROUTINE
		inc RB ; tmp index
		ldy RB
		cpy RA
		bcc .go
		beq .go
		; End of string, set zero flag and return
		lda #0
		rts
.go
		lda (R0),y
		; Set carry if not a number
		cmp #$3a
		bcs .q
		sec
		sbc #$30
		sec
		sbc #$d0
.q
		rts
		ENDIF
		
; ----------------------------------------------------------------------------
        
		IFCONST I_FOUT_IMPORTED
		IF CONFIG_SMALL
; these values are /1000 of what the labels say
CON_99999999_9:
        .byte   $91,$43,$4F,$F8
CON_999999999:
		.byte   $94,$74,$23,$F7
CON_BILLION:
        .byte   $94,$74,$24,$00
        ELSE
CON_99999999_9:
        .byte   $9B,$3E,$BC,$1F,$FD
CON_999999999:
        IF CONFIG_10A == 0
        .byte   $9E,$6E,$6B,$27,$FE
        ELSE
        .byte   $9E,$6E,$6B,$27,$FD
        ENDIF
CON_BILLION:
        .byte   $9E,$6E,$6B,$28,$00
        ENDIF

; ----------------------------------------------------------------------------
; CONVERT (FAC) TO STRING STARTING AT STACK
; RETURN WITH (Y,A) POINTING AT STRING
; ----------------------------------------------------------------------------
FOUT:
		ldy		#$00
		sty 	SHIFTSIGNEXT
        iny

; ----------------------------------------------------------------------------
; "STR$" FUNCTION ENTERS HERE, WITH (Y)=0
; SO THAT RESULT STRING STARTS AT STACK-1
; (THIS IS USED AS A FLAG)
; ----------------------------------------------------------------------------
FOUT1:
        lda     #$01
        bit     FACSIGN
        bpl     L3C73
        lda     #$2D
L3C73:
        sta     stack,y
        sta     FACSIGN
        sty     STRNG2
        iny
        lda     #$30
        ldx     FAC
        bne     L3C84
        jmp     FOUT4
L3C84:
        lda     #$00
        cpx     #$80
        beq     L3C8C
        bcs     L3C95
L3C8C:
        lda     #<CON_BILLION
        ldy     #>CON_BILLION
        jsr     FMULT
        IF CONFIG_SMALL
        lda     #-6 ; exponent adjustment
        ELSE
        lda     #-9
        ENDIF
L3C95:
        sta     INDX
; ----------------------------------------------------------------------------
; ADJUST UNTIL 1E8 <= (FAC) <1E9
; ----------------------------------------------------------------------------
L3C97:
        lda     #<CON_999999999
        ldy     #>CON_999999999
        jsr     FCOMP
        beq     L3CBE
        bpl     L3CB4
L3CA2:
        lda     #<CON_99999999_9
        ldy     #>CON_99999999_9
        jsr     FCOMP
        beq     L3CAD
        bpl     L3CBB
L3CAD:
        jsr     MUL10
        dec     INDX
        bne     L3CA2
L3CB4:
        jsr     DIV10
        inc     INDX
        bne     L3C97
L3CBB:
        jsr     FADDH
L3CBE:
		import  I_QINT
        jsr     QINT
; ----------------------------------------------------------------------------
; FAC+1...FAC+4 IS NOW IN INTEGER FORM
; WITH POWER OF TEN ADJUSTMENT IN TMPEXP
;
; IF -10 < TMPEXP > 1, PRINT IN DECIMAL FORM
; OTHERWISE, PRINT IN EXPONENTIAL FORM
; ----------------------------------------------------------------------------
        ldx     #$01
        lda     INDX
        clc
        adc     #3*BYTES_FP-5
        bmi     L3CD3
        cmp     #3*BYTES_FP-4
        bcs     L3CD4
        adc     #$FF
        tax
        lda     #$02
L3CD3:
        sec
L3CD4:
        sbc     #$02
        sta     EXPON
        stx     INDX
        txa
        beq     L3CDF
        bpl     L3CF2
L3CDF:
        ldy     STRNG2
        lda     #$2E
        iny
        sta     stack,y
        txa
        beq     L3CF0
        lda     #$30
        iny
        sta     stack,y
L3CF0:
        sty     STRNG2
; ----------------------------------------------------------------------------
; NOW DIVIDE BY POWERS OF TEN TO GET SUCCESSIVE DIGITS
; ----------------------------------------------------------------------------
L3CF2:
        ldy     #$00
LDD3A:
        ldx     #$80
L3CF6:
        lda     FAC_LAST
        clc
        IF CONFIG_SMALL == 0
        adc     DECTBL+3,y
        sta     FAC+4
        lda     FAC+3
        ENDIF
        adc     DECTBL+2,y
        sta     FAC+3
        lda     FAC+2
        adc     DECTBL+1,y
        sta     FAC+2
        lda     FAC+1
        adc     DECTBL,y
        sta     FAC+1
        inx
        bcs     L3D1A
        bpl     L3CF6
        bmi     L3D1C
L3D1A:
        bmi     L3CF6
L3D1C:
        txa
        bcc     L3D23
        eor     #$FF
        adc     #$0A
L3D23:
        adc     #$2F
        iny
        iny
        iny
        IF CONFIG_SMALL == 0
        iny
        ENDIF
        sty     VARPNT
        ldy     STRNG2
        iny
        tax
        and     #$7F
        sta     stack,y
        dec     INDX
        bne     L3D3E
        lda     #$2E
        iny
        sta     stack,y
L3D3E:
        sty     STRNG2
        ldy     VARPNT
        txa
        eor     #$FF
        and     #$80
        tax
        cpy     #DECTBL_END-DECTBL
        IF CONFIG_CBM_ALL
        beq     LDD96
        cpy     #$3C ; XXX
        ENDIF
        bne     L3CF6
; ----------------------------------------------------------------------------
; NINE DIGITS HAVE BEEN STORED IN STRING.  NOW LOOK
; BACK AND LOP OFF TRAILING ZEROES AND A TRAILING
; DECIMAL POINT.
; ----------------------------------------------------------------------------
LDD96:
        ldy     STRNG2
L3D4E:
        lda     stack,y
        dey
        cmp     #$30
        beq     L3D4E
        cmp     #$2E
        beq     L3D5B
        iny
L3D5B:
        lda     #$2B
        ldx     EXPON
        beq     L3D8F
        bpl     L3D6B
        lda     #$00
        sec
        sbc     EXPON
        tax
        lda     #$2D
L3D6B:
        sta     stack+2,y
        lda     #$45
        sta     stack+1,y
        txa
        ldx     #$2F
        sec
L3D77:
        inx
        sbc     #$0A
        bcs     L3D77
        adc     #$3A
        sta     stack+4,y
        txa
        sta     stack+3,y
        ;lda     #$00
        ;sta     stack+5,y
        ;beq     L3D94
        iny
        iny
        iny
        iny
        sty		stack
        jmp		L3D94
FOUT4:
        sta     stack,y
L3D8F:
        ;lda     #$00
        ;sta     stack,y
        sty		stack
L3D94:
        lda     #<stack
        ldy     #>stack
        rts

; ----------------------------------------------------------------------------
; POWERS OF 10 FROM 1E8 DOWN TO 1,
; AS 32-BIT INTEGERS, WITH ALTERNATING SIGNS
; ----------------------------------------------------------------------------
DECTBL:
        IF CONFIG_SMALL
        .byte   $FE,$79,$60 ; -100000
		.byte	$00,$27,$10 ; 10000
		.byte	$FF,$FC,$18 ; -1000
		.byte	$00,$00,$64 ; 100
		.byte	$FF,$FF,$F6 ; -10
		.byte	$00,$00,$01 ; 1
        ELSE
		.byte	$FA,$0A,$1F,$00	; -100000000
		.byte	$00,$98,$96,$80	; 10000000
		.byte	$FF,$F0,$BD,$C0	; -1000000
		.byte	$00,$01,$86,$A0	; 100000
		.byte	$FF,$FF,$D8,$F0	; -10000
		.byte   $00,$00,$03,$E8	; 1000
		.byte	$FF,$FF,$FF,$9C	; -100
		.byte   $00,$00,$00,$0A	; 10
		.byte	$FF,$FF,$FF,$FF	; -1
        ENDIF
DECTBL_END:
        IF CONFIG_CBM_ALL
		.byte	$FF,$DF,$0A,$80 ; TI$
		.byte	$00,$03,$4B,$C0
		.byte	$FF,$FF,$73,$60
		.byte	$00,$00,$0E,$10
		.byte	$FF,$FF,$FD,$A8
		.byte	$00,$00,$00,$3C
        ENDIF
        IF CONFIG_2
C_ZERO = CON_HALF + 2
        ENDIF

		ENDIF ; /IFCONST I_FOUT_IMPORTED

; ----------------------------------------------------------------------------
CON_HALF:
        IF CONFIG_SMALL
        .byte   $80,$00,$00,$00
        ELSE
        .byte   $80,$00,$00,$00,$00
        ENDIF

; ----------------------------------------------------------------------------
; "SQR" FUNCTION
; ----------------------------------------------------------------------------
SQR:
        jsr     COPY_FAC_TO_ARG_ROUNDED
        lda     #<CON_HALF
        ldy     #>CON_HALF
        jsr     LOAD_FAC_FROM_YA

; ----------------------------------------------------------------------------
; EXPONENTIATION OPERATION
;
; ARG ^ FAC  =  EXP( LOG(ARG) * FAC )
; ----------------------------------------------------------------------------
FPWRT:
        beq     EXP
        lda     ARG
        bne     L3DD5
        jmp     STA_IN_FAC_SIGN_AND_EXP
L3DD5:
        ldx     #TEMP3
        ldy     #$00
        jsr     STORE_FAC_AT_YX_ROUNDED
        lda     ARGSIGN
        bpl     L3DEF
        jsr     INT
        lda     #TEMP3
        ldy     #$00
        jsr     FCOMP
        bne     L3DEF
        tya
        ldy     CHARAC
L3DEF:
        jsr     MFA
        tya
        pha
        jsr     LOG
        lda     #TEMP3
        ldy     #$00
        jsr     FMULT
        jsr     EXP
        pla
        lsr
        bcc     L3E0F

; ----------------------------------------------------------------------------
; NEGATE VALUE IN FAC
; ----------------------------------------------------------------------------
NEGOP:
        lda     FAC
        beq     L3E0F
        lda     FACSIGN
        eor     #$FF
        sta     FACSIGN
L3E0F:
        rts

; ----------------------------------------------------------------------------
        IF CONFIG_SMALL
CON_LOG_E:
        .byte   $81,$38,$AA,$3B
POLY_EXP:
		.byte	$06
		.byte	$74,$63,$90,$8C
		.byte	$77,$23,$0C,$AB
		.byte	$7A,$1E,$94,$00
		.byte	$7C,$63,$42,$80
		.byte	$7E,$75,$FE,$D0
		.byte	$80,$31,$72,$15
		.byte	$81,$00,$00,$00
        ELSE
CON_LOG_E:
        .byte   $81,$38,$AA,$3B,$29
POLY_EXP:
        .byte   $07
		.byte	$71,$34,$58,$3E,$56
		.byte	$74,$16,$7E,$B3,$1B
		.byte	$77,$2F,$EE,$E3,$85
        .byte   $7A,$1D,$84,$1C,$2A
		.byte	$7C,$63,$59,$58,$0A
		.byte	$7E,$75,$FD,$E7,$C6
		.byte	$80,$31,$72,$18,$10
		.byte	$81,$00,$00,$00,$00
        ENDIF

; ----------------------------------------------------------------------------
; "EXP" FUNCTION
;
; FAC = E ^ FAC
; ----------------------------------------------------------------------------
EXP:
        lda     #<CON_LOG_E
        ldy     #>CON_LOG_E
        jsr     FMULT
        lda     FACEXTENSION
        adc     #$50
        bcc     L3E4E
        jsr     INCREMENT_MANTISSA
L3E4E:
        sta     ARGEXTENSION
        jsr     MAF
        lda     FAC
        cmp     #$88
        bcc     L3E5C
L3E59:
        jsr     OUTOFRNG
L3E5C:
        jsr     INT
        lda     CHARAC
        clc
        adc     #$81
        beq     L3E59
        sec
        sbc     #$01
        pha
        ldx     #BYTES_FP
L3E6C:
        lda     ARG,x
        ldy     FAC,x
        sta     FAC,x
        sty     ARG,x
        dex
        bpl     L3E6C
        lda     ARGEXTENSION
        sta     FACEXTENSION
        jsr     FSUBT
        jsr     NEGOP
        lda     #<POLY_EXP
        ldy     #>POLY_EXP
        jsr     POLYNOMIAL
        lda     #$00
        sta     SGNCPR
        pla
        jsr     ADD_EXPONENTS1
        rts

; ----------------------------------------------------------------------------
; ODD POLYNOMIAL SUBROUTINE
;
; F(X) = X * P(X^2)
;
; WHERE:  X IS VALUE IN FAC
;	Y,A POINTS AT COEFFICIENT TABLE
;	FIRST BYTE OF COEFF. TABLE IS N
;	COEFFICIENTS FOLLOW, HIGHEST POWER FIRST
;
; P(X^2) COMPUTED USING NORMAL POLYNOMIAL SUBROUTINE
; ----------------------------------------------------------------------------
POLYNOMIAL_ODD:
        sta     STRNG2
        sty     STRNG2+1
        jsr     STORE_FAC_IN_TEMP1_ROUNDED
        lda     #TEMP1X
        jsr     FMULT
        jsr     SERMAIN
        lda     #TEMP1X
        ldy     #$00
        jmp     FMULT

; ----------------------------------------------------------------------------
; NORMAL POLYNOMIAL SUBROUTINE
;
; P(X) = C(0)*X^N + C(1)*X^(N-1) + ... + C(N)
;
; WHERE:  X IS VALUE IN FAC
;	Y,A POINTS AT COEFFICIENT TABLE
;	FIRST BYTE OF COEFF. TABLE IS N
;	COEFFICIENTS FOLLOW, HIGHEST POWER FIRST
; ----------------------------------------------------------------------------
POLYNOMIAL:
        sta     STRNG2
        sty     STRNG2+1
SERMAIN:
        jsr     STORE_FAC_IN_TEMP2_ROUNDED
        lda     (STRNG2),y
        sta     SERLEN
        ldy     STRNG2
        iny
        tya
        bne     L3EBA
        inc     STRNG2+1
L3EBA:
        sta     STRNG2
        ldy     STRNG2+1
L3EBE:
        jsr     FMULT
        lda     STRNG2
        ldy     STRNG2+1
        clc
        adc     #BYTES_FP
        bcc     L3ECB
        iny
L3ECB:
        sta     STRNG2
        sty     STRNG2+1
        jsr     FADD
        lda     #TEMP2
        ldy     #$00
        dec     SERLEN
        bne     L3EBE
RTS19:
        rts
        ENDIF