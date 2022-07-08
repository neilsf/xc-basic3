	IF USEIRQ == 1
	; Flags
	; bit 0 - custom timer interrupts enabled
	; bit 1 - system interrupts enabled
IRQFLAGS HEX 02
IRQ_RASTER EQU 1
IRQ_TIMER EQU 2
IRQ_SYSTEM EQU 4

ted_irqsource EQU $FF09
ted_irqmask EQU $FF0a
		
		
		sei
		lda #<17734
		ldx #>17734
		sta ted_timer1lo
		stx ted_timer1hi
		lda #%00001010
		sta ted_irqmask
		lda #<irq
		ldx #>irq
		sta $0314
		stx $0315
		cli
		jmp *
irq
		lda ted_irqsource
		sta ted_irqsource
		pha
		and #%00001000
		beq nottimer
		; do timer tasks
nottimer
		pla
		and #%00000010
		beq notraster
		; do raster tasks
notraster
		pla
		tay
		pla
		tax
		pla
		rti

	ENDIF