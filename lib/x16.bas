' VERA Registers
CONST VERA_ADDRL = $9F20
CONST VERA_ADDRM = $9F21
CONST VERA_ADDRH = $9F22
CONST VERA_DATA0 = $9F23
CONST VERA_CTRL  = $9F25

SUB VPOKE (addr AS LONG, value AS BYTE) SHARED STATIC
  ASM
    lda #0
    sta {VERA_CTRL}
    lda {addr} + 2
    and #%00000001
    sta {VERA_ADDRH}
    lda {addr} + 1
    sta {VERA_ADDRM}
    lda {addr}
    sta {VERA_ADDRL}
    lda {value}
    sta {VERA_DATA0}
  END ASM
END SUB

FUNCTION VPEEK AS BYTE (addr AS LONG) SHARED STATIC
  ASM
    lda #0
    sta {VERA_CTRL}
    lda {addr} + 2
    and #%00000001
    sta {VERA_ADDRH}
    lda {addr} + 1
    sta {VERA_ADDRM}
    lda {addr}
    sta {VERA_ADDRL}
    lda {VERA_DATA0}
    sta {VPEEK}
  END ASM
END FUNCTION

SUB MEMCPYMV (srcAddr AS WORD, targetAddr AS LONG, cntBytes AS WORD) SHARED STATIC
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

SUB MEMCPYVM (srcAddr AS LONG, targetAddr AS WORD, cntBytes AS WORD) SHARED STATIC
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

SUB VMEMSET (vAddr AS LONG, cntBytes AS WORD, value AS BYTE) SHARED STATIC
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

SUB MOUSEON () SHARED STATIC
  ASM
    sec
    jsr $FF5F ; screen_mode
    lda #1
    jsr $FF68 ; mouse_config
  END ASM
END SUB

SUB MOUSEOFF () SHARED STATIC
  ASM
    lda #0
    jsr $FF68 ; mouse_config
  END ASM
END SUB

SUB MOUSE_GET () STATIC
  ASM
    ldx #R0
    jsr $FF6B
  END ASM
END SUB

FUNCTION MOUSEX AS WORD () SHARED STATIC
  CALL MOUSE_GET()
  ASM
    lda R0
    sta {MOUSEX}
    lda R0 + 1
    sta {MOUSEX} + 1
  END ASM
END FUNCTION
  
FUNCTION MOUSEY AS WORD () SHARED STATIC
  CALL MOUSE_GET()
  ASM
    lda R0 + 2
    sta {MOUSEY}
    lda R0 + 3
    sta {MOUSEY} + 1
  END ASM
END FUNCTION

FUNCTION MOUSEBTN AS BYTE () SHARED STATIC
  CALL MOUSE_GET()
  ASM
    sta {MOUSEBTN}
  END ASM
END FUNCTION

SUB SETCLOCK (year AS BYTE, month AS BYTE, day AS BYTE, hour AS BYTE, min AS BYTE, sec AS BYTE) SHARED STATIC
  ASM
    lda {year}
    sta $02   ; r0L
    lda {month}
    sta $03   ; r0H
    lda {day}
    sta $04   ; r1L
    lda {hour}
    sta $05   ; r1H
    lda {min}
    sta $06   ; r2L
    lda {sec}
    sta $07   ; r2H
    jsr $FF4D ; clock_set_date_time
  END ASM
END SUB

FUNCTION CLOCK_YEAR AS BYTE () SHARED STATIC
  ASM
    jsr $FF50 ; clock_get_date_time
    lda $02   ; r0L
    sta {CLOCK_YEAR}
  END ASM
END FUNCTION

FUNCTION CLOCK_MONTH AS BYTE () SHARED STATIC
  ASM
    jsr $FF50 ; clock_get_date_time
    lda $03   ; r0H
    sta {CLOCK_MONTH}
  END ASM
END FUNCTION

FUNCTION CLOCK_DAY AS BYTE () SHARED STATIC
  ASM
    jsr $FF50 ; clock_get_date_time
    lda $04   ; r1L
    sta {CLOCK_DAY}
  END ASM
END FUNCTION

FUNCTION CLOCK_HOUR AS BYTE () SHARED STATIC
  ASM
    jsr $FF50 ; clock_get_date_time
    lda $05   ; r1H
    sta {CLOCK_HOUR}
  END ASM
END FUNCTION

FUNCTION CLOCK_MIN AS BYTE () SHARED STATIC
  ASM
    jsr $FF50 ; clock_get_date_time
    lda $06   ; r2L
    sta {CLOCK_MIN}
  END ASM
END FUNCTION

FUNCTION CLOCK_SEC AS BYTE () SHARED STATIC
  ASM
    jsr $FF50 ; clock_get_date_time
    lda $07   ; r2H
    sta {CLOCK_SEC}
  END ASM
END FUNCTION

FUNCTION ENTROPY AS LONG () SHARED STATIC
  ASM
    jsr $FECF ; entropy_get
    sta {ENTROPY}
    stx {ENTROPY} + 1
    sty {ENTROPY} + 2
  END ASM
END FUNCTION