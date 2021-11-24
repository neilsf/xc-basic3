' GRAVITY
' An XC=BASIC example program

CONST GRAVITY  = 0.5
CONST BOUNCE   = -0.7
CONST FRICTION = 0.1
CONST MAX_X = 310.0
CONST MAX_Y = 190.0

TYPE SPRITE
  x AS FLOAT
  y AS FLOAT
  vx AS FLOAT
  vy AS FLOAT
  
  SUB update () STATIC
    THIS.x = THIS.x + THIS.vx
    THIS.y = THIS.y + THIS.vy
    THIS.vy = THIS.vy + GRAVITY
    IF THIS.x >= MAX_X OR THIS.x <= 0 THEN THIS.vx = THIS.vx * -1.0
    IF THIS.y >= MAX_Y THEN
      THIS.vy = THIS.vy * BOUNCE
    END IF
    if THIS.vx > 0.0 THEN THIS.vx = THIS.vx - FRICTION
    if THIS.vx < 0.0 THEN THIS.vx = THIS.vx + FRICTION      
  END SUB
  
  SUB draw () STATIC
    STATIC screen_x AS INT
    STATIC screen_y AS BYTE
    screen_x = CINT(THIS.x)
    screen_y = 200 - CBYTE(THIS.y)
    POKE $D000, screen_x : REM sprite X coord
    IF screen_x > 255 THEN POKE $D010, 1 ELSE POKE $D010, 0
    POKE $D001, screen_y : REM sprite y coord
  END SUB
  
  SUB init () STATIC
    THIS.x = 100.0
    THIS.y = 100.0
    THIS.vy = 0.0
    THIS.vx = 5.0
    POKE $D015, 1 : REM enable sprite
    POKE $07F8, 16 : REM sprite pointer
  END SUB
END TYPE

DIM ball AS SPRITE
CALL ball.init()
CALL ball.update()
CALL ball.draw()
END
loop:
  CALL ball.update()
  CALL ball.draw()
  GOTO loop

ball_shape:
DATA AS BYTE 255,44,23, 234, 11, 22, 0


