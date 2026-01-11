; An unoptimized fill routine.
; It seems unfinished because its multicolour support is broken,
; and it ignores its brush parameters.
postponed_coordinate_stack_ptr = $02
postponed_coordinate_stack = $CF00

fill_x = $033c
fill_y = $033e

horizontal_step = $036a

brush_1 = $0373
brush_2 = $0374

continue_left = DATASETBUF+57
continue_right = DATASETBUF+58

hires_fill:         ; parse parameters
                    jsr CHKCMA
                    ; store y
                    jsr GETNUM
                    stx fill_y
                    ; store colour
                    ldx #0
                    jsr COMBYT
                    stx colour_tmp
                    ; store brush 1
                    ldx #0
                    jsr COMBYT
                    stx brush_1
                    ; store brush 2
                    ldx #0
                    jsr COMBYT
                    sta brush_2
                    ; set hi byte of fill_y to 0
                    lda #0
                    sta fill_y+1
                    ; store x
                    lda LINNUM
                    sta fill_x
                    lda LINNUM+1
                    sta fill_x+1
                    ; check brush validity
                    lda #3
                    cmp brush_1
                    bmi _invalid_brush
                    cmp brush_2
                    bmi _invalid_brush
                    jmp Lc65d

_invalid_brush:     jsr hires_exit
                    jmp FCERR

Lc65d:              jsr prepare_for_prepare_coords
                    jsr prepare_coords
                    ; clear stack
                    lda #0
                    sta postponed_coordinate_stack_ptr

                    lda MODE
                    bne Lc679
                    lda #1
                    sta brush_1
                    sta brush_2
                    sta horizontal_step
                    jmp evaluate_coordinate

Lc679:              lda #2                      ; multi colour mode: double width pixels.
                    sta horizontal_step
evaluate_coordinate:
                    lda #0
                    sta continue_right
                    sta continue_left
                    jsr scan_right_until_pixel_hit
Lc689:              ; pixel at fill_x,y is brush_1 ? 
                    jsr prepare_for_prepare_coords
                    lda brush_1
                    sta brush
                    jsr hires_isset_internal
                    lda is_set
                    beq _not_brush_1
                    jmp pop_coordinate_and_continue

_not_brush_1:       ; pixel at fill_x,y is brush_2 ? 
                    jsr prepare_for_prepare_coords
                    lda brush_2
                    sta brush
                    jsr hires_isset_internal
                    lda is_set
                    beq _not_brush_2
                    jmp pop_coordinate_and_continue

_not_brush_2:       lda fill_y
                    cmp #199
                    beq Lc6e0
                    jsr prepare_for_prepare_coords
                    lda brush_1
                    sta brush
                    inc y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc6e0
                    jsr prepare_for_prepare_coords
                    lda brush_2
                    sta brush
                    inc y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc6e0
                    jsr Sc779
                    jmp Lc6e5

Lc6e0:              lda #0
                    sta continue_right
Lc6e5:              lda #0
                    cmp fill_y
                    beq Lc716
                    jsr prepare_for_prepare_coords
                    lda brush_1
                    sta brush
                    dec y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc716
                    jsr prepare_for_prepare_coords
                    lda brush_2
                    sta brush
                    dec y
                    jsr hires_isset_internal
                    lda is_set
                    bne Lc716
                    jsr Sc78c
                    jmp Lc71b

Lc716:              lda #0
                    sta continue_left
Lc71b:              jsr prepare_for_prepare_coords
                    lda brush_1
                    sta brush
                    lda colour_tmp
                    sta colour
                    jsr hires_plot_internal
                    sec
                    lda fill_x
                    sbc horizontal_step
                    sta fill_x
                    lda fill_x+1
                    sbc #0
                    sta fill_x+1
                    cmp #2
                    bcc Lc743
                    jmp pop_coordinate_and_continue

Lc743:              jmp Lc689

prepare_for_prepare_coords:
                    lda fill_x
                    sta x
                    lda fill_x+1
                    sta x+1
                    lda fill_y
                    sta y
                    lda #0
                    sta pixel_screen_ram_addr
                    rts

pop_coordinate_and_continue:     
                    ldx postponed_coordinate_stack_ptr
                    beq _stack_empty
                    dex
                    lda postponed_coordinate_stack,x
                    sta fill_y
                    dex
                    lda postponed_coordinate_stack,x
                    sta fill_x+1
                    dex
                    lda postponed_coordinate_stack,x
                    sta fill_x
                    stx postponed_coordinate_stack_ptr
                    jmp evaluate_coordinate
_stack_empty:       rts

Sc779:              lda continue_right
                    beq Lc77f
                    rts

Lc77f:              lda #1
                    sta continue_right
                    jsr prepare_for_prepare_coords
                    inc y
                    jmp Lc79c

Sc78c:              lda continue_left
                    beq Lc792
                    rts

Lc792:              lda #1
                    sta continue_left
                    jsr prepare_for_prepare_coords
                    dec y
Lc79c:              ldx postponed_coordinate_stack_ptr
                    cpx #$bb
                    bcc Lc7a8
                    jsr hires_exit
                    jmp OVERR

Lc7a8:              lda x
                    sta postponed_coordinate_stack,x
                    inx
                    lda x+1
                    sta postponed_coordinate_stack,x
                    inx
                    lda y
                    sta postponed_coordinate_stack,x
                    inx
                    stx postponed_coordinate_stack_ptr
                    rts

scan_right_until_pixel_hit:
tmp_x = $0340       
                    ; tmp_x = fill_x + horizontal_step
                    clc
                    lda fill_x
                    adc horizontal_step
                    sta tmp_x
                    sta x
                    lda fill_x+1
                    adc #0
                    sta tmp_x+1
                    sta x+1
                    lda fill_y
                    sta y
                    ;
                    lda #0
                    sta pixel_screen_ram_addr
                    ; x > 320 then rts
                    lda tmp_x+1
                    beq Lc7ee
                    cmp #1
                    beq Lc7e6
                    rts
Lc7e6:              lda tmp_x
                    cmp #$40
                    bcc Lc7ee
                    rts
Lc7ee:              lda brush_2
                    sta brush
                    jsr hires_isset_internal
                    lda is_set
                    beq Lc7fc
                    rts
Lc7fc:              lda tmp_x
                    sta fill_x
                    lda tmp_x+1
                    sta fill_x+1
                    jmp scan_right_until_pixel_hit
