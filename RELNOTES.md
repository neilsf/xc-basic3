#Version 3.1.0

##New features

- New targets: C128 and PET
- Multiple variables allowed in DIM statement, e.g. DIM a AS INT, b AS FLOAT
- String variables can be implicitly defined
- Constants are accepted instead of numeric literals almost everywhere
- Introduced the underscore char (_) to split long lines
- OPTION directive to define compile options in source code
- SELECT CASE ... END SELECT blocks
- SPRITE commands and functions (C64 and C128)
- Sound commands (VOICE, VOLUME, FILTER) (C64, C128, Vic-20, C16, CPlus/4)
- KEY() function to test keyboard
- JOY() function to test joystick
- SCAN() function to read scanline position (C64, C128, Vic-20, C16, CPlus/4)
- BORDER and BACKGROUND commands (C64, C128, Vic-20, C16, CPlus/4)
- HSCROLL and VSCROLL commands (C64, C128, C16, CPlus/4)
- INTERRUPT commands (raster, timer, sprite interrupts)
- VMODE command to set video mode
- CHARSET command to set video character set

##Bugfxes and improvements

- Various grammar improvements
- Reorganized zero page usage
- ASM blocks can read multiple variable references in the same line
- Fixed READ misbehaving with arrays
- Fixed crash when function name too short
- Option to protecct high memory
- Fixed dynamic string creation on function stack
- Fixed missing label at end of source
- Fixed decimal comparison crashing
- Library and var segments are relocated in memory
- Optimized INPUT routine
