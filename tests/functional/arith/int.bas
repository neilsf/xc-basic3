' Tests arithmetic operations on INTs in XC=BASIC
' MONITOR: m c000 c0ff

' This page will be used to compare the results against the golden set
DIM results(127) AS INT @ $C000
DIM a AS INT, b AS INT, i AS INT, n AS INT

' 0..15   : addition
' 16..31  : subtraction
' 32..47  : multiplication
' 48..63  : division
' 64..79  : bitwise AND
' 80..95  : bitwise OR
' 96..111 : bitwise XOR
' 112..119: SHL()
' 120..127: SHR()

' Addition: all sign combinations, with and without 16-bit overflow
a = 12345 : b = 6789    : results(0)  = a + b   ' pos+pos, no overflow
a = 32000 : b = 500     : results(1)  = a + b   ' pos+pos, near boundary, no overflow
a = 32760 : b = 10      : results(2)  = a + b   ' pos+pos, overflow
a = 32767 : b = 32767   : results(3)  = a + b   ' pos+pos, max+max overflow
a = -12345 : b = -6789  : results(4)  = a + b   ' neg+neg, no overflow
a = -32768 : b = 0      : results(5)  = a + b   ' neg+neg boundary, no overflow
a = -32760 : b = -10    : results(6)  = a + b   ' neg+neg, underflow
a = -32768 : b = -32768 : results(7)  = a + b   ' neg+neg, min+min underflow
a = 32767 : b = -1      : results(8)  = a + b   ' pos+neg, result positive
a = 1 : b = -32768      : results(9)  = a + b   ' pos+neg, result negative
a = 12345 : b = -12345  : results(10) = a + b   ' pos+neg, result zero
a = -1 : b = 32767      : results(11) = a + b   ' neg+pos, result positive
a = -500 : b = 300      : results(12) = a + b   ' neg+pos, result negative
a = 32767 : b = -32768  : results(13) = a + b   ' max+min, result -1
a = -32768 : b = 32767  : results(14) = a + b   ' min+max, result -1
a = -20000 : b = 15000  : results(15) = a + b   ' neg+pos, result negative

' Subtraction: all sign combinations, with and without 16-bit overflow
a = 500 : b = 200       : results(16) = a - b   ' pos-pos, positive result
a = 200 : b = 500       : results(17) = a - b   ' pos-pos, negative result
a = -200 : b = -500     : results(18) = a - b   ' neg-neg, positive result
a = -500 : b = -200     : results(19) = a - b   ' neg-neg, negative result
a = 100 : b = -100      : results(20) = a - b   ' pos-neg, no overflow
a = 32000 : b = -2000   : results(21) = a - b   ' pos-neg, overflow
a = 32767 : b = -32768  : results(22) = a - b   ' pos-neg, max-min overflow
a = -100 : b = 100      : results(23) = a - b   ' neg-pos, no overflow
a = -32000 : b = 2000   : results(24) = a - b   ' neg-pos, underflow
a = -32768 : b = 32767  : results(25) = a - b   ' neg-pos, min-max underflow
a = 32767 : b = 32767   : results(26) = a - b   ' pos-pos boundary, zero result
a = -32768 : b = -32768 : results(27) = a - b   ' neg-neg boundary, zero result
a = 0 : b = 32767       : results(28) = a - b   ' zero-pos
a = 0 : b = -32768      : results(29) = a - b   ' zero-neg, negation overflow
a = 32767 : b = 0       : results(30) = a - b   ' pos-zero
a = -32768 : b = 0      : results(31) = a - b   ' neg-zero

' Multiplication: all sign combinations, with and without 16-bit overflow
a = 100 : b = 200       : results(32) = a * b   ' pos*pos, no overflow
a = 200 : b = 200       : results(33) = a * b   ' pos*pos, overflow
a = -100 : b = -200     : results(34) = a * b   ' neg*neg, no overflow
a = -200 : b = -200     : results(35) = a * b   ' neg*neg, overflow
a = 100 : b = -200      : results(36) = a * b   ' pos*neg, no overflow
a = 200 : b = -200      : results(37) = a * b   ' pos*neg, overflow
a = -100 : b = 200      : results(38) = a * b   ' neg*pos, no overflow
a = -200 : b = 200      : results(39) = a * b   ' neg*pos, overflow
a = 181 : b = 181       : results(40) = a * b   ' pos*pos, just under boundary, no overflow
a = 182 : b = 181       : results(41) = a * b   ' pos*pos, just over boundary, overflow
a = 32767 : b = 1       : results(42) = a * b   ' pos boundary, identity
a = -32768 : b = 1      : results(43) = a * b   ' neg boundary, identity
a = 32767 : b = 2       : results(44) = a * b   ' pos*pos, double max, overflow
a = -32768 : b = -1     : results(45) = a * b   ' min*-1, negation overflow
a = 0 : b = -12345      : results(46) = a * b   ' zero multiplicand
a = -181 : b = -181     : results(47) = a * b   ' neg*neg, just under boundary, no overflow

' Division: all sign combinations (truncation towards zero), overflow at INT_MIN / -1
a = 100 : b = 5         : results(48) = a / b   ' pos/pos, exact
a = 17 : b = 5          : results(49) = a / b   ' pos/pos, truncated
a = -100 : b = -5       : results(50) = a / b   ' neg/neg, exact
a = -17 : b = -5        : results(51) = a / b   ' neg/neg, truncated
a = 100 : b = -5        : results(52) = a / b   ' pos/neg, exact
a = 17 : b = -5         : results(53) = a / b   ' pos/neg, truncated
a = -100 : b = 5        : results(54) = a / b   ' neg/pos, exact
a = -17 : b = 5         : results(55) = a / b   ' neg/pos, truncated
a = 32767 : b = 1       : results(56) = a / b   ' pos boundary / 1
a = -32768 : b = 1      : results(57) = a / b   ' neg boundary / 1
a = -32768 : b = -1     : results(58) = a / b   ' min / -1, overflow
a = 32767 : b = -1      : results(59) = a / b   ' max / -1
a = -32768 : b = -32768 : results(60) = a / b   ' min / min
a = 0 : b = 12345       : results(61) = a / b   ' zero dividend
a = -7 : b = 2          : results(62) = a / b   ' neg/pos, truncated towards zero
a = 7 : b = -2          : results(63) = a / b   ' pos/neg, truncated towards zero

FOR i = 0 TO 15
	' Logical operations
	a = i * 1400 + 12345
	b = i * 2100 + 23456
	results(64 + i) = a AND b
	results(80 + i) = a OR b
	results(96 + i) = a XOR b

	' SHL()/SHR()
	IF i < 8 THEN
		a = i * 1777 + 1234
		n = i AND 7
		results(112 + i) = SHL(a, n)

		b = i * 1999 + 30000
		results(120 + i) = SHR(b, n)
	END IF
NEXT i
