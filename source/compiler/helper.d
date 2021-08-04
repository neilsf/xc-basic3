module compiler.helper;

import std.string;

// Replace trailing $ with @ for DASM compatibility
public string fixSymbol(string symbol) {
    if(symbol != "" && symbol[$ - 1] == '$') {
        symbol = chomp(symbol, "$") ~ "@";
    }

    return symbol;
}