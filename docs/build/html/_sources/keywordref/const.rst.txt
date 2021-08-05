=====
CONST
=====

The ``CONST`` directive defines a constant.

Syntax
======

.. code-block::

    CONST <name> = <literal number>

Description
===========

A constant can subsequently be used as a variable, except that it is read-only. Constants of any numeric types may be defined. The number must be a numeric literal (no expression is allowed).

Examples
========

.. code-block:: xcbasic

    CONST BORDER = $d020
    CONST WHITE  = 1

    POKE BORDER, WHITE

    CONST PI = 3.1415926