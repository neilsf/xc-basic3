' Tests memory commands with expression arguments in XC=BASIC
' MONITOR: m c000 c07f

DIM results(128) AS BYTE @ $C000

MEMSET $BFFF + 1, 64 * 2, $AA AND 0
MEMSET $C000 + 0, 8 * 2, $10 + 1

POKE $C000 + 2, $20 + 2
POKE $C000 + 3, PEEK($C000 + 2)
results(8 + 8) = PEEK($BFFF + 3)

DOKE $C000 + 4, $3000 + $456
DOKE $C010 + 2, DEEK($C002 + 2)

POKE $C000 + $20, 0 + 1
POKE $C000 + $21, 1 + 1
POKE $C000 + $22, 1 + 2
POKE $C000 + $23, 2 + 2
POKE $C000 + $24, 2 + 3
POKE $C000 + $25, 3 + 3
POKE $C000 + $26, 3 + 4
POKE $C000 + $27, 4 + 4
MEMCPY $C000 + $20, $C000 + $30, 4 + 4
' Overlapping copy down: $C021-$C027 -> $C020-$C026
MEMCPY $C000 + $21, $C000 + $20, 8 - 1

POKE $C000 + $40, 4 + 5
POKE $C000 + $41, 5 + 5
POKE $C000 + $42, 5 + 6
POKE $C000 + $43, 6 + 6
POKE $C000 + $44, 6 + 7
POKE $C000 + $45, 7 + 7
POKE $C000 + $46, 7 + 8
POKE $C000 + $47, 8 + 8
MEMSHIFT $C000 + $40, $C000 + $50, 2 * 4
' Overlapping shift up: $C040-$C046 -> $C041-$C047
MEMSHIFT $C000 + $40, $C000 + $41, 8 - 1