SUB VBLANK_NMI_ENABLE(is_enabled AS BYTE) SHARED STATIC
	ASM
		lda PPUCTRL_SHADOW
		and #%01111111
		sta PPUCTRL_SHADOW
		lda {is_enabled}
		REPEAT 7
			asl
		REPEND
		ora PPUCTRL_SHADOW
		sta PPUCTRL_SHADOW
		sta PPUCTRL
	END ASM
END SUB

SUB SPRITES_ENABLE(is_enabled AS BYTE) SHARED STATIC
	ASM
		lda PPUMASK_SHADOW
		and #%11101111
		sta PPUMASK_SHADOW
		lda {is_enabled}
		REPEAT 4
		asl
		REPEND
		ora PPUMASK_SHADOW
		sta PPUMASK_SHADOW
		sta PPUMASK
	END ASM
END SUB

SUB SPRITES_SET_PATTERNTBL(tbl_no AS BYTE) SHARED STATIC
	ASM
		lda PPUCTRL_SHADOW
		and #%11110111
		sta PPUCTRL_SHADOW
		lda {tbl_no}
		REPEAT 3
			asl
		REPEND
		ora PPUCTRL_SHADOW
		sta PPUCTRL_SHADOW
		sta PPUCTRL
	END ASM
END SUB

SUB SPRITES_SET_DBLHEIGHT(is_enabled AS BYTE) SHARED STATIC
	ASM
		lda PPUCTRL_SHADOW
		and #%11011111
		sta PPUCTRL_SHADOW
		lda {is_enabled}
		REPEAT 5
			asl
		REPEND
		ora PPUCTRL_SHADOW
		sta PPUCTRL_SHADOW
		sta PPUCTRL
	END ASM
END SUB

SUB BG_ENABLE(is_enabled AS BYTE) SHARED STATIC
	ASM
		lda PPUMASK_SHADOW
		and #%11110111
		sta PPUMASK_SHADOW
		lda {is_enabled}
		REPEAT 3
		asl
		REPEND
		ora PPUMASK_SHADOW
		sta PPUMASK_SHADOW
		sta PPUMASK
	END ASM
END SUB

SUB BG_SET_PATTERNTBL(tbl_no AS BYTE) SHARED STATIC
	ASM
		lda PPUCTRL_SHADOW
		and #%11101111
		sta PPUCTRL_SHADOW
		lda {tbl_no}
		REPEAT 4
			asl
		REPEND
		ora PPUCTRL_SHADOW
		sta PPUCTRL_SHADOW
		sta PPUCTRL
	END ASM
END SUB

SUB COLOR_FILTER(r AS BYTE, g AS BYTE, b AS BYTE) SHARED STATIC
	ASM
		lda PPUMASK_SHADOW
		and #%00011111
		sta PPUMASK_SHADOW
		lda {r}
		REPEAT 5
		asl
		REPEND
		ora PPUMASK_SHADOW
		sta PPUMASK_SHADOW
		lda {g}
		REPEAT 6
		asl
		REPEND
		ora PPUMASK_SHADOW
		sta PPUMASK_SHADOW
		lda {b}
		REPEAT 7
		asl
		REPEND
		ora PPUMASK_SHADOW
		sta PPUMASK_SHADOW
		sta PPUMASK
	END ASM
END SUB

SUB GREYSCALE_ENABLE(is_enabled AS BYTE) SHARED STATIC
	ASM
		lda PPUMASK_SHADOW
		and #%11111101
		sta PPUMASK_SHADOW
		lda {is_enabled}
		asl
		ora PPUMASK_SHADOW
		sta PPUMASK_SHADOW
		sta PPUMASK
	END ASM
END SUB

SUB WAIT_FRAME() SHARED STATIC
	ASM
		lda FC
.1
		cmp FC
		beq .1
    END ASM
END SUB

SUB LOAD_PALETTE(addr AS WORD) SHARED STATIC
	ASM
		lda {addr}
		sta R0
		lda {addr} + 1
		sta R0 + 1
		
		lda PPUSTATUS
		lda #$3F
		sta PPUADDR
		lda #$00
		sta PPUADDR
		ldy #$00
.1
		lda (R0),y
		sta PPUDATA
		iny
		cpy #$20            
		bne .1
	END ASM
END SUB

SUB MEMCPYMV (srcAddr AS WORD FAST, targetAddr AS WORD, cntBytes AS WORD) SHARED STATIC
	ASM
		lda PPUCTRL_SHADOW
		and #%11111011
		sta PPUCTRL_SHADOW
		sta PPUCTRL
		
		lda PPUSTATUS
		lda {targetAddr} + 1
		sta PPUADDR
		lda {targetAddr}
		sta PPUADDR
		
		ldy #0
.loop1
		lda ({srcAddr}),y
		sta PPUDATA
		iny
		cpy {cntBytes}
		bne .loop1
		
		tya
		clc
		adc {srcAddr}
		sta {srcAddr}
		lda {srcAddr} + 1
		adc #0
		sta {srcAddr} + 1
		
		ldx #0
.loop2o
		cpx {cntBytes} + 1
		beq .q
		ldy #0
.loop2i
		lda ({srcAddr}),y
		sta PPUDATA
		iny
		bne .loop2i
		inx
		jmp .loop2o
.q	
	END ASM
END SUB

SUB VMEMSET (vAddr AS WORD, cntBytes AS WORD, value AS BYTE) SHARED STATIC
	ASM
		lda PPUCTRL_SHADOW
		and #%11111011
		sta PPUCTRL_SHADOW
		sta PPUCTRL
	    
	    lda PPUSTATUS
		lda {vaddr} + 1
		sta PPUADDR
		lda {vaddr}
		sta PPUADDR
		lda {value}
		
		ldx {cntbytes}
		ldy {cntbytes} + 1
.loop
		sta PPUDATA
		dex
		cpx #$ff
		bne .loop
		dey
		cpy #$ff
		bne .loop
	END ASM
END SUB

SUB DRAW_ROW (nametblNo AS BYTE, x AS BYTE, y AS BYTE, srcAddr AS WORD, cntBytes AS BYTE) SHARED STATIC
	ASM
		ldx NEXTBUFADDR
		beq .q
		lda #1
		sta $00,x
		lda {nametblNo}
		sta R3
		ldy {x}
		lda {y}
		sta R0
		import I_CALC_NAMETBLADDR
		jsr CALC_NAMETBLADDR
		inx
		lda R0 + 1
		sta $00,x
		inx
		lda R0
		sta $00,x
		inx
		lda {srcAddr}
		sta $00,x
		inx
		lda {srcAddr} + 1
		sta $00,x
		inx
		lda {cntBytes}
		sta $00,x
		inx
		stx NEXTBUFADDR
.q		
	END ASM
END SUB

SUB DRAW_COL (nametblNo AS BYTE, x AS BYTE, y AS BYTE, srcAddr AS WORD, cntBytes AS BYTE) SHARED STATIC
	ASM
		ldx NEXTBUFADDR
		beq .q
		lda #$FF
		sta $00,x
		lda {nametblNo}
		sta R3
		ldy {x}
		lda {y}
		sta R0
		import I_CALC_NAMETBLADDR
		jsr CALC_NAMETBLADDR
		inx
		lda R0 + 1
		sta $00,x
		inx
		lda R0
		sta $00,x
		inx
		lda {srcAddr}
		sta $00,x
		inx
		lda {srcAddr} + 1
		sta $00,x
		inx
		lda {cntBytes}
		sta $00,x
		inx
		stx NEXTBUFADDR
.q		
	END ASM
END SUB
