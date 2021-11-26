' GRAVITY
' An XC=BASIC example program
' (not yet working)

CONST GRAVITY  = 0.5
CONST BOUNCE   = -0.7
CONST FRICTION = 0.1
CONST MAX_X = 310.0
CONST MAX_Y = 224.0

DIM a$ AS STRING * 1

TYPE SPRITE
  x AS FLOAT
  y AS FLOAT
  vx AS FLOAT
  vy AS FLOAT
  
  SUB update () STATIC
    THIS.x = THIS.x + THIS.vx
    THIS.y = THIS.y + THIS.vy
    THIS.vy = THIS.vy + GRAVITY
    ''PRINT THIS.x, THIS.y, THIS.vy
    
    IF THIS.x >= MAX_X OR THIS.x <= 0 THEN THIS.vx = THIS.vx * -1.0
    IF THIS.y >= MAX_Y THEN
      THIS.vy = THIS.vy * BOUNCE
      if THIS.vx > 0.0 THEN
        THIS.vx = THIS.vx - FRICTION
      ELSE
        THIS.vx = THIS.vx + FRICTION
      END IF
    END IF
    
  END SUB
  
  SUB draw () STATIC
    STATIC screen_x AS INT
    STATIC screen_y AS BYTE
    screen_x = CINT(THIS.x)
    screen_y = CBYTE(THIS.y)
    POKE $D000, screen_x : REM sprite X coord
    IF screen_x > 255 THEN POKE $D010, 1 ELSE POKE $D010, 0
    POKE $D001, screen_y : REM sprite y coord
  END SUB
  
  SUB init () STATIC
    THIS.x = 100.0
    THIS.y = 100.0
    THIS.vy = 1.5
    THIS.vx = 3.5
    POKE $D015, 1 : REM enable sprite
    MEMCPY @ball_shape, 960, 63
    POKE $07F8, 15 : REM sprite pointer
  END SUB
END TYPE

DIM ball AS SPRITE
CALL ball.init()

loop:
  CALL ball.update()
  WAIT $d012, 0: REM -- wait for next frame
  CALL ball.draw()
  GOTO loop

ball_shape:
DATA AS BYTE 0,126,0,3,255,192,7,255,224,31,255,248
DATA AS BYTE 31,255,248,63,255,252,127,255,254
DATA AS BYTE 127,255,254,255,255,255,255,255,255
DATA AS BYTE 255,255,255,255,255,255,255,255,255
DATA AS BYTE 127,255,254,127,255,254,63,255,252
DATA AS BYTE 31,255,248,31,255,248,7,255,224
DATA AS BYTE 3,255,192,0,126,0


