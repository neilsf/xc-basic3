'==========================================
' VARIABLES, CONSTANTS AND SUB DECLARATIONS
'==========================================
CONST COLOURBAR_MIN = 56136
CONST COLOURBAR_MAX = 56152

DIM hs AS BYTE FAST : hs = 7
DIM textptr AS BYTE FAST : textptr = 1
DIM textlen AS BYTE FAST
DIM sprframe(8) AS BYTE FAST
DIM colourbarpos AS WORD FAST : colourbarpos = COLOURBAR_MIN
DIM colourbardir AS INT FAST : colourbardir = 1
DIM chrindex AS BYTE FAST : chrindex = 0
DIM animindex AS BYTE FAST : animindex = 0

DECLARE FUNCTION petsciitoscr AS BYTE (char AS BYTE) STATIC
DECLARE SUB initscrolltext () STATIC
DECLARE SUB appendscrolltext () STATIC
DECLARE SUB movecolourbar () STATIC
DECLARE SUB setsprites1 () STATIC
DECLARE SUB setsprites2 () STATIC
DECLARE SUB animsprites () STATIC
DECLARE SUB animbg () STATIC

scrolltext$ = "xc=basic v3.1 has arrived to your pet, vic-20, commodore-64, commodore-16, plus/4 and commodore-128 machines!     "
textlen = LEN(scrolltext$)

'==========================================
' INITIALIZE SCREEN
'==========================================
CALL initscrolltext()
MEMCPY $1880, $2B00, 832 ' Copy sprites
VMODE TEXT COLS 38 ROWS 25
POKE $D018, (PEEK($D018) AND %11110001) OR %00001000
PRINT "{CLR}";
MEMSET $d800, 40, 4
TEXTAT 9, 9, "version 3.1 is already", 5
TEXTAT 7, 10, "available on xc-basic.net!", 5 
TEXTAT 1, 21, "this demo was written in xc=basic v3.1", 0
TEXTAT 6, 24, "code: neils / music: rotteroy", 11
MEMSET 1588, 33, 30
MEMSET 1628, 33, 30
MEMSET 1668, 33, 30
MEMSET 1708, 33, 30
MEMSET 55816, 360, 6
BORDER 0 : BACKGROUND 0 : SPRITE MULTICOLOR 8, 10
FOR i AS BYTE = 0 TO 7
  sprframe(i) = i * 4
NEXT

' Turn off interrupts
ASM
  sei
END ASM

' Initialize music
SYS $1000 FAST

'=========================================
' MAIN LOOP
'=========================================

loop:
  DO : LOOP WHILE SCAN() < 46
  hs = hs - 1
  IF hs = 0 THEN hs = 7
  HSCROLL hs
  DO : LOOP WHILE SCAN() < 58
  HSCROLL 0
  IF hs = 1 THEN CALL appendscrolltext()
  CALL movecolourbar()
  SYS $1003 FAST ' Play a piece of music
  CALL animbg()
  DO : LOOP WHILE SCAN() < 130
  CALL setsprites2()
  DO : LOOP WHILE SCAN() < 210
  CALL setsprites1()
  CALL animsprites()
  DO : LOOP WHILE SCAN() >= 58
 GOTO loop
 
'=========================================
' RESOURCES
'=========================================
 
'Music
ORIGIN $1000
INCBIN "resources/Reset_12_Intro_h1000.sid"
' * = $184C

' Sprites (get copied to $2B00)
ORIGIN $1880
INCBIN "resources/xcbletters.bin"
INCBIN "resources/relletters.bin"
' * = $1BC0

' Charset
ORIGIN $1FFE
INCBIN "resources/combat_leader_3.64c"
' * = $2280

'=========================================
' ROUTINES
'=========================================

' Convert PETSCII character to screencode
' Not fully implemented but enough for our current needs
FUNCTION petsciitoscr AS BYTE (char AS BYTE) STATIC
  IF char <= 63 THEN RETURN char ELSE RETURN char - 64
END FUNCTION

' Convert scrolling text to screencodes for faster display
SUB initscrolltext () STATIC
  DIM txtpos AS WORD
  FOR txtpos = @scrolltext$ + CWORD(1) TO @scrolltext$ + CWORD(textlen)
    POKE txtpos, petsciitoscr(PEEK(txtpos))
  NEXT
END SUB

' Move the scrolling text one char to the left
' and append the next character to it
SUB appendscrolltext () STATIC
  MEMCPY 1025, 1024, 39
  POKE 1063, PEEK(@scrolltext$ + textptr)
  IF textptr = textlen THEN
    textptr = 1
  ELSE
    textptr = textptr + 1
  END IF
END SUB

' Move the colours of the text on the bottom of screen 
SUB movecolourbar () STATIC
  MEMSET COLOURBAR_MIN, 40, 0
  MEMCPY @colourbar, colourbarpos, 24
  colourbarpos = colourbarpos + colourbardir
  IF colourbarpos = COLOURBAR_MAX OR colourbarpos = COLOURBAR_MIN THEN
    colourbardir = -colourbardir
  END IF
  
  colourbar:
  DATA AS BYTE 11, 11, 12, 12, 15, 15
  DATA AS BYTE 1, 1, 1, 1, 7, 7, 7, 7, 1, 1, 1, 1
  DATA AS BYTE 15, 15, 12, 12, 11, 11
END SUB

' Set sprite properties for bouncing chars
SUB setsprites1 () STATIC
  FOR i AS BYTE = 0 TO 7
    SPRITE i SHAPE 172 + i _
    XYSIZE 0, 0 _
    MULTI COLOR 7 ON
  NEXT
  SPRITE 7 SHAPE 173
END SUB

' Set sprite properties for masking sprites
SUB setsprites2 () STATIC
  DIM xpos(6) AS WORD @xposdata
  FOR i AS BYTE = 0 TO 5
    SPRITE i SHAPE 179 + i _
    AT xpos(i), 162 _
    XYSIZE 1, 1 _
    HIRES COLOR 0 ON
  NEXT
  SPRITE 6 OFF
  SPRITE 7 OFF
  
  xposdata:
  DATA AS WORD 56, 104, 152, 200, 248, 296
END SUB

' Animate the sprites
SUB animsprites () STATIC
  DIM bounce(32) AS BYTE @bouncedata
  DIM xpos(8) AS WORD @xposdata
  FOR i AS BYTE = 0 TO 7
    SPRITE i AT xpos(i), 90 - bounce(sprframe(i))
    sprframe(i) = sprframe(i) + 1
    IF sprframe(i) = 32 THEN sprframe(i) = 0
  NEXT
  
  xposdata:
  DATA AS WORD 84, 108, 132, 156, 180, 204, 228, 252
  bouncedata:
  DATA AS BYTE 24, 24, 23, 23, 22, 21, 20, 18 ,17, 15, 13, 11
  DATA AS BYTE 8, 6, 3, 0
  DATA AS BYTE 0, 3, 6, 8, 11, 13, 15, 17, 18, 20, 21, 22, 23, 23, 24, 24
END SUB

' Animate checkered background
SUB animbg () STATIC
  DIM chrptrs(16) AS WORD @chrptrs_data
  animindex = animindex + 1
  IF animindex AND 1 THEN EXIT SUB
  MEMCPY chrptrs(chrindex), $20F0, 8
  chrindex = (chrindex + 1) AND %00001111
  
  chrptrs_data:
  DATA AS WORD $2200, $2208, $2210, $2218, $2220, $2228, $2230, $2238
  DATA AS WORD $2240, $2248, $2250, $2258, $2260, $2268, $2270, $2278
END SUB
