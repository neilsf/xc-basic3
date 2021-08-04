===
DIM
===

The ``DIM`` or ``STATIC`` statement is used to explicitly define variables and arrays.

Grammar
=======

.. image:: ../img/grammar_dim.png

Examples
========

.. code-block:: xcbasic

    DIM myvar AS INT
    ' Array definition
    DIM matrix(10,10) AS FLOAT
    ' String definition
    DIM myname$ AS STRING * 32
    ' Definition of a FAST variable
    DIM SHARED FAST i AS BYTE
    ' STATIC can be used inside a SUB or FUNCTION
    STATIC bignum AS LONG
    ' Array at explicit address
    DIM screen(40, 25) AS BYTE @ $0400

Test 11