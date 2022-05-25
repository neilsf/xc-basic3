; ------------------------------------------
; XC=BASIC
; Pseudo-registers
;
; ZP locations reserved
; ------------------------------------------

; R0-R1-R2-R3 must be consecutive
R0	EQU $02
R1	EQU $03
R2	EQU $04
R3	EQU $05
; R4-R5-R6-R7 must be consecutive
R4	EQU $06
R5	EQU $07
R6	EQU $08
R7	EQU $09
; R8-R9-RA-RB must be consecutive
R8	EQU $0A
R9	EQU $0B
RA	EQU $0C
RB	EQU $0D
; Pointer to current stack frame
; Must be 2 consecutive bytes
RC  EQU $0E
RD  EQU $0F
; Tmp Pointer to next stack frame
; Must be 2 consecutive bytes
RE	EQU $10
RF	EQU $11
; Pointer to "this"
TH  EQU $12
; Pointer to current string in work area
SP	EQU $14
; Current sprite number
SN  EQU $15