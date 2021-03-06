' *
' * PLASMA Effect
' *
' * This program demonstrates the optimizing
' * capabilities of XC=BASIC - a BASIC cross compiler for the C64.
' *
' * (w)2001 by groepaz/hitmen
' *
' * Porting history:
' *
' * -> Ported to CC65 by Ullrich von Bassewitz
' * -> Ported to KickC by Jesper Gravgaard
' * -> Ported to XC=BASIC by Csaba Fekete

CONST SC1 = $2800
CONST SC2 = $2c00
CONST CHARSET = $2000
CONST BORDER = $d020
CONST BACKGR = $d021
CONST COLOR = $d800

DIM sntable(256) AS BYTE @lab_sntable
DIM bittab(8) AS BYTE @lab_bittab

DIM g_c1a AS BYTE FAST
DIM g_c1b AS BYTE FAST
DIM g_c2a AS BYTE FAST
DIM g_c2b AS BYTE FAST

RANDOMIZE TI()

g_c1a = 0
g_c1b = 0
g_c2a = 0
g_c2b = 0

SUB doplasma (sc AS WORD) STATIC
  
  DIM xbuf(40) AS BYTE
  DIM ybuf(25) AS BYTE
  DIM i AS BYTE FAST
  DIM x AS BYTE FAST
  DIM y AS BYTE FAST
  DIM c1a AS BYTE FAST
  DIM c1b AS BYTE FAST
  DIM c2a AS BYTE FAST
  DIM c2b AS BYTE FAST
  DIM cursor AS WORD
  
  c1a = g_c1a : c1b = g_c1b
  
  FOR i = 0 TO 24
    ybuf(i) = sntable(c1a) + sntable(c1b)
    c1a = c1a + 4
    c1b = c1b + 9
  NEXT
  g_c1a = g_c1a + 3
  g_c1b = g_c1b - 5
  
  c2a = g_c2a : c2b = g_c2b
  
  FOR i = 0 TO 39
    xbuf(i) =  sntable(c2a) + sntable(c2b)
    c2a = c2a + 3
    c2b = c2b + 7
  NEXT
  
  g_c2a = g_c2a + 2
  g_c2b = g_c2b - 2
  
  cursor = sc
  FOR y = 0 TO 24
    FOR x = 0 TO 39
      POKE cursor, xbuf(x) + ybuf(y)
      cursor = cursor + 1
    NEXT
  NEXT
  
END SUB


SUB makecharset () STATIC
  
  DIM c AS WORD
  DIM s AS BYTE
  DIM b AS BYTE
  
  PRINT "{RED}{CLR}"
  TEXTAT 15, 10, "loading..."
  
  FOR c = 0 TO 255
    s = sntable(c)
    FOR i AS BYTE = 0 TO 7
      b = 0
      FOR ii AS BYTE = 0 TO 7
        IF CBYTE(RNDL()) > s THEN b = b OR bittab(ii)
      NEXT ii
      POKE CHARSET + c * 8 + i , b
    NEXT i
  NEXT c

END SUB

POKE BORDER, 7 : poke BACKGR, 7
CALL makecharset ()
MEMSET COLOR, 1000, 2
l:
  CALL doplasma(SC1)
  POKE $d018, %10101000
  CALL doplasma(SC2)
  POKE $d018, %10111000
  GOTO l

lab_bittab:
DATA AS BYTE 1, 2, 4, 8, 16, 32, 64, 128

lab_sntable:
DATA AS BYTE $7f, $82, $85, $88, $8b, $8f, $92, $95, $98, $9b, $9e, $a1, $a4, $a7, $aa, $ad
DATA AS BYTE $b0, $b3, $b6, $b8, $bb, $be, $c1, $c3, $c6, $c8, $cb, $cd, $d0, $d2, $d5, $d7
DATA AS BYTE $d9, $db, $dd, $e0, $e2, $e4, $e5, $e7, $e9, $eb, $ec, $ee, $ef, $f1, $f2, $f4
DATA AS BYTE $f5, $f6, $f7, $f8, $f9, $fa, $fb, $fb, $fc, $fd, $fd, $fe, $fe, $fe, $fe, $fe
DATA AS BYTE $ff, $fe, $fe, $fe, $fe, $fe, $fd, $fd, $fc, $fb, $fb, $fa, $f9, $f8, $f7, $f6
DATA AS BYTE $f5, $f4, $f2, $f1, $ef, $ee, $ec, $eb, $e9, $e7, $e5, $e4, $e2, $e0, $dd, $db
DATA AS BYTE $d9, $d7, $d5, $d2, $d0, $cd, $cb, $c8, $c6, $c3, $c1, $be, $bb, $b8, $b6, $b3
DATA AS BYTE $b0, $ad, $aa, $a7, $a4, $a1, $9e, $9b, $98, $95, $92, $8f, $8b, $88, $85, $82
DATA AS BYTE $7f, $7c, $79, $76, $73, $6f, $6c, $69, $66, $63, $60, $5d, $5a, $57, $54, $51
DATA AS BYTE $4e, $4b, $48, $46, $43, $40, $3d, $3b, $38, $36, $33, $31, $2e, $2c, $29, $27
DATA AS BYTE $25, $23, $21, $1e, $1c, $1a, $19, $17, $15, $13, $12, $10, $0f, $0d, $0c, $0a
DATA AS BYTE $09, $08, $07, $06, $05, $04, $03, $03, $02, $01, $01, $00, $00, $00, $00, $00
DATA AS BYTE $00, $00, $00, $00, $00, $00, $01, $01, $02, $03, $03, $04, $05, $06, $07, $08
DATA AS BYTE $09, $0a, $0c, $0d, $0f, $10, $12, $13, $15, $17, $19, $1a, $1c, $1e, $21, $23
DATA AS BYTE $25, $27, $29, $2c, $2e, $31, $33, $36, $38, $3b, $3d, $40, $43, $46, $48, $4b
DATA AS BYTE $4e, $51, $54, $57, $5a, $5d, $60, $63, $66, $69, $6c, $6f, $73, $76, $79, $7c
