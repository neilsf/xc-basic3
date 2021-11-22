# XC=BASIC 3

A BASIC cross compiler for MOS 6502-based machines

This software is in pre-release (currently aplha) state. Nothing is guranteed to work.

## Please help testing

We need to fix as many bugs as possible to be able to have an official release. You can contribute with testing. To do so, please follow these steps:

1. Read the docs at [xc-basic.net](https://xc-basic.net/doku.php?id=v3:start). Note that it is also under construction!
2. Download and install [DASM](https://dasm-assembler.github.io/) if you haven't yet done so. Make sure it is in your PATH.
3. Install the DMD compiler and and DUB package manager:

       sudo snap install --classic dmd
       sudo snap install --classic dub
       
(If you're on Windows, follow [these](https://dlang.org/dmd-windows.html) and [these](https://dub.pm/) instructions.)

4. Clone this repo:

       git clone https://github.com/neilsf/xc-basic3.git
       cd xc-basic3
       git submodule update
    
5. Compile:

       dub build

6. Now you have an executable called _xcbasic3_ or _xcbasic3.exe_
7. Write an example program of your interest. Try to keep it small in the beginning.
8. Compile it:

       xcbasic3 example.bas example.prg --target=vic20|c64

9. If you get a compilation error and you think it's a bug, please report it on GitHub. Please include the full BASIC listing in your report.
10. If the program is comiled but you think it doesn't do what it's supposed to, please report it.

Thanks!
