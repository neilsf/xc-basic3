NES_NMI:
	pha
  tax
  pha
  tay
  pha
  php
  ; Transfer sprite attributes to OAM Memory
  lda #<SPRATTR_TABLE
  sta OAMADDR
  lda #>SPRATTR_TABLE
  sta OAMDMA
  ; Set scroll registers
  lda PPUCTRL_SHADOW
  and #%11111100
  ora SCROLL9BITS
  sta PPUCTRL_SHADOW
  sta PPUCTRL
  bit PPUSTATUS
  lda XSCROLL
  sta PPUSCROLL
  lda YSCROLL
  sta PPUSCROLL
  ;
  inc FC
  ;
  plp
  pla
  tay
  pla
  tax
  pla
  rti
