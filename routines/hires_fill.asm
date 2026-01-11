BUF = $CF00

hires_fill:         jsr CHKCMA
                    jsr GETNUM
                    stx DATASETBUF+2
                    ldx #0
                    jsr COMBYT
                    stx colour_tmp
                    ldx #0
                    jsr COMBYT
                    stx DATASETBUF+55
                    ldx #0
                    jsr COMBYT
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
                    sta brush
                    jsr hires_isset_internal
                    lda is_set
                    beq Lc69c
                    jmp Lc75a

Lc69c:              jsr Sc746
                    lda DATASETBUF+56
                    sta brush
                    jsr hires_isset_internal
                    lda is_set
                    beq Lc6af
                    jmp Lc75a

Lc6af:              lda DATASETBUF+2
                    cmp #$c7
                    beq Lc6e0
                    jsr Sc746
                    lda DATASETBUF+55
                    sta brush
                    inc y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc6e0
                    jsr Sc746
                    lda DATASETBUF+56
                    sta brush
                    inc y
                    jsr hires_isset_internal
                    lda is_set
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
                    sta brush
                    dec y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc716
                    jsr Sc746
                    lda DATASETBUF+56
                    sta brush
                    dec y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc716
                    jsr Sc78c
                    jmp Lc71b

Lc716:              lda #0
                    sta DATASETBUF+57
Lc71b:              jsr Sc746
                    lda DATASETBUF+55
                    sta brush
                    lda colour_tmp
                    sta colour
                    jsr hires_plot_internal
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
                    sta x
                    lda DATASETBUF+1
                    sta x+1
                    lda DATASETBUF+2
                    sta y
                    lda #0
                    sta pixel_screen_ram_addr
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
                    inc y
                    jmp Lc79c

Sc78c:              lda DATASETBUF+57
                    beq Lc792
                    rts

Lc792:              lda #1
                    sta DATASETBUF+57
                    jsr Sc746
                    dec y
Lc79c:              ldx $02
                    cpx #$bb
                    bcc Lc7a8
                    jsr hires_exit
                    jmp OVERR

Lc7a8:              lda x
                    sta BUF,x
                    inx
                    lda x+1
                    sta BUF,x
                    inx
                    lda y
                    sta BUF,x
                    inx
                    stx $02
                    rts

Sc7bd:              clc
                    lda DATASETBUF
                    adc DATASETBUF+46
                    sta DATASETBUF+4
                    sta x
                    lda DATASETBUF+1
                    adc #0
                    sta DATASETBUF+5
                    sta x+1
                    lda DATASETBUF+2
                    sta y
                    lda #0
                    sta pixel_screen_ram_addr
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
                    sta brush
                    jsr hires_isset_internal
                    lda is_set
                    beq Lc7fc
                    rts

Lc7fc:              lda DATASETBUF+4
                    sta DATASETBUF
                    lda DATASETBUF+5
                    sta DATASETBUF+1
                    jmp Sc7bd
