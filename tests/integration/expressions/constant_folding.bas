' CHECK: ^[[:space:]]*pint 256[[:space:]]*$
' CHECK: ^[[:space:]]*pint -5[[:space:]]*$
' CHECK: ^[[:space:]]*plong 1000000[[:space:]]*$
' CHECK: ^[[:space:]]*pword 1001[[:space:]]*$
' CHECK: ^[[:space:]]*pword 300[[:space:]]*$
' CHECK: ^[[:space:]]*addword[[:space:]]*$
' CHECK: ^[[:space:]]*poke_constaddr \$D020[[:space:]]*$
' CHECK-NOT: ^[[:space:]]*(addbyte|subbyte|mulbyte|addint|subint|mulint|addlong)[[:space:]]*$
' CHECK-NOT: ^[[:space:]]*p[a-z]+_F_c[a-z]+_[a-z]+ 

' Constant expressions are evaluated at compile time and
' untyped constants take the type of the other operand
DIM i AS INT, w AS WORD, l AS LONG, b AS BYTE
CONST BASE = $D000
CONST K AS WORD = 1000

i = 250 + 6
i = 5 - 10
l = 1000 * 1000
w = K + 1
w = b + 200 + 100
POKE BASE + $20, 0
