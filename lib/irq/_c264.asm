    	IF USEIRQ == 1

IRQVECTOR EQU $0314
TED_TIMER1 EQU $FF00
TED_TIMER2 EQU $FF02
TED_IRQST EQU $FF09
TED_IRQMASK EQU $FF0A
TED_RASTER EQU $FF0B

IRQ_RASTER EQU 2
IRQ_SYSTEM EQU 8
IRQ_TIMER EQU 16

    ; Store timeout value here
IRQ_TIMER_LATCH HEX 00 00

    MAC irqenable
	sei
    lda TED_IRQMASK
    ora #{1}
    sta TED_IRQMASK
	IF {1} == IRQ_TIMER
    lda IRQ_TIMER_LATCH
    sta TED_TIMER2
    lda IRQ_TIMER_LATCH + 1
    sta TED_TIMER2 + 1
    ENDIF
	cli
	ENDM
    
	MAC irqdisable
	sei
    lda TED_IRQMASK
    and #[{1} ^ $FF]
    sta TED_IRQMASK
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
	lda TED_IRQMASK
	ora #%00000001
	sta TED_IRQMASK
	bne .low
.clear
	lda TED_IRQMASK
	and #%11111110
	sta TED_IRQMASK
.low	
	pla
	sta TED_RASTER
	ENDIF
	IF {1} == IRQ_TIMER
    pla
    sta IRQ_TIMER_LATCH + 1
    pla 
    sta IRQ_TIMER_LATCH
	ENDIF
    ENDM
    
IRQRESET SUBROUTINE
    sei
	lda #<$CE0E
	sta IRQVECTOR
	lda #>$CE0E
	sta IRQVECTOR + 1
	ldx #$A2
    stx TED_IRQMASK
    dex
    stx TED_RASTER
	cli
	rts

IRQSETUP SUBROUTINE
	sei
	lda #<XCBIRQ
	sta IRQVECTOR
	lda #>XCBIRQ
	sta IRQVECTOR + 1
    ; Disable raster interrupt and set timer
	lda #%00001000
    sta TED_IRQMASK
    lda #$25
    sta TED_TIMER1
    lda #$40
    sta TED_TIMER1 + 1
	lda %01111111
    sta TED_IRQST
    cli
	rts
    
XCBIRQ SUBROUTINE
    cld
    lda #IRQ_RASTER
    bit TED_IRQST
    bne .timer
    ; Raster interrupt
    phsr
IRQ_RASTER_V
	jsr $FFFF ; To be modified by application
	plsr
    lda #IRQ_RASTER
    jmp .q
.timer   
    lda #IRQ_TIMER
    bit TED_IRQST
    bne .system
    ; Timer interrupt
    phsr
IRQ_TIMER_V
	jsr $FFFF ; To be modified by application
	plsr
    lda #IRQ_TIMER
    jmp .q
.system:
    lda #IRQ_SYSTEM
    bit TED_IRQST
    bne .q
    jsr $DB11 ; Read keyboard
    jsr $CEF0 ; Update Jiffy and read Stop key  
    lda #IRQ_SYSTEM
.q
    sta TED_IRQST
    jmp $FCBE
    
    ENDIF
>>>>>>> release/v3.1
