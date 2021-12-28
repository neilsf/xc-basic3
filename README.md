# XC=BASIC 3

A BASIC cross compiler for MOS 6502-based machines

**This software is in pre-release (currently beta) state and may contain bugs.**

## Please help testing

We need to fix as many bugs as possible to be able to have an official release. You can contribute with testing. To do so, please follow these steps:

1. Read the docs at [xc-basic.net](https://xc-basic.net/doku.php?id=v3:start). Note that it is also under construction!
2. Download and install [DASM](https://dasm-assembler.github.io/) if you haven't yet done so. Make sure it is in your PATH.
3. Download this repo. You will find pre-compiled executables in the bin/ directory.
4. Write an example program of your interest. Try to keep it small in the beginning.
5. Compile it:

       xcbasic3 example.bas example.prg

or, for VIC-20:

       xcbasic3 example.bas example.prg --target=vic20

6. If you get a compilation error and you think it's a bug, please report it on GitHub. Please include the full BASIC listing in your report.
7. If the program crashes, try compiling without optimizing. In many cases it solves the problem and it means that the bug is in the optimizer.

       xcbasic3 example.bas example.prg --optimize=false

## Compiling from source

If a pre-compiled binary doesn't exist for your operating system, you can try compiling from sources.

Install the DMD compiler and the DUB package manager:

       sudo snap install --classic dmd
       sudo snap install --classic dub
       
(If you're on Windows, follow [these](https://dlang.org/dmd-windows.html) and [these](https://dub.pm/) instructions.)

Clone this repo:

       git clone https://github.com/neilsf/xc-basic3.git
       cd xc-basic3
       git submodule init
       git submodule update
    
Compile:

       dub build
