	IF USEIRQ == 1
IRQVECTOR EQU $0314
VICII_SCREENCTR EQU $D011
VICII_RASTER    EQU $D012
VICII_IRQSTATUS EQU $D019
VICII_IRQCTR    EQU $D01A
CIA1_IRQCTR     EQU $DC0D
	; Flags
	; bit 0 - raster interrupts enabled
	; bit 1 - sprite-bg interrupts enabled
	; bit 2 - sprite-sprte interrupts enabled
	; bit 3 - custom timer interrupts enabled
	; bit 4 - system interrupts enabled
IRQFLAGS HEX 10

IRQ_RASTER EQU 1
IRQ_BACKGROUND EQU 2
IRQ_SPRITE EQU 4
IRQ_TIMER EQU 8
IRQ_SYSTEM EQU 16

	MAC irqenable
	sei
	lda #{1}
	ora IRQFLAGS
	sta IRQFLAGS
	IF {1} < IRQ_TIMER
	sta VICII_IRQCTR
	ELSE
	lda #$81
	sta CIA1_IRQCTR
	ENDIF
	; ack pending interrupts
	lda CIA1_IRQCTR
	lda #%00000111
	sta VICII_IRQSTATUS
	cli
	ENDM
	
	MAC irqdisable
	sei
	lda #[{1} ^ $FF]
	and IRQFLAGS
	sta IRQFLAGS
	IF {1} < IRQ_TIMER
	sta VICII_IRQCTR
	ELSE
	and %00011000
	bne .q
	lda #$7F
	sta CIA1_IRQCTR
	ENDIF
.q	
	; ack pending interrupts
	lda CIA1_IRQCTR
	lda #%00000111
	sta VICII_IRQSTATUS
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
	lda VICII_SCREENCTR
	ora #%10000000
	sta VICII_SCREENCTR
	bne .low
.clear
	lda VICII_SCREENCTR
	and #%01111111
	sta VICII_SCREENCTR
.low	
	pla
	sta VICII_RASTER
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
	lda #<$EA31
	sta IRQVECTOR
	lda #>$EA31
	sta IRQVECTOR + 1
	cli
	rts

XCBIRQ	SUBROUTINE
	cld
	; is it a raster irq?
	lda #IRQ_RASTER
	and IRQFLAGS
	bit VICII_IRQSTATUS
	beq .1
	phsr
IRQ_RASTER_V
	jsr $FFFF ; To be modified by application
	plsr
	lda VICII_IRQSTATUS ; ACK
	ora #%00000001
	sta VICII_IRQSTATUS
	jmp $EA81
.1
	; is it a sprite-background collision?
	lda #IRQ_BACKGROUND
	and IRQFLAGS
	bit VICII_IRQSTATUS
	beq .2
	phsr
IRQ_BACKGROUND_V
	jsr $FFFF ; To be modified by application
	plsr
	lda VICII_IRQSTATUS ; ACK
	ora #%00000010
	sta VICII_IRQSTATUS
	jmp $EA81
.2
	; is it a sprite-sprite collision?
	lda #IRQ_SPRITE
	and IRQFLAGS
	bit VICII_IRQSTATUS
	beq .3
	phsr
IRQ_SPRITE_V
	jsr $FFFF ; To be modified by application
	plsr
	lda VICII_IRQSTATUS ; ACK
	ora #%00000100
	sta VICII_IRQSTATUS
	jmp $EA81
.3	
	; it is a timer interrupt	
	lda #IRQ_TIMER
	bit IRQFLAGS
	beq .4
	phsr
IRQ_TIMER_V	
	jsr $FFFF ; To be modified by application
	plsr
.4
	lda #IRQ_SYSTEM
	bit IRQFLAGS
	beq .q
	jmp $EA31
.q	
	jmp $EA7E
	
	ENDIF