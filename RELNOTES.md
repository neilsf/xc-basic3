Version 3.1.0-alpha-0
=====================

This release is experimental only. There are probably lots of bugs to fix yet and some features may be missing on some targets.

- New targets: C128 and PET
- Multiple variables allowed in DIM statement, e.g. DIM a AS INT, b AS FLOAT
- String variables can be defined implicitly if length of RHS is given, e. g a$ = "hello" will define a$ AS STRING * 5
- Constants are accepted instead of numeric literals almost everywhere
- Use the underscore char (_) to split long lines
- OPTION directive to define compile options in source code
- SELECT CASE ... END SELECT blocks
- SPRITE commands (C64 and C128)
- SOUND commands (C64, C128, Vic-20, C16, CPlus/4)
- KEY() function to test keyboard
- JOY() function to test joystick
- BORDER and BACKGROUND commands (C64, C128, Vic-20, C16, CPlus/4)
- HSCROLL and VSCROLL commands (C64, C128, C16, CPlus/4)
- SCAN() function that returns scan line position (C64, C128, Vic-20, C16, CPlus/4)
- INTERRUPT commands (raster, timer, sprite interrupts)
- VMODE command to set video mode
