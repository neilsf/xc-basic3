' GRAVITY
' An XC=BASIC example program
' Could be reworked to use fixed-point numbers
' instead of floating point to save a lot of memory

CONST GRAVITY = 0.3
CONST VBOUNCE = -0.8
CONST HBOUNCE = -0.95
CONST FRICTION = 0.2
CONST MIN_X = 24.0
CONST MAX_X = 318.0
CONST MAX_Y = 228.0

TYPE MOB
  x AS FLOAT
  y AS FLOAT
  vx AS FLOAT
  vy AS FLOAT
  
  SUB update () STATIC
    THIS.x = THIS.x + THIS.vx
    THIS.y = THIS.y + THIS.vy
    THIS.vy = THIS.vy + GRAVITY

    ' Hit the wall
    IF (THIS.x >= MAX_X AND THIS.vx > 0) OR (THIS.x <= MIN_X AND THIS.vx < 0) THEN THIS.vx = THIS.vx * HBOUNCE
    ' Hit the ground
    IF THIS.y >= MAX_Y AND THIS.vy > 0.0 THEN
      IF ABS(THIS.vx) < 0.2 THEN END
      THIS.vy = THIS.vy * VBOUNCE
      
      IF THIS.vx > 0.0 THEN
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
    lab_h:
    SPRITE 1 AT screen_x, screen_y
  END SUB
  
  SUB init () STATIC
    THIS.x = 28.0
    THIS.y = 48.0
    THIS.vy = 0.0
    THIS.vx = 5.5
    MEMCPY @ball_shape, 960, 63
    SPRITE 1 SHAPE 15 COLOR 13 ON
  END SUB
END TYPE

DIM ball AS MOB
CALL ball.init()

DO
  CALL ball.update()
  ' wait one frame
  WAIT 53265, 128
  CALL ball.draw()
LOOP WHILE 1

ball_shape:
DATA AS BYTE 0,126,0,3,255,192,7,255,224,31,255,248
DATA AS BYTE 31,255,248,63,255,252,127,255,254
DATA AS BYTE 127,255,254,255,255,255,255,255,255
DATA AS BYTE 255,255,255,255,255,255,255,255,255
DATA AS BYTE 127,255,254,127,255,254,63,255,252
DATA AS BYTE 31,255,248,31,255,248,7,255,224
DATA AS BYTE 3,255,192,0,126,0
