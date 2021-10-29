REM --
REM -- XC=PONG
REM --

INCLUDE "trigono.bas"

TYPE VECTOR
  x AS FLOAT
  y AS FLOAT
  
  SUB init (angle AS FLOAT) STATIC
    ''THIS.x = COS(angle)
    ''THIS.y = SIN(angle)
    PRINT COS(angle)
  END SUB
END TYPE

TYPE BALL
  posx AS FLOAT
  posy AS FLOAT
  speed AS VECTOR

  SUB init () STATIC
    THIS.posx = 160.0
    THIS.posy = 100.0
    CALL THIS.speed.init(PI / 8.0)
    POKE $D015, PEEK($D015) OR %00000001
  END SUB
  
  SUB updatepos () STATIC
    DIM tmpx AS INT
    THIS.posx = THIS.posx + THIS.speed.x
    THIS.posy = THIS.posy + THIS.speed.y
    tmpx = CINT(THIS.posx)
    POKE $D000, CBYTE(tmpx)
    POKE $D010, PEEK($D010) OR CBYTE(SHR(tmpx, 8))
    POKE $D001, CBYTE(THIS.posy)
  END SUB
END TYPE

TYPE RACKET
  y AS INT
  dir AS INT
END TYPE

DIM ball AS BALL
DIM rackets(2) AS RACKET

CALL ball.init()
''CALL ball.updatepos()
