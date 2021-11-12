REM --
REM -- Bubble sort
REM --

CONST TRUE = 255
CONST FALSE = 0

DIM nums(10) AS LONG
DIM swapped AS BYTE FAST
DIM i AS BYTE FAST
DIM j AS BYTE FAST

PRINT "{REV_ON}unsorted:"
RANDOMIZE TI()
FOR i = 0 TO 9 : nums(i) = RNDL() : PRINT nums(i) : NEXT

swapped = FALSE
FOR i = 0 TO 8
    FOR j = 0 TO 8 - i
        IF nums(j) > nums(j + 1) THEN
          SWAP nums(j), nums(j + 1)
          swapped = TRUE
        END IF
    NEXT j
    IF swapped = FALSE THEN EXIT FOR
NEXT i

PRINT "{REV_ON}sorted:"
FOR i = 0 TO 9: PRINT nums(i): NEXT