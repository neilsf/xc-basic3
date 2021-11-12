; ------------------------------------------
; XC=BASIC
; Pseudo-registers
;
; ZP locations reserved
; ------------------------------------------

; R0-R1-R2-R3 must be consecutive
R0	EQU $FB
R1	EQU $FC
R2	EQU $FD
R3	EQU $FE
; R4-R5-R6-R7 must be consecutive
R4	EQU $08
R5	EQU $09
R6	EQU $0A
R7	EQU $0B
; R8-R9-RA-RB must be consecutive
R8	EQU $0C
R9	EQU $0D
RA	EQU $0E
RB	EQU $0F
; Pointer to current stack frame
; Must be 2 consecutive bytes
RC  EQU $06
RD  EQU $07
; Tmp Pointer to next stack frame
; Must be 2 consecutive bytes
RE	EQU $03
RF	EQU $04
; Pointer to "this"
TH  EQU $05
; Pointer to current string in work area
SP	EQU $02