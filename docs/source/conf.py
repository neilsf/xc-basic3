# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))

import sphinx_rtd_theme

# -- Project information -----------------------------------------------------

project = 'XC=BASIC 3'
copyright = '2021, Csaba Fekete'
author = 'Csaba Fekete'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    "sphinx_rtd_theme",
    "sphinx.ext.autosectionlabel",
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

from pygments.lexer import RegexLexer, bygroups, default, words, include
from pygments.token import *
from sphinx.highlighting import lexers
import re

class XCBLexer(RegexLexer):
    
    name = 'XC=BASIC'
    aliases = ['xcbasic']

    declarations = ('DATA', 'LET')

    functions = (
        'ABS', 'ASC', 'ATN', 'CDBL', 'CHR$', 'CINT', 'CLNG',
        'COMMAND$', 'COS', 'CSNG', 'CSRLIN', 'CVD', 'CVDMBF', 'CVI',
        'CVL', 'CVS', 'CVSMBF', 'DATE$', 'ENVIRON$', 'EOF', 'ERDEV',
        'ERDEV$', 'ERL', 'ERR', 'EXP', 'FILEATTR', 'FIX', 'FRE',
        'FREEFILE', 'HEX$', 'INKEY$', 'INP', 'INPUT$', 'INSTR', 
        'IOCTL$', 'LBOUND', 'LCASE$', 'LEFT$', 'LEN', 'LOC', 'LOF',
        'LOG', 'LPOS', 'LTRIM$', 'MID$', 'MKD$', 'MKDMBF$', 'MKI$',
        'MKL$', 'MKS$', 'MKSMBF$', 'OCT$', 'PEEK', 'PEN', 'PLAY',
        'PMAP', 'POINT', 'POS', 'RIGHT$', 'RND', 'RTRIM$', 'SADD',
        'SCREEN', 'SEEK', 'SETMEM', 'SGN', 'SIN', 'SPACE$', 'SPC',
        'SQR', 'STICK', 'STR$', 'STRIG', 'STRING$', 'TAB', 'TAN',
        'TIME$', 'TIMER', 'UBOUND', 'UCASE$', 'VAL', 'VARPTR',
        'VARPTR$', 'VARSEG'
    )

    metacommands = ('$DYNAMIC', '$INCLUDE', '$STATIC')

    operators = ('AND', 'EQV', 'IMP', 'NOT', 'OR', 'XOR')

    keywords = (
        'ACCESS', 'INCLUDE', 'CONST', 'APPEND', 'AS', 'BASE', 'DECIMAL',
        'BYVAL', 'CASE', 'CDECL', 'FLOAT', 'ELSE', 'ELSEIF', 'ENDIF',
        'INT', 'IS', 'LIST', 'LOCAL', 'LONG', 'LOOP', 'MOD',
        'NEXT', 'OFF', 'ON', 'OUTPUT', 'RANDOM', 'SIGNAL', 'BYTE',
        'STEP', 'STRING', 'THEN', 'TO', 'UNTIL', 'USING', 'WEND',
        'SHARED', 'FAST', 'DIM',
         'BEEP', 'BLOAD', 'BSAVE', 'CALL', 'CALL ABSOLUTE',
        'CALL INTERRUPT', 'CALLS', 'CHAIN', 'CHDIR', 'CIRCLE', 'CLEAR',
        'CLOSE', 'CLS', 'COLOR', 'COM', 'COMMON', 'CONST', 'DATA',
        'DATE$', 'DECLARE', 'DEF FN', 'DEF SEG', 'DEFDBL', 'DEFINT',
        'DEFLNG', 'DEFSNG', 'DEFSTR', 'DEF', 'DIM', 'DO', 'LOOP',
        'DRAW', 'END', 'ENVIRON', 'ERASE', 'ERROR', 'EXIT', 'FIELD',
        'FILES', 'FOR', 'NEXT', 'FUNCTION', 'GET', 'GOSUB', 'GOTO',
        'IF', 'THEN', 'INPUT', 'INPUT #', 'IOCTL', 'KEY', 'KEY',
        'KILL', 'LET', 'LINE', 'LINE INPUT', 'LINE INPUT #', 'LOCATE',
        'LOCK', 'UNLOCK', 'LPRINT', 'LSET', 'MID$', 'MKDIR', 'NAME',
        'ON COM', 'ON ERROR', 'ON KEY', 'ON PEN', 'ON PLAY',
        'ON STRIG', 'ON TIMER', 'ON UEVENT', 'ON', 'OPEN', 'OPEN COM',
        'OPTION BASE', 'OUT', 'PAINT', 'PALETTE', 'PCOPY', 'PEN',
        'PLAY', 'POKE', 'PRESET', 'PRINT', 'PRINT #', 'PRINT USING',
        'PSET', 'POKE', 'PUT', 'RANDOMIZE', 'READ', 'REDIM', 'REM',
        'RESET', 'RESTORE', 'RESUME', 'RETURN', 'RMDIR', 'RSET', 'RUN',
        'SCREEN', 'SEEK', 'SELECT CASE', 'SHARED', 'SHELL', 'SLEEP',
        'SOUND', 'STATIC', 'STOP', 'STRIG', 'SUB', 'SWAP', 'SYSTEM',
        'TIME$', 'TIMER', 'TROFF', 'TRON', 'TYPE', 'UEVENT', 'UNLOCK',
        'VIEW', 'WAIT', 'WHILE', 'WEND', 'WIDTH', 'WINDOW', 'WRITE'
    )

    tokens = {
        'root': [
            (r'\n+', Text),
            (r'\s+', Text.Whitespace),
            (r'^(\s*)(\d*)(\s*)(REM .*)$',
             bygroups(Text.Whitespace, Name.Label, Text.Whitespace,
                      Comment.Single)),
            (r'^(\s*)(\d+)(\s*)',
             bygroups(Text.Whitespace, Name.Label, Text.Whitespace)),
            (r'(?=[\s]*)(\w+)(?=[\s]*=)', Name.Variable.Global),
            (r'(?=[^"]*)\'.*$', Comment.Single),
            (r'"[^\n"]*"', String.Double),
            (r'(END)(\s+)(FUNCTION|IF|SELECT|SUB)',
             bygroups(Keyword.Reserved, Text.Whitespace, Keyword.Reserved)),
            (r'(DECLARE)(\s+)([A-Z]+)(\s+)(\S+)',
             bygroups(Keyword.Declaration, Text.Whitespace, Name.Variable,
                      Text.Whitespace, Name)),
            (r'^(\s*)([a-zA-Z_]+)(\s*)(\=)',
             bygroups(Text.Whitespace, Name.Variable.Global, Text.Whitespace,
                      Operator)),
            (r'(GOTO|GOSUB)(\s+)(\w+\:?)',
             bygroups(Keyword.Reserved, Text.Whitespace, Name.Label)),
            (r'(SUB)(\s+)(\w+\:?)',
             bygroups(Keyword.Reserved, Text.Whitespace, Name.Label)),
            #include('declarations'),
            #include('functions'),
            #include('metacommands'),
            #include('operators'),
            include('keywords'),
            (r'[a-zA-Z_]\w*[$@#&!]', Name.Variable.Global),
            (r'[a-zA-Z_]\w*\:', Name.Label),
            (r'\-?\d*\.\d+[@|#]?', Number.Float),
            (r'\-?\d+[@|#]', Number.Float),
            (r'\-?\d+#?', Number.Integer.Long),
            (r'\-?\d+#?', Number.Integer),
            (r'\$[0-9a-f]+', Number.Hex),
            (r'\%[10]+', Number.Bin),
            (r'!=|==|:=|\.=|<<|>>|[-~+/\\*%=<>&^|?:!.]', Operator),
            (r'[\[\]{}(),;]', Punctuation),
            (r'[\w]+', Name.Variable.Global),
        ],
        # can't use regular \b because of X$()
        # XXX: use words() here
        'declarations': [
            (r'\b(%s)(?=\(|\b)' % '|'.join(map(re.escape, declarations)),
             Keyword.Declaration),
        ],
        'functions': [
            (r'\b(%s)(?=\(|\b)' % '|'.join(map(re.escape, functions)),
             Keyword.Reserved),
        ],
        'metacommands': [
            (r'\b(%s)(?=\(|\b)' % '|'.join(map(re.escape, metacommands)),
             Keyword.Constant),
        ],
        'operators': [
            (r'\b(%s)(?=\(|\b)' % '|'.join(map(re.escape, operators)), Operator.Word),
        ],
        'keywords': [
            (r'\b(%s)\b' % '|'.join(keywords), Keyword),
        ],
    }

    def analyse_text(text):
        if '$DYNAMIC' in text or '$STATIC' in text:
            return 0.9

lexers['xcbasic'] = XCBLexer(startinline=True)