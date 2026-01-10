; Takes the coordinates parsed from the BASIC program,
; and puts them in the right places for the plot routine.

; Output
pixel_screen_ram_addr = $5C
pixel_bitmap_addr = $57
pixel_mask_1 = $5E
pixel_mask_2 = $5F

prepare_coords:
                    ; X should have 0 or 1 as high byte
                    lda x+1
                    cmp #0
                    beq check_y
                    cmp #1
                    bne invalid_x
                    ; and when high byte is 1, low byte should be < 64
                    ; because 256+64 = 320
                    lda x
                    cmp #64
                    bcc check_y
invalid_x:          jsr hires_exit
                    jmp FCERR

check_y:            lda y
                    cmp #200
                    bcc make_pixel_masks
                    jsr hires_exit
                    jmp FCERR

make_pixel_masks:   lda x
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
Lc112:              asl
                    dey
                    bne Lc112
                    beq Lc11a
Lc118:              lda #1
Lc11a:              sta pixel_mask_1
                    lda pixel_mask_2
                    beq Lc129
                    tay
                    lda #1
Lc123:              asl
                    dey
                    bne Lc123
                    beq Lc12b
Lc129:              lda #1
Lc12b:              sta pixel_mask_2
                    ; now calculate memory address of the coordinate
                    lda #0
                    sta pixel_screen_ram_addr
                    sta pixel_bitmap_addr+1
                    sta pixel_bitmap_addr
                    lda y
                    and #%00000111
                    sta pixel_screen_ram_addr+1
                    lda y
                    lsr
                    lsr
                    lsr
                    sta y
                    ldy #5
Lc144:              clc
                    asl
                    rol pixel_bitmap_addr+1
                    dey
                    bne Lc144
                    sta pixel_bitmap_addr
                    lda y
                    ldy #3
Lc151:              clc
                    asl
                    dey
                    bne Lc151
                    sta y
                    clc
                    adc pixel_bitmap_addr
                    sta y
                    lda pixel_bitmap_addr+1
                    adc #0
                    sta pixel_screen_ram_addr
                    ldy #3
Lc165:              clc
                    lsr x+1
                    ror x
                    dey
                    bne Lc165
                    lda x
                    sta pixel_bitmap_addr
                    lda x+1
                    sta pixel_bitmap_addr+1
                    ldy #3
Lc177:              clc
                    asl pixel_bitmap_addr
                    rol pixel_bitmap_addr+1
                    dey
                    bne Lc177
                    ldy #8
Lc181:              clc
                    lda y
                    adc pixel_bitmap_addr
                    sta pixel_bitmap_addr
                    lda pixel_screen_ram_addr
                    adc pixel_bitmap_addr+1
                    sta pixel_bitmap_addr+1
                    dey
                    bne Lc181
                    clc
                    lda pixel_screen_ram_addr+1
                    adc pixel_bitmap_addr
                    sta pixel_bitmap_addr
                    lda #0
                    adc pixel_bitmap_addr+1
                    clc
                    lda #$a0
                    adc pixel_bitmap_addr+1
                    sta pixel_bitmap_addr+1
                    clc
                    lda x
                    adc y
                    sta y
                    lda #0
                    adc pixel_screen_ram_addr
                    sta pixel_screen_ram_addr
                    rts
