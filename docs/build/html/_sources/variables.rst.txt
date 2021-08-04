=========
Variables
=========

XC=BASIC is a statically typed programming language which means that the type of a variable is known at compile time. 
All variables have a type and that type can not change.

Defining variables
===================

In an XC=BASIC program, all variables must be defined before they're used.
Either you define them using the ``DIM`` statement (this is called explicit definition)
or the compiler can auto-define them in some situations. The latter is called implicit definition.

Explicit definition
-------------------

The ``DIM`` statement can be used to explicitly define variables. The syntax is **DIM <variable name> AS <type>**.
Examples of variable definition using ``DIM``:

.. code-block:: xcbasic

    DIM enemy_count AS INT
    DIM score AS DECIMAL
    DIM gravity AS FLOAT
    DIM name$ AS STRING * 16

Apart from the ``DIM`` statement, there are other cases where you can explicitly define a variable.
You will learn about them later.

.. note:: Defining variable types by using sigils (the ``#``, ``%`` and ``!`` suffixes) is not supported in XC=BASIC. The ``$`` character is allowed in variable names for readibility but the variable won't be defined as String just because the ``$`` sign is there. You must use ``DIM`` to define Strings.

Implicit definition
-------------------

If an undefined variable is encountered by the compiler, it will try to define it silently. For example:

.. code-block:: xcbasic

    a = 5
    PRINT a

The above program will work because the compiler will implicitly define the variable ``a`` in the first line. But what type will
it be? Well, the compiler will first check the right hand side of the assignment, that is the number ``5``. If you remember from
the previous topic, a number between 0 and 255 will be of Byte type and therefore ``a`` will also be of type Byte. This is called
an inferred type because the type is concluded by looking at the expression.

This seems very convenient but it is something you should avoid. Take the following example:

.. code-block:: xcbasic

    a = 5
    a = a + 300
    PRINT a

In CBM BASIC, where the only numeric type is Float, you can safely expect the result to be ``305``. Well, in
XC=BASIC, this is not the case. Let's break down the above program and see how it's compiled:

1. The compiler defines ``a`` as Byte and assigns the value ``5`` to it
2. The expression ``a + 300`` is evaluated. Since ``300`` is an Int, the expression will be evaluated as Int, resulting to ``305``.
3. Now the result must be assigned to ``a``. The number ``305`` can't be assigned to a Byte, so it will be truncated to 8 bits first.
4. The result is ``49``.

We can fix the above program by explicitly defining ``a`` as Int:

.. code-block:: xcbasic

    DIM a AS INT
    a = 5
    a = a + 300
    ' The result is: 305
    PRINT a

.. warning:: It is recommended that you define variables explicitly rather than let the compiler make guesses.

.. note:: Unlike CBM BASIC variables, which are automatically initialized to ``0``, XC=BASIC does not provide any initialization of variables. This means that you cannot assume anything about the value of a variable until you have assigned some value to it. The initial value of a variable is simply whatever happens to be in the memory location XC=BASIC assigns to the variable.

Constants
=========

Constants are not variables in a sense that they do not reserve memory at all. However, you can use them just like a variable, except that they may not change value in runtime.

The benefits of using constants instead of variables are:

- Constants do not reserve space in memory
- Constants are faster to evaluate

Always prefer constants over variables, whenever possible. See the ``CONST`` keyword for more information.

Arrays
======

Arrays are similar to arrays in CBM BASIC.

- They must be explicitly defined in all cases using ``DIM``
- The maximum number of dimensions is 3

A few examples of defining arrays:

.. code-block:: xcbasic

    DIM cards(52) AS BYTE
    DIM my_cards(5) AS BYTE
    DIM matrix(5, 5) AS FLOAT

Accessing array members is done using the usual BASIC syntax:

.. code-block:: xcbasic

    DIM my_array(3, 3) AS LONG
    x = my_array(0, 1)

.. warning:: Array indices are zero-based as opposed to CBM BASIC where they're one-based. The ``OPTION BASE`` statement is currently not supported, so you can't change this.

.. warning:: In order to access array members as fast as possible, array bounds are not checked in runtime! If you use an index that is out of the bounds, the result will be undefined.

.. code-block:: xcbasic

    DIM numbers(10) AS LONG
    ' This will compile fine but
    ' probably break your program because
    ' the last index in the array is 9.
    i = 10
    numbers(i) = 9999

Variable scope
==============

There are three scopes in XC=BASIC: 

- **Shared**: the widest scope, a shared variable is visible in all code modules (or source files)
- **Global**: the variable is visible in the current code module (in the source file where it was defined)
- **Local**: the variable is only visible within the ``SUB`` or ``FUNCTION`` where it was defined.

If you define a variable outside a ``SUB`` or ``FUNCTION``, it will be defined the **Global** scope which
means that you can access it everywhere in that file (even from within ``SUB``\s and ``FUNCTION``\s), but not in other files.

If you define a variable inside a ``SUB`` or ``FUNCTION``, it will be defined in the **Local** scope of that ``SUB`` or ``FUNCTION``
and it won't be accessible from anywhere else.

Using the ``SHARED`` keyword in a ``DIM`` statement, you can make a variable visible from all code modules (or source files):

.. code-block:: xcbasic

    ' This file is first.bas
    ' 'a' is a global variable in this file only
    DIM a AS INT
    ' 'b' is a shared variable visible in other files as well
    DIM SHARED b AS INT
    a = 5
    b = 10
    INCLUDE "second.bas"
    ' Will print: 5
    PRINT a
    ' Will print: 11
    PRINT b

.. code-block:: xcbasic

    ' This file is second.bas
    ' 'a' is a global variable in this file only
    ' It doesn't collide with the other 'a' in first.bas
    DIM a AS INT
    a = 6
    ' We can access 'b' from first.bas
    b = 11

Fast variables
==============

If you define a variable as ``FAST``, it will be reserved on the zero page, making it faster to operate on. The space on zero page is limited, therefore you may only define a few variables as ``FAST``.

.. code-block:: xcbasic

    DIM FAST ix AS BYTE
    FOR ix = 0 TO 255
      ' A very fast loop
    NEXT

.. note:: When no more variables can be placed on the zero page, the compiler will emit a warning and ignore the ``FAST`` directive.

Data definitions
================

TBD 5