' VERA Registers
SHARED CONST VERA_ADDRL = $9F20
SHARED CONST VERA_ADDRM = $9F21
SHARED CONST VERA_ADDRH = $9F22
SHARED CONST VERA_DATA0 = $9F23
SHARED CONST VERA_CTRL  = $9F25

SUB X16_COPY_MV (srcAddr AS WORD, targetAddr AS LONG, cntBytes AS WORD) SHARED STATIC
  ASM
    sei
    lda #0
    sta {VERA_CTRL}
    lda {targetAddr} + 2
    and #%00000001
    ora #%00010000
    sta {VERA_ADDRH}
    lda {targetAddr} + 1
    sta {VERA_ADDRM}
    lda {targetAddr}
    sta {VERA_ADDRL}
    lda {srcAddr}
    sta R0
    lda {srcAddr} + 1
    sta R1
    ldx {cntBytes} + 1
    beq .1
.0
    ldy #0
.01
    lda (R0),y
    sta {VERA_DATA0}
    iny
    bne .01
    inc R1
    dex
    bne .0
.1
    lda {cntBytes}
    beq .q
    ldy #0
.11
    lda (R0),y
    sta {VERA_DATA0}
    iny
    cpy {cntBytes}
    bne .11
.q
    cli
  END ASM
END SUB

SUB X16_COPY_VM (srcAddr AS LONG, targetAddr AS WORD, cntBytes AS WORD) SHARED STATIC
  ASM
    sei
    lda #0
    sta {VERA_CTRL}
    lda {srcAddr} + 2
    and #%00000001
    ora #%00010000
    sta {VERA_ADDRH}
    lda {srcAddr} + 1
    sta {VERA_ADDRM}
    lda {srcAddr}
    sta {VERA_ADDRL}
    lda {targetAddr}
    sta R0
    lda {targetAddr} + 1
    sta R1
    ldx {cntBytes} + 1
    beq .1
.0
    ldy #0
.01
    lda {VERA_DATA0}
    sta (R0),y
    iny
    bne .01
    inc R1
    dex
    bne .0
.1
    lda {cntBytes}
    beq .q
    ldy #0
.11
    lda {VERA_DATA0}
    sta (R0),y
    iny
    cpy {cntBytes}
    bne .11
.q
    cli
  END ASM
END SUB

SUB X16_VFILL (vAddr AS LONG, cntBytes AS WORD, value AS BYTE) SHARED STATIC
  ASM
    sei
    lda #0
    sta {VERA_CTRL}
    lda {vAddr} + 2
    and #%00000001
    ora #%00010000
    sta {VERA_ADDRH}
    lda {vAddr} + 1
    sta {VERA_ADDRM}
    lda {vAddr}
    sta {VERA_ADDRL}
    lda {value}
    ldx {cntBytes} + 1
    beq .1
.0
    ldy #0
.01
    sta {VERA_DATA0}
    iny
    bne .01
    dex
    bne .0
.1
    ldy {cntBytes}
    beq .q
    ldy #0
.11
    sta {VERA_DATA0}
    iny
    cpy {cntBytes}
    bne .11
.q
    cli
  END ASM
END SUB