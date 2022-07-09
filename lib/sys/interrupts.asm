	PROCESSOR 6502

IRQVEC			EQU $0314
	IF TARGET == c64
DEFAULT_IRQSERV	EQU $EA31
DEFAULT_EXIT	EQU $EA7E
VICII_IRQ		EQU $D019
	ENDIF
	IF TARGET & vic20
DEFAULT_IRQSERV	EQU $EABF
	ENDIF
	IF TARGET & c264
DEFAULT_IRQSERV	EQU $CE0E	
	ENDIF

	MAC enable_xcb_irq_service
	sei
	lda #<xcb_irq_service
	sta IRQVEC
	lda #>xcb_irq_service
	sta IRQVEC + 1
	cli
	ENDM
	
	MAC disable_xcb_irq_service
	sei
	lda #<DEFAULT_IRQSERV
	sta IRQVEC
	lda #>DEFAULT_IRQSERV
	sta IRQVEC + 1
	cli
	ENDM
	
	IFCONST I_IRQSERVICE_IMPORTED
default_service_enabled DC.B 1
xcb_irq_service SUBROUTINE
	IF TARGET == c64
	; Check sprite collisions
	lda SPRSPRC
	sta spritehit
	lda SPRBGC
	sta sprbghit
	ENDIF
	; Do default service if enabled
	lda default_service_enabled
	beq .not_enabled
	jmp DEFAULT_IRQSERV
.not_enabled
	jmp DEFAULT_EXIT
	ENDIF