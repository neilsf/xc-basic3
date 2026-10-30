	; Sprite attributes data order:
	; vert tile attr horiz
SPRATTR_TABLE EQU $0200
PPUCTRL		    EQU $2000
PPUMASK		    EQU $2001
PPUSTATUS     EQU $2002
OAMADDR       EQU $2003
PPUSCROLL     EQU $2005
PPUADDR		    EQU $2006
PPUDATA		    EQU $2007
OAMDMA        EQU $4014

	; After this macro call
    ; SN Reg will hold a 8-bit pointer to
    ; the sprite's attribute table
    ; relative to SPRATTR_TABLE
    MAC sprite ; @pull
	  IF	!FPULL
	    pla
	  ENDIF
	  asl
	  asl
	  sta SN
    ENDM

	MAC sprite_on_bg
	  ldx SN
	  lda SPRATTR_TABLE + 2,x
	  and #%11011111
	  sta SPRATTR_TABLE + 2,x
	ENDM
	
	MAC sprite_under_bg
	  ldx SN
      lda SPRATTR_TABLE + 2,x
	  ora #%00100000
	  sta SPRATTR_TABLE + 2,x
	ENDM

	MAC sprite_at; @pull
	  IF !FPULL
	    pla ; Y-pos
	  ENDIF
	  ldx SN
	  sta SPRATTR_TABLE,x
	  pla ; X-pos
	  sta SPRATTR_TABLE + 3,x
	ENDM
	
	MAC sprite_color ; @pull
	  IF !FPULL
	    pla
	  ENDIF
	  sta R0
	  ldx SN
	  lda SPRATTR_TABLE + 2,x
	  and #%11111100
	  ora R0
	  lda SPRATTR_TABLE + 2,x
	ENDM

	; @TODO - support 8x16 sprites
	MAC sprite_shape; @pull
	  IF !FPULL
	    pla
	  ENDIF
	  ldx SN
	  sta SPRATTR_TABLE + 1,x
	ENDM

	MAC sprite_xyflip
	ldx SN
	lda SPRATTR_TABLE + 2,x
	and #%00111111
	sta SPRATTR_TABLE + 2,x
	pla ; y-flip
	REPEAT 7
	  asl
	REPEND
	ora SPRATTR_TABLE + 2,x
	sta SPRATTR_TABLE + 2,x
	pla ; x-flip
	REPEAT 6
	  asl
	REPEND
	ora SPRATTR_TABLE + 2,x
	sta SPRATTR_TABLE + 2,x
    ENDM
    
	; DECLARE FUNCTION SPRITEHITBG AS BYTE (sprno AS BYTE) SHARED STATIC INLINE
	MAC F_spritehitbg_byte ; @pull @push
	IF !FPULL
	  pla
	ENDIF
	beq .cont ; Only Sprite 0 hit is supported
	lda #$00
	beq .q
.cont
	lda PPUSTATUS
	and #%01000000
	beq .q
	lda #$FF
.q
	IF !FPUSH
	  pha
	ENDIF
	ENDM
	
	MAC savesprite
	ENDM
