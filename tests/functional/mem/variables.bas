' Tests memory commands with variable arguments in XC=BASIC
' MONITOR: m c000 c07f

DIM results(128) AS BYTE @ $C000
DIM base AS WORD
DIM addr AS WORD
DIM addr2 AS WORD
DIM source AS WORD
DIM dest AS WORD
DIM count AS WORD
DIM value AS BYTE
DIM wordValue AS WORD

base = $C000 : count = 128 : value = 0
MEMSET base, count, value

count = 16 : value = $11
MEMSET base, count, value

addr = $C002 : value = $22
POKE addr, value
addr2 = $C003 : value = PEEK(addr)
POKE addr2, value
results(16) = PEEK(addr)

addr = $C004 : wordValue = $3456
DOKE addr, wordValue
addr2 = $C012 : wordValue = DEEK(addr)
DOKE addr2, wordValue

source = $C020 : addr = source : value = 1 : POKE addr, value
addr = $C021 : value = 2 : POKE addr, value
addr = $C022 : value = 3 : POKE addr, value
addr = $C023 : value = 4 : POKE addr, value
addr = $C024 : value = 5 : POKE addr, value
addr = $C025 : value = 6 : POKE addr, value
addr = $C026 : value = 7 : POKE addr, value
addr = $C027 : value = 8 : POKE addr, value
dest = $C030 : count = 8
MEMCPY source, dest, count
source = $C021 : dest = $C020 : count = 7
' Overlapping copy down: $C021-$C027 -> $C020-$C026
MEMCPY source, dest, count

source = $C040 : addr = source : value = 9 : POKE addr, value
addr = $C041 : value = 10 : POKE addr, value
addr = $C042 : value = 11 : POKE addr, value
addr = $C043 : value = 12 : POKE addr, value
addr = $C044 : value = 13 : POKE addr, value
addr = $C045 : value = 14 : POKE addr, value
addr = $C046 : value = 15 : POKE addr, value
addr = $C047 : value = 16 : POKE addr, value
dest = $C050 : count = 8
MEMSHIFT source, dest, count
dest = $C041 : count = 7
' Overlapping shift up: $C040-$C046 -> $C041-$C047
MEMSHIFT source, dest, count