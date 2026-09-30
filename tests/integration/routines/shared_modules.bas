' CHECK: ^F_clear_keyboard_buffer SUBROUTINE$
' CHECK: ^F_shared_value SUBROUTINE$

INCLUDE "./shared_modules.decl"
CALL clear_keyboard_buffer()
DIM value AS BYTE
value = shared_value()
