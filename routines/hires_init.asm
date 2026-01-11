; SYS49152,MODE,KLEUR
;   MODE=0: standaard(tweekleuren)instelling
;   MODE=1: multi-colourstand
;   KLEUR : kleurcode voor de rand en het scherm
;           (rand valt dus weg) (0=zwart; 1=wit)

MODE = $FB      ; zeropage storage for mode (0=320x200, 1=160x200)

hires_init:         ; parse parameters
                    jsr CHKCMA
                    jsr GETNUM
                    ; Set KLEUR
                    txa
                    sta EXTCOL
                    sta BGCOL0
                    ; Store MODE
                    lda LINNUM
                    sta MODE
                    beq Lc015
                    ldx #0
Lc015:              jsr hires_clear
                    jsr clear_screen_ram
                    jsr clear_colour_ram

hires_enter:        lda #%00111011 ; set bit 5 (bitmap mode)
                    sta VMCTRL1
                    ; VIC memory setup:
                    ; - Bitmap at a000-bfff
                    ; - Color memory at 8400-87e7
                    lda #%00011101
                    sta VMCSB
                    ; Set hires/multicolour
                    lda MODE
                    beq Lc031
                    lda #%11011000 ; set bit 4 (multicolour mode)
                    sta VMCTRL2
                    ; protect graphics memory from BASIC
Lc031:              lda #>$8000
                    sta $38         ; pointer to begin of string area
                    sta $34         ; pointer to end of basic area
                    ; set port A on CIA#2 to output
                    lda CIA2PRDDRA
                    ora #%00000011
                    sta CIA2PRDDRA
                    ; Set VIC bank to 8000-bfff
                    lda CIA2PRTA
                    and #%11111100
                    ora #%00000001
                    sta CIA2PRTA
                    ; TODO Make cursor work ???
                    lda #>$8400
                    sta $0288       ; hi-byte of screen editor address
                    ; make USR() call hires_isset
                    lda #<hires_isset
                    sta $0311
                    lda #>hires_isset
                    sta $0312
                    rts
