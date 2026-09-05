' Tests arithmetic operations on WORD arrays in XC=BASIC
' MONITOR: m c000 c0ff

' This page will be used to compare the results against the golden set
DIM results(127) AS WORD @ $C000
DIM myarr(4) AS WORD
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

' Addition: with and without 16-bit overflow (unsigned wraparound)
myarr(1) = 1000 : myarr(2) = 2000     : results(0)  = myarr(1) + myarr(2)   ' no overflow
myarr(1) = 60000 : myarr(2) = 3000    : results(1)  = myarr(1) + myarr(2)   ' near boundary, no overflow
myarr(1) = 65530 : myarr(2) = 10      : results(2)  = myarr(1) + myarr(2)   ' overflow
myarr(1) = 65535 : myarr(2) = 65535   : results(3)  = myarr(1) + myarr(2)   ' max+max, overflow
myarr(1) = 0 : myarr(2) = 0           : results(4)  = myarr(1) + myarr(2)   ' zero+zero
myarr(1) = 65535 : myarr(2) = 0       : results(5)  = myarr(1) + myarr(2)   ' max+0, no overflow
myarr(1) = 0 : myarr(2) = 65535       : results(6)  = myarr(1) + myarr(2)   ' 0+max, no overflow
myarr(1) = 1 : myarr(2) = 65535       : results(7)  = myarr(1) + myarr(2)   ' overflow by 1
myarr(1) = 32768 : myarr(2) = 32768   : results(8)  = myarr(1) + myarr(2)   ' symmetric overflow
myarr(1) = 40000 : myarr(2) = 25535   : results(9)  = myarr(1) + myarr(2)   ' exact boundary, no overflow
myarr(1) = 40000 : myarr(2) = 25536   : results(10) = myarr(1) + myarr(2)   ' exact boundary + 1, overflow
myarr(1) = 12345 : myarr(2) = 6789    : results(11) = myarr(1) + myarr(2)   ' plain, no overflow
myarr(1) = 50000 : myarr(2) = 50000   : results(12) = myarr(1) + myarr(2)   ' overflow
myarr(1) = 65535 : myarr(2) = 1       : results(13) = myarr(1) + myarr(2)   ' max+1, overflow
myarr(1) = 20000 : myarr(2) = 45535   : results(14) = myarr(1) + myarr(2)   ' exact boundary, no overflow
myarr(1) = 20000 : myarr(2) = 45536   : results(15) = myarr(1) + myarr(2)   ' exact boundary + 1, overflow

' Subtraction: with and without underflow (unsigned wraparound)
myarr(1) = 5000 : myarr(2) = 2000     : results(16) = myarr(1) - myarr(2)   ' no underflow
myarr(1) = 2000 : myarr(2) = 5000     : results(17) = myarr(1) - myarr(2)   ' underflow
myarr(1) = 0 : myarr(2) = 0           : results(18) = myarr(1) - myarr(2)   ' zero-zero
myarr(1) = 65535 : myarr(2) = 0       : results(19) = myarr(1) - myarr(2)   ' max-0
myarr(1) = 0 : myarr(2) = 65535       : results(20) = myarr(1) - myarr(2)   ' underflow, 0-max
myarr(1) = 65535 : myarr(2) = 65535   : results(21) = myarr(1) - myarr(2)   ' max-max, zero
myarr(1) = 1 : myarr(2) = 0           : results(22) = myarr(1) - myarr(2)   ' 1-0
myarr(1) = 0 : myarr(2) = 1           : results(23) = myarr(1) - myarr(2)   ' underflow, 0-1
myarr(1) = 30000 : myarr(2) = 30000   : results(24) = myarr(1) - myarr(2)   ' equal operands, zero
myarr(1) = 10000 : myarr(2) = 10001   : results(25) = myarr(1) - myarr(2)   ' underflow by 1
myarr(1) = 65535 : myarr(2) = 1       : results(26) = myarr(1) - myarr(2)   ' near max, no underflow
myarr(1) = 1 : myarr(2) = 65535       : results(27) = myarr(1) - myarr(2)   ' underflow, big
myarr(1) = 40000 : myarr(2) = 39999   : results(28) = myarr(1) - myarr(2)   ' no underflow, small diff
myarr(1) = 39999 : myarr(2) = 40000   : results(29) = myarr(1) - myarr(2)   ' underflow, small diff
myarr(1) = 65535 : myarr(2) = 65534   : results(30) = myarr(1) - myarr(2)   ' no underflow, diff 1
myarr(1) = 65534 : myarr(2) = 65535   : results(31) = myarr(1) - myarr(2)   ' underflow, diff 1

' Multiplication: with and without 16-bit overflow (unsigned wraparound)
myarr(1) = 100 : myarr(2) = 200       : results(32) = myarr(1) * myarr(2)   ' no overflow
myarr(1) = 300 : myarr(2) = 300       : results(33) = myarr(1) * myarr(2)   ' overflow
myarr(1) = 0 : myarr(2) = 12345       : results(34) = myarr(1) * myarr(2)   ' zero multiplicand
myarr(1) = 1 : myarr(2) = 65535       : results(35) = myarr(1) * myarr(2)   ' identity, no overflow
myarr(1) = 2 : myarr(2) = 32767       : results(36) = myarr(1) * myarr(2)   ' just under boundary, no overflow
myarr(1) = 2 : myarr(2) = 32768       : results(37) = myarr(1) * myarr(2)   ' exact boundary, overflow
myarr(1) = 255 : myarr(2) = 255       : results(38) = myarr(1) * myarr(2)   ' no overflow
myarr(1) = 256 : myarr(2) = 256       : results(39) = myarr(1) * myarr(2)   ' exact boundary, overflow
myarr(1) = 65535 : myarr(2) = 1       : results(40) = myarr(1) * myarr(2)   ' max identity, no overflow
myarr(1) = 65535 : myarr(2) = 2       : results(41) = myarr(1) * myarr(2)   ' overflow
myarr(1) = 200 : myarr(2) = 300       : results(42) = myarr(1) * myarr(2)   ' no overflow
myarr(1) = 200 : myarr(2) = 400       : results(43) = myarr(1) * myarr(2)   ' overflow
myarr(1) = 3 : myarr(2) = 20000       : results(44) = myarr(1) * myarr(2)   ' no overflow
myarr(1) = 3 : myarr(2) = 21846       : results(45) = myarr(1) * myarr(2)   ' overflow
myarr(1) = 500 : myarr(2) = 131       : results(46) = myarr(1) * myarr(2)   ' no overflow
myarr(1) = 500 : myarr(2) = 132       : results(47) = myarr(1) * myarr(2)   ' overflow

' Division: unsigned integer division
myarr(1) = 100 : myarr(2) = 5         : results(48) = myarr(1) / myarr(2)   ' exact
myarr(1) = 17 : myarr(2) = 5          : results(49) = myarr(1) / myarr(2)   ' truncated
myarr(1) = 65535 : myarr(2) = 1       : results(50) = myarr(1) / myarr(2)   ' max / 1
myarr(1) = 65535 : myarr(2) = 65535   : results(51) = myarr(1) / myarr(2)   ' max / max
myarr(1) = 1 : myarr(2) = 65535       : results(52) = myarr(1) / myarr(2)   ' small / large, result 0
myarr(1) = 0 : myarr(2) = 12345       : results(53) = myarr(1) / myarr(2)   ' zero dividend
myarr(1) = 65535 : myarr(2) = 2       : results(54) = myarr(1) / myarr(2)   ' truncated
myarr(1) = 60000 : myarr(2) = 7       : results(55) = myarr(1) / myarr(2)   ' truncated
myarr(1) = 50000 : myarr(2) = 50000   : results(56) = myarr(1) / myarr(2)   ' equal operands
myarr(1) = 65535 : myarr(2) = 3       : results(57) = myarr(1) / myarr(2)   ' exact
myarr(1) = 10 : myarr(2) = 3          : results(58) = myarr(1) / myarr(2)   ' truncated
myarr(1) = 9 : myarr(2) = 3           : results(59) = myarr(1) / myarr(2)   ' exact
myarr(1) = 65535 : myarr(2) = 65534   : results(60) = myarr(1) / myarr(2)   ' truncated to 1
myarr(1) = 2 : myarr(2) = 65535       : results(61) = myarr(1) / myarr(2)   ' small / large, result 0
myarr(1) = 40000 : myarr(2) = 1       : results(62) = myarr(1) / myarr(2)   ' division by 1
myarr(1) = 1 : myarr(2) = 1           : results(63) = myarr(1) / myarr(2)   ' identity

FOR i = 0 TO 15
	' Logical operations
	myarr(1) = i * 4100 + 43690
	myarr(2) = i * 3700 + 21845
	results(64 + i) = myarr(1) AND myarr(2)
	results(80 + i) = myarr(1) OR myarr(2)
	results(96 + i) = myarr(1) XOR myarr(2)

	' SHL()/SHR()
	IF i < 8 THEN
		myarr(1) = i * 1234 + 32100
		n(0) = i AND 7
		results(112 + i) = SHL(myarr(1), n(0))

		myarr(2) = i * 2222 + 50000
		results(120 + i) = SHR(myarr(2), n(0))
	END IF
NEXT i
