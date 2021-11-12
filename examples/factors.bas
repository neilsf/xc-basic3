SUB displayfactors (num AS LONG) STATIC
  DIM i AS LONG FAST
  PRINT "factors of "; num; " are:"
  FOR i = 1 TO num / 2
    IF num MOD i = 0 THEN PRINT i
  NEXT
END SUB

CALL displayfactors(320)