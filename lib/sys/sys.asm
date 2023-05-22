	; XC=BASIC system functions
	IF TARGET == c64 || TARGET & vic20 || TARGET == mega65
SAREG EQU $030C
SXREG EQU $030D 
SYREG EQU $030E 
SPREG EQU $030F
	ENDIF
	IF TARGET & c264
SAREG EQU $07F2
SXREG EQU $07F3
SYREG EQU $07F4
SPREG EQU $07F5
	ENDIF
	
	IF TARGET == c128
MMU EQU $FF00
INIT_STATUS EQU $0A04
	ENDIF
	
	IF TARGET == c64 || TARGET & vic20 || TARGET == c128 || TARGET == mega65
JIFFY EQU $A0
	ENDIF
	IF TARGET & c264
JIFFY EQU $A3
	ENDIF
	IF TARGET >= pet && TARGET < mega65
JIFFY EQU $8D
	ENDIF

	; Initial code that runs when the program is started
	MAC xbegin
	spreset
	framereset
	IF TARGET == c64
		; Bank out BASIC ROM
		lda $01
		and #%11111110
		sta $01
	ENDIF
    IF TARGET == mega65
        lda $01    
        pha
        lda #$35
        sta $01
        ;Set BP to $BD00
        ;lda #$BD
        ;tab
    ENDIF
	IF TARGET == c128
		; Set up MMU
		lda #%001110
		sta MMU
		; Disable irq based screen editor
		lda #$ff
		sta $D8
		; Disable BASIC IRQ
		lda INIT_STATUS
		and #%11111110
		sta INIT_STATUS
	ENDIF
    IF USEIRQ == 1
		jsr IRQSETUP
	ENDIF
	; Init FP workspace
	ldx #[TEMP3 - CHARAC + 1]
	lda #0
.1
	sta CHARAC,x
	dex
	bne .1
	ENDM
	
	; Final code that runs when the program is terminated
	MAC xend
	IF USEIRQ == 1
	jsr IRQRESET
	ENDIF
	IF TARGET == c64
        ; Bank in BASIC ROM
        lda $01
        ora #%00000001         
        sta $01
	ENDIF
    IF TARGET == mega65
        pla
        sta $01
        ; Set BP to $0000
        ;lda #$00
        ;tab
    ENDIF
	IF TARGET == c128
	; Reset MMU
	lda #%0
	sta MMU
    ; Enable irq based screen editor
	lda #$00
	sta $D8
     ; Enable BASIC IRQ
    lda INIT_STATUS
    ora #1
    sta INIT_STATUS
	ENDIF
	; Do BASIC start
	IF TARGET & vic20
	jmp ($C002)
	ENDIF
	IF TARGET & c264
	jmp $8003
	ENDIF
	IF TARGET == c64
	jmp ($A002)
	ENDIF
	IF TARGET == c128
	jmp ($0A00)
    ENDIF
	IF TARGET & pet && TARGET < pet4
	jmp $C389
	ENDIF
	IF TARGET & pet && TARGET >= pet4
	jmp $B3FF
	ENDIF
    IF TARGET == mega65
    rts
    ENDIF
	ENDM
	
	; DECLARE FUNCTION TI AS LONG () SHARED STATIC INLINE
	MAC F_ti ; @push
	IF !USEIRQ
    sei
    ENDIF
	lda JIFFY + 2
	IF !FPUSH
	pha
	lda JIFFY + 1
	pha
	lda JIFFY
	pha
	ELSE
	ldy JIFFY + 1
	ldx JIFFY
	ENDIF
	IF !USEIRQ
    cli
    ENDIF
	ENDM
	
	; SYS Command
	; Use SYS 1 for fast call, SYS 0 for regular call
	MAC sys ; @pull
	IF !FPULL
	pla
	sta .jsr + 2
	pla
	sta .jsr + 1
	ELSE
	sta .jsr + 1
	sty .jsr + 2
	ENDIF
	IF {1} == 0
	lda SPREG
	pha
	lda SAREG
	ldx SXREG
	ldy SYREG
	plp
	ENDIF
.jsr	
	jsr $FFFF
	IF {1} == 0
	php
	sta SAREG
	stx SXREG
	sty SYREG
	pla
	sta SPREG
	ENDIF
	ENDM
	
	; SYS Command with constant address
	; Use SYS <addr>, 1 for fast call, SYS <addr>, 0 for regular call
	MAC sys_constaddr
	IF {2} == 0
	lda SPREG
	pha
	lda SAREG
	ldx SXREG
	ldy SYREG
	plp
	ENDIF
.jsr	
	jsr {1}
	IF {2} == 0
	php
	sta SAREG
	stx SXREG
	sty SYREG
	pla
	sta SPREG
	ENDIF
	ENDM
	
	MAC wait ; @pull
.MASK EQU R2
.TRIG EQU R3
	IF !FPULL
	pla
	sta .loop + 2
	pla
	sta .loop + 1
	ELSE
	sta .loop + 1
	sty .loop + 2
	ENDIF
	pla
	sta .MASK
	pla
	sta .TRIG
.loop
	lda.w $0000
	eor .TRIG
	and .MASK
	beq .loop
	ENDM