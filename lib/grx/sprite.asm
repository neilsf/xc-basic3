	PROCESSOR 6502
	
SPRPOS    EQU $D000
SPRPOSX9  EQU $D010
SPRENABLE EQU $D015
SPRYEXP   EQU $D017
SPRPRIO	  EQU $D01B
SPRMULTI  EQU $D01C
SPRXEXP   EQU $D01D
SPRSPRC	  EQU $D01E
SPRBGC	  EQU $D01F
SPRMCLR1  EQU $D025
SPRMCLR2  EQU $D026
SPRCOLOR  EQU $D027

    IF USESPR
bittab_t  HEX 01 02 04 08 10 20 40 80
bittab_f  HEX FE FD FB F7 EF DF BF 7F
spritehit DC.B 0
sprbghit  DC.B 0
; Sprite collision refresh flag: 0 = Must reread collision 
sprcollr  DC.B 0
    ENDIF   
    
    ; After this macro call
    ; pseudo-register SN holds the sprite number (0 to 7)
    ; for all subcommands
    MAC sprite ; @pull
    IF	!FPULL
    pla
    ENDIF
    sta SN
    ENDM
    
    ; For all subcommands:
	; {1} = 255 if <n> is not constant
	; otherwise it holds sprite no
	
	MAC sprite_on
	lda SPRENABLE
	IF	{1} == 255
	ldx SN
	ora bittab_t,x
	ELSE 
	ora	#[1 << {1}]
	ENDIF
	sta SPRENABLE
	ENDM
	
	MAC sprite_off
	lda SPRENABLE
	IF	{1} == 255
	ldx SN
	and bittab_f,x
	ELSE 
	and	#[(1 << {1}) ^ $FF]
	ENDIF
	sta SPRENABLE
	ENDM

	MAC sprite_multi
	lda SPRMULTI
	IF	{1} == 255
	ldx SN
	ora bittab_t,x
	ELSE 
	ora	#[1 << {1}]
	ENDIF
	sta SPRMULTI
	ENDM
	
	MAC sprite_hires
	lda SPRMULTI
	IF	{1} == 255
	ldx SN
	and bittab_f,x
	ELSE 
	and	#[(1 << {1}) ^ $FF]
	ENDIF
	sta SPRMULTI
	ENDM
	
	MAC sprite_on_bg
	lda SPRPRIO
	IF	{1} == 255
	ldx SN
	and bittab_f,x
	ELSE 
	and	#[(1 << {1}) ^ $FF]
	ENDIF
	sta SPRPRIO
	ENDM
	
	MAC sprite_under_bg
	lda SPRPRIO
	IF	{1} == 255
	ldx SN
	ora bittab_t,x
	ELSE 
	ora	#[1 << {1}]
	ENDIF
	sta SPRPRIO
	ENDM
	
	MAC sprite_at
	IF	{1} == 255
	lda SN
	asl
	tax
	ELSE
	ldx #[{1} << 1]
	ENDIF
	pla ; Y pos
	sta SPRPOS + 1,x
	pla ; X pos hi
	tay
	pla ; X pos lo
	sta SPRPOS,x
	IF	{1} == 255
	ldx SN
	ELSE
	ldx #{1}
	ENDIF
	tya ; X pos lo
	beq .clear
.set
	lda SPRPOSX9
	ora bittab_t,x
	jmp .go
.clear
	lda SPRPOSX9
	and bittab_f,x
.go
	sta SPRPOSX9
	ENDM
	
	MAC sprite_color ; @pull
	IF !FPULL
	pla
	ENDIF
	IF	{1} == 255
	ldx SN
	sta SPRCOLOR,x
	ELSE
	sta [SPRCOLOR + {1}]
	ENDIF
	ENDM
	
	MAC sprite_shape
	lda #$F8
	sta R0
    lda KERNAL_SCREEN_ADDR
    clc
	adc #3
	sta R0 + 1
	pla
	IF	{1} == 255
	ldy SN
	ELSE
	ldy #{1}
	ENDIF
	sta (R0),y
	ENDM
	
	MAC sprite_xysize
	IF	{1} == 255
	ldx SN
	ELSE
	ldx #{1}
	ENDIF
	pla ; Y-expansion
	beq .clear
	lda SPRYEXP
	ora bittab_t,x
	bne .1 
.clear
    lda SPRYEXP
	and bittab_f,x
.1
	sta SPRYEXP
    pla ; X-expansion
    beq .clear2
    lda SPRXEXP
	ora bittab_t,x
	bne .2
.clear2
	lda SPRXEXP
	and bittab_f,x
.2
	sta SPRXEXP
	ENDM
	
	MAC sprite_multicolor ; @pull
	IF !FPULL
	pla
	ENDIF
	sta SPRMCLR2	
	pla	
	sta SPRMCLR1	
	ENDM
	
	MAC sprite_clear_hit
	lda #0
	sta sprcollr
	ENDM
	
	; DECLARE FUNCTION SPRITEHIT AS BYTE (sprno AS BYTE) SHARED STATIC INLINE
	MAC F_spritehit_byte ; @pull @push
	IF !FPULL
	pla
	ENDIF
	tax
	lda sprcollr
	bne .readcached
	lda SPRSPRC
	sta spritehit
	lda #1
	sta sprcollr
.readcached
	lda spritehit
	and bittab_t,x
	beq .q
	lda #$FF
.q
	IF !FPUSH
	pha
	ENDIF
	ENDM
	
	; DECLARE FUNCTION SPRITEHITBG AS BYTE (sprno AS BYTE) SHARED STATIC INLINE
	MAC F_spritebghit_byte ; @pull
	IF !FPULL
	pla
	ENDIF
	tax
	lda sprcollr
	bne .readcached
	lda SPRBGC
	sta sprbghit
	lda #1
	sta sprcollr
.readcached
	lda sprbghit
	and bittab_t,x
	beq .q
	lda #$FF
.q
	IF !FPUSH
	pha
	ENDIF
	ENDM