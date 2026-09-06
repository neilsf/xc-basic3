' Tests string operations and built-in string functions in XC=BASIC
' MONITOR: m c000 c03f

DIM results(64) AS BYTE @ $C000
DIM a$ AS STRING * 12
DIM b$ AS STRING * 12
DIM c$ AS STRING * 24
DIM part$ AS STRING * 12
DIM short$ AS STRING * 4
DIM maxstr$ AS STRING * 96
DIM exprstr$ AS STRING * 96
DIM n AS WORD
DIM numint AS INT

MEMSET $C000, 64, 0

a$ = "xc"
b$ = "basic"
c$ = a$ + "=" + b$
results(0) = LEN(c$)
results(1) = ASC(c$)

part$ = RIGHT$(c$, 5)
results(2) = LEN(part$)
results(3) = ASC(part$)

part$ = LEFT$(c$, 2)
results(4) = LEN(part$)
results(5) = ASC(part$)

part$ = MID$(c$, 3, 5)
results(6) = LEN(part$)
results(7) = ASC(part$)

part$ = MID$(c$, 99, 2)
results(8) = LEN(part$)
results(9) = ASC(part$)

part$ = CHR$(65) + CHR$(66)
results(10) = LEN(part$)
results(11) = ASC(part$)

part$ = LCASE$("ABC!")
results(12) = LEN(part$)
results(13) = ASC(part$)

part$ = UCASE$("abc!")
results(14) = LEN(part$)
results(15) = ASC(part$)

n = 1234
part$ = STR$(n)
results(16) = LEN(part$)
results(17) = ASC(part$)

numint = -45
part$ = STR$(numint)
results(18) = LEN(part$)
results(19) = ASC(part$)
results(20) = ASC(RIGHT$(part$, 2))

part$ = "0077"
results(21) = CBYTE(VAL(part$))

short$ = "abcdef"
results(22) = LEN(short$)
results(23) = ASC(RIGHT$(short$, 1))

IF c$ = "xc=basic" THEN results(24) = 1 ELSE results(24) = 2
IF c$ <> "xc=other" THEN results(25) = 1 ELSE results(25) = 2

POKE @c$ + 1, ASC("z")
results(26) = ASC(c$)

part$ = RIGHT$(a$, 9)
results(27) = LEN(part$)
results(28) = ASC(part$)

part$ = LEFT$(a$, 9)
results(29) = LEN(part$)
results(30) = ASC(part$)

maxstr$ = "abcdefghijklmnopqrstuvwxabcdefghijklmnopqrstuvwxabcdefghijklmnopqrstuvwxabcdefghijklmnopqrstuvwx"
results(31) = LEN(maxstr$)
results(32) = ASC(maxstr$)
results(33) = ASC(RIGHT$(maxstr$, 1))

part$ = MID$(maxstr$, 88, 8)
results(34) = LEN(part$)
results(35) = ASC(part$)

exprstr$ = LEFT$(maxstr$, 48) + RIGHT$(maxstr$, 48)
results(36) = LEN(exprstr$)
results(37) = ASC(exprstr$)
results(38) = ASC(RIGHT$(exprstr$, 1))
IF exprstr$ = maxstr$ THEN results(39) = 1 ELSE results(39) = 2

part$ = MID$(LEFT$(exprstr$, 60) + RIGHT$(maxstr$, 36), 48, 12)
results(40) = LEN(part$)
results(41) = ASC(part$)