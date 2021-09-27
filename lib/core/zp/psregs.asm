; ------------------------------------------
; XC=BASIC
; Pseudo-registers
;
; ZP locations reserved
; ------------------------------------------

; R0-R1-R2-R3 must be consecutive
R0	EQU $fb
R1	EQU $fc
R2	EQU $fd
R3	EQU $fe
; R4-R5-R6-R7 must be consecutive
R4	EQU $3f
R5	EQU $40
R6	EQU $41
R7	EQU $42
; R8-R9-RA-RB must be consecutive
R8	EQU $43
R9	EQU $44
RA	EQU $45
RB	EQU $46
; Pointer to current stack frame
; Must be 2 consecutive bytes
RC  EQU $07
RD  EQU $08
; Tmp Pointer to next stack frame
; Must be 2 consecutive bytes
RE	EQU $03
RF	EQU $04
; Pointer to "this"
TH  EQU $05
; Pointer to current string in work area
SP	EQU $02