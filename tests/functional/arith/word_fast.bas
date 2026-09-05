' Tests arithmetic operations on FAST WORDs in XC=BASIC
' MONITOR: m c000 c0ff

' This page will be used to compare the results against the golden set
DIM results(127) AS WORD @ $C000
DIM a AS WORD FAST
DIM b AS WORD FAST
DIM n AS BYTE FAST
DIM i AS BYTE FAST

' 0..15   : addition
' 16..31  : subtraction
' 32..47  : multiplication
' 48..63  : division
' 64..79  : bitwise AND
' 80..95  : bitwise OR
' 96..111 : bitwise XOR
' 112..119: SHL()
' 120..127: SHR()

' Addition: with and without 16-bit overflow (unsigned wraparound)
a = 1000 : b = 2000     : results(0)  = a + b   ' no overflow
a = 60000 : b = 3000    : results(1)  = a + b   ' near boundary, no overflow
a = 65530 : b = 10      : results(2)  = a + b   ' overflow
a = 65535 : b = 65535   : results(3)  = a + b   ' max+max, overflow
a = 0 : b = 0           : results(4)  = a + b   ' zero+zero
a = 65535 : b = 0       : results(5)  = a + b   ' max+0, no overflow
a = 0 : b = 65535       : results(6)  = a + b   ' 0+max, no overflow
a = 1 : b = 65535       : results(7)  = a + b   ' overflow by 1
a = 32768 : b = 32768   : results(8)  = a + b   ' symmetric overflow
a = 40000 : b = 25535   : results(9)  = a + b   ' exact boundary, no overflow
a = 40000 : b = 25536   : results(10) = a + b   ' exact boundary + 1, overflow
a = 12345 : b = 6789    : results(11) = a + b   ' plain, no overflow
a = 50000 : b = 50000   : results(12) = a + b   ' overflow
a = 65535 : b = 1       : results(13) = a + b   ' max+1, overflow
a = 20000 : b = 45535   : results(14) = a + b   ' exact boundary, no overflow
a = 20000 : b = 45536   : results(15) = a + b   ' exact boundary + 1, overflow

' Subtraction: with and without underflow (unsigned wraparound)
a = 5000 : b = 2000     : results(16) = a - b   ' no underflow
a = 2000 : b = 5000     : results(17) = a - b   ' underflow
a = 0 : b = 0           : results(18) = a - b   ' zero-zero
a = 65535 : b = 0       : results(19) = a - b   ' max-0
a = 0 : b = 65535       : results(20) = a - b   ' underflow, 0-max
a = 65535 : b = 65535   : results(21) = a - b   ' max-max, zero
a = 1 : b = 0           : results(22) = a - b   ' 1-0
a = 0 : b = 1           : results(23) = a - b   ' underflow, 0-1
a = 30000 : b = 30000   : results(24) = a - b   ' equal operands, zero
a = 10000 : b = 10001   : results(25) = a - b   ' underflow by 1
a = 65535 : b = 1       : results(26) = a - b   ' near max, no underflow
a = 1 : b = 65535       : results(27) = a - b   ' underflow, big
a = 40000 : b = 39999   : results(28) = a - b   ' no underflow, small diff
a = 39999 : b = 40000   : results(29) = a - b   ' underflow, small diff
a = 65535 : b = 65534   : results(30) = a - b   ' no underflow, diff 1
a = 65534 : b = 65535   : results(31) = a - b   ' underflow, diff 1

' Multiplication: with and without 16-bit overflow (unsigned wraparound)
a = 100 : b = 200       : results(32) = a * b   ' no overflow
a = 300 : b = 300       : results(33) = a * b   ' overflow
a = 0 : b = 12345       : results(34) = a * b   ' zero multiplicand
a = 1 : b = 65535       : results(35) = a * b   ' identity, no overflow
a = 2 : b = 32767       : results(36) = a * b   ' just under boundary, no overflow
a = 2 : b = 32768       : results(37) = a * b   ' exact boundary, overflow
a = 255 : b = 255       : results(38) = a * b   ' no overflow
a = 256 : b = 256       : results(39) = a * b   ' exact boundary, overflow
a = 65535 : b = 1       : results(40) = a * b   ' max identity, no overflow
a = 65535 : b = 2       : results(41) = a * b   ' overflow
a = 200 : b = 300       : results(42) = a * b   ' no overflow
a = 200 : b = 400       : results(43) = a * b   ' overflow
a = 3 : b = 20000       : results(44) = a * b   ' no overflow
a = 3 : b = 21846       : results(45) = a * b   ' overflow
a = 500 : b = 131       : results(46) = a * b   ' no overflow
a = 500 : b = 132       : results(47) = a * b   ' overflow

' Division: unsigned integer division
a = 100 : b = 5         : results(48) = a / b   ' exact
a = 17 : b = 5          : results(49) = a / b   ' truncated
a = 65535 : b = 1       : results(50) = a / b   ' max / 1
a = 65535 : b = 65535   : results(51) = a / b   ' max / max
a = 1 : b = 65535       : results(52) = a / b   ' small / large, result 0
a = 0 : b = 12345       : results(53) = a / b   ' zero dividend
a = 65535 : b = 2       : results(54) = a / b   ' truncated
a = 60000 : b = 7       : results(55) = a / b   ' truncated
a = 50000 : b = 50000   : results(56) = a / b   ' equal operands
a = 65535 : b = 3       : results(57) = a / b   ' exact
a = 10 : b = 3          : results(58) = a / b   ' truncated
a = 9 : b = 3           : results(59) = a / b   ' exact
a = 65535 : b = 65534   : results(60) = a / b   ' truncated to 1
a = 2 : b = 65535       : results(61) = a / b   ' small / large, result 0
a = 40000 : b = 1       : results(62) = a / b   ' division by 1
a = 1 : b = 1           : results(63) = a / b   ' identity

FOR i = 0 TO 15
	' Logical operations
	a = i * 4100 + 43690
	b = i * 3700 + 21845
	results(64 + i) = a AND b
	results(80 + i) = a OR b
	results(96 + i) = a XOR b

	' SHL()/SHR()
	IF i < 8 THEN
		a = i * 1234 + 32100
		n = i AND 7
		results(112 + i) = SHL(a, n)

		b = i * 2222 + 50000
		results(120 + i) = SHR(b, n)
	END IF
NEXT i
