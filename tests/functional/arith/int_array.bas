' Tests arithmetic operations on INT arrays in XC=BASIC
' MONITOR: m c000 c0ff

' This page will be used to compare the results against the golden set
DIM results(127) AS INT @ $C000
DIM myarr(4) AS INT
DIM n(1) AS BYTE
DIM i AS BYTE

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
myarr(1) = 12345 : myarr(2) = 6789    : results(0)  = myarr(1) + myarr(2)   ' pos+pos, no overflow
myarr(1) = 32000 : myarr(2) = 500     : results(1)  = myarr(1) + myarr(2)   ' pos+pos, near boundary, no overflow
myarr(1) = 32760 : myarr(2) = 10      : results(2)  = myarr(1) + myarr(2)   ' pos+pos, overflow
myarr(1) = 32767 : myarr(2) = 32767   : results(3)  = myarr(1) + myarr(2)   ' pos+pos, max+max overflow
myarr(1) = -12345 : myarr(2) = -6789  : results(4)  = myarr(1) + myarr(2)   ' neg+neg, no overflow
myarr(1) = -32768 : myarr(2) = 0      : results(5)  = myarr(1) + myarr(2)   ' neg+neg boundary, no overflow
myarr(1) = -32760 : myarr(2) = -10    : results(6)  = myarr(1) + myarr(2)   ' neg+neg, underflow
myarr(1) = -32768 : myarr(2) = -32768 : results(7)  = myarr(1) + myarr(2)   ' neg+neg, min+min underflow
myarr(1) = 32767 : myarr(2) = -1      : results(8)  = myarr(1) + myarr(2)   ' pos+neg, result positive
myarr(1) = 1 : myarr(2) = -32768      : results(9)  = myarr(1) + myarr(2)   ' pos+neg, result negative
myarr(1) = 12345 : myarr(2) = -12345  : results(10) = myarr(1) + myarr(2)   ' pos+neg, result zero
myarr(1) = -1 : myarr(2) = 32767      : results(11) = myarr(1) + myarr(2)   ' neg+pos, result positive
myarr(1) = -500 : myarr(2) = 300      : results(12) = myarr(1) + myarr(2)   ' neg+pos, result negative
myarr(1) = 32767 : myarr(2) = -32768  : results(13) = myarr(1) + myarr(2)   ' max+min, result -1
myarr(1) = -32768 : myarr(2) = 32767  : results(14) = myarr(1) + myarr(2)   ' min+max, result -1
myarr(1) = -20000 : myarr(2) = 15000  : results(15) = myarr(1) + myarr(2)   ' neg+pos, result negative

' Subtraction: all sign combinations, with and without 16-bit overflow
myarr(1) = 500 : myarr(2) = 200       : results(16) = myarr(1) - myarr(2)   ' pos-pos, positive result
myarr(1) = 200 : myarr(2) = 500       : results(17) = myarr(1) - myarr(2)   ' pos-pos, negative result
myarr(1) = -200 : myarr(2) = -500     : results(18) = myarr(1) - myarr(2)   ' neg-neg, positive result
myarr(1) = -500 : myarr(2) = -200     : results(19) = myarr(1) - myarr(2)   ' neg-neg, negative result
myarr(1) = 100 : myarr(2) = -100      : results(20) = myarr(1) - myarr(2)   ' pos-neg, no overflow
myarr(1) = 32000 : myarr(2) = -2000   : results(21) = myarr(1) - myarr(2)   ' pos-neg, overflow
myarr(1) = 32767 : myarr(2) = -32768  : results(22) = myarr(1) - myarr(2)   ' pos-neg, max-min overflow
myarr(1) = -100 : myarr(2) = 100      : results(23) = myarr(1) - myarr(2)   ' neg-pos, no overflow
myarr(1) = -32000 : myarr(2) = 2000   : results(24) = myarr(1) - myarr(2)   ' neg-pos, underflow
myarr(1) = -32768 : myarr(2) = 32767  : results(25) = myarr(1) - myarr(2)   ' neg-pos, min-max underflow
myarr(1) = 32767 : myarr(2) = 32767   : results(26) = myarr(1) - myarr(2)   ' pos-pos boundary, zero result
myarr(1) = -32768 : myarr(2) = -32768 : results(27) = myarr(1) - myarr(2)   ' neg-neg boundary, zero result
myarr(1) = 0 : myarr(2) = 32767       : results(28) = myarr(1) - myarr(2)   ' zero-pos
myarr(1) = 0 : myarr(2) = -32768      : results(29) = myarr(1) - myarr(2)   ' zero-neg, negation overflow
myarr(1) = 32767 : myarr(2) = 0       : results(30) = myarr(1) - myarr(2)   ' pos-zero
myarr(1) = -32768 : myarr(2) = 0      : results(31) = myarr(1) - myarr(2)   ' neg-zero

' Multiplication: all sign combinations, with and without 16-bit overflow
myarr(1) = 100 : myarr(2) = 200       : results(32) = myarr(1) * myarr(2)   ' pos*pos, no overflow
myarr(1) = 200 : myarr(2) = 200       : results(33) = myarr(1) * myarr(2)   ' pos*pos, overflow
myarr(1) = -100 : myarr(2) = -200     : results(34) = myarr(1) * myarr(2)   ' neg*neg, no overflow
myarr(1) = -200 : myarr(2) = -200     : results(35) = myarr(1) * myarr(2)   ' neg*neg, overflow
myarr(1) = 100 : myarr(2) = -200      : results(36) = myarr(1) * myarr(2)   ' pos*neg, no overflow
myarr(1) = 200 : myarr(2) = -200      : results(37) = myarr(1) * myarr(2)   ' pos*neg, overflow
myarr(1) = -100 : myarr(2) = 200      : results(38) = myarr(1) * myarr(2)   ' neg*pos, no overflow
myarr(1) = -200 : myarr(2) = 200      : results(39) = myarr(1) * myarr(2)   ' neg*pos, overflow
myarr(1) = 181 : myarr(2) = 181       : results(40) = myarr(1) * myarr(2)   ' pos*pos, just under boundary, no overflow
myarr(1) = 182 : myarr(2) = 181       : results(41) = myarr(1) * myarr(2)   ' pos*pos, just over boundary, overflow
myarr(1) = 32767 : myarr(2) = 1       : results(42) = myarr(1) * myarr(2)   ' pos boundary, identity
myarr(1) = -32768 : myarr(2) = 1      : results(43) = myarr(1) * myarr(2)   ' neg boundary, identity
myarr(1) = 32767 : myarr(2) = 2       : results(44) = myarr(1) * myarr(2)   ' pos*pos, double max, overflow
myarr(1) = -32768 : myarr(2) = -1     : results(45) = myarr(1) * myarr(2)   ' min*-1, negation overflow
myarr(1) = 0 : myarr(2) = -12345      : results(46) = myarr(1) * myarr(2)   ' zero multiplicand
myarr(1) = -181 : myarr(2) = -181     : results(47) = myarr(1) * myarr(2)   ' neg*neg, just under boundary, no overflow

' Division: all sign combinations (truncation towards zero), overflow at INT_MIN / -1
myarr(1) = 100 : myarr(2) = 5         : results(48) = myarr(1) / myarr(2)   ' pos/pos, exact
myarr(1) = 17 : myarr(2) = 5          : results(49) = myarr(1) / myarr(2)   ' pos/pos, truncated
myarr(1) = -100 : myarr(2) = -5       : results(50) = myarr(1) / myarr(2)   ' neg/neg, exact
myarr(1) = -17 : myarr(2) = -5        : results(51) = myarr(1) / myarr(2)   ' neg/neg, truncated
myarr(1) = 100 : myarr(2) = -5        : results(52) = myarr(1) / myarr(2)   ' pos/neg, exact
myarr(1) = 17 : myarr(2) = -5         : results(53) = myarr(1) / myarr(2)   ' pos/neg, truncated
myarr(1) = -100 : myarr(2) = 5        : results(54) = myarr(1) / myarr(2)   ' neg/pos, exact
myarr(1) = -17 : myarr(2) = 5         : results(55) = myarr(1) / myarr(2)   ' neg/pos, truncated
myarr(1) = 32767 : myarr(2) = 1       : results(56) = myarr(1) / myarr(2)   ' pos boundary / 1
myarr(1) = -32768 : myarr(2) = 1      : results(57) = myarr(1) / myarr(2)   ' neg boundary / 1
myarr(1) = -32768 : myarr(2) = -1     : results(58) = myarr(1) / myarr(2)   ' min / -1, overflow
myarr(1) = 32767 : myarr(2) = -1      : results(59) = myarr(1) / myarr(2)   ' max / -1
myarr(1) = -32768 : myarr(2) = -32768 : results(60) = myarr(1) / myarr(2)   ' min / min
myarr(1) = 0 : myarr(2) = 12345       : results(61) = myarr(1) / myarr(2)   ' zero dividend
myarr(1) = -7 : myarr(2) = 2          : results(62) = myarr(1) / myarr(2)   ' neg/pos, truncated towards zero
myarr(1) = 7 : myarr(2) = -2          : results(63) = myarr(1) / myarr(2)   ' pos/neg, truncated towards zero

FOR i = 0 TO 15
	' Logical operations
	myarr(1) = i * 1400 + 12345
	myarr(2) = i * 2100 + 23456
	results(64 + i) = myarr(1) AND myarr(2)
	results(80 + i) = myarr(1) OR myarr(2)
	results(96 + i) = myarr(1) XOR myarr(2)

	' SHL()/SHR()
	IF i < 8 THEN
		myarr(1) = i * 1777 + 1234
		n(0) = i AND 7
		results(112 + i) = SHL(myarr(1), n(0))

		myarr(2) = i * 1999 + 30000
		results(120 + i) = SHR(myarr(2), n(0))
	END IF
NEXT i
