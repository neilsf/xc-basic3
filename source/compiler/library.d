module compiler.library;

import std.file, std.path;

/** Name of the XC=BASIC library file */
public const string LIBRARY_FILENAME = "xcb3lib.asm";

/**
 * Returns full path to the XC=BASIC library
 */
public string getLibraryPath()
{
    return getLibraryDir() ~ "/" ~ LIBRARY_FILENAME;
}

/**
 * Returns location of the XC=BASIC library
 */
public string getLibraryDir()
{
    string path = thisExePath();
    version(Posix) {
        if(isSymlink(path)) {
            const string target = readLink(path);
            if(isAbsolute(target)) {
                path = target;
            }
            else {
                const string currentDir = getcwd();
                chdir(dirName(path));
                path = absolutePath(target);
                chdir(currentDir);
            }
        }
    }
    return dirName(path) ~ "/lib";
}