' CHECK: ^[[:space:]]*INCBIN[[:space:]]+".+/incbin\.test\.data"[[:space:]]*$
' CHECK: ^[[:space:]]*INCBIN[[:space:]]+".+/incbin\.test\.data"[[:space:]]*,[[:space:]]*4[[:space:]]*$

INCBIN "./incbin.test.data"
INCBIN "./incbin.test.data", 4