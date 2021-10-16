REM **************************************
REM * TRIGONO.BAS                        *
REM * XC=BASIC fundamental               *
REM * trigonometric functions            *
REM *                                    *
REM * (mostly) ported from C to XC=BASIC *
REM * http://www.ganssle.com/approx.htm  *
REM **************************************

REM ** Constants
SHARED CONST PI      = 3.14159 : REM PI
CONST TWOPI   = 6.28318 : REM PI * 2
CONST HALFPI  = 1.57079 : REM PI / 2
CONST QTRPI   = 0.78539 : REM PI / 4
CONST FOVRPI  = 1.27324 : REM 4 / PI
CONST THALFPI = 4.71239 : REM 3 / 2 * PI

REM **
REM ** (PRIVATE)
REM ** Cosine approximation of an angle between 0 and 90 degrees
REM **
FUNCTION APCOS AS FLOAT (x AS FLOAT) STATIC
  CONST C1 =  0.99940
  CONST C2 = -0.49558
  CONST C3 =  0.03679
  STATIC x2 AS FLOAT
  x2 = x * x
  RETURN C1 + x2 * (C2 + C3 * x2)
END FUNCTION

REM **
REM ** Cosine of an angle
REM **
FUNCTION COS AS FLOAT (x AS FLOAT) SHARED STATIC
  x = ABS(x) MOD TWOPI
  ON CBYTE(x / HALFPI) GOTO q0, q1, q2, q3
q0: RETURN APCOS(x)
q1: RETURN -APCOS(PI - x)
q2: RETURN -APCOS(x - PI)
q3: RETURN APCOS(TWOPI - x)
END FUNCTION

REM **
REM ** Sine of an angle
REM **
FUNCTION SIN AS FLOAT (x AS FLOAT) SHARED STATIC
  RETURN COS(HALFPI - x)
END FUNCTION

REM **
REM ** (PRIVATE)
REM ** Tangent approximation of an angle between 0 and 45 degrees
REM **
FUNCTION APTAN AS FLOAT (x AS FLOAT) STATIC
  CONST C1 = -3.61122
  CONST C2 = -4.61333
  STATIC x2 AS FLOAT
  x2 = x * x
  RETURN x * C1 / (C2 + x2)
END FUNCTION

REM **
REM ** Tangent of an angle
REM **
FUNCTION TAN AS FLOAT (x AS FLOAT) SHARED STATIC
  x = x MOD TWOPI
  IF x < 0 THEN x = -x
  ON CBYTE(x / QTRPI) GOTO o0, o1, o2, o3, o4, o5, o6, o7
o0: RETURN APTAN(x * FOVRPI)
o1: RETURN 1.0 / APTAN((HALFPI - x) * FOVRPI)
o2: RETURN -1.0 / APTAN((x - HALFPI) * FOVRPI)
o3: RETURN -APTAN((PI - x) * FOVRPI)
o4: RETURN APTAN((x - PI) * FOVRPI)
o5: RETURN 1.0 / APTAN((x - THALFPI) * FOVRPI)
o6: RETURN -1.0 / APTAN((THALFPI - x) * FOVRPI)
o7: RETURN -APTAN((TWOPI - x) * FOVRPI)
END FUNCTION

REM **
REM ** Arctangent of a number
REM **
FUNCTION ATN AS FLOAT (x AS FLOAT) SHARED STATIC
  CONST C1 = 0.07765
  CONST C2 = -0.28743
  CONST C3 = 0.99518
  STATIC x2 AS FLOAT
  x2 = x * x
  return ((C1 * x2 + C2) * x2 + C3) * x
END FUNCTION