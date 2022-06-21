	IF USEIRQ == 1
IRQVECTOR EQU $0314
VIA_AUX	  EQU $911B
VIA_IRQFL EQU $911D
VIA_IRQEN EQU $911E
	; Flags
	; bit 0 - custom timer interrupts enabled
	; bit 1 - system interrupts enabled
IRQFLAGS HEX 02
IRQ_TIMER EQU 1
IRQ_SYSTEM EQU 2

	MAC irqenable
	lda #{1}
	ora IRQFLAGS
	sta IRQFLAGS
	ENDM
	
	MAC irqdisable
	lda #[{1} ^ $FF]
	and IRQFLAGS
	sta IRQFLAGS
	ENDM
	
	MAC onirqgosub
	lda #<{2}
	sta {1}_V + 1
	lda #>{2}
	sta {1}_V + 2
	ENDM
	
IRQSETUP SUBROUTINE
	sei
	lda #<XCBIRQ
	sta IRQVECTOR
	lda #>XCBIRQ
	sta IRQVECTOR + 1
	cli
	rts
	
IRQRESET SUBROUTINE
	sei
	lda #<$EABF
	sta IRQVECTOR
	lda #>$EABF
	sta IRQVECTOR + 1
	cli
	rts
	
XCBIRQ	SUBROUTINE
	cld
	lda #IRQ_TIMER
	bit IRQFLAGS
	beq .1
	phsr
IRQ_TIMER_V
	jsr $FFFF ; To be modified by application
	plsr
.1
	lda #IRQ_SYSTEM
	bit IRQFLAGS
	beq .q
	jmp $EABF
.q
	jmp $EB12
	
	ENDIF