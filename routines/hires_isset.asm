; TODO no support for brush 00

FAC1 = $61          ; USR() parameter and return value storage
; return value for callers of hires_isset_internal
is_set = $0372

hires_isset:        ; parse the number in FAC1
                    lda FAC1+5
                    bne invalid_brush
                    lda FAC1+4
                    bne invalid_brush
                    lda FAC1+3
                    bne invalid_brush
                    lda FAC1+2
                    bne invalid_brush
                    lda FAC1+1
                    cmp #$80
                    beq Lc575
                    cmp #$c0
                    bne invalid_brush
                    lda FAC1
                    cmp #$82
                    bne invalid_brush
                    ; 82 c0 -> brush 11
                    lda #3
                    sta brush
                    bne parse_coordinate
Lc575:              lda FAC1
                    beq invalid_brush
                    cmp #$81
                    ; 81 80 -> brush 01
                    beq brush_01
                    cmp #$82
                    ; 82 80 -> brush 10
                    beq brush_10
invalid_brush:      jsr hires_exit
                    jmp FCERR
brush_01:           lda #1
                    sta brush
                    bne parse_coordinate
brush_10:           lda #2
                    sta brush
                    bne parse_coordinate
parse_coordinate:   jsr CHKCMA
                    jsr GETNUM
                    stx y
                    lda #0
                    sta pixel_screen_ram_addr
                    lda LINNUM
                    sta x
                    lda LINNUM+1
                    sta x+1
hires_isset_internal:
                    jsr prepare_coords
                    ; combine pixel masks when multi colour mode
                    lda MODE
                    beq Lc5b5
                    lda pixel_mask_2
                    clc
                    adc pixel_mask_1
                    sta pixel_mask_1
Lc5b5:              ; switch out BASIC ROM bank
                    lda #%00110110
                    sta PPORT
                    ;
                    ldy #0
                    lda (pixel_bitmap_addr),y
                    and pixel_mask_1
                    ; bit 1 and 2 are 0, return false
                    beq return_false
                    ; bit 1 and/or 2 is 1
                    lda MODE
                    ; in hires mode, there is only 1 bit, so it must be 1
                    beq check_brush_1
                    ; TODO undo the combining that we did about 15 lines before?!
                    lda pixel_mask_1
                    sec
                    sbc pixel_mask_2
                    sta pixel_mask_1
                    lda (pixel_bitmap_addr),y
                    and pixel_mask_2
                    ; if bit 2 = 0, we have 01
                    beq check_brush_1
                    ; bit 2 = 1
                    lda (pixel_bitmap_addr),y
                    and pixel_mask_1
                    ; do we have 10?
                    beq check_brush_2
                    ; we have 11
                    lda brush
                    cmp #3
                    beq return_true
                    bne return_false
check_brush_1:      lda brush
                    cmp #1
                    beq return_true
                    bne return_false
check_brush_2:      lda brush
                    cmp #2
                    beq return_true
return_false:       ; put 0 in FAC1 as return value
                    lda #0
                    sta is_set
                    sta FAC1
                    sta FAC1+1
                    beq Lc606
return_true:        ; put 1 in FAC1 as return value
                    lda #1
                    sta is_set
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

