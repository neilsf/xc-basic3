# Unreleased

## Breaking changes

- Numeric literals and `CONST` values defined without an explicit type are now untyped.
  An untyped constant adapts to the type of the other operand, e.g. `b + 1` is a `BYTE`
  operation if `b` is a `BYTE`. If the constant does not fit in that type, the operation is
  promoted to the smallest type that can hold both, e.g. `b + 300` is a `WORD` operation and
  `b * -1` is an `INT` operation.
- Constant expressions (numeric literals and `CONST` values) are evaluated at compile time with
  exact arithmetic, e.g. `250 + 6` now evaluates to `256` instead of wrapping to `0`.
  Division truncates toward zero and `MOD` follows the runtime rules. Division by zero and
  results out of the 24-bit range are compile-time errors.
- Constants in an expression are combined where possible, e.g. `b + 200 + 100` is compiled
  as `b + 300`.
- Assigning or passing an untyped constant that does not fit the target type is now an error
  (e.g. `b = 300` or `POKE addr, -1`). Use an explicitly typed constant or a variable if
  wrapping is intended.
- Arithmetic on typed operands (variables, functions, typed constants) is unchanged and still
  wraps within its type, e.g. `b1 + b2` where both are `BYTE`.
- `CONST` accepts constant expressions (e.g. `CONST SIZE = WIDTH * HEIGHT`). A constant
  declared with `AS <type>` is typed and behaves like a variable of that type in expressions.
- Untyped constant arguments match any numeric parameter type that can hold their value when
  resolving overloaded routines.
- A `FOR` loop with an unsigned counter and a negative constant `STEP` is now an error.

# Version 3.1.13

## Bugfixes and improvements

- Fixed implicit type conversion when argument list contains strings (#247)
- Fixed `REM` being included in intermediate code (#266)
- Fixed missing `TI()` function on X16 target (#267)
- Fixed compiler error when targeting vic20_8k (#269)
- Fixed `KEY()` function for PET and updated keyboard scancode library (#270)
- Unused subroutines no longer consume variable memory (#274)
- Additional grammar fixes and compiler output improvements (#276)
- Build pipeline updates: switched Linux builds to LDC and refreshed macOS build setup

# Version 3.1.12

## New features

- `DATA` statements now support labels (#261)

# Version 3.1.11

## Bugfixes and improvements

- Updated grammar module and applied grammar fixes
- Fixed `ON BACKGROUND` not working (#249)
- Fixed assembly error regression (#254)
- Fixed `SPRITE XYSIZE` argument order (#252)
- Fixed `LET`/`CONST` whitespace parsing regression (#250)
- Fixed `SPRITEBGHIT()` function behavior (#256)
- Fixed shorthand boolean expression handling (#253)
- Additional timer interrupt fixes

# Version 3.1.10

## Bugfixes and improvements

- Fixed timer interrupt handling problems

# Version 3.1.9

## Bugfixes and improvements

- Fixed wrong sign in `LONG` division result (#238)

# Version 3.1.8

## Bugfixes and improvements

- Added and fixed missing `DOKE` keyword handling

# Version 3.1.7

## Bugfixes and improvements

- Fixed string stack issues (#236)
- Fixed `VAL()` function leaving a string on stack (#236)
- Fixed wrong line numbers in Windows error messages (#234)

# Version 3.1.6

## Bugfixes and improvements

- Fixed variable name parsing in `NEXT` statement (#232)
- Fixed `SPRITE` number overwriting `THIS` address (#231)

# Version 3.1.5

## Bugfixes and improvements

- Fixed regression bug in `PRINT#` and `INPUT#` commands (#223)
- Fixed grammar bug (#208)

# Version 3.1.4

## Bugfixes and improvements

- Fixed grammar error in `SPRITE ON BACKGROUND` command (#224)
- Additional grammar fixes (#228)
- Release pipeline updates for branch and build handling

# Version 3.1.3

## New features

- Added `DOKE` and `DEEK` memory access commands

# Version 3.1.2

## Bugfixes and improvements

- Proper initialization of floating point workspace (#220)
- On-demand inclusion of sprite and sound libraries (#222)
- Fixed `FOR` loop overflow edge case at 32767 (#225)

# Version 3.1.1

## Bugfixes and improvements

- Fixed crash when too many values are used in `DATA` statements (#213)
- Fixed wrong `ADSR` register values in sound handling (#218)
- Fixed `SELECT` block handling in dynamic `SUB`s (#214, #215)
- Fixed invalid result on first call to `FOUT` (#217)

# Version 3.1.0

## New features

- New targets: C128 and PET
- Multiple variables allowed in `DIM` statement, e.g. `DIM a AS INT, b AS FLOAT`
- String variables can be implicitly defined
- Constants are accepted instead of numeric literals almost everywhere
- Introduced the underscore char (`_`) to split long lines
- `OPTION` directive to define compile options in source code
- `SELECT CASE ... END SELECT` blocks
- `SPRITE` commands and functions (C64 and C128)
- Sound commands (`VOICE`, `VOLUME`, `FILTER`) (C64, C128, Vic-20, C16, CPlus/4)
- `KEY()` function to test keyboard
- `JOY()` function to test joystick
- `SCAN()` function to read scanline position (C64, C128, Vic-20, C16, CPlus/4)
- `BORDER` and `BACKGROUND` commands (C64, C128, Vic-20, C16, CPlus/4)
- `HSCROLL` and `VSCROLL` commands (C64, C128, C16, CPlus/4)
- `INTERRUPT` commands (raster, timer, sprite interrupts)
- `VMODE` command to set video mode
- `CHARSET` command to set video character set

## Bugfxes and improvements

- Various grammar improvements
- Reorganized zero page usage
- `ASM` blocks can read multiple variable references in the same line
- Fixed `READ` misbehaving with arrays
- Fixed crash when function name too short
- Option to protect high memory
- Fixed dynamic string creation on function stack
- Fixed missing label at end of source
- Fixed decimal comparison crashing
- Library and var segments are relocated in memory
- Optimized `INPUT` routine
