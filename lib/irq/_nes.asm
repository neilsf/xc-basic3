NES_NMI SUBROUTINE
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
  ; Perform buffered draw
  ldx #DRAW_BUFFER
.loop  
  lda $00,x
  beq .skip_one
  bmi .vertical
  lda PPUCTRL_SHADOW
  and #%11111011
  sta PPUCTRL_SHADOW
  sta PPUCTRL
  jmp .draw
.vertical
  lda PPUCTRL_SHADOW
  ora #%00000100
  sta PPUCTRL_SHADOW
  sta PPUCTRL
.draw
  lda PPUSTATUS
  inx
  lda $00,x
  sta PPUADDR
  inx
  lda $00,x
  sta PPUADDR
  inx
  lda $00,x
  sta R0
  inx
  lda $00,x
  sta R0 + 1
  inx
  lda $00,x
  sta R2
  ldy #0
.inner
  lda (R0),y
  sta PPUDATA
  iny
  cpy R2
  bne .inner
  jmp .2
.skip_one
  inx
  inx
  inx
  inx
  inx
.2
  inx
  bne .loop
  ; Reset draw buffer ptr and invalidate draw buffer
  lda #DRAW_BUFFER
  sta NEXTBUFADDR
  lda #0
  sta DRAW_BUFFER
  sta DRAW_BUFFER + 6
  sta DRAW_BUFFER + 12
  sta DRAW_BUFFER + 18
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
  ; Update frame counter
  inc FC
  ;
  plp
  pla
  tay
  pla
  tax
  pla
  rti
