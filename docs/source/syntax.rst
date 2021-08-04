======
Syntax
======

Vocabulary
==========

The following reserved keywords form the basic vocabulary of the language. The keywords may be spelled with either upper or lower case letters, or a mix of both. Therefore ``PRINT``, ``print`` and ``Print`` are equivalent.

ASM BYTE CALL CHARAT CONST CONTINUE CURPOS DATA DECIMAL DECLARE DIM DO ELSE END ERROR EXIT FAST FLOAT FOR FUNCTION GOSUB GOSUB GOTO IF INCBIN INCLUDE INLINE INPUT INT LET LOAD LOOP MEMCPY MEMSET MEMSHIFT NEXT ON ORIGIN OVERRIDE POKE PRINT PRIVATE RETURN SAVE SHARED STATIC STEP STRING SUB SWAP SYS TEXTAT TO TYPE UNTIL WAIT WATCH WHILE WORD

In XC=BASIC (unlike CBM BASIC) you must separate keywords from each other or from other identifiers with at least one space. This does not impose any speed or size penalty on the program.

Identifiers
===========

Identifiers are used to name constants, variables, labels, subs and functions in XC=BASIC. You may choose identifiers
as you wish, following these rules:

 1. The first character must be alphabetic or an underscore (``_``) character
 2. The remaining characters must be alphabetic, numeric, or the underscore (``_``) character
 3. Either upper or lower case alphabetic characters may be used. Both are considered equivalent. Therefore ``XYZ`` and ``xyz`` are considered the same identifier.
 4. An identifer may not duplicate one of the reserved keywords in the basic vocabulary above.

Identifiers can be of any length. Unlike CBM BASIC, where only the first two characters are significant, in XC=BASIC all characters are significant. The length of your identifers does not affect the size of the compiled program. For this reason it is advised to use descriptive identifiers that are easy to read.

Statements
==========

Statements can be separated using the colon (``:``) character. The separator is not required if there's only one statement in a line. The following two code pieces will be compiled to the same exact executable.

.. code-block:: xcbasic

    FOR i AS INT = 1 TO 5 : PRINT i : NEXT

.. code-block:: xcbasic

    FOR i AS INT = 1 TO 5
      PRINT i
    NEXT

Comments
========

The only way to add comments is the REM statement. The REM keyword however has an alias: the single quote (') character:

.. code-block:: xcbasic

    REM This is a comment
    ' This is also a comment

Whitespace
==========

Whitespace (e.g spaces and tabs) are required between identifiers and keywords to avoid confusions. It is encouraged to use indentation to make the program more readable:

.. code-block:: xcbasic

    FOR i AS INT = 0 TO 10
      FOR j AS INT = 0 TO 10
        PRINT "row ", i, "column ", j
      NEXT j
    NEXT i

Labels and line numbers
=======================

Labels can be used to mark points in your code. Labels can be referenced by ``GOTO`` and ``GOSUB`` statements. Labels must be followed by a colon (``:``).

.. code-block:: xcbasic

    GOSUB intro
    END

    intro:
    PRINT "welcome to my program"  
    RETURN

In later sections of this tutorial you will learn more about how labels can be useful in your program.

In addition to labels, you can use line numbers as well. Line numbers will be treated by XC=BASIC like labels. However, bear in mind that:  
  
  - Line numbers do not have to be consecutive
  - The colon (``:``) character must not be appended to line numbers
  - Labels, line numbers or unnumbered/unlabeled lines can be mixed in the program

