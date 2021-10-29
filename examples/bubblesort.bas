REM --
REM -- Bubble sort
REM --

DIM nums(10) AS long
DIM swapped AS BYTE FAST
DIM i AS BYTE FAST

RANDOMIZE TI()
FOR i = 0 TO 9 : nums(i) = RNDL() : NEXT

DO
  swapped = 0
  FOR i = 1 TO 9
    IF nums(i - 1) > nums(i) THEN SWAP nums(i - 1), nums(i) : swapped = 1
  NEXT
LOOP WHILE swapped
END

FOR i = 1 TO 9 : PRINT nums(i) : NEXT