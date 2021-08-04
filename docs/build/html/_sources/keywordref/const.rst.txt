=====
CONST
=====

The ``CONST`` directive defines a constant.

Grammar
=======

.. image:: ../img/grammar_const.png

A constant can subsequently be used as a variable, except that it is read-only. Constants of any numeric types may be defined. The number must be a numeric literal (no expression is allowed).

Examples
========

.. code-block:: xcbasic

    CONST BORDER = $d020
    CONST WHITE  = 1

    POKE BORDER, WHITE

    CONST PI = 3.1415926