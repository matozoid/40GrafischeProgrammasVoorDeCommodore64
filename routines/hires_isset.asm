FAC1 = $61          ; tmp pointer storage
dunno__ = $0372

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
                    sta brush
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
                    sta brush
                    bne Lc593
Lc58d:              lda #2
                    sta brush
                    bne Lc593
Lc593:              jsr CHKCMA
                    jsr GETNUM
                    stx y
                    lda #0
                    sta pixel_screen_ram_addr
                    lda LINNUM
                    sta x
                    lda LINNUM+1
                    sta x+1
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
                    lda (pixel_bitmap_addr),y
                    and pixel_mask_1
                    beq Lc5ee
                    lda MODE
                    beq Lc5e0
                    lda pixel_mask_1
                    sec
                    sbc pixel_mask_2
                    sta pixel_mask_1
                    lda (pixel_bitmap_addr),y
                    and pixel_mask_2
                    beq Lc5e0
                    lda (pixel_bitmap_addr),y
                    and pixel_mask_1
                    beq Lc5e8
                    lda brush
                    cmp #3
                    beq Lc5f9
                    bne Lc5ee
Lc5e0:              lda brush
                    cmp #1
                    beq Lc5f9
                    bne Lc5ee
Lc5e8:              lda brush
                    cmp #2
                    beq Lc5f9
Lc5ee:              lda #0
                    sta dunno__
                    sta FAC1
                    sta FAC1+1
                    beq Lc606
Lc5f9:              lda #1
                    sta dunno__
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

