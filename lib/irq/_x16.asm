	IF USEIRQ == 1
IRQVECTOR      EQU $0314
VERA_RASTER    EQU $9F28
VERA_IRQSTATUS EQU $9F27
VERA_IRQCTR    EQU $9F26
VIA_TIMERBLO   EQU $9F18
VIA_TIMERBHI   EQU $9F19
VIA_IRQFL      EQU $9F1D
VIA_IRQEN      EQU $9F1E

	; Flags
	; bit 0 - system interrupts enabled
	; bit 1 - raster interrupts enabled
	; bit 2 - sprite interrupts enabled
	; bit 3 - custom timer interrupts enabled

IRQFLAGS HEX 01

    ; Store timeout value here
IRQ_TIMER_LATCH HEX 00 00

IRQ_VBLANK EQU 1
IRQ_RASTER EQU 2
IRQ_SPRITE EQU 4
IRQ_TIMER EQU 8
IRQ_SYSTEM EQU 16

    MAC irqenable
	sei
	lda #{1}
	ora IRQFLAGS
	sta IRQFLAGS
	IF {1} < IRQ_TIMER
	    sta VERA_IRQCTR
	ELSE
        lda #%10100000
        sta VIA_IRQEN
        lda IRQ_TIMER_LATCH
        sta VIA_TIMERBLO
        lda IRQ_TIMER_LATCH + 1
        sta VIA_TIMERBHI
    ENDIF
	; ack pending interrupts
	lda #%00000111
	sta VERA_IRQSTATUS
	cli
	ENDM

    MAC irqdisable
	sei
	lda #[{1} ^ $FF]
	and IRQFLAGS
	sta IRQFLAGS
	IF {1} < IRQ_TIMER && {1} > IRQ_VBLANK
	    sta VERA_IRQCTR
	ELSE
        lda #%00100000
        sta VIA_IRQEN
	ENDIF
	; ack pending interrupts
	lda #%00000111
	sta VERA_IRQSTATUS
	cli	
	ENDM

    MAC onirqgosub
	lda #<{2}
	sta {1}_V + 1
	lda #>{2}
	sta {1}_V + 2
	IF {1} == IRQ_RASTER
        pla ; raster line high byte
        beq .clear
        lda VERA_IRQCTR
        ora #%10000000
        sta VERA_IRQCTR
        bne .low
.clear
        lda VERA_IRQCTR
        and #%01111111
        sta VERA_IRQCTR
.low	
        pla
        sta VERA_RASTER
	ENDIF
	IF {1} == IRQ_TIMER
        pla
        sta IRQ_TIMER_LATCH + 1
        pla 
        sta IRQ_TIMER_LATCH
	ENDIF
    ENDM

IRQSETUP SUBROUTINE
	sei
    lda IRQVECTOR
    sta irq_default_handlerinterrupts
	lda #<XCBIRQ
	sta IRQVECTOR
    lda IRQVECTOR + 1
    sta irq_default_handler + 1
	lda #>XCBIRQ
	sta IRQVECTOR + 1
	cli
	rts
irq_default_handler HEX 00 00
	
IRQRESET SUBROUTINE
	irqdisable IRQ_TIMER
    irqdisable IRQ_RASTER
    irqdisable IRQ_SPRITE
    sei
	lda irq_default_handler
	sta IRQVECTOR
	lda irq_default_handler + 1
	sta IRQVECTOR + 1
	cli
	rts

XCBIRQ	SUBROUTINE
	cld
	; is it a raster irq?
	lda #IRQ_RASTER
	and IRQFLAGS
	bit VERA_IRQSTATUS
	beq .1
	phsr
IRQ_RASTER_V
	jsr $FFFF ; To be modified by application
	plsr
	lda #IRQ_RASTER
	sta VERA_IRQSTATUS ; ACK
	jmp .rti
.1
	; is it a sprite collision?
	lda #IRQ_SPRITE
	and IRQFLAGS
	bit VERA_IRQSTATUS
	beq .3
	phsr
IRQ_SPRITE_V
	jsr $FFFF ; To be modified by application
	plsr
	lda #IRQ_SPRITE ; ACK
	sta VERA_IRQSTATUS
	jmp .rti
.3	
	; is it a timer interrupt
    lda VIA_IRQFL
    and #%00100000
	beq .4
	phsr
IRQ_TIMER_V	
	jsr $FFFF ; To be modified by application
	plsr
    lda VIA_TIMERBLO
    lda IRQ_TIMER_LATCH
    sta VIA_TIMERBLO
    lda IRQ_TIMER_LATCH + 1
    sta VIA_TIMERBHI
    jmp .rti
.4
    ; is it a  vblank / system interrupt?
	lda #IRQ_VBLANK
	bit VERA_IRQSTATUS
	beq .rti
	lda IRQFLAGS
	and #IRQ_VBLANK
	beq .sys
	phsr
IRQ_VBLANK_V	
	jsr $FFFF ; To be modified by application
	plsr
	lda #IRQ_VBLANK ; ACK
	sta VERA_IRQSTATUS
.sys
	lda IRQFLAGS
	and #IRQ_SYSTEM
	beq .rti
	jmp (irq_default_handler)
.rti
    HEX 7A ;ply
    HEX FA ;plx
    pla
    rti
    ENDIF