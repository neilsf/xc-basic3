' Tests memory commands with array element arguments in XC=BASIC
' MONITOR: m c000 c07f

DIM results(128) AS BYTE @ $C000
DIM addr(16) AS WORD
DIM count(4) AS WORD
DIM value(16) AS BYTE
DIM wordValue(2) AS WORD

addr(0) = $C000 : count(0) = 128 : value(0) = 0
MEMSET addr(0), count(0), value(0)

count(1) = 16 : value(1) = $11
MEMSET addr(0), count(1), value(1)

addr(1) = $C002 : value(2) = $22
POKE addr(1), value(2)
addr(2) = $C003 : value(3) = PEEK(addr(1))
POKE addr(2), value(3)
results(16) = PEEK(addr(1))

addr(3) = $C004 : wordValue(0) = $3456
DOKE addr(3), wordValue(0)
addr(4) = $C012 : wordValue(1) = DEEK(addr(3))
DOKE addr(4), wordValue(1)

addr(5) = $C020 : value(4) = 1 : POKE addr(5), value(4)
addr(6) = $C021 : value(5) = 2 : POKE addr(6), value(5)
addr(7) = $C022 : value(6) = 3 : POKE addr(7), value(6)
addr(8) = $C023 : value(7) = 4 : POKE addr(8), value(7)
addr(9) = $C024 : value(8) = 5 : POKE addr(9), value(8)
addr(10) = $C025 : value(9) = 6 : POKE addr(10), value(9)
addr(11) = $C026 : value(10) = 7 : POKE addr(11), value(10)
addr(12) = $C027 : value(11) = 8 : POKE addr(12), value(11)
addr(13) = $C030 : count(2) = 8
MEMCPY addr(5), addr(13), count(2)
count(3) = 7
' Overlapping copy down: $C021-$C027 -> $C020-$C026
MEMCPY addr(6), addr(5), count(3)

addr(5) = $C040 : value(4) = 9 : POKE addr(5), value(4)
addr(6) = $C041 : value(5) = 10 : POKE addr(6), value(5)
addr(7) = $C042 : value(6) = 11 : POKE addr(7), value(6)
addr(8) = $C043 : value(7) = 12 : POKE addr(8), value(7)
addr(9) = $C044 : value(8) = 13 : POKE addr(9), value(8)
addr(10) = $C045 : value(9) = 14 : POKE addr(10), value(9)
addr(11) = $C046 : value(10) = 15 : POKE addr(11), value(10)
addr(12) = $C047 : value(11) = 16 : POKE addr(12), value(11)
addr(13) = $C050 : count(2) = 8
MEMSHIFT addr(5), addr(13), count(2)
addr(14) = $C041 : count(3) = 7
' Overlapping shift up: $C040-$C046 -> $C041-$C047
MEMSHIFT addr(5), addr(14), count(3)