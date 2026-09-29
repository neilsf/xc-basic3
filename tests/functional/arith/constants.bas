' Tests untyped constants and compile-time constant folding in XC=BASIC
' MONITOR: m c000 c04a

' This page will be used to compare the results against the golden set
DIM results(25) AS LONG @ $C000
DIM b AS BYTE, b2 AS BYTE, w AS WORD, i AS INT, l AS LONG

CONST N = 4 * 8
CONST K AS BYTE = 200
CONST H = 3000000 * 2

' Constant-only expressions are evaluated exactly at compile time
results(0) = 250 + 6                 ' 256, no BYTE overflow
results(1) = 5 - 10                  ' -5
results(2) = 1000 * 1000             ' 1000000
results(3) = (3 + 4) * (10 - 2)      ' 56
results(4) = -7 / 2                  ' -3, truncates toward zero
results(5) = -7 MOD 3                ' 1, same as runtime MOD
results(6) = N * N * N * N           ' 1048576
results(7) = H                       ' 6000000

' Mixed expressions: the untyped constant adapts to the typed operand
' and promotes the operation if its value does not fit
b = 200 : results(8) = b + 300       ' 500
b = 5   : results(9) = b * -1        ' -5
w = 0   : results(10) = w + -1       ' -1
b = 10  : results(11) = b + 200 + 100 ' 310, constants are combined
i = -5  : results(12) = i * 2 + 1    ' -9
l = 100000 : results(13) = l + 1     ' 100001

' Variable arithmetic keeps wrapping within its own type
b = 0   : results(14) = b - 1        ' 255
b = 200 : b2 = 100 : results(15) = b + b2 ' 44
w = 65535 : results(16) = w + 1      ' 0
results(17) = K + 100                ' 44, K is a typed BYTE constant

' Bitwise NOT of an untyped constant
b = NOT 0 : results(18) = b          ' 255
i = NOT 0 : results(19) = i          ' -1

' Comparisons with untyped constants
b = 100 : results(20) = b < 300      ' 255 (true)
b = 255 : results(21) = b = -1      ' 0 (false)
results(22) = 3 > 2                  ' 255 (true)

' Constant expressions in DIM and FOR
DIM arr(N * 2) AS BYTE
results(23) = N * 2                  ' 64
l = 0
FOR i = 1 TO N / 4
  l = l + i
NEXT
results(24) = l                      ' 36

END
