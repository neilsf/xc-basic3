' Tests arithmetic operations on bytes in XC=BASIC
' MONITOR: m c000 c0ff

' This page will be used to compare the results against the golden set
DIM results(256) AS BYTE @ $C000
DIM a AS BYTE, b AS BYTE, n AS BYTE, i AS BYTE

' 0..31   : addition
' 32..63  : subtraction
' 64..95  : multiplication
' 96..127 : division
' 128..159: bitwise AND
' 160..191: bitwise OR
' 192..223: bitwise XOR
' 224..239: SHL()
' 240..255: SHR()

FOR i = 0 TO 31
	' Addition (with overflow)
	a = i * 7 + 200
	b = i * 13 + 100
	results(i) = a + b

	' Subtraction (with underflow)
	a = i * 5 + 10
	b = i * 9 + 130
	results(32 + i) = a - b

	' Multiplication (with overflow)
	a = i * 11 + 3
	b = i * 7 + 5
	results(64 + i) = a * b

	' Division (integer division)
	a = i * 17 + 255
	b = (i AND 7) + 1
	results(96 + i) = a / b

	' Logical operations
	a = i * 19 + 85
	b = i * 23 + 170
	results(128 + i) = a AND b
	results(160 + i) = a OR b
	results(192 + i) = a XOR b

	' SHL()/SHR()
	IF i < 16 THEN
		a = i * 29 + 3
		n = i AND 7
		results(224 + i) = SHL(a, n)

		b = i * 31 + 240
		results(240 + i) = SHR(b, n)
	END IF
NEXT i