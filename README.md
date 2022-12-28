# XC=BASIC 3

XC=BASIC is a cross compiled, modern BASIC programming language for MOS 65xx based targets. The supported targets are:

* Commodore-64
* Commodore VIC-20
* Commodore-16
* Commodore Plus/4
* Commodore PET series
* Commodore-128

XC=BASIC compiles BASIC source code to fast machine code. Although not 100% compatible, its syntax was designed to be similar to that of QuickBASIC and CBM BASIC.

## Documentation

You can find the documentation (including installation instructions) at [xc-basic.net](https://xc-basic.net/doku.php?id=v3:start).

## Compiling from source

You can find pre-compiled binaries for Windows (x86_64), Linux (x86_64, ARM) and macOS (x86_64) in the `bin/` dir. If you run a different operating system, you have to compile the program from source.

XC=BASIC was written in the [D programming language](https://dlang.org/). To compile it, you need

* a [D compiler](https://dlang.org/download.html) (DMD is recommended)
* the [DUB](https://dub.pm/) package manager

If you install DUB using a package manager, it will most likely install DMD as a dependency. When you have both installed, just `cd` to the XC=BASIC directory and issue the command:

    dub build

Then move the generated executable to any subfolder in the `bin/` dir, for example:

    mkdir bin/myOS
    mv xcbasic3 bin/myOS/

(This last step is important because XC=BASIC can only find the library files if they're located in `../../lib` relative to the executable.)

That's it, you can now run XC=BASIC.
