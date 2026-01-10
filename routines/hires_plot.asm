; Input
x = $59
y = $5B
brush = $fc
colour = $fd

hires_plot:
                    ; parse parameters: x, y
                    jsr CHKCMA
                    jsr GETNUM
                    lda LINNUM
                    sta x
                    lda LINNUM+1
                    sta x+1
                    txa
                    sta y
                    ; parse parameters colour, brush
                    jsr CHKCMA
                    jsr GETNUM
                    txa
                    sta brush
                    lda LINNUM
                    sta colour
hires_plot_internal:
                    jsr prepare_coords
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
                    lda brush
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
                    lda (pixel_bitmap_addr),y
                    and pixel_mask_1
                    and pixel_mask_2
                    sta (pixel_bitmap_addr),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts

hires_plot_mc_01:
                    ldy #0
                    lda pixel_mask_2
                    eor #%11111111
                    sta pixel_mask_2
                    lda (pixel_bitmap_addr),y
                    ora pixel_mask_1
                    and pixel_mask_2
                    sta (pixel_bitmap_addr),y
                    lda #$84
                    clc
                    adc pixel_screen_ram_addr
                    sta pixel_screen_ram_addr
                    asl colour
                    asl colour
                    asl colour
                    asl colour
                    lda (y),y
                    and #%00001111
                    clc
                    adc colour
                    sta (y),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts

hires_plot_mc_10:
                    ldy #0
                    lda pixel_mask_1
                    eor #%11111111
                    sta pixel_mask_1
                    lda (pixel_bitmap_addr),y
                    and pixel_mask_1
                    ora pixel_mask_2
                    sta (pixel_bitmap_addr),y
                    clc
                    lda #$84
                    adc pixel_screen_ram_addr
                    sta pixel_screen_ram_addr
                    lda (y),y
                    and #%11110000
                    clc
                    adc colour
                    sta (y),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts

hires_plot_mc_11:
                    ldy #0
                    lda (pixel_bitmap_addr),y
                    ora pixel_mask_1
                    ora pixel_mask_2
                    sta (pixel_bitmap_addr),y
                    lda #$d8
                    clc
                    adc pixel_screen_ram_addr
                    sta pixel_screen_ram_addr
                    lda colour
                    sta (y),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts

                    ; do a hires plot
hires_plot_hr:      ldy #0
                    lda brush
                    beq hires_plot_hr_0
hires_plot_hr_1:
                    lda (pixel_bitmap_addr),y
                    ora pixel_mask_1
                    sta (pixel_bitmap_addr),y
                    lda #$84
                    clc
                    adc pixel_screen_ram_addr
                    sta pixel_screen_ram_addr
                    lda colour
                    asl
                    asl
                    asl
                    asl
                    sta pixel_mask_2
                    lda (y),y
                    and #%00001111
                    clc
                    adc pixel_mask_2
                    sta (y),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts

hires_plot_hr_0:    lda pixel_mask_1
                    eor #%11111111
                    sta pixel_mask_1
                    lda (pixel_bitmap_addr),y
                    and pixel_mask_1
                    sta (pixel_bitmap_addr),y
                    ; switch in BASIC ROM bank
                    lda #%00110111
                    sta PPORT
                    rts

