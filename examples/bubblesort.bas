REM --
REM -- Bubble sort
REM --

DIM nums(10) AS long @lbl
DIM swapped AS BYTE FAST
DIM i AS BYTE FAST

DO
  swapped = 0
  FOR i = 1 TO 9
    IF nums(i - 1) > nums(i) THEN SWAP nums(i - 1), nums(i) : swapped = 1
  NEXT
LOOP WHILE swapped

FOR i = 1 TO 9 : PRINT nums(i) : NEXT

lbl:
DATA AS LONG 5672010, -126566, 0, 1, 99, 100, 98659, -176000, -1, 1000000