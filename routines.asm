*                   = $C000

                    CHKCMA = $AEFD  ; check for comma
                    GETNUM = $B7EB  ; Get a 16-Bit Address Parameter and an 8-Bit Parameter in LINNUM and X
                    OVERR = $B97E   ; prints overflow error
                    FCERR = $B248   ; prints illegal quantity error
                    LINNUM = $14    ;
                    VMCSB = $D018   ; VIC-II Chip Memory Control Register
                    BGCOL0 = $D021  ; Background Color 0
                    EXTCOL = $D020  ; Border Color Register

                    MODE = $FB      ; zeropage storage for mode (0=320x200, 1=160x200)
                    NUMWRK_0 = $57           ; BASIC Numeric Work Area byte 0
                    NUMWRK_1 = NUMWRK_0+1    ; BASIC Numeric Work Area byte 1
                    NUMWRK_2 = NUMWRK_0+2    ; BASIC Numeric Work Area byte 2
                    NUMWRK_3 = NUMWRK_0+3    ; BASIC Numeric Work Area byte 3
                    NUMWRK_4 = NUMWRK_0+4    ; BASIC Numeric Work Area byte 4
                    NUMWRK_5 = NUMWRK_0+5    ; BASIC Numeric Work Area byte 5
                    NUMWRK_6 = NUMWRK_0+6    ; BASIC Numeric Work Area byte 6
                    NUMWRK_7 = NUMWRK_0+7    ; BASIC Numeric Work Area byte 7
                    NUMWRK_8 = NUMWRK_0+8    ; BASIC Numeric Work Area byte 8


; SYS49152,MODE,KLEUR
;   MODE=0: standaard(tweekleuren)instelling
;   MODE=1: multi-colourstand
;   KLEUR : kleurcode voor de rand en het scherm
;           (rand valt dus weg) (0=zwart; 1=wit)
hires_init:         jsr CHKCMA
                    jsr GETNUM
                    txa         ; KLEUR
                    sta EXTCOL
                    sta BGCOL0
                    lda LINNUM  ; MODE
                    sta MODE
                    beq Lc015
                    ldx #$00
Lc015:              jsr hires_clear
                    jsr Sc080
                    jsr Sc0a6
hires_enter:        lda #$3b
                    sta $d011
                    lda #$1d
                    sta VMCSB
                    lda MODE
                    beq Lc031
                    lda #$d8
                    sta $d016
Lc031:              lda #$80
                    sta $38
                    sta $34
                    lda $dd02
                    ora #$03
                    sta $dd02
                    lda $dd00
                    and #$fc
                    ora #$01
                    sta $dd00
                    lda #$84
                    sta $0288
                    lda #$4f
                    sta $0311
                    lda #$c5
                    sta $0312
                    rts

hires_clear:        ldy #$00        ; Clear color memory?
                    lda #$40
                    sta NUMWRK_0
                    lda #$bf
                    sta NUMWRK_1
Lc063:              lda #$00
                    sta (NUMWRK_0),y
                    lda NUMWRK_0
                    beq Lc070
                    dec NUMWRK_0
                    jmp Lc063
                    
Lc070:              dec NUMWRK_1
                    lda NUMWRK_1
                    cmp #$9f
                    beq Lc07f
                    lda #$ff
                    sta $57
                    jmp Lc063
                    
Lc07f:              rts
                    
Sc080:              ldy #$00
                    lda #$e7
                    sta $57
                    lda #$87
                    sta NUMWRK_1
Lc08a:              txa
                    sta ($57),y
                    lda $57
                    beq Lc096
                    dec $57
                    jmp Lc08a
                    
Lc096:              dec NUMWRK_1
                    lda NUMWRK_1
                    cmp #$83
                    beq Lc0a5
                    lda #$ff
                    sta $57
                    jmp Lc08a
                    
Lc0a5:              rts
                    
Sc0a6:              ldy #$00
                    lda #$e7
                    sta $57
                    lda #$db
                    sta NUMWRK_1
Lc0b0:              lda #$00
                    sta ($57),y
                    lda $57
                    beq Lc0bd
                    dec $57
                    jmp Lc0b0
                    
Lc0bd:              dec NUMWRK_1
                    lda NUMWRK_1
                    cmp #$d7
                    beq Lc0cc
                    lda #$ff
                    sta $57
                    jmp Lc0b0
                    
Lc0cc:              rts
                    
Lc0cd:              lda NUMWRK_3
                    cmp #$00
                    beq Lc0e3
                    cmp #$01
                    bne Lc0dd
                    lda $59
                    cmp #$40
                    bcc Lc0e3
Lc0dd:              jsr hires_exit
                    jmp FCERR
                    
Lc0e3:              lda NUMWRK_4
                    cmp #$c8
                    bcc Lc0ef
                    jsr hires_exit
                    jmp FCERR
                    
Lc0ef:              lda $59
                    and #$07
                    sta NUMWRK_7
                    lda #$07
                    sec
                    sbc NUMWRK_7
                    sta NUMWRK_7
                    lda MODE
                    beq Lc10b
                    lsr NUMWRK_7
                    asl NUMWRK_7
                    lda NUMWRK_7
                    clc
                    adc #$01
                    sta NUMWRK_8
Lc10b:              lda NUMWRK_7
                    beq Lc118
                    tay
                    lda #$01
Lc112:              asl a
                    dey
                    bne Lc112
                    beq Lc11a
Lc118:              lda #$01
Lc11a:              sta NUMWRK_7
                    lda NUMWRK_8
                    beq Lc129
                    tay
                    lda #$01
Lc123:              asl a
                    dey
                    bne Lc123
                    beq Lc12b
Lc129:              lda #$01
Lc12b:              sta NUMWRK_8
                    lda #$00
                    sta NUMWRK_5
                    sta NUMWRK_1
                    sta $57
                    lda NUMWRK_4
                    and #$07
                    sta NUMWRK_6
                    lda NUMWRK_4
                    lsr a
                    lsr a
                    lsr a
                    sta NUMWRK_4
                    ldy #$05
Lc144:              clc
                    asl a
                    rol NUMWRK_1
                    dey
                    bne Lc144
                    sta $57
                    lda NUMWRK_4
                    ldy #$03
Lc151:              clc
                    asl a
                    dey
                    bne Lc151
                    sta NUMWRK_4
                    clc
                    adc $57
                    sta NUMWRK_4
                    lda NUMWRK_1
                    adc #$00
                    sta NUMWRK_5
                    ldy #$03
Lc165:              clc
                    lsr NUMWRK_3
                    ror $59
                    dey
                    bne Lc165
                    lda $59
                    sta $57
                    lda NUMWRK_3
                    sta NUMWRK_1
                    ldy #$03
Lc177:              clc
                    asl $57
                    rol NUMWRK_1
                    dey
                    bne Lc177
                    ldy #$08
Lc181:               clc
                    lda NUMWRK_4
                    adc $57
                    sta $57
                    lda NUMWRK_5
                    adc NUMWRK_1
                    sta NUMWRK_1
                    dey
                    bne Lc181
                    clc
                    lda NUMWRK_6
                    adc $57
                    sta $57
                    lda #$00
                    adc NUMWRK_1
                    clc
                    lda #$a0
                    adc NUMWRK_1
                    sta NUMWRK_1
                    clc
                    lda $59
                    adc NUMWRK_4
                    sta NUMWRK_4
                    lda #$00
                    adc NUMWRK_5
                    sta NUMWRK_5
                    rts
                    
hires_plot:          jsr CHKCMA
                    jsr GETNUM
                    lda LINNUM
                    sta $59
                    lda LINNUM+1
                    sta NUMWRK_3
                    txa
                    sta NUMWRK_4
                    jsr CHKCMA
                    jsr GETNUM
                    txa
                    sta $fc
                    lda LINNUM
                    sta $fd
Sc1cf:               jsr Lc0cd
                    lda #$36
                    sta $01
                    lda MODE
                    bne Lc1dd
                    jmp Lc27b
                    
Lc1dd:               lda $fc
                    cmp #$00
                    beq Lc1f4
                    cmp #$01
                    beq Lc20f
                    cmp #$02
                    beq Lc23c
                    cmp #$03
                    beq Lc261
                    lda #$37
                    sta $01
                    rts
                    
Lc1f4:               ldy #$00
                    lda NUMWRK_7
                    eor #$ff
                    sta NUMWRK_7
                    lda NUMWRK_8
                    eor #$ff
                    sta NUMWRK_8
                    lda (NUMWRK_0),y
                    and NUMWRK_7
                    and NUMWRK_8
                    sta (NUMWRK_0),y
                    lda #$37
                    sta $01
                    rts
                    
Lc20f:               ldy #$00
                    lda NUMWRK_8
                    eor #$ff
                    sta NUMWRK_8
                    lda (NUMWRK_0),y
                    ora NUMWRK_7
                    and NUMWRK_8
                    sta (NUMWRK_0),y
                    lda #$84
                    clc
                    adc NUMWRK_5
                    sta NUMWRK_5
                    asl $fd
                    asl $fd
                    asl $fd
                    asl $fd
                    lda (NUMWRK_4),y
                    and #$0f
                    clc
                    adc $fd
                    sta (NUMWRK_4),y
                    lda #$37
                    sta $01
                    rts
                    
Lc23c:               ldy #$00
                    lda NUMWRK_7
                    eor #$ff
                    sta NUMWRK_7
                    lda (NUMWRK_0),y
                    and NUMWRK_7
                    ora NUMWRK_8
                    sta (NUMWRK_0),y
                    clc
                    lda #$84
                    adc NUMWRK_5
                    sta NUMWRK_5
                    lda (NUMWRK_4),y
                    and #$f0
                    clc
                    adc $fd
                    sta (NUMWRK_4),y
                    lda #$37
                    sta $01
                    rts
                    
Lc261:               ldy #$00
                    lda (NUMWRK_0),y
                    ora NUMWRK_7
                    ora NUMWRK_8
                    sta (NUMWRK_0),y
                    lda #$d8
                    clc
                    adc NUMWRK_5
                    sta NUMWRK_5
                    lda $fd
                    sta (NUMWRK_4),y
                    lda #$37
                    sta $01
                    rts
                    
Lc27b:               ldy #$00
                    lda $fc
                    beq Lc2a4
                    lda (NUMWRK_0),y
                    ora NUMWRK_7
                    sta (NUMWRK_0),y
                    lda #$84
                    clc
                    adc NUMWRK_5
                    sta NUMWRK_5
                    lda $fd
                    asl a
                    asl a
                    asl a
                    asl a
                    sta NUMWRK_8
                    lda (NUMWRK_4),y
                    and #$0f
                    clc
                    adc NUMWRK_8
                    sta (NUMWRK_4),y
                    lda #$37
                    sta $01
                    rts
                    
Lc2a4:               lda NUMWRK_7
                    eor #$ff
                    sta NUMWRK_7
                    lda (NUMWRK_0),y
                    and NUMWRK_7
                    sta (NUMWRK_0),y
                    lda #$37
                    sta $01
                    rts
                    
hires_exit:          lda #$04
                    sta $0288
                    lda $dd02
                    and #$fc
                    sta $dd02
                    lda #$1b
                    sta $d011
                    lda #$c8
                    sta $d016
                    lda #$15
                    sta VMCSB
                    rts
                    
hires_line:          jsr CHKCMA
                    jsr GETNUM
                    txa
                    sta $033e
                    lda #$00
                    sta $033f
                    lda LINNUM
                    sta $033c
                    lda LINNUM+1
                    sta $033d
                    jsr CHKCMA
                    jsr GETNUM
                    txa
                    sta $0342
                    lda #$00
                    sta $0343
                    lda LINNUM
                    sta $0340
                    lda LINNUM+1
                    sta $0341
                    jsr CHKCMA
                    jsr GETNUM
                    txa
                    sta $fc
                    lda LINNUM
                    sta $fe
                    lda $0340
                    sec
                    sbc $033c
                    sta $0344
                    lda $0341
                    sbc $033d
                    sta $0345
                    lda $0342
                    sec
                    sbc $033e
                    sta $0346
                    lda $033f
                    sbc $0343
                    sta $0347
                    lda #$01
                    sta $035e
                    sta $0360
                    lda #$00
                    sta $035f
                    sta $0361
                    lda $0347
                    and #$80
                    beq Lc356
                    lda #$ff
                    sta $035e
                    sta $035f
Lc356:               lda $0345
                    and #$80
                    beq Lc365
                    lda #$ff
                    sta $0360
                    sta $0361
Lc365:               lda $0345
                    and #$80
                    beq Lc38a
                    lda $0345
                    eor #$ff
                    sta $0349
                    clc
                    lda $0344
                    eor #$ff
                    adc #$01
                    sta $0348
                    lda $0349
                    adc #$00
                    sta $0349
                    jmp Lc396
                    
Lc38a:               lda $0344
                    sta $0348
                    lda $0345
                    sta $0349
Lc396:               lda $0347
                    and #$80
                    beq Lc3bb
                    lda $0347
                    eor #$ff
                    sta $034b
                    clc
                    lda $0346
                    eor #$ff
                    adc #$01
                    sta $034a
                    lda $034b
                    adc #$00
                    sta $034b
                    jmp Lc3c7
                    
Lc3bb:               lda $0346
                    sta $034a
                    lda $0347
                    sta $034b
Lc3c7:               lda $0348
                    sec
                    sbc $034a
                    sta $0358
                    lda $0349
                    sbc $034b
                    sta $0359
                    and #$80
                    beq Lc41a
                    lda #$ff
                    sta $035a
                    sta $035b
                    lda #$00
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
                    lda $0347
                    and #$80
                    bne Lc453
                    lda #$01
                    sta $035a
                    lda #$00
                    sta $035b
                    jmp Lc453
                    
Lc41a:               lda #$00
                    sta $035a
                    sta $035b
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
                    lda $0345
                    and #$80
                    bne Lc453
                    lda #$01
                    sta $035c
                    lda #$00
                    sta $035d
Lc453:               lda $034c
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
                    sta $0354
                    lda $034d
                    sbc $034f
                    sta $0355
                    lsr $034d
                    ror $034c
                    lda $034e
                    sec
                    sbc $034c
                    sta $0356
                    lda $034f
                    sbc $034d
                    sta $0357
Lc497:               lda $033c
                    sta $59
                    lda $033d
                    sta NUMWRK_3
                    lda $033e
                    sta NUMWRK_4
                    lda $fe
                    sta $fd
                    jsr Sc1cf
                    lda $0357
                    and #$80
                    beq Lc4f0
                    lda $0356
                    clc
                    adc $0350
                    sta $0356
                    lda $0357
                    adc $0351
                    sta $0357
                    lda $033c
                    clc
                    adc $035c
                    sta $033c
                    lda $033d
                    adc $035d
                    sta $033d
                    lda $033e
                    clc
                    adc $035a
                    sta $033e
                    lda $033f
                    adc $035b
                    sta $033f
                    jmp Lc529
                    
Lc4f0:               lda $0356
                    sec
                    sbc $0354
                    sta $0356
                    lda $0357
                    sbc $0355
                    sta $0357
                    lda $033c
                    clc
                    adc $0360
                    sta $033c
                    lda $033d
                    adc $0361
                    sta $033d
                    lda $033e
                    clc
                    adc $035e
                    sta $033e
                    lda $033f
                    adc $035f
                    sta $033f
Lc529:               lda $0352
                    sec
                    sbc #$01
                    sta $0352
                    lda $0353
                    sbc #$00
                    sta $0353
                    lda $0353
                    beq Lc546
                    cmp #$ff
                    beq Lc54e
                    jmp Lc497
                    
Lc546:               lda $0352
                    beq Lc54e
                    jmp Lc497
                    
Lc54e:               rts
                    
hires_isset:         lda $66
                    bne Lc581
                    lda $65
                    bne Lc581
                    lda $64
                    bne Lc581
                    lda $63
                    bne Lc581
                    lda $62
                    cmp #$80
                    beq Lc575
                    cmp #$c0
                    bne Lc581
                    lda $61
                    cmp #$82
                    bne Lc581
                    lda #$03
                    sta $fc
                    bne Lc593
Lc575:               lda $61
                    beq Lc581
                    cmp #$81
                    beq Lc587
                    cmp #$82
                    beq Lc58d
Lc581:               jsr hires_exit
                    jmp FCERR
                    
Lc587:               lda #$01
                    sta $fc
                    bne Lc593
Lc58d:               lda #$02
                    sta $fc
                    bne Lc593
Lc593:               jsr CHKCMA
                    jsr GETNUM
                    stx NUMWRK_4
                    lda #$00
                    sta NUMWRK_5
                    lda LINNUM
                    sta $59
                    lda LINNUM+1
                    sta NUMWRK_3
Sc5a7:               jsr Lc0cd
                    lda MODE
                    beq Lc5b5
                    lda NUMWRK_8
                    clc
                    adc NUMWRK_7
                    sta NUMWRK_7
Lc5b5:               lda #$36
                    sta $01
                    ldy #$00
                    lda (NUMWRK_0),y
                    and NUMWRK_7
                    beq Lc5ee
                    lda MODE
                    beq Lc5e0
                    lda NUMWRK_7
                    sec
                    sbc NUMWRK_8
                    sta NUMWRK_7
                    lda (NUMWRK_0),y
                    and NUMWRK_8
                    beq Lc5e0
                    lda (NUMWRK_0),y
                    and NUMWRK_7
                    beq Lc5e8
                    lda $fc
                    cmp #$03
                    beq Lc5f9
                    bne Lc5ee
Lc5e0:               lda $fc
                    cmp #$01
                    beq Lc5f9
                    bne Lc5ee
Lc5e8:               lda $fc
                    cmp #$02
                    beq Lc5f9
Lc5ee:               lda #$00
                    sta $0372
                    sta $61
                    sta $62
                    beq Lc606
Lc5f9:               lda #$01
                    sta $0372
                    lda #$81
                    sta $61
                    lda #$80
                    sta $62
Lc606:               lda #$00
                    tax
                    tay
                    sta $63
                    sta $64
                    sta $65
                    sta $66
                    lda #$37
                    sta $01
                    lda #$00
                    rts
                    
hires_fill:          jsr CHKCMA
                    jsr GETNUM
                    stx $033e
                    ldx #$00
                    jsr $b7f1
                    stx $fe
                    ldx #$00
                    jsr $b7f1
                    stx $0373
                    ldx #$00
                    jsr $b7f1
                    sta $0374
                    lda #$00
                    sta $033f
                    lda LINNUM
                    sta $033c
                    lda LINNUM+1
                    sta $033d
                    lda #$03
                    cmp $0373
                    bmi Lc657
                    cmp $0374
                    bmi Lc657
                    jmp Lc65d
                    
Lc657:               jsr hires_exit
                    jmp FCERR
                    
Lc65d:               jsr Sc746
                    jsr Lc0cd
                    lda #$00
                    sta $02
                    lda MODE
                    bne Lc679
                    lda #$01
                    sta $0373
                    sta $0374
                    sta $036a
                    jmp Lc67e
                    
Lc679:               lda #$02
                    sta $036a
Lc67e:               lda #$00
                    sta $0376
                    sta $0375
                    jsr Sc7bd
Lc689:               jsr Sc746
                    lda $0373
                    sta $fc
                    jsr Sc5a7
                    lda $0372
                    beq Lc69c
                    jmp Lc75a
                    
Lc69c:               jsr Sc746
                    lda $0374
                    sta $fc
                    jsr Sc5a7
                    lda $0372
                    beq Lc6af
                    jmp Lc75a
                    
Lc6af:               lda $033e
                    cmp #$c7
                    beq Lc6e0
                    jsr Sc746
                    lda $0373
                    sta $fc
                    inc NUMWRK_4
                    jsr Sc5a7
                    lda $0372
                    bne Lc6e0
                    jsr Sc746
                    lda $0374
                    sta $fc
                    inc NUMWRK_4
                    jsr Sc5a7
                    lda $0372
                    bne Lc6e0
                    jsr Sc779
                    jmp Lc6e5
                    
Lc6e0:               lda #$00
                    sta $0376
Lc6e5:               lda #$00
                    cmp $033e
                    beq Lc716
                    jsr Sc746
                    lda $0373
                    sta $fc
                    dec NUMWRK_4
                    jsr Sc5a7
                    lda $0372
                    bne Lc716
                    jsr Sc746
                    lda $0374
                    sta $fc
                    dec NUMWRK_4
                    jsr Sc5a7
                    lda $0372
                    bne Lc716
                    jsr Sc78c
                    jmp Lc71b
                    
Lc716:               lda #$00
                    sta $0375
Lc71b:               jsr Sc746
                    lda $0373
                    sta $fc
                    lda $fe
                    sta $fd
                    jsr Sc1cf
                    sec
                    lda $033c
                    sbc $036a
                    sta $033c
                    lda $033d
                    sbc #$00
                    sta $033d
                    cmp #$02
                    bcc Lc743
                    jmp Lc75a
                    
Lc743:               jmp Lc689
                    
Sc746:               lda $033c
                    sta NUMWRK_2
                    lda $033d
                    sta NUMWRK_3
                    lda $033e
                    sta NUMWRK_4
                    lda #$00
                    sta NUMWRK_5
                    rts
                    
Lc75a:               ldx $02
                    beq Lc778
                    dex
                    lda $cf00,x
                    sta $033e
                    dex
                    lda $cf00,x
                    sta $033d
                    dex
                    lda $cf00,x
                    sta $033c
                    stx $02
                    jmp Lc67e
                    
Lc778:               rts
                    
Sc779:               lda $0376
                    beq Lc77f
                    rts
                    
Lc77f:               lda #$01
                    sta $0376
                    jsr Sc746
                    inc NUMWRK_4
                    jmp Lc79c
                    
Sc78c:               lda $0375
                    beq Lc792
                    rts
                    
Lc792:               lda #$01
                    sta $0375
                    jsr Sc746
                    dec NUMWRK_4
Lc79c:               ldx $02
                    cpx #$bb
                    bcc Lc7a8
                    jsr hires_exit
                    jmp OVERR
                    
Lc7a8:               lda NUMWRK_2
                    sta $cf00,x
                    inx
                    lda NUMWRK_3
                    sta $cf00,x
                    inx
                    lda NUMWRK_4
                    sta $cf00,x
                    inx
                    stx $02
                    rts
                    
Sc7bd:               clc
                    lda $033c
                    adc $036a
                    sta $0340
                    sta NUMWRK_2
                    lda $033d
                    adc #$00
                    sta $0341
                    sta NUMWRK_3
                    lda $033e
                    sta NUMWRK_4
                    lda #$00
                    sta NUMWRK_5
                    lda $0341
                    beq Lc7ee
                    cmp #$01
                    beq Lc7e6
                    rts
                    
Lc7e6:               lda $0340
                    cmp #$40
                    bcc Lc7ee
                    rts
                    
Lc7ee:               lda $0374
                    sta $fc
                    jsr Sc5a7
                    lda $0372
                    beq Lc7fc
                    rts
                    
Lc7fc:               lda $0340
                    sta $033c
                    lda $0341
                    sta $033d
                    jmp Sc7bd
