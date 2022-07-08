'XC=BASIC built-in function headers

'Math functions
DECLARE FUNCTION ABS AS BYTE (num AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION ABS AS INT (num AS INT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION ABS AS WORD (num AS WORD) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION ABS AS LONG (num AS LONG) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION ABS AS FLOAT (num AS FLOAT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION RNDL AS LONG () SHARED STATIC INLINE
DECLARE FUNCTION RNDI AS INT () SHARED STATIC INLINE
DECLARE FUNCTION RNDW AS WORD () SHARED STATIC INLINE
DECLARE FUNCTION RNDB AS BYTE () SHARED STATIC INLINE
DECLARE FUNCTION RND AS FLOAT () SHARED STATIC INLINE
DECLARE FUNCTION SGN AS INT (num AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION SGN AS INT (num AS INT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SGN AS INT (num AS WORD) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SGN AS INT (num AS LONG) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SGN AS INT (num AS FLOAT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SQR AS BYTE (num AS INT) SHARED STATIC INLINE
DECLARE FUNCTION SQR AS BYTE (num AS WORD) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SQR AS WORD (num AS LONG) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SQR AS FLOAT (num AS FLOAT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION POW AS LONG (base AS WORD, exp AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION POW AS LONG (base AS INT, exp AS BYTE) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION POW AS FLOAT (base AS FLOAT, exp AS FLOAT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION EXP AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
DECLARE FUNCTION LOG AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
DECLARE FUNCTION INT AS FLOAT (num AS FLOAT) SHARED STATIC INLINE
DECLARE FUNCTION SHL AS BYTE (num AS BYTE, n AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION SHL AS INT (num AS INT, n AS BYTE) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SHL AS WORD (num AS WORD, n AS BYTE) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SHL AS LONG (num AS LONG, n AS BYTE) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SHR AS BYTE (num AS BYTE, n AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION SHR AS INT (num AS INT, n AS BYTE) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SHR AS WORD (num AS WORD, n AS BYTE) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION SHR AS LONG (num AS LONG, n AS BYTE) OVERLOAD SHARED STATIC INLINE

'System and IO functions
DECLARE FUNCTION PEEK AS BYTE (address AS WORD) SHARED STATIC INLINE
DECLARE FUNCTION TI AS LONG () SHARED STATIC INLINE
DECLARE FUNCTION ST AS BYTE () SHARED STATIC INLINE
DECLARE FUNCTION CSRLIN AS BYTE () SHARED STATIC INLINE
DECLARE FUNCTION POS AS BYTE () SHARED STATIC INLINE
DECLARE FUNCTION ERR AS BYTE () SHARED STATIC INLINE

'String functions
DECLARE FUNCTION LEFT$ AS STRING (instr$ AS STRING, length AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION RIGHT$ AS STRING (instr$ AS STRING, length AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION MID$ AS STRING (instr$ AS STRING, pos AS BYTE, length AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION LEN AS BYTE (instr$ AS STRING) SHARED STATIC INLINE
DECLARE FUNCTION CHR$ AS STRING (charcode AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION ASC AS BYTE (char$ AS STRING) SHARED STATIC INLINE
DECLARE FUNCTION STR$ AS STRING (number AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION STR$ AS STRING (number AS INT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION STR$ AS STRING (number AS WORD) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION STR$ AS STRING (number AS LONG) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION STR$ AS STRING (number AS FLOAT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION STR$ AS STRING (number AS DECIMAL) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION VAL AS FLOAT (instr$ AS string) SHARED STATIC INLINE
DECLARE FUNCTION LCASE$ AS STRING (instr$ AS STRING) SHARED STATIC INLINE
DECLARE FUNCTION UCASE$ AS STRING (instr$ AS STRING) SHARED STATIC INLINE

'Type Conversion
DECLARE FUNCTION CBYTE AS BYTE (number AS INT) SHARED STATIC INLINE
DECLARE FUNCTION CBYTE AS BYTE (number AS WORD) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CBYTE AS BYTE (number AS LONG) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CBYTE AS BYTE (number AS FLOAT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CINT AS INT (number AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION CINT AS INT (number AS WORD) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CINT AS INT (number AS LONG) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CINT AS INT (number AS FLOAT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CWORD AS WORD (number AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION CWORD AS WORD (number AS INT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CWORD AS WORD (number AS LONG) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CWORD AS WORD (number AS FLOAT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CLONG AS LONG (number AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION CLONG AS LONG (number AS INT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CLONG AS LONG (number AS WORD) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CLONG AS LONG (number AS FLOAT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CFLOAT AS FLOAT (number AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION CFLOAT AS FLOAT (number AS INT) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CFLOAT AS FLOAT (number AS WORD) OVERLOAD SHARED STATIC INLINE
DECLARE FUNCTION CFLOAT AS FLOAT (number AS LONG) OVERLOAD SHARED STATIC INLINE

'Sprites
DECLARE FUNCTION SPRITEHIT AS BYTE (sprno AS BYTE) SHARED STATIC INLINE
DECLARE FUNCTION SPRITEHITBG AS BYTE (sprno AS BYTE) SHARED STATIC INLINE
