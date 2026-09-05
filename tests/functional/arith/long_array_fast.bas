' Tests arithmetic operations on FAST LONG arrays in XC=BASIC
' MONITOR: m c000 c0ff

' This page will be used to compare the results against the golden set
DIM results(79) AS LONG @ $C000
DIM extras(15) AS BYTE @ $C0F0
DIM myarr(4) AS LONG FAST
DIM n(1) AS BYTE FAST
DIM i, j AS BYTE FAST

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
myarr(1) = 1000000 : myarr(2) = 2000000    : results(0) = myarr(1) + myarr(2)   ' pos+pos, no overflow
myarr(1) = 7000000 : myarr(2) = 2000000    : results(1) = myarr(1) + myarr(2)   ' pos+pos, overflow
myarr(1) = -1000000 : myarr(2) = -2000000  : results(2) = myarr(1) + myarr(2)   ' neg+neg, no overflow
myarr(1) = -7000000 : myarr(2) = -2000000  : results(3) = myarr(1) + myarr(2)   ' neg+neg, underflow
myarr(1) = 8388607 : myarr(2) = -1         : results(4) = myarr(1) + myarr(2)   ' pos+neg, no overflow
myarr(1) = 1 : myarr(2) = -8388608         : results(5) = myarr(1) + myarr(2)   ' pos+neg, result negative
myarr(1) = 8388607 : myarr(2) = 8388607    : results(6) = myarr(1) + myarr(2)   ' max+max, overflow
myarr(1) = -8388608 : myarr(2) = -8388608  : results(7) = myarr(1) + myarr(2)   ' min+min, underflow
myarr(1) = 8388607 : myarr(2) = -8388608   : results(8) = myarr(1) + myarr(2)   ' max+min, result -1
myarr(1) = -8388608 : myarr(2) = 8388607   : results(9) = myarr(1) + myarr(2)   ' min+max, result -1

' Subtraction: all sign combinations, with and without 24-bit overflow
myarr(1) = 5000000 : myarr(2) = 2000000    : results(10) = myarr(1) - myarr(2)   ' pos-pos, positive result
myarr(1) = 2000000 : myarr(2) = 5000000    : results(11) = myarr(1) - myarr(2)   ' pos-pos, negative result
myarr(1) = -2000000 : myarr(2) = -5000000  : results(12) = myarr(1) - myarr(2)   ' neg-neg, positive result
myarr(1) = -5000000 : myarr(2) = -2000000  : results(13) = myarr(1) - myarr(2)   ' neg-neg, negative result
myarr(1) = 8388607 : myarr(2) = -1         : results(14) = myarr(1) - myarr(2)   ' pos-neg, overflow
myarr(1) = -8388608 : myarr(2) = 1         : results(15) = myarr(1) - myarr(2)   ' neg-pos, underflow
myarr(1) = 8388607 : myarr(2) = 8388607    : results(16) = myarr(1) - myarr(2)   ' pos-pos boundary, zero result
myarr(1) = -8388608 : myarr(2) = -8388608  : results(17) = myarr(1) - myarr(2)   ' neg-neg boundary, zero result
myarr(1) = 0 : myarr(2) = 8388607          : results(18) = myarr(1) - myarr(2)   ' zero-pos
myarr(1) = 0 : myarr(2) = -8388608         : results(19) = myarr(1) - myarr(2)   ' zero-neg, negation overflow

' Multiplication: all sign combinations, with and without 24-bit overflow
myarr(1) = 1000 : myarr(2) = 2000          : results(20) = myarr(1) * myarr(2)   ' pos*pos, no overflow
myarr(1) = 3000 : myarr(2) = 3000          : results(21) = myarr(1) * myarr(2)   ' pos*pos, overflow
myarr(1) = -1000 : myarr(2) = -2000        : results(22) = myarr(1) * myarr(2)   ' neg*neg, no overflow
myarr(1) = -3000 : myarr(2) = -3000        : results(23) = myarr(1) * myarr(2)   ' neg*neg, overflow
myarr(1) = 1000 : myarr(2) = -2000         : results(24) = myarr(1) * myarr(2)   ' pos*neg, no overflow
myarr(1) = 3000 : myarr(2) = -3000         : results(25) = myarr(1) * myarr(2)   ' pos*neg, underflow
myarr(1) = -1000 : myarr(2) = 2000         : results(26) = myarr(1) * myarr(2)   ' neg*pos, no overflow
myarr(1) = -3000 : myarr(2) = 3000         : results(27) = myarr(1) * myarr(2)   ' neg*pos, underflow
myarr(1) = 8388607 : myarr(2) = 1          : results(28) = myarr(1) * myarr(2)   ' pos boundary, identity
myarr(1) = -8388608 : myarr(2) = -1        : results(29) = myarr(1) * myarr(2)   ' min*-1, negation overflow

' Division: all sign combinations (truncation towards zero), overflow at LONG_MIN / -1
myarr(1) = 1000000 : myarr(2) = 7          : results(30) = myarr(1) / myarr(2)   ' pos/pos, truncated
myarr(1) = -1000000 : myarr(2) = -7        : results(31) = myarr(1) / myarr(2)   ' neg/neg, truncated
myarr(1) = 1000000 : myarr(2) = -7         : results(32) = myarr(1) / myarr(2)   ' pos/neg, truncated
myarr(1) = -1000000 : myarr(2) = 7         : results(33) = myarr(1) / myarr(2)   ' neg/pos, truncated
myarr(1) = 8388607 : myarr(2) = 1          : results(34) = myarr(1) / myarr(2)   ' pos boundary / 1
myarr(1) = -8388608 : myarr(2) = 1         : results(35) = myarr(1) / myarr(2)   ' neg boundary / 1
myarr(1) = -8388608 : myarr(2) = -1        : results(36) = myarr(1) / myarr(2)   ' min / -1, overflow
myarr(1) = 8388607 : myarr(2) = -1         : results(37) = myarr(1) / myarr(2)   ' max / -1
myarr(1) = 0 : myarr(2) = 12345            : results(38) = myarr(1) / myarr(2)   ' zero dividend
myarr(1) = -7 : myarr(2) = 2               : results(39) = myarr(1) / myarr(2)   ' neg/pos, truncated towards zero

FOR i = 0 TO 9
	' Logical operations
	myarr(1) = i * 90000 + 3456789
	myarr(2) = i * 110000 + 1234567
	results(40 + i) = myarr(1) AND myarr(2)
	results(50 + i) = myarr(1) OR myarr(2)
	results(60 + i) = myarr(1) XOR myarr(2)

	' SHL()/SHR()
	IF i < 5 THEN
		myarr(1) = i * 70000 + 600000
		n(0) = i AND 7
		results(70 + i) = SHL(myarr(1), n(0))

		myarr(2) = i * 123456 + 7000000
		results(75 + i) = SHR(myarr(2), n(0))
	END IF
NEXT i

FOR j = 0 TO 15
	extras(j) = CBYTE((j * 17 + 3) XOR $AA)
NEXT j
