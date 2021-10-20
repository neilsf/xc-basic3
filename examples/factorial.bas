FUNCTION factorial AS LONG (n AS LONG)
  IF n >= 1 THEN factorial = n * factorial(n - 1) ELSE factorial = 1
END FUNCTION

FOR i AS LONG = 1 TO 10
  PRINT i;"! =";factorial(i)
NEXT i