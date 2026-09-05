' Tests arithmetic operations on byte arrays in XC=BASIC
' MONITOR: m c000 c0ff

' This page will be used to compare the results against the golden set
DIM results(256) AS BYTE @ $C000
DIM myarr(4) AS BYTE
DIM n(1) AS BYTE
DIM i AS BYTE

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
	myarr(1) = i * 7 + 200
	myarr(2) = i * 13 + 100
	results(i) = myarr(1) + myarr(2)

	' Subtraction (with underflow)
	myarr(1) = i * 5 + 10
	myarr(2) = i * 9 + 130
	results(32 + i) = myarr(1) - myarr(2)

	' Multiplication (with overflow)
	myarr(1) = i * 11 + 3
	myarr(2) = i * 7 + 5
	results(64 + i) = myarr(1) * myarr(2)

	' Division (integer division)
	myarr(1) = i * 17 + 255
	myarr(2) = (i AND 7) + 1
	results(96 + i) = myarr(1) / myarr(2)

	' Logical operations
	myarr(1) = i * 19 + 85
	myarr(2) = i * 23 + 170
	results(128 + i) = myarr(1) AND myarr(2)
	results(160 + i) = myarr(1) OR myarr(2)
	results(192 + i) = myarr(1) XOR myarr(2)

	' SHL()/SHR()
	IF i < 16 THEN
		myarr(1) = i * 29 + 3
		n(0) = i AND 7
		results(224 + i) = SHL(myarr(1), n(0))

		myarr(2) = i * 31 + 240
		results(240 + i) = SHR(myarr(2), n(0))
	END IF
NEXT i