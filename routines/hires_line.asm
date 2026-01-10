DATASETBUF = $033C       ; datasette buffer
x1 = DATASETBUF
y1 = DATASETBUF+2
x2 = DATASETBUF+4
y2 = DATASETBUF+6
TMP = $FE

hires_line:
                    ; parse x1,y1
                    jsr CHKCMA
                    jsr GETNUM
                    ; store y1
                    txa
                    sta y1
                    lda #0
                    sta y1+1
                    ; store x1
                    lda LINNUM
                    sta x1
                    lda LINNUM+1
                    sta x1+1
                    ; parse x2, y2
                    jsr CHKCMA
                    jsr GETNUM
                    ; store y2
                    txa
                    sta y2
                    lda #0
                    sta y2+1
                    ; store x2
                    lda LINNUM
                    sta x2
                    lda LINNUM+1
                    sta x2+1
                    ; parse colour, brush
                    jsr CHKCMA
                    jsr GETNUM
                    ; store brush
                    txa
                    sta SOMEPTR
                    lda LINNUM
                    ; store colour
                    sta TMP
                    ;
                    lda x2
                    sec
                    sbc x1
                    sta DATASETBUF+8
                    lda x2+1
                    sbc x1+1
                    sta DATASETBUF+9
                    lda y2
                    sec
                    sbc y1
                    sta DATASETBUF+10
                    lda y1+1
                    sbc y2+1
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
Lc497:              lda x1
                    sta X_COORD_LO
                    lda x1+1
                    sta X_COORD_HI
                    lda y1
                    sta Y_COORD
                    lda TMP
                    sta SOMEPTR+1
                    jsr hires_plot_internal
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
                    lda x1
                    clc
                    adc $035c
                    sta x1
                    lda x1+1
                    adc $035d
                    sta x1+1
                    lda y1
                    clc
                    adc DATASETBUF+30
                    sta y1
                    lda y1+1
                    adc DATASETBUF+31
                    sta y1+1
                    jmp Lc529

Lc4f0:              lda DATASETBUF+26
                    sec
                    sbc DATASETBUF+24
                    sta DATASETBUF+26
                    lda DATASETBUF+27
                    sbc DATASETBUF+25
                    sta DATASETBUF+27
                    lda x1
                    clc
                    adc DATASETBUF+36
                    sta x1
                    lda x1+1
                    adc DATASETBUF+37
                    sta x1+1
                    lda y1
                    clc
                    adc DATASETBUF+34
                    sta y1
                    lda y1+1
                    adc DATASETBUF+35
                    sta y1+1
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
