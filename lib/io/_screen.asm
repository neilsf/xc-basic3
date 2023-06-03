atus    IF TARGET == c64
KERNAL_SCREEN_ADDR  EQU $0288
KERNAL_HOME         EQU $E566
SRVEC               EQU $D9
COLOR_RAM           EQU $D800
	ENDIF
    
	IF TARGET == c128
KERNAL_SCREEN_ADDR  EQU $0A3B
KERNAL_HOME         EQU $C150
SRVEC               EQU $E0
COLOR_RAM           EQU $D800
C128_VM1            EQU $0A2C
    ENDIF
    
	IF TARGET & c264
COLOR_RAM           EQU $0800    
	ENDIF
	
    IF TARGET & vic20
KERNAL_SCREEN_ADDR  EQU $0288
COLOR_RAM EQU $9600
      IF TARGET == vic20_8k
COLOR_RAM EQU $9400
      ENDIF
	ENDIF

; Various C-64 registers
VICII_MEMCONTROL EQU $D018
CIA_DIRECTIONALR EQU $DD00

; Various C264 registers
TED_CRSR_LO		 EQU $FF0D
TED_CRSR_HI		 EQU $FF0C


	; Print byte on stack as PETSCII string
	MAC printbyte ; @pull
	import I_STDLIB_PRINT_BYTE
	IF !FPULL
	pla
	ENDIF
	jsr STDLIB_PRINT_BYTE
	ENDM
	
	; Print int on stack as PETSCII string
	MAC printint ; @pull
	F_str@_int
	printstring
	ENDM
	
	; Print word on stack as PETSCII string
	MAC printword ; @pull
	F_str@_word
	printstring
	ENDM
	
	; Print word on stack as PETSCII string
	MAC printdecimal ; @pull
	import I_STDLIB_PRINT_DECIMAL 
	IF !FPULL
	pla
	sta R2 + 1
	pla
	sta R2
	ELSE
	sta R2
	sty R2 + 1
	ENDIF
	jsr STDLIB_PRINT_DECIMAL
	ENDM
	
	; Print string in memory (pointer on stack)
	MAC printstaticstring ; @pull
	IF !FPULL
	pla
	tay
	pla
	ENDIF
	import I_STDLIB_PRINTSTR
	jsr STDLIB_PRINTSTR
	ENDM
	
	; Print string on string stack and pull it off
	MAC printstring
	ldx SP
	inx
	txa
	ldy #>STRING_WORKAREA
	import I_STDLIB_PRINTSTR
	jsr STDLIB_PRINTSTR
	; Move stack pointer
	tya	
	clc	
	adc SP	
	sta SP
	ENDM
	
	; Print int on stack as PETSCII string
	MAC printlong ; @pull
	F_str@_long
	printstring
	ENDM
	
	MAC printfloat ; @pull
	import I_FPLIB
	import I_FOUT
	import I_STDLIB_PRINTSTR
	plfloattofac
	jsr FOUT
	jsr STDLIB_PRINTSTR
	ENDM 
	
	; Print tab character
	MAC printtab
	import I_STDLIB_TAB
	jsr STDLIB_TAB
	ENDM
	
	; Print a newline character
	MAC printnl
	lda #13
	kerncall KERNAL_CHROUT
	ENDM

; Move cursor to next tab
	IFCONST I_STDLIB_TAB_IMPORTED
STDLIB_TAB SUBROUTINE
	sec
	kerncall KERNAL_PLOT
	tya
	ldy #$ff
.1
	iny
	cmp.wy .tabs
	bcs .1
	cpy #3
	bne .2
	printnl
	rts
.2	lda.wy .tabs
	tay
	clc
	kerncall KERNAL_PLOT
	rts

.tabs HEX 0A 14 1E 28 00
	ENDIF

; print petscii string
; Pointer to string in AY
; At the end Y holds chars printed + 1
	IFCONST I_STDLIB_PRINTSTR_IMPORTED
STDLIB_PRINTSTR SUBROUTINE                  
	sta R0 	        ; store string start low byte
    sty R0 + 1      ; store string start high byte
    ldy #0
    lda (R0),y		; string length
    beq .2
    sta R2
    iny
.1:
    lda (R0),y      ; get byte from string 
    kerncall KERNAL_CHROUT
    iny
    cpy R2
    bcc .1
    beq .1
.2:
	rts
	ENDIF
	
; convert byte to decimal petscii in YXA
	IFCONST I_STDLIB_BYTE_TO_PETSCII_IMPORTED
STDLIB_BYTE_TO_PETSCII SUBROUTINE
	ldy #$2f
  	ldx #$3a
  	sec
.1: iny
  	sbc #100
  	bcs .1
.2: dex
  	adc #10
  	bmi .2
  	adc #$2f
  	rts
  	ENDIF
  	
; print byte type as decimal
	IFCONST I_STDLIB_PRINT_BYTE_IMPORTED
	import I_STDLIB_BYTE_TO_PETSCII
STDLIB_PRINT_BYTE SUBROUTINE
	ldy #$00
	sty R0 ; has a digit been printed?
	jsr STDLIB_BYTE_TO_PETSCII
	pha
	tya
	cmp #$30
	beq .skip                                      
	kerncall KERNAL_CHROUT
	inc R0
.skip
	txa
	cmp #$30
	bne .printit
	ldy R0
	beq .skip2
.printit	
	kerncall KERNAL_CHROUT
.skip2
	pla
	kerncall KERNAL_CHROUT
	rts
	ENDIF
	
	IFCONST I_STDLIB_PRINT_DECIMAL_IMPORTED
STDLIB_PRINT_DECIMAL SUBROUTINE
	ldx #1
.1
	lda R2,x
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$30
	kerncall KERNAL_CHROUT
	lda R2,x
	and #%00001111
	adc #$30
	kerncall KERNAL_CHROUT
	dex
	bpl .1
	rts
	ENDIF
	
	MAC locate  ; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	pla
	tay
	clc
	kerncall KERNAL_PLOT
	ENDM
	
	; DECLARE FUNCTION CSRLIN AS BYTE () SHARED STATIC INLINE
	MAC F_csrlin  ; @push
	sec
	kerncall KERNAL_PLOT
	txa
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	;DECLARE FUNCTION POS AS BYTE () SHARED STATIC INLINE
	MAC F_pos ; @push
	sec
	kerncall KERNAL_PLOT
	tya
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; [Color,] Char, Col, Row pushed on stack
	; {1} = 1 color was pushed
	MAC charat ; @pull
	IF !FPULL
	pla
	ENDIF
	; Commander X16
	IF TARGET == x16
	  tay
	  pla
	  tax
	  clc
	  import I_VERA_SETADDR
	  jsr VERA_SETADDR
	  pla
	  sta VERA_DATA0
	  IF {1} == 1 ; Color was provided
	    pla
	    sta VERA_DATA0
	  ENDIF
	; All other targets
	ELSE  
	  import I_CALC_SCRROWPTR
	  jsr CALC_SCRROWPTR
	  pla
	  tay
	  pla
	  sta (R0),y
	  IF {1} == 1 ; Color was provided
		pla
        ; Not MEGA65 and not PET
		IF TARGET != mega65 && ((TARGET & pet) == 0)
		  tax
		  lda R0 + 1
		  sec
		  IF TARGET & c264
			sbc #$0C
		  ELSE
			sbc KERNAL_SCREEN_ADDR
		  ENDIF
		  clc
		  adc #>COLOR_RAM
		  sta R0 + 1
		  txa
		  sta (R0),y
	    ENDIF
        ; MEGA65
	    IF TARGET == mega65
          tax
          ; Store color ram base addr ($0001F800) + relative from screen
          lda R0
          sta R4
          lda R0 + 1
          clc
          adc #$F0
          sta R4 + 1
          lda #$01
          sta R4 + 2
          lda #0
          sta R4 + 3
          tya
          taz
          txa
          sta_indz R4
        ENDIF
      ENDIF
	ENDIF
	ENDM
	
	; [Color,] Col, Row pushed on stack
	; String on string stack
	MAC textat ; @pull
	IF !FPULL
	pla
	ENDIF
	; Commander X16
	IF TARGET == x16
	  tay
	  pla
	  tax
	  clc
	  import I_VERA_SETADDR
	  import I_VERA_MOV_STRING  
	  jsr VERA_SETADDR
	  ; override increment value to 2
	  lda #%00100001
	  sta VERA_ADDR + 2
	  jsr VERA_MOV_STRING
	  IF {1} == 1; Color was provided
	    pla
	    ; Decrement VERA addr by 1 ...
	    ldy #%00011001
	    sty VERA_ADDR + 2
	    ldy VERA_DATA0
	    ; .. Then by 2 at each subsequent write
	    ldy #%00101001
	    sty VERA_ADDR + 2
	    ldx R0
.loop
	    beq .q
	    sta VERA_DATA0
	    dex
	    jmp .loop
.q
	  ENDIF
    ; All other targets
	ELSE
	import I_CALC_SCRROWPTR
	jsr CALC_SCRROWPTR
	pla
	clc
	adc R0
	sta R0
	bcc .2
	inc R0 + 1
.2
	lda #$60
	import I_STRREMOV_SC
	jsr STRREMOV_SC
	IF {1} == 1; Color was provided
      pla
      IF TARGET == mega65
        tax
        ; Store color ram base addr ($0001F800) + relative from screen
        lda R0
        sta R4
        lda R0 + 1
        clc
        adc #$F0
        sta R4 + 1
        lda #$01
        sta R4 + 2
        lda #0
        sta R4 + 3
        txa
        DC.B $AB, R3, $00 ; ldz R3
.loop2:
        sta_indz R4  ; sta [R4],z
        dez          ; dez
        bpl .loop2
      ENDIF
      IF TARGET != mega65 && ((TARGET & pet) == 0)
        tax
        lda R0 + 1
        sec
        IF TARGET & c264 
        sbc #$0C  ; high byte is always 0C on plus4
        ELSE
        sbc KERNAL_SCREEN_ADDR
        ENDIF
        clc
        adc #>COLOR_RAM
        sta R0 + 1
        lda R3
        tay
        dey
        txa
.loop
        sta (R0),y
        dey
        bpl .loop
      ENDIF
	ENDIF
    ENDIF
	ENDM
	
	; Calculates a pointer to screen row
	; Row number in A
	; Outputs pointer in R0
	IFCONST I_CALC_SCRROWPTR_IMPORTED
CALC_SCRROWPTR SUBROUTINE
	; 22-column screen
	IF TARGET & vic20
		REPEAT 2
		asl
		REPEND
		tax		; A * 4
		sta R0
		lda #0
		sta R0 + 1
		REPEAT 2
		asl R0
		rol R0 + 1
		REPEND ; A * 16
		txa
		clc
		adc R0
		sta R0
		lda #0
		adc R0 + 1
		sta R0 + 1
		txa
		lsr
		clc
		adc R0
		sta R0
		lda #0
		adc R0 + 1
	; 40 or 80-column screen
	ELSE
	  	REPEAT 3
		asl
		REPEND
		pha		; A * 8
		sta R0
		lda #0
		sta R0 + 1
		REPEAT 2
		asl R0
		rol R0 + 1
		REPEND	; A * 32
		pla
		; A * 32 + A * 8 = A * 40
		clc
		adc R0
		sta R0
		lda #$00
		adc R0 + 1
		IF TARGET == pet8032 || TARGET = mega65 || TARGET == x16; 80-column machines
		sta R0 + 1
		asl R0
		rol R0 + 1
		lda R0 + 1
		ENDIF
	ENDIF
	IF TARGET & pet
	adc #$80 ; high byte is always 08 on a PET
	ENDIF
	IF TARGET & c264 
	adc #$0c ; high byte is always 0C on plus4
	ENDIF
    IF TARGET == mega65 
	adc #$08 ; // TODO implement relocatable screen
	ENDIF
	IF (TARGET == c64) || (TARGET == c128) || (TARGET & vic20)
	adc KERNAL_SCREEN_ADDR
	ENDIF
	sta R0 + 1
	rts
	ENDIF
			
	; Set Video Matrix Base Address
	MAC screen ; @pull
	IF !FPULL
	pla
	ENDIF
    IF TARGET == x16
    clc
    jsr KERNAL_SCREENMODE
    ENDIF
    IF TARGET == c64 || TARGET == c128
	asl
	asl
	sta KERNAL_SCREEN_ADDR
	pha
	lda CIA_DIRECTIONALR
	and #%00000011
	eor #%00000011
	REPEAT 6
	asl
	REPEND
	adc KERNAL_SCREEN_ADDR
	sta KERNAL_SCREEN_ADDR
	pla
	asl
	asl
	sta R0
	lda VICII_MEMCONTROL
	and #%00001111
	ora R0
	sta VICII_MEMCONTROL
    IF TARGET == c64
	import I_RESET_SCRVECTORS
	jsr RESET_SCRVECTORS
	ELSE
    jsr $CA24
    jsr KERNAL_HOME
    ENDIF
    ENDIF
	ENDM
	
	IFCONST I_RESET_SCRVECTORS_IMPORTED
RESET_SCRVECTORS SUBROUTINE
	lda KERNAL_SCREEN_ADDR
	ora #$80
	tay
	lda #0
	tax
.loop
	sty SRVEC,x
	clc
	adc #$28
	bcc .skip
	iny
.skip
	inx
	cpx #$1a
	bne .loop
	lda #$ff
	sta SRVEC,x
	jmp KERNAL_HOME
	ENDIF
	
	MAC border ; @fpull	
	
	IF !FPULL
	pla
	ENDIF
	
	IF TARGET == c64 || TARGET == c128
	sta VICII_BORDER
	ENDIF
	
	IF TARGET & vic20
	sta R0
	lda VICI_BORDER_BG
	and #%11111000
	ora R0
	sta VICI_BORDER_BG
	ENDIF
	
	IF TARGET & c264 
	sta R0
	pla
	asl
	asl
	asl
	asl
	ora R0
	sta TED_BORDER
	ENDIF
    
	IF TARGET == mega65
    sta_far $0FFD3020
	ENDIF
    
	IF TARGET == x16
	sta VERA_BORDER
	ENDIF
	
	ENDM
	
	MAC background ; @fpull	
	
    IF !FPULL
    pla
    ENDIF
    
    IF TARGET == c64 || TARGET == c128
    sta VICII_BACKGROUND
    ENDIF
    
    IF TARGET & vic20
    asl
    asl
    asl
    asl
    sta R0
    lda VICI_BORDER_BG
    and #%00001111
    ora R0
    sta VICI_BORDER_BG
    ENDIF
    
    IF TARGET & c264 
    sta R0
    pla
    asl
    asl
    asl
    asl
    ora R0
    sta TED_BACKGROUND
    ENDIF
    
    IF TARGET == mega65
    sta_far $0FFD3021
	ENDIF
    
	IF TARGET == x16 
    ;
    ENDIF
	
	ENDM