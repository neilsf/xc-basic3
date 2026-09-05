' Tests arithmetic operations on FAST LONGs in XC=BASIC
' MONITOR: m c000 c0ff

' This page will be used to compare the results against the golden set
DIM results(79) AS LONG @ $C000
DIM extras(15) AS BYTE @ $C0F0
DIM a AS LONG FAST
DIM b AS LONG FAST
DIM n AS BYTE FAST
DIM i AS BYTE FAST
DIM j AS BYTE FAST

' 0..9    : addition
' 10..19  : subtraction
' 20..29  : multiplication
' 30..39  : division
' 40..49  : bitwise AND
' 50..59  : bitwise OR
' 60..69  : bitwise XOR
' 70..74  : SHL()
' 75..79  : SHR()

' Addition: all sign combinations, with and without 24-bit overflow
a = 1000000 : b = 2000000    : results(0) = a + b   ' pos+pos, no overflow
a = 7000000 : b = 2000000    : results(1) = a + b   ' pos+pos, overflow
a = -1000000 : b = -2000000  : results(2) = a + b   ' neg+neg, no overflow
a = -7000000 : b = -2000000  : results(3) = a + b   ' neg+neg, underflow
a = 8388607 : b = -1         : results(4) = a + b   ' pos+neg, no overflow
a = 1 : b = -8388608         : results(5) = a + b   ' pos+neg, result negative
a = 8388607 : b = 8388607    : results(6) = a + b   ' max+max, overflow
a = -8388608 : b = -8388608  : results(7) = a + b   ' min+min, underflow
a = 8388607 : b = -8388608   : results(8) = a + b   ' max+min, result -1
a = -8388608 : b = 8388607   : results(9) = a + b   ' min+max, result -1

' Subtraction: all sign combinations, with and without 24-bit overflow
a = 5000000 : b = 2000000    : results(10) = a - b   ' pos-pos, positive result
a = 2000000 : b = 5000000    : results(11) = a - b   ' pos-pos, negative result
a = -2000000 : b = -5000000  : results(12) = a - b   ' neg-neg, positive result
a = -5000000 : b = -2000000  : results(13) = a - b   ' neg-neg, negative result
a = 8388607 : b = -1         : results(14) = a - b   ' pos-neg, overflow
a = -8388608 : b = 1         : results(15) = a - b   ' neg-pos, underflow
a = 8388607 : b = 8388607    : results(16) = a - b   ' pos-pos boundary, zero result
a = -8388608 : b = -8388608  : results(17) = a - b   ' neg-neg boundary, zero result
a = 0 : b = 8388607          : results(18) = a - b   ' zero-pos
a = 0 : b = -8388608         : results(19) = a - b   ' zero-neg, negation overflow

' Multiplication: all sign combinations, with and without 24-bit overflow
a = 1000 : b = 2000          : results(20) = a * b   ' pos*pos, no overflow
a = 3000 : b = 3000          : results(21) = a * b   ' pos*pos, overflow
a = -1000 : b = -2000        : results(22) = a * b   ' neg*neg, no overflow
a = -3000 : b = -3000        : results(23) = a * b   ' neg*neg, overflow
a = 1000 : b = -2000         : results(24) = a * b   ' pos*neg, no overflow
a = 3000 : b = -3000         : results(25) = a * b   ' pos*neg, underflow
a = -1000 : b = 2000         : results(26) = a * b   ' neg*pos, no overflow
a = -3000 : b = 3000         : results(27) = a * b   ' neg*pos, underflow
a = 8388607 : b = 1          : results(28) = a * b   ' pos boundary, identity
a = -8388608 : b = -1        : results(29) = a * b   ' min*-1, negation overflow

' Division: all sign combinations (truncation towards zero), overflow at LONG_MIN / -1
a = 1000000 : b = 7          : results(30) = a / b   ' pos/pos, truncated
a = -1000000 : b = -7        : results(31) = a / b   ' neg/neg, truncated
a = 1000000 : b = -7         : results(32) = a / b   ' pos/neg, truncated
a = -1000000 : b = 7         : results(33) = a / b   ' neg/pos, truncated
a = 8388607 : b = 1          : results(34) = a / b   ' pos boundary / 1
a = -8388608 : b = 1         : results(35) = a / b   ' neg boundary / 1
a = -8388608 : b = -1        : results(36) = a / b   ' min / -1, overflow
a = 8388607 : b = -1         : results(37) = a / b   ' max / -1
a = 0 : b = 12345            : results(38) = a / b   ' zero dividend
a = -7 : b = 2               : results(39) = a / b   ' neg/pos, truncated towards zero

FOR i = 0 TO 9
	' Logical operations
	a = i * 90000 + 3456789
	b = i * 110000 + 1234567
	results(40 + i) = a AND b
	results(50 + i) = a OR b
	results(60 + i) = a XOR b

	' SHL()/SHR()
	IF i < 5 THEN
		a = i * 70000 + 600000
		n = i AND 7
		results(70 + i) = SHL(a, n)

		b = i * 123456 + 7000000
		results(75 + i) = SHR(b, n)
	END IF
NEXT i

FOR j = 0 TO 15
	extras(j) = CBYTE((j * 17 + 3) XOR $AA)
NEXT j
