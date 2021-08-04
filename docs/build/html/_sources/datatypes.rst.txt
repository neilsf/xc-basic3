==========
Data types
==========

Primitive types
===============

XC=BASIC offers 7 built-in data types, called primitive types:

+---------+---------------------------------------------------+------------------+
| Type    | Numeric range                                     | Size in bytes    |
+=========+===================================================+==================+
| BYTE    | 0 to 255                                          |                1 |
+---------+---------------------------------------------------+------------------+
| INTEGER | -16,378 to 16,377                                 |                2 |
+---------+---------------------------------------------------+------------------+
| WORD    | 0 to 65,535                                       |                2 |
+---------+---------------------------------------------------+------------------+
| LONG    | -8,388,608 to 8,388,607                           |                3 |
+---------+---------------------------------------------------+------------------+
| FLOAT   | ±2.93874⨉10\ :sup:`-39` to ±1.69477⨉10\ :sup:`38` |                4 |
+---------+---------------------------------------------------+------------------+
| DECIMAL | 0 to 9999                                         |                2 |
+---------+---------------------------------------------------+------------------+
| STRING  | N/A                                               |             1-97 |
+---------+---------------------------------------------------+------------------+

Byte
----

Byte is the smallest and fastest numeric type. Bytes can typically be used
as array indices,counters in FOR loops,  boolean (TRUE/FALSE) values and many
more.

Integer
-------

The most commonly used type in XC=BASIC programs. Integers offer a reasonably
high range, they support negative numbers while still being very fast.

Word
----

A Word is the unsigned version of an integer. They're especially useful for
specifying memory addresses, e.g in a POKE or PEEK statement.

Long
----

Similar to Integers, but the numeric large is much larger. Longs take 3 bytes
in memory.

Float
-----

Floats are 32-bit floating point numbers with a 24-bit mantissa and an 8-bit
exponent. They are similar to the numeric data type in CBM BASIC, but are
accurate to only 6-7 decimal digits.

.. warning:: Floating point variables have great flexibility because they can store very large and very small numbers, including a decimal fraction. However, they are manipulated much more slowly than the other types, and therefore should be used with caution.

Decimal
-------

This is a special type and the only reason it exists in XC=BASIC is because
decimal (BCD) numbers can be displayed on screen without the overhead of
binary-decimal conversion. Decimals come in handy when you have to display
scores or other numeric information in a game fairy quickly. Decimals have
strict limitations. They only support addition and subtraction and they can
not be converted to or from any other types.

.. note:: When displaying decimals, all the leading zeroes will be displayed, e.g the number ``99`` will be displayed as ``0099``.

Literal numbers
===============

When compiling the program, the compiler has to assign a type to the literal numbers. The type of a number
is recognized using the following rules, in this order:

* A number with a decimal dot (``.``) will be recognized as Float. For example, the number ``1.0`` is a Float.
* A number appended with a ``d`` will be recognized as Decimal. For example, ``9999d`` is a valid Decimal.
* A number between 0 and 255 will be recognized as Byte
* A number between -32,768 and 32,767 will be recognized as Integer
* A number between 32,768 and 65,535 will be recognized as Word
* A number between -8,388,608 and 8,388,607 will be recognized as Long
* Any other number will trigger a compile-time error

Floats must use a decimal point, even if its fractional part is zero. Without
the decimal point the compiler will treat the number as integer and
the program might be spending precious runtime converting it back to Float.

.. note:: You can use scientific notation, e.g ``1.453E-12`` when writing Float literals.

User-defined types (UDTs)
=========================

Apart from the built-in types you can define your own types using the ``TYPE`` keyword.