*                   = $C000

;
; From Commodore_Computing_International_Vol_02-06_1983_Oct.pdf
;
;******************************
;* THESE ROUTINES ALLOW THE   *
;*PRODUCTION OF HIRES GRAPHICS*
;*DISPLAYS ON THE 64. ALL OF  *
;*THE ROUTINES HAVE THE       *
;*FACILITY FOR MULTI-COLOUR OR*
;*STANDARD HI-RES EXCEPT FOR  *
;*THE FILL ROUTINE WHICH ONLY *
;*ALLOWS THE FILLING OF STAND-*
;*ARD HIRES AREAS.            *
;******************************
;* EACH ROUTINE IS CALLED WITH*
;*A SYS CALL FOLLOWED BY THE  *
;*PARAMETERS SEPARATED BY ','.*
;******************************
;*SYS(49152),MODE,COLOUR      *
;*   SELECT AND SET UP HI-RES *
;*   MODE. MODE=0 FOR STANDARD*
;*   AND 1 FOR MULTI-COLOUR.  *    
;*   COLOUR IS FOR THE BORDER *
;*   AND THE SCREEN.          *
;******************************
;*SYS(49182)                  *
;*   GO FROM NORMAL SCREEN TO *
;*   HIRES SCREEN.            *
;******************************
;*SYS(49241)                  *
;*   CLEARS THE HIRES SCREEN. *
;******************************
;*SYS(49845)                  *
;*   GO FROM HIRES SCREEN TO  *
;*   NORMAL SCREEN.           *
;******************************
;*SYS(49585),X,Y,COL,BR       *
;*   PLOTS A POINT AT X,Y IN  *
;*   COLOUR COL USING BRUSH BR*
;******************************
;*SYS(49874),X1,Y1,X2,Y2,CL,BR*
;*   PLOTS A LINE BETWEEN.    *
;*   X1,Y1 AND X2,Y2 WITH     *
;*   COLOUR COL AND BRUSH BR. *
;******************************
;*SYS(50713),X,Y,COL,BR1,BR2  *
;*   FILLS AN ENCLOSED AREA.  *
;*   POINT X,Y IS WITHIN THE  *
;*   AREA AND BR1 AND BR2 MUST*
;*   BOTH BE 1.               *
;******************************
;*USR(BRUSH),X,Y              *
;*   RETURNS A 1 IF THE POINT *
;*   IS SET USING THAT BRUSH  *
;*   OR A 0 IF IT IS NOT.     *
;******************************


                    CHKCMA = $AEFD  ; check for comma
                    GETNUM = $B7EB  ; Get a 16-Bit Address Parameter and an 8-Bit Parameter in LINNUM and X
                    OVERR = $B97E   ; prints overflow error
                    FCERR = $B248   ; prints illegal quantity error

                    PPORT = $01     ; Processor Port
                    LINNUM = $14    ;

                    ; VIC-II registers
                    VMCTRL1 = $D011 ; VIC-II Screen control register #1
                    VMCTRL2 = $D016 ; VIC-II Screen control register #2
                    VMCSB = $D018   ; VIC-II Chip Memory Control Register
                    BGCOL0 = $D021  ; Background Color 0
                    EXTCOL = $D020  ; Border Color Register

                    ; CIA #2 registers
                    CIA2PRTA = $DD00
                    CIA2PRDDRA = $DD02

                    DATASETBUF = $033C       ; datasette buffer
                    BUF = $CF00

                    MODE = $FB      ; zeropage storage for mode (0=320x200, 1=160x200)
                    SOMEPTR = $FC
                    TMP = $FE
                    FAC3 = $57          ; tmp pointer storage
                    X_COORD_LO = $59
                    X_COORD_HI = $5A
                    Y_COORD = $5B
                    FAC4 = $5C          ; tmp pointer storage
                    pixel_mask_1 = FAC4+2
                    pixel_mask_2 = FAC4+3
                    FAC1 = $61          ; tmp pointer storage


; SYS49152,MODE,KLEUR
;   MODE=0: standaard(tweekleuren)instelling
;   MODE=1: multi-colourstand
;   KLEUR : kleurcode voor de rand en het scherm
;           (rand valt dus weg) (0=zwart; 1=wit)
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
                    ; ???
Lc031:              lda #>$8000
                    sta $38         ; pointer to begin of string area
                    sta $34         ; pointer to end of basic area
                    ; ???
                    lda CIA2PRDDRA
                    ora #%00000011
                    sta CIA2PRDDRA
                    ; Set VIC bank to 8000-bfff
                    lda CIA2PRTA
                    and #%11111100
                    ora #%00000001
                    sta CIA2PRTA
                    ; ??? Make cursor work ???
                    lda #>$8400
                    sta $0288       ; hi-byte of screen editor address
                    ; make USR() call hires_isset
                    lda #<hires_isset
                    sta $0311
                    lda #>hires_isset
                    sta $0312
                    rts

; Clear hires bitmap (a000 to bf40)
hires_clear:        ldy #0
                    lda #$40
                    sta FAC3
                    lda #$bf
                    sta FAC3+1
Lc063:              lda #0
                    sta (FAC3),y
                    lda FAC3
                    beq Lc070
                    dec FAC3
                    jmp Lc063
Lc070:              dec FAC3+1
                    lda FAC3+1
                    cmp #$9f
                    beq Lc07f
                    lda #$ff
                    sta FAC3
                    jmp Lc063
Lc07f:              rts

; Set bitmap colour memory (screen RAM from 8400 to 87e7) to X
clear_screen_ram:              ldy #0
                    lda #$e7
                    sta FAC3
                    lda #$87
                    sta FAC3+1
Lc08a:              txa
                    sta (FAC3),y
                    lda FAC3
                    beq Lc096
                    dec FAC3
                    jmp Lc08a
Lc096:              dec FAC3+1
                    lda FAC3+1
                    cmp #$83
                    beq Lc0a5
                    lda #$ff
                    sta FAC3
                    jmp Lc08a
Lc0a5:              rts

; Clear colour memory (d800 to dbe7)
clear_colour_ram:              ldy #0
                    lda #$e7
                    sta FAC3
                    lda #$db
                    sta FAC3+1
Lc0b0:              lda #0
                    sta (FAC3),y
                    lda FAC3
                    beq Lc0bd
                    dec FAC3
                    jmp Lc0b0
Lc0bd:              dec FAC3+1
                    lda FAC3+1
                    cmp #$d7
                    beq Lc0cc
                    lda #$ff
                    sta FAC3
                    jmp Lc0b0
Lc0cc:              rts

; Takes the coordinates parsed from the BASIC program,
; and puts them in the right places for the graphics routines.
prepare_coords:
                    ; X should have 0 or 1 as high byte
                    lda X_COORD_HI
                    cmp #0
                    beq check_y
                    cmp #1
                    bne invalid_x
                    ; and when high byte is 1, low byte should be < 64
                    ; because 256+64 = 320
                    lda X_COORD_LO
                    cmp #64
                    bcc check_y
invalid_x:              jsr hires_exit
                    jmp FCERR
                    
check_y:              lda Y_COORD
                    cmp #200
                    bcc make_pixel_masks
                    jsr hires_exit
                    jmp FCERR

make_pixel_masks:              lda X_COORD_LO
                    and #%00000111
                    sta pixel_mask_1
                    lda #7
                    sec
                    sbc pixel_mask_1
                    sta pixel_mask_1
                    lda MODE
                    beq Lc10b
                    lsr pixel_mask_1
                    asl pixel_mask_1
                    lda pixel_mask_1
                    clc
                    adc #1
                    sta pixel_mask_2
Lc10b:              lda pixel_mask_1
                    beq Lc118
                    tay
                    lda #1
Lc112:              asl a
                    dey
                    bne Lc112
                    beq Lc11a
Lc118:              lda #1
Lc11a:              sta pixel_mask_1
                    lda pixel_mask_2
                    beq Lc129
                    tay
                    lda #1
Lc123:              asl a
                    dey
                    bne Lc123
                    beq Lc12b
Lc129:              lda #1
Lc12b:              sta pixel_mask_2
                    ; now calculate memory address of the coordinate
                    lda #0
                    sta FAC4
                    sta FAC3+1
                    sta FAC3
                    lda Y_COORD
                    and #%00000111
                    sta FAC4+1
                    lda Y_COORD
                    lsr a
                    lsr a
                    lsr a
                    sta Y_COORD
                    ldy #5
Lc144:              clc
                    asl a
                    rol FAC3+1
                    dey
                    bne Lc144
                    sta FAC3
                    lda Y_COORD
                    ldy #3
Lc151:              clc
                    asl a
                    dey
                    bne Lc151
                    sta Y_COORD
                    clc
                    adc FAC3
                    sta Y_COORD
                    lda FAC3+1
                    adc #0
                    sta FAC4
                    ldy #3
Lc165:              clc
                    lsr X_COORD_HI
                    ror X_COORD_LO
                    dey
                    bne Lc165
                    lda X_COORD_LO
                    sta FAC3
                    lda X_COORD_HI
                    sta FAC3+1
                    ldy #3
Lc177:              clc
                    asl FAC3
                    rol FAC3+1
                    dey
                    bne Lc177
                    ldy #8
Lc181:              clc
                    lda Y_COORD
                    adc FAC3
                    sta FAC3
                    lda FAC4
                    adc FAC3+1
                    sta FAC3+1
                    dey
                    bne Lc181
                    clc
                    lda FAC4+1
                    adc FAC3
                    sta FAC3
                    lda #0
                    adc FAC3+1
                    clc
                    lda #$a0
                    adc FAC3+1
                    sta FAC3+1
                    clc
                    lda X_COORD_LO
                    adc Y_COORD
                    sta Y_COORD
                    lda #0
                    adc FAC4
                    sta FAC4
                    rts
                    
hires_plot:
                    ; parse parameters: x, y
                    jsr CHKCMA
                    jsr GETNUM
                    lda LINNUM
                    sta X_COORD_LO
                    lda LINNUM+1
                    sta X_COORD_HI
                    txa
                    sta Y_COORD
                    ; parse parameters color, brush
                    jsr CHKCMA
                    jsr GETNUM
                    txa
                    sta SOMEPTR
                    lda LINNUM
                    sta SOMEPTR+1
Sc1cf:              jsr prepare_coords
                    ; switch out BASIC ROM bank
                    lda #%00110110
                    sta PPORT
                    ;
                    lda MODE
                    bne hires_plot_mc
                    jmp hires_plot_hr
                    ; do a multi colour plot
hires_plot_mc: 
                    ; jump to a specific route for each brush
                    lda SOMEPTR
                    cmp #0
                    beq hires_plot_mc_00
                    cmp #1
                    beq hires_plot_mc_01
                    cmp #2
                    beq hires_plot_mc_10
                    cmp #3
                    beq hires_plot_mc_11
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts
hires_plot_mc_00:              
                    ldy #0
                    lda pixel_mask_1
                    eor #%11111111
                    sta pixel_mask_1
                    lda pixel_mask_2
                    eor #%11111111
                    sta pixel_mask_2
                    lda (FAC3),y
                    and pixel_mask_1
                    and pixel_mask_2
                    sta (FAC3),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts
                    
hires_plot_mc_01:
                    ldy #0
                    lda pixel_mask_2
                    eor #%11111111
                    sta pixel_mask_2
                    lda (FAC3),y
                    ora pixel_mask_1
                    and pixel_mask_2
                    sta (FAC3),y
                    lda #$84
                    clc
                    adc FAC4
                    sta FAC4
                    asl SOMEPTR+1
                    asl SOMEPTR+1
                    asl SOMEPTR+1
                    asl SOMEPTR+1
                    lda (Y_COORD),y
                    and #%00001111
                    clc
                    adc SOMEPTR+1
                    sta (Y_COORD),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts
                    
hires_plot_mc_10:
                    ldy #0
                    lda pixel_mask_1
                    eor #%11111111
                    sta pixel_mask_1
                    lda (FAC3),y
                    and pixel_mask_1
                    ora pixel_mask_2
                    sta (FAC3),y
                    clc
                    lda #$84
                    adc FAC4
                    sta FAC4
                    lda (Y_COORD),y
                    and #%11110000
                    clc
                    adc SOMEPTR+1
                    sta (Y_COORD),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts
                    
hires_plot_mc_11:
                    ldy #0
                    lda (FAC3),y
                    ora pixel_mask_1
                    ora pixel_mask_2
                    sta (FAC3),y
                    lda #$d8
                    clc
                    adc FAC4
                    sta FAC4
                    lda SOMEPTR+1
                    sta (Y_COORD),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts
                    
                    ; do a hires plot
hires_plot_hr:              ldy #0
                    lda SOMEPTR
                    beq hires_plot_hr_0
hires_plot_hr_1:
                    lda (FAC3),y
                    ora pixel_mask_1
                    sta (FAC3),y
                    lda #$84
                    clc
                    adc FAC4
                    sta FAC4
                    lda SOMEPTR+1
                    asl a
                    asl a
                    asl a
                    asl a
                    sta pixel_mask_2
                    lda (Y_COORD),y
                    and #%00001111
                    clc
                    adc pixel_mask_2
                    sta (Y_COORD),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts
                    
hires_plot_hr_0:              lda pixel_mask_1
                    eor #%11111111
                    sta pixel_mask_1
                    lda (FAC3),y
                    and pixel_mask_1
                    sta (FAC3),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts
                    
hires_exit:         lda #>$0400
                    sta $0288
                    ; ???
                    lda CIA2PRDDRA
                    and #%11111100
                    sta CIA2PRDDRA
                    ;
                    lda #%00011011
                    sta VMCTRL1
                    lda #%11001000
                    sta VMCTRL2
                    lda #%00010101
                    sta VMCSB
                    rts
                    
hires_line:         jsr CHKCMA
                    jsr GETNUM
                    txa
                    sta DATASETBUF+2
                    lda #0
                    sta DATASETBUF+3
                    lda LINNUM
                    sta DATASETBUF
                    lda LINNUM+1
                    sta DATASETBUF+1
                    jsr CHKCMA
                    jsr GETNUM
                    txa
                    sta DATASETBUF+6
                    lda #0
                    sta DATASETBUF+7
                    lda LINNUM
                    sta DATASETBUF+4
                    lda LINNUM+1
                    sta DATASETBUF+5
                    jsr CHKCMA
                    jsr GETNUM
                    txa
                    sta SOMEPTR
                    lda LINNUM
                    sta TMP
                    lda DATASETBUF+4
                    sec
                    sbc DATASETBUF
                    sta DATASETBUF+8
                    lda DATASETBUF+5
                    sbc DATASETBUF+1
                    sta DATASETBUF+9
                    lda DATASETBUF+6
                    sec
                    sbc DATASETBUF+2
                    sta DATASETBUF+10
                    lda DATASETBUF+3
                    sbc DATASETBUF+7
                    sta DATASETBUF+11
                    lda #1
                    sta DATASETBUF+34
                    sta DATASETBUF+36
                    lda #0
                    sta DATASETBUF+35
                    sta DATASETBUF+37
                    lda DATASETBUF+11
                    and #%10000000
                    beq Lc356
                    lda #$ff
                    sta DATASETBUF+34
                    sta DATASETBUF+35
Lc356:              lda DATASETBUF+9
                    and #%10000000
                    beq Lc365
                    lda #$ff
                    sta DATASETBUF+36
                    sta DATASETBUF+37
Lc365:              lda DATASETBUF+9
                    and #%10000000
                    beq Lc38a
                    lda DATASETBUF+9
                    eor #%11111111
                    sta $0349
                    clc
                    lda DATASETBUF+8
                    eor #%11111111
                    adc #1
                    sta $0348
                    lda $0349
                    adc #0
                    sta $0349
                    jmp Lc396
                    
Lc38a:              lda DATASETBUF+8
                    sta $0348
                    lda DATASETBUF+9
                    sta $0349
Lc396:              lda DATASETBUF+11
                    and #%10000000
                    beq Lc3bb
                    lda DATASETBUF+11
                    eor #%11111111
                    sta $034b
                    clc
                    lda DATASETBUF+10
                    eor #%11111111
                    adc #1
                    sta $034a
                    lda $034b
                    adc #0
                    sta $034b
                    jmp Lc3c7
                    
Lc3bb:              lda DATASETBUF+10
                    sta $034a
                    lda DATASETBUF+11
                    sta $034b
Lc3c7:              lda $0348
                    sec
                    sbc $034a
                    sta $0358
                    lda $0349
                    sbc $034b
                    sta $0359
                    and #%10000000
                    beq Lc41a
                    lda #$ff
                    sta DATASETBUF+30
                    sta DATASETBUF+31
                    lda #0
                    sta $035c
                    sta $035d
                    lda $034a
                    sta $034c
                    lda $034b
                    sta $034d
                    lda $0348
                    sta $034e
                    lda $0349
                    sta $034f
                    lda DATASETBUF+11
                    and #%10000000
                    bne Lc453
                    lda #1
                    sta DATASETBUF+30
                    lda #0
                    sta DATASETBUF+31
                    jmp Lc453
                    
Lc41a:              lda #0
                    sta DATASETBUF+30
                    sta DATASETBUF+31
                    lda #$ff
                    sta $035c
                    sta $035d
                    lda $0348
                    sta $034c
                    lda $0349
                    sta $034d
                    lda $034a
                    sta $034e
                    lda $034b
                    sta $034f
                    lda DATASETBUF+9
                    and #%10000000
                    bne Lc453
                    lda #1
                    sta $035c
                    lda #0
                    sta $035d
Lc453:              lda $034c
                    sta $0352
                    lda $034d
                    sta $0353
                    lda $034e
                    sta $0350
                    lda $034f
                    sta $0351
                    lda $034c
                    sec
                    sbc $034e
                    sta DATASETBUF+24
                    lda $034d
                    sbc $034f
                    sta DATASETBUF+25
                    lsr $034d
                    ror $034c
                    lda $034e
                    sec
                    sbc $034c
                    sta DATASETBUF+26
                    lda $034f
                    sbc $034d
                    sta DATASETBUF+27
Lc497:              lda DATASETBUF
                    sta X_COORD_LO
                    lda DATASETBUF+1
                    sta X_COORD_HI
                    lda DATASETBUF+2
                    sta Y_COORD
                    lda TMP
                    sta SOMEPTR+1
                    jsr Sc1cf
                    lda DATASETBUF+27
                    and #%10000000
                    beq Lc4f0
                    lda DATASETBUF+26
                    clc
                    adc $0350
                    sta DATASETBUF+26
                    lda DATASETBUF+27
                    adc $0351
                    sta DATASETBUF+27
                    lda DATASETBUF
                    clc
                    adc $035c
                    sta DATASETBUF
                    lda DATASETBUF+1
                    adc $035d
                    sta DATASETBUF+1
                    lda DATASETBUF+2
                    clc
                    adc DATASETBUF+30
                    sta DATASETBUF+2
                    lda DATASETBUF+3
                    adc DATASETBUF+31
                    sta DATASETBUF+3
                    jmp Lc529
                    
Lc4f0:              lda DATASETBUF+26
                    sec
                    sbc DATASETBUF+24
                    sta DATASETBUF+26
                    lda DATASETBUF+27
                    sbc DATASETBUF+25
                    sta DATASETBUF+27
                    lda DATASETBUF
                    clc
                    adc DATASETBUF+36
                    sta DATASETBUF
                    lda DATASETBUF+1
                    adc DATASETBUF+37
                    sta DATASETBUF+1
                    lda DATASETBUF+2
                    clc
                    adc DATASETBUF+34
                    sta DATASETBUF+2
                    lda DATASETBUF+3
                    adc DATASETBUF+35
                    sta DATASETBUF+3
Lc529:              lda $0352
                    sec
                    sbc #1
                    sta $0352
                    lda $0353
                    sbc #0
                    sta $0353
                    lda $0353
                    beq Lc546
                    cmp #$ff
                    beq Lc54e
                    jmp Lc497
                    
Lc546:              lda $0352
                    beq Lc54e
                    jmp Lc497
                    
Lc54e:              rts
                    
hires_isset:        lda FAC1+5
                    bne Lc581
                    lda FAC1+4
                    bne Lc581
                    lda FAC1+3
                    bne Lc581
                    lda FAC1+2
                    bne Lc581
                    lda FAC1+1
                    cmp #$80
                    beq Lc575
                    cmp #$c0
                    bne Lc581
                    lda FAC1
                    cmp #$82
                    bne Lc581
                    lda #3
                    sta SOMEPTR
                    bne Lc593
Lc575:              lda FAC1
                    beq Lc581
                    cmp #$81
                    beq Lc587
                    cmp #$82
                    beq Lc58d
Lc581:              jsr hires_exit
                    jmp FCERR
                    
Lc587:              lda #1
                    sta SOMEPTR
                    bne Lc593
Lc58d:              lda #2
                    sta SOMEPTR
                    bne Lc593
Lc593:              jsr CHKCMA
                    jsr GETNUM
                    stx Y_COORD
                    lda #0
                    sta FAC4
                    lda LINNUM
                    sta X_COORD_LO
                    lda LINNUM+1
                    sta X_COORD_HI
Sc5a7:              jsr prepare_coords
                    lda MODE
                    beq Lc5b5
                    lda pixel_mask_2
                    clc
                    adc pixel_mask_1
                    sta pixel_mask_1
Lc5b5:        ; switch out BASIC ROM bank
                    lda #%00110110
                    sta PPORT
                    ldy #0
                    lda (FAC3),y
                    and pixel_mask_1
                    beq Lc5ee
                    lda MODE
                    beq Lc5e0
                    lda pixel_mask_1
                    sec
                    sbc pixel_mask_2
                    sta pixel_mask_1
                    lda (FAC3),y
                    and pixel_mask_2
                    beq Lc5e0
                    lda (FAC3),y
                    and pixel_mask_1
                    beq Lc5e8
                    lda SOMEPTR
                    cmp #3
                    beq Lc5f9
                    bne Lc5ee
Lc5e0:              lda SOMEPTR
                    cmp #1
                    beq Lc5f9
                    bne Lc5ee
Lc5e8:              lda SOMEPTR
                    cmp #2
                    beq Lc5f9
Lc5ee:              lda #0
                    sta DATASETBUF+54
                    sta FAC1
                    sta FAC1+1
                    beq Lc606
Lc5f9:              lda #1
                    sta DATASETBUF+54
                    lda #$81
                    sta FAC1
                    lda #$80
                    sta FAC1+1
Lc606:              lda #0
                    tax
                    tay
                    sta FAC1+2
                    sta FAC1+3
                    sta FAC1+4
                    sta FAC1+5
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    lda #0
                    rts
                    
hires_fill:         jsr CHKCMA
                    jsr GETNUM
                    stx DATASETBUF+2
                    ldx #0
                    jsr $b7f1
                    stx TMP
                    ldx #0
                    jsr $b7f1
                    stx DATASETBUF+55
                    ldx #0
                    jsr $b7f1
                    sta DATASETBUF+56
                    lda #0
                    sta DATASETBUF+3
                    lda LINNUM
                    sta DATASETBUF
                    lda LINNUM+1
                    sta DATASETBUF+1
                    lda #3
                    cmp DATASETBUF+55
                    bmi Lc657
                    cmp DATASETBUF+56
                    bmi Lc657
                    jmp Lc65d
                    
Lc657:              jsr hires_exit
                    jmp FCERR
                    
Lc65d:              jsr Sc746
                    jsr prepare_coords
                    lda #0
                    sta $02
                    lda MODE
                    bne Lc679
                    lda #1
                    sta DATASETBUF+55
                    sta DATASETBUF+56
                    sta DATASETBUF+46
                    jmp Lc67e
                    
Lc679:              lda #2
                    sta DATASETBUF+46
Lc67e:              lda #0
                    sta DATASETBUF+58
                    sta DATASETBUF+57
                    jsr Sc7bd
Lc689:              jsr Sc746
                    lda DATASETBUF+55
                    sta SOMEPTR
                    jsr Sc5a7
                    lda DATASETBUF+54
                    beq Lc69c
                    jmp Lc75a
                    
Lc69c:              jsr Sc746
                    lda DATASETBUF+56
                    sta SOMEPTR
                    jsr Sc5a7
                    lda DATASETBUF+54
                    beq Lc6af
                    jmp Lc75a
                    
Lc6af:              lda DATASETBUF+2
                    cmp #$c7
                    beq Lc6e0
                    jsr Sc746
                    lda DATASETBUF+55
                    sta SOMEPTR
                    inc Y_COORD
                    jsr Sc5a7
                    lda DATASETBUF+54
                    bne Lc6e0
                    jsr Sc746
                    lda DATASETBUF+56
                    sta SOMEPTR
                    inc Y_COORD
                    jsr Sc5a7
                    lda DATASETBUF+54
                    bne Lc6e0
                    jsr Sc779
                    jmp Lc6e5
                    
Lc6e0:              lda #0
                    sta DATASETBUF+58
Lc6e5:              lda #0
                    cmp DATASETBUF+2
                    beq Lc716
                    jsr Sc746
                    lda DATASETBUF+55
                    sta SOMEPTR
                    dec Y_COORD
                    jsr Sc5a7
                    lda DATASETBUF+54
                    bne Lc716
                    jsr Sc746
                    lda DATASETBUF+56
                    sta SOMEPTR
                    dec Y_COORD
                    jsr Sc5a7
                    lda DATASETBUF+54
                    bne Lc716
                    jsr Sc78c
                    jmp Lc71b
                    
Lc716:              lda #0
                    sta DATASETBUF+57
Lc71b:              jsr Sc746
                    lda DATASETBUF+55
                    sta SOMEPTR
                    lda TMP
                    sta SOMEPTR+1
                    jsr Sc1cf
                    sec
                    lda DATASETBUF
                    sbc DATASETBUF+46
                    sta DATASETBUF
                    lda DATASETBUF+1
                    sbc #0
                    sta DATASETBUF+1
                    cmp #2
                    bcc Lc743
                    jmp Lc75a
                    
Lc743:              jmp Lc689
                    
Sc746:              lda DATASETBUF
                    sta X_COORD_LO
                    lda DATASETBUF+1
                    sta X_COORD_HI
                    lda DATASETBUF+2
                    sta Y_COORD
                    lda #0
                    sta FAC4
                    rts
                    
Lc75a:              ldx $02
                    beq Lc778
                    dex
                    lda BUF,x
                    sta DATASETBUF+2
                    dex
                    lda BUF,x
                    sta DATASETBUF+1
                    dex
                    lda BUF,x
                    sta DATASETBUF
                    stx $02
                    jmp Lc67e
                    
Lc778:              rts
                    
Sc779:              lda DATASETBUF+58
                    beq Lc77f
                    rts
                    
Lc77f:              lda #1
                    sta DATASETBUF+58
                    jsr Sc746
                    inc Y_COORD
                    jmp Lc79c
                    
Sc78c:              lda DATASETBUF+57
                    beq Lc792
                    rts
                    
Lc792:              lda #1
                    sta DATASETBUF+57
                    jsr Sc746
                    dec Y_COORD
Lc79c:              ldx $02
                    cpx #$bb
                    bcc Lc7a8
                    jsr hires_exit
                    jmp OVERR
                    
Lc7a8:              lda X_COORD_LO
                    sta BUF,x
                    inx
                    lda X_COORD_HI
                    sta BUF,x
                    inx
                    lda Y_COORD
                    sta BUF,x
                    inx
                    stx $02
                    rts
                    
Sc7bd:              clc
                    lda DATASETBUF
                    adc DATASETBUF+46
                    sta DATASETBUF+4
                    sta X_COORD_LO
                    lda DATASETBUF+1
                    adc #0
                    sta DATASETBUF+5
                    sta X_COORD_HI
                    lda DATASETBUF+2
                    sta Y_COORD
                    lda #0
                    sta FAC4
                    lda DATASETBUF+5
                    beq Lc7ee
                    cmp #1
                    beq Lc7e6
                    rts
                    
Lc7e6:              lda DATASETBUF+4
                    cmp #$40
                    bcc Lc7ee
                    rts
                    
Lc7ee:              lda DATASETBUF+56
                    sta SOMEPTR
                    jsr Sc5a7
                    lda DATASETBUF+54
                    beq Lc7fc
                    rts
                    
Lc7fc:              lda DATASETBUF+4
                    sta DATASETBUF
                    lda DATASETBUF+5
                    sta DATASETBUF+1
                    jmp Sc7bd
