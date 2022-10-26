	IF USEIRQ == 1
    
IRQVECTOR EQU $0314
VIA_TIMERBLO EQU $9128
VIA_TIMERBHI EQU $9129
VIA_IRQFL EQU $912D
VIA_IRQEN EQU $912E
	; Flags
	; bit 0 - custom timer interrupts enabled
	; bit 1 - system interrupts enabled
IRQ_TIMER EQU 1
IRQ_SYSTEM EQU 2
    ; Store timeout value here
IRQ_TIMER_LATCH HEX 00 00

	MAC irqenable
    sei
    IF {1} == IRQ_TIMER
    lda #%10100000
    sta VIA_IRQEN
    lda IRQ_TIMER_LATCH
    sta VIA_TIMERBLO
    lda IRQ_TIMER_LATCH + 1
    sta VIA_TIMERBHI
    ENDIF
    IF {1} == IRQ_SYSTEM
    lda #%11000000
    sta VIA_IRQEN
    ENDIF
	cli
    ENDM
	
	MAC irqdisable
	sei
    IF {1} == IRQ_TIMER
    lda #%00100000
    ENDIF
    IF {1} == IRQ_SYSTEM
    lda #%01000000
    ENDIF
    sta VIA_IRQEN
	cli
    ENDM
	
	MAC onirqgosub
	lda #<{2}
	sta IRQ_TIMER_V + 1
	lda #>{2}
	sta IRQ_TIMER_V + 2
    IF {1} == IRQ_TIMER
    pla
    sta IRQ_TIMER_LATCH + 1
    pla 
    sta IRQ_TIMER_LATCH
	ENDIF
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
	lda #%00100000
    sta VIA_IRQEN
    lda #%11000000
    sta VIA_IRQEN
    cli
	rts
	
XCBIRQ	SUBROUTINE
	cld
    lda VIA_IRQFL
    and #%00100000
    beq .sysirq
	phsr
IRQ_TIMER_V
	jsr $FFFF ; To be modified by application
	plsr
    lda VIA_TIMERBLO
    lda IRQ_TIMER_LATCH
    sta VIA_TIMERBLO
    lda IRQ_TIMER_LATCH + 1
    sta VIA_TIMERBHI
    jmp $EB18
.sysirq	
    jmp $EABF
	
    ENDIF